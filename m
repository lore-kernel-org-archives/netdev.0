From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Fri, 20 Dec 2013 08:01:49 -0800
Message-ID: <20131220080149.09e93a9f@nehalam.linuxnetplumber.net>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	<1387096221-20112-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Terry Lam <vtlam@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:60363 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab3LTQBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:01:54 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so2662923pdj.5
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:01:53 -0800 (PST)
In-Reply-To: <1387096221-20112-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Dec 2013 00:30:21 -0800
Terry Lam <vtlam@google.com> wrote:

> This patch implements the first size-based qdisc that attempts to
> differentiate between small flows and heavy-hitters.  The goal is to
> catch the heavy-hitters and move them to a separate queue with less
> priority so that bulk traffic does not affect the latency of critical
> traffic.  Currently "less priority" means less weight (2:1 in
> particular) in a Weighted Deficit Round Robin (WDRR) scheduler.
> 
> In essence, this patch addresses the "delay-bloat" problem due to
> bloated buffers. In some systems, large queues may be necessary for
> obtaining CPU efficiency, or due to the presence of unresponsive
> traffic like UDP, or just a large number of connections with each
> having a small amount of outstanding traffic. In these circumstances,
> HHF aims to reduce the HoL blocking for latency sensitive traffic,
> while not impacting the queues built up by bulk traffic.  HHF can also
> be used in conjunction with other AQM mechanisms such as CoDel.
> 
> To capture heavy-hitters, we implement the "multi-stage filter" design
> in the following paper:
> C. Estan and G. Varghese, "New Directions in Traffic Measurement and
> Accounting", in ACM SIGCOMM, 2002.
> 
> Some configurable qdisc settings through 'tc':
> - hhf_reset_timeout: period to reset counter values in the multi-stage
>                      filter (default 40ms)
> - hhf_admit_bytes:   threshold to classify heavy-hitters
>                      (default 128KB)
> - hhf_evict_timeout: threshold to evict idle heavy-hitters
>                      (default 1s)
> - hhf_non_hh_weight: Weighted Deficit Round Robin (WDRR) weight for
>                      non-heavy-hitters (default 2)
> - hh_flows_limit:    max number of heavy-hitter flow entries
>                      (default 2048)
> 
> Note that the ratio between hhf_admit_bytes and hhf_reset_timeout
> reflects the bandwidth of heavy-hitters that we attempt to capture
> (25Mbps with the above default settings).
> 
> The false negative rate (heavy-hitter flows getting away unclassified)
> is zero by the design of the multi-stage filter algorithm.
> With 100 heavy-hitter flows, using four hashes and 4000 counters yields
> a false positive rate (non-heavy-hitters mistakenly classified as
> heavy-hitters) of less than 1e-4.
> 
> Signed-off-by: Terry Lam <vtlam@google.com>
> ---
> Changelog since v2:
> - With u32 timestamp (to save memory), standard time_before() does not
> work, so we need hhf_time_before(). Also re-test with netperf that
> HHF can improve mice latency (eg 10X with 200 bulk flows on 10G link).
> 
> Changelog since v1:
> - Use time_before and no explicit inline
> 
>  include/uapi/linux/pkt_sched.h |  25 ++
>  net/sched/Kconfig              |   9 +
>  net/sched/Makefile             |   1 +
>  net/sched/sch_hhf.c            | 746 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 781 insertions(+)
>  create mode 100644 net/sched/sch_hhf.c

Please post the iproute2 changes as well...
