From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 12/22] e1000: Fix powerdown link loss when forced to gig speed
Date: Fri, 08 Dec 2006 15:03:11 -0800
Message-ID: <20061208230311.30109.32860.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4388 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761264AbWLHWxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:05 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


disable phy power mode to prevent the NIC from attempting to autoneg
to i10/100mbit when running in forced gig mode as it would lose link at
shutdown. This allows you to force gig speed and still use WoL/IPMI
after shutdow.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c5c764f..9ddcadd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -819,6 +819,20 @@ e1000_reset(struct e1000_adapter *adapte
 	if (e1000_init_hw(&adapter->hw))
 		DPRINTK(PROBE, ERR, "Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
+
+	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
+	if (adapter->hw.mac_type >= e1000_82544 &&
+	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
+	    adapter->hw.autoneg == 1 &&
+	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
+		uint32_t ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		/* clear phy power management bit if we are in gig only mode,
+		 * which if enabled will attempt negotiation to 100Mb, which
+		 * can cause a loss of link at power off or driver unload */
+		ctrl &= ~E1000_CTRL_SWDPIN3;
+		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+	}
+
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
 	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
 



---
Auke Kok <auke-jan.h.kok@intel.com>
