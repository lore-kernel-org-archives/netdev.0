From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 05/11] isdn/gigaset: improve CAPI message debugging
Date: Tue,  6 Jul 2010 02:18:59 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-05.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide better control of debugging output for DATA_B3 CAPI messages
which tend to occur very frequently.

Impact: logging
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index c38750c..ff074e9 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -270,9 +270,13 @@ static inline void dump_rawmsg(enum debuglevel level, const char *tag,
 	kfree(dbgline);
 	if (CAPIMSG_COMMAND(data) == CAPI_DATA_B3 &&
 	    (CAPIMSG_SUBCOMMAND(data) == CAPI_REQ ||
-	     CAPIMSG_SUBCOMMAND(data) == CAPI_IND) &&
-	    CAPIMSG_DATALEN(data) > 0) {
+	     CAPIMSG_SUBCOMMAND(data) == CAPI_IND)) {
 		l = CAPIMSG_DATALEN(data);
+		gig_dbg(level, "   DataLength=%d", l);
+		if (l <= 0 || !(gigaset_debuglevel & DEBUG_LLDATA))
+			return;
+		if (l > 64)
+			l = 64; /* arbitrary limit */
 		dbgline = kmalloc(3*l, GFP_ATOMIC);
 		if (!dbgline)
 			return;
@@ -384,7 +388,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 
 	/* don't send further B3 messages if disconnected */
 	if (bcs->apconnstate < APCONN_ACTIVE) {
-		gig_dbg(DEBUG_LLDATA, "disconnected, discarding ack");
+		gig_dbg(DEBUG_MCMD, "disconnected, discarding ack");
 		return;
 	}
 
@@ -428,7 +432,7 @@ void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
 
 	/* don't send further B3 messages if disconnected */
 	if (bcs->apconnstate < APCONN_ACTIVE) {
-		gig_dbg(DEBUG_LLDATA, "disconnected, discarding data");
+		gig_dbg(DEBUG_MCMD, "disconnected, discarding data");
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -454,7 +458,7 @@ void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
 	/* Data64 parameter not present */
 
 	/* emit message */
-	dump_rawmsg(DEBUG_LLDATA, "DATA_B3_IND", skb->data);
+	dump_rawmsg(DEBUG_MCMD, __func__, skb->data);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
 EXPORT_SYMBOL_GPL(gigaset_skb_rcvd);
@@ -978,6 +982,9 @@ static void gigaset_register_appl(struct capi_ctr *ctr, u16 appl,
 	struct cardstate *cs = ctr->driverdata;
 	struct gigaset_capi_appl *ap;
 
+	gig_dbg(DEBUG_CMD, "%s [%u] l3cnt=%u blkcnt=%u blklen=%u",
+		__func__, appl, rp->level3cnt, rp->datablkcnt, rp->datablklen);
+
 	list_for_each_entry(ap, &iif->appls, ctrlist)
 		if (ap->id == appl) {
 			dev_notice(cs->dev,
@@ -1062,6 +1069,8 @@ static void gigaset_release_appl(struct capi_ctr *ctr, u16 appl)
 	struct gigaset_capi_appl *ap, *tmp;
 	unsigned ch;
 
+	gig_dbg(DEBUG_CMD, "%s [%u]", __func__, appl);
+
 	list_for_each_entry_safe(ap, tmp, &iif->appls, ctrlist)
 		if (ap->id == appl) {
 			/* remove from any channels */
@@ -1951,11 +1960,7 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 	u16 handle = CAPIMSG_HANDLE_REQ(skb->data);
 
 	/* frequent message, avoid _cmsg overhead */
-	dump_rawmsg(DEBUG_LLDATA, "DATA_B3_REQ", skb->data);
-
-	gig_dbg(DEBUG_LLDATA,
-		"Receiving data from LL (ch: %d, flg: %x, sz: %d|%d)",
-		channel, flags, msglen, datalen);
+	dump_rawmsg(DEBUG_MCMD, __func__, skb->data);
 
 	/* check parameters */
 	if (channel == 0 || channel > cs->channels || ncci != 1) {
@@ -2064,7 +2069,7 @@ static void do_data_b3_resp(struct gigaset_capi_ctr *iif,
 			    struct gigaset_capi_appl *ap,
 			    struct sk_buff *skb)
 {
-	dump_rawmsg(DEBUG_LLDATA, __func__, skb->data);
+	dump_rawmsg(DEBUG_MCMD, __func__, skb->data);
 	dev_kfree_skb_any(skb);
 }
 
-- 
1.6.5.3.298.g39add
