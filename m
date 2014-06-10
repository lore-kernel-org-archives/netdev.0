From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/4] tcp: set skb checksum unnecessary and encapsulation in
 TCP GRO
Date: Mon, 9 Jun 2014 23:35:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406092324450.8959@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:54391 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933692AbaFJGfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 02:35:02 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so41240pab.0
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 23:35:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once checksum has been validated in TCP RO we can assume all
preceeding checksums have been properly validated so ip_summed can
changed to unnecessary. Also, if UDP encapsulation was encountered
we set skb->encapsulation to indicated encapsulated checksums are
verified.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 5 ++++-
 net/ipv4/tcp_offload.c    | 4 ++++
 net/ipv4/udp_offload.c    | 2 ++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 774e539..d39221f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1760,7 +1760,10 @@ struct napi_gro_cb {
 	u16	proto;
 
 	/* Used in udp_gro_receive */
-	u16	udp_mark;
+	u8	udp_mark;
+
+	/* Crossed encpsulation boundary */
+	u8	encapsulation;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 4e86c59..f40eb4c 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -290,7 +290,11 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
 	case CHECKSUM_COMPLETE:
 		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
 				  wsum)) {
+			/* Assume all previous checksums have succeeded
+			 * so we can convert to CHECKSUM_UNNECESSARY now.
+			 */
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			skb->encapsulation = NAPI_GRO_CB(skb)->encapsulation;
 			break;
 		}
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 546d2d4..56749a2 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -167,6 +167,8 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
 	/* mark that this skb passed once through the udp gro layer */
 	NAPI_GRO_CB(skb)->udp_mark = 1;
 
+	NAPI_GRO_CB(skb)->encapsulation = 1;
+
 	off  = skb_gro_offset(skb);
 	hlen = off + sizeof(*uh);
 	uh   = skb_gro_header_fast(skb, off);
-- 
2.0.0.526.g5318336
