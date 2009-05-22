From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 01/19] Add watchdog functionality to hfcmulti driver
Date: Fri, 22 May 2009 23:04:44 +0200
Message-ID: <c9cf6a56ab02e09941e5916e1d71f0325fdbbb58.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758195AbZEVVFT@vger.kernel.org>
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas@eversberg.eu>

This patch was made by Titus Moldovan and provides IOCTL functions for enabling
and disabling the controller's built in watchdog. The use is optional.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |    1 +
 drivers/isdn/hardware/mISDN/hfcmulti.c  |   32 ++++++++++++++++++++++++++++++-
 include/linux/mISDNif.h                 |    3 +-
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index 663b77f..5765e19 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -62,6 +62,7 @@ struct hfcm_hw {
 	u_char	r_sci_msk;
 	u_char	r_tx0, r_tx1;
 	u_char	a_st_ctrl0[8];
+	u_char	r_bert_wd_md;
 	timer_t	timer;
 };
 
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 0b28141..ca153de 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -4013,11 +4013,41 @@ open_bchannel(struct hfc_multi *hc, struct dchannel *dch,
 static int
 channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 {
+	struct hfc_multi	*hc = dch->hw;
 	int	ret = 0;
+	int	wd_mode, wd_cnt;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = 0;
+		cq->op = MISDN_CTRL_HFC_OP;
+		break;
+	case MISDN_CTRL_HFC_WD_INIT: /* init the watchdog */
+		wd_cnt = cq->p1 & 0xf;
+		wd_mode = !!(cq->p1 >> 4);
+		if (debug & DEBUG_HFCMULTI_MSG)
+			printk(KERN_DEBUG
+			    "%s: MISDN_CTRL_HFC_WD_INIT mode %s counter 0x%x\n",
+			    __func__, wd_mode ? "AUTO" : "MANUAL", wd_cnt);
+		/* set the watchdog timer */
+		HFC_outb(hc, R_TI_WD, poll_timer | (wd_cnt << 4));
+		hc->hw.r_bert_wd_md = (wd_mode ? V_AUTO_WD_RES : 0);
+		if (hc->ctype == HFC_TYPE_XHFC)
+			hc->hw.r_bert_wd_md |= 0x40 /* V_WD_EN */;
+		/* init the watchdog register and reset the counter */
+		HFC_outb(hc, R_BERT_WD_MD, hc->hw.r_bert_wd_md | V_WD_RES);
+		if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
+			/* enable the watchdog output for Speech-Design */
+			HFC_outb(hc, R_GPIO_SEL, V_GPIO_SEL7);
+			HFC_outb(hc, R_GPIO_EN1, V_GPIO_EN15);
+			HFC_outb(hc, R_GPIO_OUT1, 0);
+			HFC_outb(hc, R_GPIO_OUT1, V_GPIO_OUT15);
+		}
+		break;
+	case MISDN_CTRL_HFC_WD_RESET: /* reset the watchdog counter */
+		if (debug & DEBUG_HFCMULTI_MSG)
+			printk(KERN_DEBUG "%s: MISDN_CTRL_HFC_WD_RESET\n",
+			    __func__);
+		HFC_outb(hc, R_BERT_WD_MD, hc->hw.r_bert_wd_md | V_WD_RES);
 		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 5da3d95..cf97459 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -362,7 +362,8 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_HFC_RECEIVE_ON	0x4006
 #define MISDN_CTRL_HFC_ECHOCAN_ON 	0x4007
 #define MISDN_CTRL_HFC_ECHOCAN_OFF 	0x4008
-
+#define MISDN_CTRL_HFC_WD_INIT		0x4009
+#define MISDN_CTRL_HFC_WD_RESET		0x400A
 
 /* socket options */
 #define MISDN_TIME_STAMP		0x0001
-- 
1.6.0.2
