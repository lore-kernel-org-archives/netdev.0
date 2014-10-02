From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Thu, 2 Oct 2014 07:42:54 -0700
Message-ID: <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
References: <20141001203345.3321.99675.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:45175 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbaJBOmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:42:55 -0400
Received: by mail-ig0-f169.google.com with SMTP id uq10so1926528igb.4
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 07:42:54 -0700 (PDT)
In-Reply-To: <20141001203345.3321.99675.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 1:35 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> from the qdisc layer, to implement dequeue bulking.
>
> Patch01: "qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE"
>  - Implement basic qdisc dequeue bulking
>  - This time, 100% relying on BQL limits, no magic safe-guard constants
>
> Patch02: "qdisc: dequeue bulking also pickup GSO/TSO packets"
>  - Extend bulking to bulk several GSO/TSO packets
>  - Seperate patch, as it introduce a small regression, see test section.
>
> We do have a patch03, which exports a userspace tunable as a BQL
> tunable, that can byte-cap or disable the bulking/bursting.  But we
> could not agree on it internally, thus not sending it now.  We
> basically strive to avoid adding any new userspace tunable.
>
Unfortunately we probably still need something. If BQL were disabled
(by setting BQL min_limit to infinity) then we'll always dequeue all
the packets in the qdisc. Disabling BQL might be legitimate in
deployment if say a bug is found in a device that prevents prompt
transmit completions for some corner case.

>
> Testing patch01:
> ================
>  Demonstrating the performance improvement of qdisc dequeue bulking, is
> tricky because the effect only "kicks-in" once the qdisc system have a
> backlog. Thus, for a backlog to form, we need either 1) to exceed wirespeed
> of the link or 2) exceed the capability of the device driver.
>
> For practical use-cases, the measureable effect of this will be a
> reduction in CPU usage
>
> 01-TCP_STREAM:
> --------------
> Testing effect for TCP involves disabling TSO and GSO, because TCP
> already benefit from bulking, via TSO and especially for GSO segmented
> packets.  This patch view TSO/GSO as a seperate kind of bulking, and
> avoid further bulking of these packet types.
>
> The measured perf diff benefit (at 10Gbit/s) for a single netperf
> TCP_STREAM were 9.24% less CPU used on calls to _raw_spin_lock()
> (mostly from sch_direct_xmit).
>
> If my E5-2695v2(ES) CPU is tuned according to:
>  http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html
> Then it is possible that a single netperf TCP_STREAM, with GSO and TSO
> disabled, can utilize all bandwidth on a 10Gbit/s link.  This will
> then cause a standing backlog queue at the qdisc layer.
>
> Trying to pressure the system some more CPU util wise, I'm starting
> 24x TCP_STREAMs and monitoring the overall CPU utilization.  This
> confirms bulking saves CPU cycles when it "kicks-in".
>
> Tool mpstat, while stressing the system with netperf 24x TCP_STREAM, shows:
>  * Disabled bulking: sys:2.58%  soft:8.50%  idle:88.78%
>  * Enabled  bulking: sys:2.43%  soft:7.66%  idle:89.79%
>
> 02-UDP_STREAM
> -------------
> The measured perf diff benefit for UDP_STREAM were 6.41% less CPU used
> on calls to _raw_spin_lock().  24x UDP_STREAM with packet size -m 1472 (to
> avoid sending UDP/IP fragments).
>
> 03-trafgen driver test
> ----------------------
> The performance of the 10Gbit/s ixgbe driver is limited due to
> updating the HW ring-queue tail-pointer on every packet.  As
> previously demonstrated with pktgen.
>
> Using trafgen to send RAW frames from userspace (via AF_PACKET), and
> forcing it through qdisc path (with option --qdisc-path and -t0),
> sending with 12 CPUs.
>
> I can demonstrate this driver layer limitation:
>  * 12.8 Mpps with no qdisc bulking
>  * 14.8 Mpps with qdisc bulking (full 10G-wirespeed)
>
>
> Testing patch02:
> ================
> Testing Bulking several GSO/TSO packets:
>
> Measuring HoL (Head-of-Line) blocking for TSO and GSO, with
> netperf-wrapper. Bulking several TSO show no performance regressions
> (requeues were in the area 32 requeues/sec for 10G while transmitting
> approx 813Kpps).
>
> Bulking several GSOs does show small regression or very small
> improvement (requeues were in the area 8000 requeues/sec, for 10G
> while transmitting approx 813Kpps).
>
>  Using ixgbe 10Gbit/s with GSO bulking, we can measure some additional
> latency. Base-case, which is "normal" GSO bulking, sees varying
> high-prio queue delay between 0.38ms to 0.47ms.  Bulking several GSOs
> together, result in a stable high-prio queue delay of 0.50ms.
>
> Corrosponding to:
>  (10000*10^6)*((0.50-0.47)/10^3)/8 = 37500 bytes
>  (10000*10^6)*((0.50-0.38)/10^3)/8 = 150000 bytes
>  37500/1500  = 25 pkts
>  150000/1500 = 100 pkts
>
>  Using igb at 100Mbit/s with GSO bulking, shows an improvement.
> Base-case sees varying high-prio queue delay between 2.23ms to 2.35ms
> diff of 0.12ms corrosponding to 1500 bytes at 100Mbit/s. Bulking
> several GSOs together, result in a stable high-prio queue delay of
> 2.23ms.
>
> ---
>
> Jesper Dangaard Brouer (2):
>       qdisc: dequeue bulking also pickup GSO/TSO packets
>       qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE
>
>
>  include/net/sch_generic.h |   16 ++++++++++++++++
>  net/sched/sch_generic.c   |   40 ++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 54 insertions(+), 2 deletions(-)
>
> --
