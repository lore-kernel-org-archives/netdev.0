From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 4/9] irda: reserve irda_skb on sock_alloc_send_skb() skbs
Date: Mon, 15 Dec 2008 02:57:33 +0100
Message-ID: <20081215015859.438954905@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:34885 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751606AbYLOCDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:09 -0500
Content-Disposition: inline; filename=0004-irda-reserve-irda_skb-on-sock_alloc_send_skb-skbs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those skbs are on the TX path, and need to have the irda_skb_cb space
allocated as well.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/af_irda.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 61def98..8b0ac27 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -59,6 +59,7 @@
 #include <net/tcp_states.h>
 
 #include <net/irda/af_irda.h>
+#include <net/irda/irda_device.h>
 
 static int irda_create(struct net *net, struct socket *sock, int protocol);
 
@@ -1288,12 +1289,14 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 		len = self->max_data_size;
 	}
 
-	skb = sock_alloc_send_skb(sk, len + self->max_header_size + 16,
+	skb = sock_alloc_send_skb(sk, len + self->max_header_size + 16
+				  + sizeof(struct irda_skb_cb),
 				  msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto out_err;
 
-	skb_reserve(skb, self->max_header_size + 16);
+	skb_reserve(skb, self->max_header_size + 16
+		    + sizeof(struct irda_skb_cb));
 	skb_reset_transport_header(skb);
 	skb_put(skb, len);
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
@@ -1534,12 +1537,13 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 		len = self->max_data_size;
 	}
 
-	skb = sock_alloc_send_skb(sk, len + self->max_header_size,
+	skb = sock_alloc_send_skb(sk, len + self->max_header_size
+				  + sizeof(struct irda_skb_cb),
 				  msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		return -ENOBUFS;
 
-	skb_reserve(skb, self->max_header_size);
+	skb_reserve(skb, self->max_header_size + sizeof(struct irda_skb_cb));
 	skb_reset_transport_header(skb);
 
 	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
@@ -1629,12 +1633,13 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 		len = self->max_data_size;
 	}
 
-	skb = sock_alloc_send_skb(sk, len + self->max_header_size,
+	skb = sock_alloc_send_skb(sk, len + self->max_header_size
+				  + sizeof(struct irda_skb_cb),
 				  msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		return -ENOBUFS;
 
-	skb_reserve(skb, self->max_header_size);
+	skb_reserve(skb, self->max_header_size + sizeof(struct irda_skb_cb));
 	skb_reset_transport_header(skb);
 
 	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
