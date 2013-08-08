From: Andrew Ruder <andy@aeruder.net>
Subject: Regression from [PATCH] DM9000B: driver initialization upgrade
Date: Thu, 8 Aug 2013 13:18:36 -0500
Message-ID: <20130808181836.GA32646@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Corbet <corbet@lwn.net>
To: netdev@vger.kernel.org, Joseph CHANG <joseph_chang@davicom.com.tw>,
	Allen Huant <allen_huang@davicom.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:34253 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965337Ab3HHSUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 14:20:49 -0400
Received: by mail-ob0-f179.google.com with SMTP id fb19so5558877obc.10
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 11:20:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My DM9000A based board broke (no longer getting any PHY interrupts so
never determines that it has established a link) as a result of this
patch (6741f40d198c).  This email is partially a call for help to the
Davicom guys who introduced this change and partially a probe to see if
anyone else has had any luck with the DM9000A or DM9000B post this
patch.

For the purpose of clarity/discussion, the patch shown at the bottom of
this email is not the actual patch applied because the patch applied
moved around functions, reformatted comments, and other things which
kind of obscures the actual changes being made so I went through and put
together a minimal patch with the same overall effect on the code.

There's really two changes being introduced by this patch: initial reset
turns on the MAC loopback and internal PHY reset.

===
On the subject of the initial reset:

This doesn't seem to be the source of my issues and I have noticed that
a similar change has already been introduced to the U-Boot dm9000
driver.  I will eventually be submitting a follow-up patch that fixes
this to Jonathan Corbet's initial suggestion
( https://lkml.org/lkml/2013/3/25/481 ) because the bare iow() ignores
the reset timing requirements of the DM9000 and consequently always hits
the following error message as it attempts to read the ID before the
part has come out of reset.

	dev_err(db->dev, "read wrong id 0x%08x\n", id_val);

===
On the subject of the PHY reset:

Removing just this portion of the patch gets me up and working again.
Unfortunately there is little documentation on these registers available
in the datasheet and the "DSP Control Register" in particular is
actually not even shown in the memory map of the DM9000A or DM9000B in
the datasheet.  I have even modified the driver to properly wait for the
PHY reset to finish (which was also omitted from this patch series)
before writing more to the PHY but I'm still out of luck.

Any thoughts, experiences?

Thanks,
Andy

From: Joseph CHANG <josright123@gmail.com>
Date: Thu, 28 Mar 2013 23:13:42 +0000
Subject: [PATCH] DM9000B: driver initialization upgrade

Fix bug for DM9000 revision B which contain a DSP PHY

DM9000B use DSP PHY instead previouse DM9000 revisions' analog PHY,
So need extra change in initialization, For
explicity PHY Reset and PHY init parameter, and
first DM9000_NCR reset need NCR_MAC_LBK bit by dm9000_probe().

Following DM9000_NCR reset cause by dm9000_open() clear the
NCR_MAC_LBK bit.

Without this fix, Power-up FIFO pointers error happen around 2%
rate among Davicom's customers' boards. With this fix, All above
cases can be solved.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/davicom/dm9000.c | 16 +++++++++++++++-
 drivers/net/ethernet/davicom/dm9000.h | 11 ++++++++++-
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index d084d17..9937095 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -143,6 +143,12 @@ typedef struct board_info {
 	int		ip_summed;
 } board_info_t;
 
+/* declarations */
+
+static void
+dm9000_phy_write(struct net_device *dev,
+		 int phyaddr_unused, int reg, int value);
+
 /* debug code */
 
 #define dm9000_dbg(db, lev, msg...) do {		\
@@ -790,6 +796,9 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 
+	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
+	dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM); /* Init */
+
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
 
 	/* if wol is needed, then always set NCR_WAKEEN otherwise we end
@@ -1528,7 +1537,12 @@ dm9000_probe(struct platform_device *pdev)
 	db->flags |= DM9000_PLATF_SIMPLE_PHY;
 #endif
 
-	dm9000_reset(db);
+	/* Fixing bug on dm9000_probe, takeover dm9000_reset(db),
+	 * Need 'NCR_MAC_LBK' bit to indeed stable our DM9000 fifo
+	 * while probe stage.
+	 */
+
+	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
diff --git a/drivers/net/ethernet/davicom/dm9000.h b/drivers/net/ethernet/davicom/dm9000.h
index 55688bd..9ce058a 100644
--- a/drivers/net/ethernet/davicom/dm9000.h
+++ b/drivers/net/ethernet/davicom/dm9000.h
@@ -69,7 +69,9 @@
 #define NCR_WAKEEN          (1<<6)
 #define NCR_FCOL            (1<<4)
 #define NCR_FDX             (1<<3)
-#define NCR_LBK             (3<<1)
+
+#define NCR_RESERVED        (3<<1)
+#define NCR_MAC_LBK         (1<<1)
 #define NCR_RST	            (1<<0)
 
 #define NSR_SPEED           (1<<7)
@@ -167,5 +169,12 @@
 #define ISR_LNKCHNG		(1<<5)
 #define ISR_UNDERRUN		(1<<4)
 
+/* Davicom MII registers.
+ */
+
+#define MII_DM_DSPCR		0x1b    /* DSP Control Register */
+
+#define DSPCR_INIT_PARAM	0xE100	/* DSP init parameter */
+
 #endif /* _DM9000X_H_ */
 
-- 
1.8.3.1.377.g4d1c565
