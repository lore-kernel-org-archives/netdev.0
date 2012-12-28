From: pablo@netfilter.org
Subject: [PATCH 05/12] netfilter: nfnetlink_log: fix mac address for 6in4 tunnels
Date: Fri, 28 Dec 2012 12:52:44 +0100
Message-ID: <1356695571-3305-6-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51009 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513Ab2L1LxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:16 -0500
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bob Hockney <bhockney@ix.netcom.com>

For tunnelled ipv6in4 packets, the LOG target (xt_LOG.c) adjusts
the start of the mac field to start at the ethernet header instead
of the ipv4 header for the tunnel. This patch conforms what is
passed by the NFLOG target through nfnetlink to what the LOG target
does. Code borrowed from xt_LOG.c.

Signed-off-by: Bob Hockney <bhockney@ix.netcom.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 9f199f2..4e210e0 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -384,6 +384,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 	struct nfgenmsg *nfmsg;
 	sk_buff_data_t old_tail = inst->skb->tail;
 	struct sock *sk;
+	const unsigned char *hwhdrp;
 
 	nlh = nlmsg_put(inst->skb, 0, 0,
 			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
@@ -485,9 +486,17 @@ __build_packet_message(struct nfulnl_instance *inst,
 	if (indev && skb_mac_header_was_set(skb)) {
 		if (nla_put_be16(inst->skb, NFULA_HWTYPE, htons(skb->dev->type)) ||
 		    nla_put_be16(inst->skb, NFULA_HWLEN,
-				 htons(skb->dev->hard_header_len)) ||
-		    nla_put(inst->skb, NFULA_HWHEADER, skb->dev->hard_header_len,
-			    skb_mac_header(skb)))
+				 htons(skb->dev->hard_header_len)))
+			goto nla_put_failure;
+
+		hwhdrp = skb_mac_header(skb);
+
+		if (skb->dev->type == ARPHRD_SIT)
+			hwhdrp -= ETH_HLEN;
+
+		if (hwhdrp >= skb->head &&
+		    nla_put(inst->skb, NFULA_HWHEADER,
+			    skb->dev->hard_header_len, hwhdrp))
 			goto nla_put_failure;
 	}
 
-- 
1.7.10.4
