From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/10] e1000: Esb2 wol link cycle bug and uninitialized registers
Date: Fri, 14 Apr 2006 11:36:51 -0700
Message-ID: <20060414183651.3461.58411.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:47876 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751398AbWDNSdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Esb2 link didn't return after wol disable. The code previously assumed
that writing reset to PHY_CTRL phy register turned the phy back on.
In the ESB2 phy case that didn't occur.

Add ESB2 to acquire/release_hw functions upon review it was
discovered that esb2 was skipped on these functions


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ac1e838..8de9f9a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -359,6 +359,7 @@ e1000_release_hw_control(struct e1000_ad
 	switch (adapter->hw.mac_type) {
 	case e1000_82571:
 	case e1000_82572:
+	case e1000_80003es2lan:
 		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
 		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
 				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
@@ -392,6 +393,7 @@ e1000_get_hw_control(struct e1000_adapte
 	switch (adapter->hw.mac_type) {
 	case e1000_82571:
 	case e1000_82572:
+	case e1000_80003es2lan:
 		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
 		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
 				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
@@ -419,7 +421,7 @@ e1000_up(struct e1000_adapter *adapter)
 		uint16_t mii_reg;
 		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
 		if (mii_reg & MII_CR_POWER_DOWN)
-			e1000_phy_reset(&adapter->hw);
+			e1000_phy_hw_reset(&adapter->hw);
 	}
 
 	e1000_set_multi(netdev);



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
