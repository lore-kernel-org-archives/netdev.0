From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/12] e1000e: bad state after running ethtool
	diagnostics with AMT enabled
Date: Mon, 10 May 2010 17:59:31 -0700
Message-ID: <20100511005929.30827.30176.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:53246 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755754Ab0EKA7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 20:59:48 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When running ethtool online diagnostics with no open interface, there is a
short period of time where the driver relinquishes control of the adapter
during which time AMT (manageability firmware) can put the adapter into an
unknown state resulting in such things as link test failure, hardware hang,
reporting an incorrect link speed, etc.  Resetting the adapter during an
open() resolves this by putting the adapter into a quiescent state.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    9 +++++++++
 drivers/net/e1000e/netdev.c  |   16 +++++++++-------
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6ff376c..2c52121 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1737,6 +1737,12 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
+		if (!if_running && (adapter->flags & FLAG_HAS_AMT)) {
+			clear_bit(__E1000_TESTING, &adapter->state);
+			dev_open(netdev);
+			set_bit(__E1000_TESTING, &adapter->state);
+		}
+
 		e_info("online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
@@ -1748,6 +1754,9 @@ static void e1000_diag_test(struct net_device *netdev,
 		data[2] = 0;
 		data[3] = 0;
 
+		if (!if_running && (adapter->flags & FLAG_HAS_AMT))
+			dev_close(netdev);
+
 		clear_bit(__E1000_TESTING, &adapter->state);
 	}
 	msleep_interruptible(4 * 1000);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c5f65a2..ab79bec 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3444,6 +3444,15 @@ static int e1000_open(struct net_device *netdev)
 	if (err)
 		goto err_setup_rx;
 
+	/*
+	 * If AMT is enabled, let the firmware know that the network
+	 * interface is now open and reset the part to a known state.
+	 */
+	if (adapter->flags & FLAG_HAS_AMT) {
+		e1000_get_hw_control(adapter);
+		e1000e_reset(adapter);
+	}
+
 	e1000e_power_up_phy(adapter);
 
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -3452,13 +3461,6 @@ static int e1000_open(struct net_device *netdev)
 		e1000_update_mng_vlan(adapter);
 
 	/*
-	 * If AMT is enabled, let the firmware know that the network
-	 * interface is now open
-	 */
-	if (adapter->flags & FLAG_HAS_AMT)
-		e1000_get_hw_control(adapter);
-
-	/*
 	 * before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our

