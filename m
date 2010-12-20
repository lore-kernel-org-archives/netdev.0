From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH v4 net-next-2.6] netfilter: x_tables: dont block BH
 while reading counters
Date: Mon, 20 Dec 2010 14:42:21 +0100
Message-ID: <1292852541.31289.75.camel@firesoul.comx.local>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
	 <1292515625.2883.336.camel@edumazet-laptop>
	 <1292518436.2883.393.camel@edumazet-laptop>
	 <20101216093149.71f082c7@nehalam>
	 <1292521986.2883.472.camel@edumazet-laptop>
	 <1292646579.7894.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53121 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab0LTNmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 08:42:23 -0500
In-Reply-To: <1292646579.7894.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have tested the patch on 2.6.35.  Which implies I also needed to
cherry-pick 870f67dcf7ef, which implements the vzalloc() call. (Latest
net-next has a problem with my HP CCISS driver/controller or the PCI
layout, and will not boot)

According to the function_graph trace, the execution time of
get_counters() has increased (approx) from 109 ms to 120 ms, which is
the expected result.

The results are not all positive, but I think its related to the
debugging options I have enabled.

Because I now see packet drops if my 1Gbit/s pktgen script are sending
packet with a packet size below 512 bytes, which is "only" approx 230
kpps (this is 1Gbit/s on my 10G labsetup where I have seen 5 Mpps).

There is no packet overruns/drops, iif I run "iptables -vnL >
/dev/null" without tracing enabled and only 1Gbit/s pktgen at 512
bytes packets.  If I enable tracing while calling iptables I see
packet drops/overruns.  So I guess this is caused by the tracing
overhead.

I'll try to rerun my test without all the lock debugging options
enabled.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


On Sat, 2010-12-18 at 05:29 +0100, Eric Dumazet wrote:
> Using "iptables -L" with a lot of rules have a too big BH latency.
> Jesper mentioned ~6 ms and worried of frame drops.
> 
> Switch to a per_cpu seqlock scheme, so that taking a snapshot of
> counters doesnt need to block BH (for this cpu, but also other cpus).
> 
> This adds two increments on seqlock sequence per ipt_do_table() call,
> its a reasonable cost for allowing "iptables -L" not block BH
> processing.
> 
> Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> ---


