From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/5] pktgen: avoid atomic_inc per packet in
 xmit loop
Date: Wed, 14 May 2014 07:35:31 -0700
Message-ID: <1400078131.7973.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140514141545.20309.28343.stgit@dragon>
	 <20140514141753.20309.19785.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58023 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaENOfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 10:35:33 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so1775301pab.10
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 07:35:32 -0700 (PDT)
In-Reply-To: <20140514141753.20309.19785.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> Avoid the expensive atomic refcnt increase in the pktgen xmit loop, by
> simply setting the refcnt only when a new SKB gets allocated. Setting
> it according to how many times we are spinning the same SKB (and
> handling the case of skb_clone=0).
> 
> Performance data with CLONE_SKB==100000 and TX ring buffer size=1024:
>  (single CPU performance, ixgbe 10Gbit/s, E5-2630)
>  * Before: 5,362,722 pps --> 186.47ns per pkt (1/5362722*10^9)
>  * Now:    5,608,781 pps --> 178.29ns per pkt (1/5608781*10^9)
>  * Diff:    +246,059 pps -->  -8.18ns
> 
> The performance increase converted to nanoseconds (8.18ns), correspond
> well to the measured overhead of LOCK prefixed assembler instructions
> on my E5-2630 CPU which is measured to be 8.23ns.
> 
> Note, with TX ring size 768 I see some "tx_restart_queue" events.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

OK, but then you need to properly undo the refcnt at the end of pktgen
loop, otherwise you leak one skb ?

Say you run pktgen for 995 sends, and clone_count is 10.

If done properly, you probably can avoid the kfree_skb(pkt_dev->skb) in
pktgen_xmit(), and set initial skb->users to max(1, pkt_dev->clone_skb);
