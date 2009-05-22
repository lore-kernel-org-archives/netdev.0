From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 10/19] Add "sapi" information to debug messages
Date: Fri, 22 May 2009 23:04:51 +0200
Message-ID: <ac87c09a8ffdde66c1effd8c4d52893a20d7ab7b.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1243024967.git.kkeil-Zw2aQviYsaUCyFmpLCWB8V3+hHH5wKcB@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas-BhNU7qSqiUAcB3Tz54LwoQ@public.gmane.org>

Using sapi values other than 0 work now.
The "OpenBSC" project does not require special kernel patch anymore.

Signed-off-by: Andreas Eversberg <andreas-BhNU7qSqiUAcB3Tz54LwoQ@public.gmane.org>
Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/mISDN/layer2.c |   24 +++++++++++-------------
 drivers/isdn/mISDN/tei.c    |   11 +++++++++--
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 0628ef6..9efee8e 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -99,7 +99,7 @@ l2m_debug(struct FsmInst *fi, char *fmt, ...)
 	if (!(*debug & DEBUG_L2_FSM))
 		return;
 	va_start(va, fmt);
-	printk(KERN_DEBUG "l2 (tei %d): ", l2->tei);
+	printk(KERN_DEBUG "l2 (sapi %d tei %d): ", l2->sapi, l2->tei);
 	vprintk(fmt, va);
 	printk("\n");
 	va_end(va);
@@ -1859,20 +1859,18 @@ ph_data_indication(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb)
 		psapi >>= 2;
 		ptei >>= 1;
 		if (psapi != l2->sapi) {
-			/* not our bussiness
-			 * printk(KERN_DEBUG "%s: sapi %d/%d sapi mismatch\n",
-			 *  __func__,
-			 *	psapi, l2->sapi);
-			 */
+			/* not our bussiness */
+			if (*debug & DEBUG_L2)
+				printk(KERN_DEBUG "%s: sapi %d/%d mismatch\n",
+					__func__, psapi, l2->sapi);
 			dev_kfree_skb(skb);
 			return 0;
 		}
 		if ((ptei != l2->tei) && (ptei != GROUP_TEI)) {
-			/* not our bussiness
-			 * printk(KERN_DEBUG "%s: tei %d/%d sapi %d mismatch\n",
-			 *  __func__,
-			 *	ptei, l2->tei, psapi);
-			 */
+			/* not our bussiness */
+			if (*debug & DEBUG_L2)
+				printk(KERN_DEBUG "%s: tei %d/%d mismatch\n",
+					__func__, ptei, l2->tei);
 			dev_kfree_skb(skb);
 			return 0;
 		}
@@ -1927,8 +1925,8 @@ l2_send(struct mISDNchannel *ch, struct sk_buff *skb)
 	int 			ret = -EINVAL;
 
 	if (*debug & DEBUG_L2_RECV)
-		printk(KERN_DEBUG "%s: prim(%x) id(%x) tei(%d)\n",
-		    __func__, hh->prim, hh->id, l2->tei);
+		printk(KERN_DEBUG "%s: prim(%x) id(%x) sapi(%d) tei(%d)\n",
+		    __func__, hh->prim, hh->id, l2->sapi, l2->tei);
 	switch (hh->prim) {
 	case PH_DATA_IND:
 		ret = ph_data_indication(l2, hh, skb);
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 9e88135..4ebba5c 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -227,7 +227,7 @@ tei_debug(struct FsmInst *fi, char *fmt, ...)
 	if (!(*debug & DEBUG_L2_TEIFSM))
 		return;
 	va_start(va, fmt);
-	printk(KERN_DEBUG "tei(%d): ", tm->l2->tei);
+	printk(KERN_DEBUG "sapi(%d) tei(%d): ", tm->l2->sapi, tm->l2->tei);
 	vprintk(fmt, va);
 	printk("\n");
 	va_end(va);
@@ -1188,9 +1188,16 @@ check_data(struct manager *mgr, struct sk_buff *skb)
 	if ((skb->data[2] & ~0x10) != SABME)
 		return -ENOTCONN;
 	/* We got a SABME for a fixed TEI */
+	if (*debug & DEBUG_L2_CTRL)
+		printk(KERN_DEBUG "%s: SABME sapi(%d) tei(%d)\n",
+		    __func__, sapi, tei);
 	l2 = create_new_tei(mgr, tei, sapi);
-	if (!l2)
+	if (!l2) {
+		if (*debug & DEBUG_L2_CTRL)
+			printk(KERN_DEBUG "%s: failed to create new tei\n",
+			    __func__);
 		return -ENOMEM;
+	}
 	ret = l2->ch.send(&l2->ch, skb);
 	return ret;
 }
-- 
1.6.0.2
