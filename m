From: kaber@trash.net
Subject: [PATCH 02/28] netfilter: ipt_REJECT: postpone the checksum calculation.
Date: Mon,  2 Aug 2010 21:57:19 +0200
Message-ID: <1280779065-9333-3-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab0HBT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:57:57 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

postpone the checksum calculation, then if the output NIC supports checksum
offloading, we can utlize it. And though the output NIC doesn't support
checksum offloading, but we'll mangle this packet, this can free us from
updating the checksum, as the checksum calculation occurs later.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_REJECT.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index f5f4a88..3d0e064 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -95,10 +95,11 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	}
 
 	tcph->rst	= 1;
-	tcph->check	= tcp_v4_check(sizeof(struct tcphdr),
-				       niph->saddr, niph->daddr,
-				       csum_partial(tcph,
-						    sizeof(struct tcphdr), 0));
+	tcph->check = ~tcp_v4_check(sizeof(struct tcphdr), niph->saddr,
+				    niph->daddr, 0);
+	nskb->ip_summed = CHECKSUM_PARTIAL;
+	nskb->csum_start = (unsigned char *)tcph - nskb->head;
+	nskb->csum_offset = offsetof(struct tcphdr, check);
 
 	addr_type = RTN_UNSPEC;
 	if (hook != NF_INET_FORWARD
@@ -115,7 +116,6 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 		goto free_nskb;
 
 	niph->ttl	= dst_metric(skb_dst(nskb), RTAX_HOPLIMIT);
-	nskb->ip_summed = CHECKSUM_NONE;
 
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(skb_dst(nskb)))
-- 
1.7.1

