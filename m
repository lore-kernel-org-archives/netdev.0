From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] net: irda: irttp: sync error paths of data- and udata-requests
Date: Tue, 16 Nov 2010 20:40:02 +0100
Message-ID: <1289936402-25277-1-git-send-email-w.sang@pengutronix.de>
References: <20101116.095101.115945762.davem@davemloft.net>
Cc: Wolfram Sang <w.sang@pengutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37578 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145Ab0KPTkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:40:07 -0500
In-Reply-To: <20101116.095101.115945762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irttp_data_request() returns meaningful errorcodes, while irttp_udata_request()
just returns -1 in similar situations. Sync the two and the loglevels of the
accompanying output.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: David Miller <davem@davemloft.net>
---

Thank you David for picking up the zero-byte-packet-patch. Now as it was
applied, this one might be interesting, too (on top of it)? Nothing seriously
needed, but looks more proper IMHO. LXR says that are callers of these
functions check with < 0 anyhow.

 net/irda/irttp.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 6cfaeaf..f6054f9 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -550,7 +550,7 @@ EXPORT_SYMBOL(irttp_close_tsap);
  */
 int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 {
-	int ret = -1;
+	int ret;
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
@@ -566,13 +566,14 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 
 	/* Check that nothing bad happens */
 	if (!self->connected) {
-		IRDA_DEBUG(1, "%s(), Not connected\n", __func__);
+		IRDA_WARNING("%s(), Not connected\n", __func__);
+		ret = -ENOTCONN;
 		goto err;
 	}
 
 	if (skb->len > self->max_seg_size) {
-		IRDA_DEBUG(1, "%s(), UData is too large for IrLAP!\n",
-			   __func__);
+		IRDA_ERROR("%s(), UData is too large for IrLAP!\n", __func__);
+		ret = -EMSGSIZE;
 		goto err;
 	}
 
-- 
1.7.2.3

