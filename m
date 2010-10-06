From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 14:19:00 +0200
Message-ID: <201010061419.00257.arnd@arndb.de>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com> <20100919124443.GJ7350@redhat.com> <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, anthony@codemonkey.ws,
	avi@redhat.com, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Ben Greear <greearb@candelatech.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 05 October 2010, Krishna Kumar2 wrote:
> After testing various combinations of #txqs, #vhosts, #netperf
> sessions, I think the drop for 1 stream is due to TX and RX for
> a flow being processed on different cpus.  I did two more tests:
>     1. Pin vhosts to same CPU:
>         - BW drop is much lower for 1 stream case (- 5 to -8% range)
>         - But performance is not so high for more sessions.
>     2. Changed vhost to be single threaded:
>           - No degradation for 1 session, and improvement for upto
>               8, sometimes 16 streams (5-12%).
>           - BW degrades after that, all the way till 128 netperf sessions.
>           - But overall CPU utilization improves.
>             Summary of the entire run (for 1-128 sessions):
>                 txq=4:  BW: (-2.3)      CPU: (-16.5)    RCPU: (-5.3)
>                 txq=16: BW: (-1.9)      CPU: (-24.9)    RCPU: (-9.6)
> 
> I don't see any reasons mentioned above.  However, for higher
> number of netperf sessions, I see a big increase in retransmissions:
> _______________________________________
> #netperf      ORG           NEW
>             BW (#retr)    BW (#retr)
> _______________________________________
> 1          70244 (0)     64102 (0)
> 4          21421 (0)     36570 (416)
> 8          21746 (0)     38604 (148)
> 16         21783 (0)     40632 (464)
> 32         22677 (0)     37163 (1053)
> 64         23648 (4)     36449 (2197)
> 128        23251 (2)     31676 (3185)
> _______________________________________


This smells like it could be related to a problem that Ben Greear found
recently (see "macvlan:  Enable qdisc backoff logic"). When the hardware
is busy, used to just drop the packet. With Ben's patch, we return -EAGAIN
to qemu (or vhost-net) to trigger a resend.

I suppose what we really should do is feed that condition back to the
guest network stack and implement the backoff in there.

	Arnd
