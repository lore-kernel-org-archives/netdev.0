From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 6 Jan 2012 09:09:29 -0800
Message-ID: <20120106090929.009a78d6@nehalam.linuxnetplumber.net>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41255 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab2AFRJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 12:09:32 -0500
In-Reply-To: <1325867504.2911.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Jan 2012 17:31:44 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Adds an optional Random Early Detection on each SFQ flow queue.
> 
> Traditional SFQ limits count of packets, while RED permits to also
> control number of bytes per flow, and adds ECN capability as well.
> 
> 1) We dont handle the idle time management in this RED implementation,
> since each 'new flow' begins with a null qavg. We really want to address
> backlogged flows.
> 
> 2) if headdrop is selected, we try to ecn mark first packet instead of
> currently enqueued packet. This gives faster feedback for tcp flows
> compared to traditional RED [ marking the last packet in queue ]
> 
> Example of use :
> 
> tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 4sec sfq \
> 	limit 3000 headdrop flows 512 divisor 16384 \
> 	redflowlimit 100000 min 8000 max 60000 probability 0.20 ecn
> 
> qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
> flows 512/16384 divisor 16384 
>  ewma 6 min 8000b max 60000b probability 0.2 ecn 
>  prob_mark 0 prob_mark_head 4876 prob_drop 6131
>  forced_mark 0 forced_mark_head 0 forced_drop 0
>  Sent 1175211782 bytes 777537 pkt (dropped 6131, overlimits 11007
> requeues 0) 
>  rate 99483Kbit 8219pps backlog 689392b 456p requeues 0 
> 
> In this test, with 64 netperf TCP_STREAM sessions, 50% using ECN enabled
> flows, we can see number of packets CE marked is smaller than number of
> drops (for non ECN flows)
> 
> If same test is run, without RED, we can check backlog is much bigger.
> 
> qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
> flows 512/16384 divisor 16384 
>  Sent 1148683617 bytes 795006 pkt (dropped 0, overlimits 0 requeues 0) 
>  rate 98429Kbit 8521pps backlog 1221290b 841p requeues 0 
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Dave Taht <dave.taht@gmail.com>


Since SFQ is classful, I don't see what this buys over just putting
a red qdisc under each SFQ class?
