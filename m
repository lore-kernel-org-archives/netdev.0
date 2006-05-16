From: "Guenther Thomsen" <GThomsen@bluearc.com>
Subject: RE: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Tue, 16 May 2006 13:15:09 -0700
Message-ID: <CECD6E8A589E8447BC6E836C8369AFF50682862C@us-email.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmimesweeper.bluearc.com ([63.203.197.133]:16914 "EHLO
	us-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S1750785AbWEPUPK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 16:15:10 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your continued work on it. I will test the patch, as soon as I get access to the hardware again (probably next week).

best regards
	Guenther 

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org]
Sent: Tuesday, May 16, 2006 12:12 PM
To: Guenther Thomsen
Cc: John W. Linville; netdev@vger.kernel.org
Subject: Re: kernel panic (on DHCP discover?) in sky2 driver of
2.6.17-rc1


Could you try the 2.6.17-rc4 version with this patch. It turns out the board
seems to give out of order status responses.

Ignore the vendor sk98lin driver, when I try the stock version it spends it's
life resetting itself because it sets up PCI bus wrong. If I fix that, it spends
it's time getting confused because it can't handle intermixed status reports
properly (checksum et all is per port not per board).


 drivers/net/sky2.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

792547bc5e8e4f7d5a1070a168056f429635c254
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ffd267f..11e7914 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1020,8 +1020,27 @@ static int sky2_up(struct net_device *de
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace, imask;
-	int err = -ENOMEM;
+	int cap, err;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
 
+	/*
+	 * Reduce split transactions (and turn off) rx checksums to
+	 * prevent problems with dual ports.
+	 */
+	if (otherdev && netif_running(otherdev) &&
+	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+		struct sky2_port *osky2 = netdev_priv(otherdev);
+		u16 cmd;
+
+		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
+		sky2->rx_csum = 0;
+		osky2->rx_csum = 0;
+	}
+
+	err = -ENOMEM;
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
@@ -3067,12 +3086,7 @@ static __devinit struct net_device *sky2
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-
-	/* Receive checksum disabled for Yukon XL
-	 * because of observed problems with incorrect
-	 * values when multiple packets are received in one interrupt
-	 */
-	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
+	sky2->rx_csum = 1;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
-- 
1.2.4

