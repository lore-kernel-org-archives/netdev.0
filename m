From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/5] tg3: WOL defaults
Date: Wed, 10 Oct 2007 17:45:26 -0700
Message-ID: <1192063527.4878.186.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1630 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757093AbXJKApg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables WOL by default if out-of-box WOL is enabled in the
NVRAM.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3af93b5..8967bc3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10412,8 +10412,12 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
 			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
 		}
-		if (tr32(VCPU_CFGSHDW) & VCPU_CFGSHDW_ASPM_DBNC)
+		val = tr32(VCPU_CFGSHDW);
+		if (val & VCPU_CFGSHDW_ASPM_DBNC)
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
+		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
+		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
+			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 		return;
 	}
 
@@ -10536,6 +10540,10 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
 
+		if (tp->tg3_flags & TG3_FLAG_WOL_CAP &&
+		    nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE)
+			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+
 		if (cfg2 & (1 << 17))
 			tp->tg3_flags2 |= TG3_FLG2_CAPACITIVE_COUPLING;
 
@@ -11454,11 +11462,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 		tp->rx_std_max_post = 8;
 
-	/* By default, disable wake-on-lan.  User can change this
-	 * using ETHTOOL_SWOL.
-	 */
-	tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
-
 	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND)
 		tp->pwrmgmt_thresh = tr32(PCIE_PWR_MGMT_THRESH) &
 				     PCIE_PWR_MGMT_L1_THRESH_MSK;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d1f5fa3..6dbdad2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1151,6 +1151,8 @@
 #define  VCPU_STATUS_DRV_RESET		 0x08000000
 
 #define VCPU_CFGSHDW			0x00005104
+#define  VCPU_CFGSHDW_WOL_ENABLE	 0x00000001
+#define  VCPU_CFGSHDW_WOL_MAGPKT	 0x00000004
 #define  VCPU_CFGSHDW_ASPM_DBNC		 0x00001000
 
 /* Mailboxes */


