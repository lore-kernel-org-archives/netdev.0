From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 1/6] sctp: allow others to use sctp_input_cb
Date: Wed, 13 Jul 2016 15:08:55 -0300
Message-ID: <615beca39da498ba640c767a1b046bce67357bc7.1468432819.git.marcelo.leitner@gmail.com>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbcGMSJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:09:42 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We process input path in other files too and having access to it is
nice, so move it to a header where it's shared.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 15 +++++++++++++++
 net/sctp/input.c           | 11 -----------
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8626bdd3249a9283955fe81bc3255be0a18717f9..966c3a40039c12a7c525612594a51312d5de1d2a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -59,6 +59,7 @@
 #include <linux/workqueue.h>	/* We need tq_struct.	 */
 #include <linux/sctp.h>		/* We need sctp* header structs.  */
 #include <net/sctp/auth.h>	/* We need auth specific structs */
+#include <net/ip.h>		/* For inet_skb_parm */
 
 /* A convenience structure for handling sockaddr structures.
  * We should wean ourselves off this.
@@ -1092,6 +1093,20 @@ static inline void sctp_outq_cork(struct sctp_outq *q)
 	q->cork = 1;
 }
 
+/* SCTP skb control block.
+ * sctp_input_cb is currently used on rx and sock rx queue
+ */
+struct sctp_input_cb {
+	union {
+		struct inet_skb_parm	h4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct inet6_skb_parm	h6;
+#endif
+	} header;
+	struct sctp_chunk *chunk;
+};
+#define SCTP_INPUT_CB(__skb)	((struct sctp_input_cb *)&((__skb)->cb[0]))
+
 /* These bind address data fields common between endpoints and associations */
 struct sctp_bind_addr {
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 6f8e676d285ead987b0a1337beec3b29c34e0a8e..7a327ff71f08985f6ebb963d5cdc9540b23d0666 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -90,17 +90,6 @@ static inline int sctp_rcv_checksum(struct net *net, struct sk_buff *skb)
 	return 0;
 }
 
-struct sctp_input_cb {
-	union {
-		struct inet_skb_parm	h4;
-#if IS_ENABLED(CONFIG_IPV6)
-		struct inet6_skb_parm	h6;
-#endif
-	} header;
-	struct sctp_chunk *chunk;
-};
-#define SCTP_INPUT_CB(__skb)	((struct sctp_input_cb *)&((__skb)->cb[0]))
-
 /*
  * This is the routine which IP calls when receiving an SCTP packet.
  */
-- 
2.7.4
