From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v2 [PATCH 6/7] dccp: Fix incorrect length check for ICMPv4 packets
Date: Fri, 25 Jul 2008 15:30:33 +0100
Message-ID: <20080725143033.GC7422@gerrit.erg.abdn.ac.uk>
References: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk> <20080725142834.GA7422@gerrit.erg.abdn.ac.uk> <20080725142957.GB7422@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40415 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751213AbYGYOak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 10:30:40 -0400
Content-Disposition: inline
In-Reply-To: <20080725142957.GB7422@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike TCP, which only needs 8 octets of original packet data, DCCP requires
minimally 12 or 16 bytes for ICMP-payload sequence number checks.

This patch replaces the insufficient length constant of 8 with a dynamic
value, using the routine introduced previously.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -196,8 +196,8 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 static void dccp_v4_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (struct iphdr *)skb->data;
-	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data +
-							(iph->ihl << 2));
+	const u8 offset = (iph->ihl << 2);
+	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
 	struct dccp_sock *dp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(skb)->type;
@@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (dccp_skb_too_short(skb, offset)) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
