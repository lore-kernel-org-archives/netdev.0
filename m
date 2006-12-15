From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 05/14] e1000: Fix Wake-on-Lan with forced gigabit speed
Date: Fri, 15 Dec 2006 10:33:46 +0100
Message-ID: <1166175226.3365.119.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751520AbWLOKBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:05 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gobW006151
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:50 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gnH1006150
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:50 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: Fix Wake-on-Lan with forced gigabit speed
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the user has forced gigabit speed, phy power management must be disabled;
otherwise the NIC would try to negotiate to a linkspeed of 10/100 mbit on
shutdown, which would lead to a total loss of link. This loss of link breaks
Wake-on-Lan and IPMI.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -732,6 +732,20 @@ e1000_reset(struct e1000_adapter *adapte
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
 

