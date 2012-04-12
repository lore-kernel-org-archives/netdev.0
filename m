From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 1/4] caif: set traffic class for caif packets
Date: Thu, 12 Apr 2012 20:27:24 +0200
Message-ID: <1334255247-3372-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: sjurbren@gmail.com,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:55061 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933931Ab2DLS1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:27:38 -0400
Received: by lbbgm6 with SMTP id gm6so1843208lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:27:36 -0700 (PDT)
In-Reply-To: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

Set traffic class for CAIF packets, based on socket
priority, CAIF protocol type, or type of message.

Traffic class mapping for different packet types:
 - control:       TC_PRIO_CONTROL;
 - flow control:  TC_PRIO_CONTROL;
 - at:            TC_PRIO_CONTROL;
 - rfm:           TC_PRIO_INTERACTIVE_BULK;
 - other sockets: equals to socket's TC;
 - network data:  no change.

Signed-off-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
---
 include/net/caif/cfpkt.h |    9 ++++++++-
 net/caif/caif_socket.c   |   16 ++++++++++++++--
 net/caif/cfctrl.c        |    4 ++++
 net/caif/cfpkt_skbuff.c  |    7 +++++++
 net/caif/cfsrvl.c        |    3 +++
 5 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
index 6bd200a..83a89ba 100644
--- a/include/net/caif/cfpkt.h
+++ b/include/net/caif/cfpkt.h
@@ -188,11 +188,18 @@ struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt);
  */
 void *cfpkt_tonative(struct cfpkt *pkt);
 
-
 /*
  * Returns packet information for a packet.
  * pkt Packet to get info from;
  * @return Packet information
  */
 struct caif_payload_info *cfpkt_info(struct cfpkt *pkt);
+
+/** cfpkt_set_prio - set priority for a CAIF packet.
+ *
+ * @pkt: The CAIF packet to be adjusted.
+ * @prio: one of TC_PRIO_ constants.
+ */
+void cfpkt_set_prio(struct cfpkt *pkt, int prio);
+
 #endif				/* CFPKT_H_ */
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 5016fa5..ce47ee9 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -19,7 +19,7 @@
 #include <linux/uaccess.h>
 #include <linux/debugfs.h>
 #include <linux/caif/caif_socket.h>
-#include <linux/atomic.h>
+#include <linux/pkt_sched.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <net/caif/caif_layer.h>
@@ -505,6 +505,7 @@ static int transmit_skb(struct sk_buff *skb, struct caifsock *cf_sk,
 
 	pkt = cfpkt_fromnative(CAIF_DIR_OUT, skb);
 	memset(skb->cb, 0, sizeof(struct caif_payload_info));
+	cfpkt_set_prio(pkt, cf_sk->sk.sk_priority);
 
 	if (cf_sk->layer.dn == NULL) {
 		kfree_skb(skb);
@@ -1062,6 +1063,18 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	/* Store the protocol */
 	sk->sk_protocol = (unsigned char) protocol;
 
+	/* Initialize default priority for well-known cases */
+	switch (protocol) {
+	case CAIFPROTO_AT:
+		sk->sk_priority = TC_PRIO_CONTROL;
+		break;
+	case CAIFPROTO_RFM:
+		sk->sk_priority = TC_PRIO_INTERACTIVE_BULK;
+		break;
+	default:
+		sk->sk_priority = TC_PRIO_BESTEFFORT;
+	}
+
 	/*
 	 * Lock in order to try to stop someone from opening the socket
 	 * too early.
@@ -1081,7 +1094,6 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	set_rx_flow_on(cf_sk);
 
 	/* Set default options on configuration */
-	cf_sk->sk.sk_priority = CAIF_PRIO_NORMAL;
 	cf_sk->conn_req.link_selector = CAIF_LINK_LOW_LATENCY;
 	cf_sk->conn_req.protocol = protocol;
 	release_sock(&cf_sk->sk);
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 5cf5222..047cd0e 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -9,6 +9,7 @@
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
+#include <linux/pkt_sched.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfctrl.h>
@@ -189,6 +190,7 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 	cfctrl->serv.dev_info.id = physlinkid;
 	cfpkt_addbdy(pkt, CFCTRL_CMD_ENUM);
 	cfpkt_addbdy(pkt, physlinkid);
+	cfpkt_set_prio(pkt, TC_PRIO_CONTROL);
 	dn->transmit(dn, pkt);
 }
 
@@ -281,6 +283,7 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	 *	might arrive with the newly allocated channel ID.
 	 */
 	cfpkt_info(pkt)->dev_info->id = param->phyid;
+	cfpkt_set_prio(pkt, TC_PRIO_CONTROL);
 	ret =
 	    dn->transmit(dn, pkt);
 	if (ret < 0) {
@@ -314,6 +317,7 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
 	cfpkt_addbdy(pkt, channelid);
 	init_info(cfpkt_info(pkt), cfctrl);
+	cfpkt_set_prio(pkt, TC_PRIO_CONTROL);
 	ret =
 	    dn->transmit(dn, pkt);
 #ifndef CAIF_NO_LOOP
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index e335ba8..863dedd 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -381,6 +381,7 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
 	memcpy(skb2->data, split, len2nd);
 	skb2->tail += len2nd;
 	skb2->len += len2nd;
+	skb2->priority = skb->priority;
 	return skb_to_pkt(skb2);
 }
 
@@ -394,3 +395,9 @@ struct caif_payload_info *cfpkt_info(struct cfpkt *pkt)
 	return (struct caif_payload_info *)&pkt_to_skb(pkt)->cb;
 }
 EXPORT_SYMBOL(cfpkt_info);
+
+void cfpkt_set_prio(struct cfpkt *pkt, int prio)
+{
+	pkt_to_skb(pkt)->priority = prio;
+}
+EXPORT_SYMBOL(cfpkt_set_prio);
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 4aa33d4..dd485f6 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -11,6 +11,7 @@
 #include <linux/errno.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/pkt_sched.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
@@ -120,6 +121,7 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			info->channel_id = service->layer.id;
 			info->hdr_len = 1;
 			info->dev_info = &service->dev_info;
+			cfpkt_set_prio(pkt, TC_PRIO_CONTROL);
 			return layr->dn->transmit(layr->dn, pkt);
 		}
 	case CAIF_MODEMCMD_FLOW_OFF_REQ:
@@ -140,6 +142,7 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			info->channel_id = service->layer.id;
 			info->hdr_len = 1;
 			info->dev_info = &service->dev_info;
+			cfpkt_set_prio(pkt, TC_PRIO_CONTROL);
 			return layr->dn->transmit(layr->dn, pkt);
 		}
 	default:
-- 
1.7.5.4
