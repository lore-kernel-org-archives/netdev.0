From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] pch_gbe: memory corruption calling pch_gbe_validate_option()
Date: Thu, 1 Mar 2012 10:17:08 +0300
Message-ID: <20120301071708.GB6959@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:18017 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457Ab2CAIyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 03:54:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pch_gbe_validate_option() modifies 32 bits of memory but we pass
&hw->phy.autoneg_advertised which only has 16 bits and &hw->mac.fc
which only has 8 bits.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
index 9cb5f91..29e23be 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
@@ -321,10 +321,10 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 			pr_debug("AutoNeg specified along with Speed or Duplex, AutoNeg parameter ignored\n");
 			hw->phy.autoneg_advertised = opt.def;
 		} else {
-			hw->phy.autoneg_advertised = AutoNeg;
-			pch_gbe_validate_option(
-				(int *)(&hw->phy.autoneg_advertised),
-				&opt, adapter);
+			int tmp = AutoNeg;
+
+			pch_gbe_validate_option(&tmp, &opt, adapter);
+			hw->phy.autoneg_advertised = tmp;
 		}
 	}
 
@@ -495,9 +495,10 @@ void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
 			.arg  = { .l = { .nr = (int)ARRAY_SIZE(fc_list),
 					 .p = fc_list } }
 		};
-		hw->mac.fc = FlowControl;
-		pch_gbe_validate_option((int *)(&hw->mac.fc),
-						&opt, adapter);
+		int tmp = FlowControl;
+
+		pch_gbe_validate_option(&tmp, &opt, adapter);
+		hw->mac.fc = tmp;
 	}
 
 	pch_gbe_check_copper_options(adapter);
