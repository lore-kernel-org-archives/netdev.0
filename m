From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/5] isdn/gigaset: correct CAPI DATA_B3 Delivery Confirmation
Date: Tue, 22 Jun 2010 01:54:50 +0200 (CEST)
Message-ID: <20100622-patch-gigaset-03.tilman@imap.cc>
References: <20100622-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100622-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Gigaset CAPI driver handled all DATA_B3_REQ messages as if the
Delivery Confirmation flag bit was set, delaying the emission of the
DATA_B3_CONF reply until the data was actually transmitted. Some
CAPI applications (notably Asterisk) aren't happy with that
behaviour. Change it to actually evaluate the Delivery Confirmation
flag as described the CAPI specification.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |   83 ++++++++++++++++++++++++++----------------
 1 files changed, 51 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index cb55ead..e685123 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -320,6 +320,39 @@ static const char *format_ie(const char *ie)
 	return result;
 }
 
+/*
+ * emit DATA_B3_CONF message
+ */
+static void send_data_b3_conf(struct cardstate *cs, struct capi_ctr *ctr,
+			      u16 appl, u16 msgid, int channel,
+			      u16 handle, u16 info)
+{
+	struct sk_buff *cskb;
+	u8 *msg;
+
+	cskb = alloc_skb(CAPI_DATA_B3_CONF_LEN, GFP_ATOMIC);
+	if (!cskb) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	/* frequent message, avoid _cmsg overhead */
+	msg = __skb_put(cskb, CAPI_DATA_B3_CONF_LEN);
+	CAPIMSG_SETLEN(msg, CAPI_DATA_B3_CONF_LEN);
+	CAPIMSG_SETAPPID(msg, appl);
+	CAPIMSG_SETCOMMAND(msg, CAPI_DATA_B3);
+	CAPIMSG_SETSUBCOMMAND(msg,  CAPI_CONF);
+	CAPIMSG_SETMSGID(msg, msgid);
+	CAPIMSG_SETCONTROLLER(msg, ctr->cnr);
+	CAPIMSG_SETPLCI_PART(msg, channel);
+	CAPIMSG_SETNCCI_PART(msg, 1);
+	CAPIMSG_SETHANDLE_CONF(msg, handle);
+	CAPIMSG_SETINFO_CONF(msg, info);
+
+	/* emit message */
+	dump_rawmsg(DEBUG_MCMD, __func__, msg);
+	capi_ctr_handle_message(ctr, appl, cskb);
+}
+
 
 /*
  * driver interface functions
@@ -340,7 +373,6 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	struct gigaset_capi_ctr *iif = cs->iif;
 	struct gigaset_capi_appl *ap = bcs->ap;
 	unsigned char *req = skb_mac_header(dskb);
-	struct sk_buff *cskb;
 	u16 flags;
 
 	/* update statistics */
@@ -357,34 +389,17 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 		return;
 	}
 
-	/* ToDo: honor unset "delivery confirmation" bit */
+	/*
+	 * send DATA_B3_CONF if "delivery confirmation" bit was set in request;
+	 * otherwise it has already been sent by do_data_b3_req()
+	 */
 	flags = CAPIMSG_FLAGS(req);
-
-	/* build DATA_B3_CONF message */
-	cskb = alloc_skb(CAPI_DATA_B3_CONF_LEN, GFP_ATOMIC);
-	if (!cskb) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
-		return;
-	}
-	/* frequent message, avoid _cmsg overhead */
-	CAPIMSG_SETLEN(cskb->data, CAPI_DATA_B3_CONF_LEN);
-	CAPIMSG_SETAPPID(cskb->data, ap->id);
-	CAPIMSG_SETCOMMAND(cskb->data, CAPI_DATA_B3);
-	CAPIMSG_SETSUBCOMMAND(cskb->data,  CAPI_CONF);
-	CAPIMSG_SETMSGID(cskb->data, CAPIMSG_MSGID(req));
-	CAPIMSG_SETCONTROLLER(cskb->data, iif->ctr.cnr);
-	CAPIMSG_SETPLCI_PART(cskb->data, bcs->channel + 1);
-	CAPIMSG_SETNCCI_PART(cskb->data, 1);
-	CAPIMSG_SETHANDLE_CONF(cskb->data, CAPIMSG_HANDLE_REQ(req));
-	if (flags & ~CAPI_FLAGS_DELIVERY_CONFIRMATION)
-		CAPIMSG_SETINFO_CONF(cskb->data,
-				     CapiFlagsNotSupportedByProtocol);
-	else
-		CAPIMSG_SETINFO_CONF(cskb->data, CAPI_NOERROR);
-
-	/* emit message */
-	dump_rawmsg(DEBUG_LLDATA, "DATA_B3_CONF", cskb->data);
-	capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
+	if (flags & CAPI_FLAGS_DELIVERY_CONFIRMATION)
+		send_data_b3_conf(cs, &iif->ctr, ap->id, CAPIMSG_MSGID(req),
+				  bcs->channel + 1, CAPIMSG_HANDLE_REQ(req),
+				  (flags & ~CAPI_FLAGS_DELIVERY_CONFIRMATION) ?
+					CapiFlagsNotSupportedByProtocol :
+					CAPI_NOERROR);
 }
 EXPORT_SYMBOL_GPL(gigaset_skb_sent);
 
@@ -1795,6 +1810,8 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 	u16 msglen = CAPIMSG_LEN(skb->data);
 	u16 datalen = CAPIMSG_DATALEN(skb->data);
 	u16 flags = CAPIMSG_FLAGS(skb->data);
+	u16 msgid = CAPIMSG_MSGID(skb->data);
+	u16 handle = CAPIMSG_HANDLE_REQ(skb->data);
 
 	/* frequent message, avoid _cmsg overhead */
 	dump_rawmsg(DEBUG_LLDATA, "DATA_B3_REQ", skb->data);
@@ -1845,12 +1862,14 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 		return;
 	}
 
-	/* DATA_B3_CONF reply will be sent by gigaset_skb_sent() */
-
 	/*
-	 * ToDo: honor unset "delivery confirmation" bit
-	 * (send DATA_B3_CONF immediately?)
+	 * DATA_B3_CONF will be sent by gigaset_skb_sent() only if "delivery
+	 * confirmation" bit is set; otherwise we have to send it now
 	 */
+	if (!(flags & CAPI_FLAGS_DELIVERY_CONFIRMATION))
+		send_data_b3_conf(cs, &iif->ctr, ap->id, msgid, channel, handle,
+				  flags ? CapiFlagsNotSupportedByProtocol
+					: CAPI_NOERROR);
 }
 
 /*
-- 
1.6.5.3.298.g39add
