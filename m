From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 19/19] Fix DTMF detection enable/disable
Date: Fri, 22 May 2009 23:04:58 +0200
Message-ID: <4df523cf314b1890e64eceb29def2bce41cbdffc.1243024967.git.kkeil@pingi.linux-pingi.de>
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

DTMF detection was enabled when it was not supposed to.

Signed-off-by: Andreas Eversberg <andreas-BhNU7qSqiUAcB3Tz54LwoQ@public.gmane.org>
Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/mISDN/dsp.h      |    1 +
 drivers/isdn/mISDN/dsp_core.c |    2 ++
 drivers/isdn/mISDN/dsp_dtmf.c |    3 +++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp.h b/drivers/isdn/mISDN/dsp.h
index 564ea3e..18af868 100644
--- a/drivers/isdn/mISDN/dsp.h
+++ b/drivers/isdn/mISDN/dsp.h
@@ -116,6 +116,7 @@ struct dsp_conf {
 #define ECHOCAN_BUFF_MASK 0x3ff /* -1 */
 
 struct dsp_dtmf {
+	int		enable; /* dtmf is enabled */
 	int		treshold; /* above this is dtmf (square of) */
 	int		software; /* dtmf uses software decoding */
 	int		hardware; /* dtmf uses hardware decoding */
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index c357506..c12cd2f 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -306,6 +306,7 @@ dsp_control_req(struct dsp *dsp, struct mISDNhead *hh, struct sk_buff *skb)
 					"to %d\n", *((int *)data));
 			dsp->dtmf.treshold = (*(int *)data) * 10000;
 		}
+		dsp->dtmf.enable = 1;
 		/* init goertzel */
 		dsp_dtmf_goertzel_init(dsp);
 
@@ -316,6 +317,7 @@ dsp_control_req(struct dsp *dsp, struct mISDNhead *hh, struct sk_buff *skb)
 	case DTMF_TONE_STOP: /* turn off DTMF */
 		if (dsp_debug & DEBUG_DSP_CORE)
 			printk(KERN_DEBUG "%s: stop dtmf\n", __func__);
+		dsp->dtmf.enable = 0;
 		dsp->dtmf.hardware = 0;
 		dsp->dtmf.software = 0;
 		break;
diff --git a/drivers/isdn/mISDN/dsp_dtmf.c b/drivers/isdn/mISDN/dsp_dtmf.c
index efc371c..9ae2d33 100644
--- a/drivers/isdn/mISDN/dsp_dtmf.c
+++ b/drivers/isdn/mISDN/dsp_dtmf.c
@@ -51,6 +51,9 @@ void dsp_dtmf_hardware(struct dsp *dsp)
 {
 	int hardware = 1;
 
+	if (!dsp->dtmf.enable)
+		return;
+
 	if (!dsp->features.hfc_dtmf)
 		hardware = 0;
 
-- 
1.6.0.2
