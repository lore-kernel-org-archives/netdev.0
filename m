From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] BUG: NULL pointer dereference in(?)
 ip6_flush_pending_frames
Date: Mon, 10 Sep 2007 08:38:47 +0900 (JST)
Message-ID: <20070910.083847.40751994.yoshfuji@linux-ipv6.org>
References: <20070909222400.GC7591@obelix.birkenwald.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	miyazawa@linux-ipv6.org
To: berni@birkenwald.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42304 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbXIIXhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 19:37:22 -0400
In-Reply-To: <20070909222400.GC7591@obelix.birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070909222400.GC7591@obelix.birkenwald.de> (at Mon, 10 Sep 2007 00:24:00 +0200), Bernhard Schmidt <berni@birkenwald.de> says:

> I'm running a public Teredo relay (IPv4-to-IPv6 migration protocol)
> using Miredo. Every once in a while (a few minutes to days after
> daemon restart) it becomes unusable and I see the following kernel
> message:
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 0000008c
:
> EIP is at ip6_flush_pending_frames+0x97/0x121

I think I've found a bug.

Some of skbs in sk->write_queue do not have skb->dst because
we do not fill skb->dst when we allocate new skb in append_data().

Miyazawa-san, am I right?

BTW, I think we may not need to (or we should not) increment some stats
when using corking; if 100 sendmsg() (with MSG_MORE) result in 2 packets,
how many should we increment?

If 100, we should set skb->dst for every queued skbs.

If 1 (or 2 (*)), we increment the stats for the first queued skb and
we should just skip incrementing OutDiscards for the rest of queued skbs,
adn we should also impelement this semantics in other places;
e.g., we should increment other stats just once, not 100 times.

*: depends on the place we are discarding the datagram.

I guess should just increment by 1 (or 2).

Anyway, please try this.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4704b5f..e489499 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1423,8 +1423,9 @@ void ip6_flush_pending_frames(struct sock *sk)
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
-		IP6_INC_STATS(ip6_dst_idev(skb->dst),
-			      IPSTATS_MIB_OUTDISCARDS);
+		if (skb->dst)
+			IP6_INC_STATS(ip6_dst_idev(skb->dst),
+				      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 	}
 


--yoshfuji
