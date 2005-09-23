From: Jeff Garzik <jgarzik@pobox.com>
Subject: [git patches] net driver fixes
Date: Fri, 23 Sep 2005 19:09:17 -0400
Message-ID: <20050923230917.GA3243@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932102AbVIWXJV@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

to obtain the following fixes:


 drivers/net/8390.c |    2 +-
 drivers/net/skge.c |   22 ++++++++++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)


Paul Gortmaker:
  8390 Tx fix for non i386 machines

Stephen Hemminger:
  skge: fix Yukon-Lite A0 workaround


diff --git a/drivers/net/8390.c b/drivers/net/8390.c
--- a/drivers/net/8390.c
+++ b/drivers/net/8390.c
@@ -1094,7 +1094,7 @@ static void NS8390_trigger_send(struct n
    
 	outb_p(E8390_NODMA+E8390_PAGE0, e8390_base+E8390_CMD);
     
-	if (inb_p(e8390_base) & E8390_TRANS) 
+	if (inb_p(e8390_base + E8390_CMD) & E8390_TRANS) 
 	{
 		printk(KERN_WARNING "%s: trigger_send() called with the transmitter busy.\n",
 			dev->name);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1643,6 +1643,22 @@ static void yukon_reset(struct skge_hw *
 			 | GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 }
 
+/* Apparently, early versions of Yukon-Lite had wrong chip_id? */
+static int is_yukon_lite_a0(struct skge_hw *hw)
+{
+	u32 reg;
+	int ret;
+
+	if (hw->chip_id != CHIP_ID_YUKON)
+		return 0;
+
+	reg = skge_read32(hw, B2_FAR);
+	skge_write8(hw, B2_FAR + 3, 0xff);
+	ret = (skge_read8(hw, B2_FAR + 3) != 0);
+	skge_write32(hw, B2_FAR, reg);
+	return ret;
+}
+
 static void yukon_mac_init(struct skge_hw *hw, int port)
 {
 	struct skge_port *skge = netdev_priv(hw->dev[port]);
@@ -1758,9 +1774,11 @@ static void yukon_mac_init(struct skge_h
 	/* Configure Rx MAC FIFO */
 	skge_write16(hw, SK_REG(port, RX_GMF_FL_MSK), RX_FF_FL_DEF_MSK);
 	reg = GMF_OPER_ON | GMF_RX_F_FL_ON;
-	if (hw->chip_id == CHIP_ID_YUKON_LITE &&
-	    hw->chip_rev >= CHIP_REV_YU_LITE_A3)
+
+	/* disable Rx GMAC FIFO Flush for YUKON-Lite Rev. A0 only */
+	if (is_yukon_lite_a0(hw))
 		reg &= ~GMF_RX_F_FL_ON;
+
 	skge_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
 	skge_write16(hw, SK_REG(port, RX_GMF_CTRL_T), reg);
 	/*
