From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] e1000/e1000e: implement a simple interrupt
	moderation
Date: Wed, 05 May 2010 01:26:03 -0700
Message-ID: <20100505082601.5956.29024.stgit@localhost.localdomain>
References: <20100505082537.5956.86868.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:47650
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155Ab0EEI0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:26:21 -0400
In-Reply-To: <20100505082537.5956.86868.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Back before e1000-7.3.20, the e1000 driver had a simple algorithm that
managed interrupt moderation.  The driver was updated in 7.3.20 to
have the new "adaptive" interrupt moderation but we have customer
requests to redeploy the old way as an option.  This patch adds the
old functionality back.  The new functionality can be enabled via
module parameter or at runtime via ethtool.
Module parameter: (InterruptThrottleRate=4) to use this new
moderation method.
Ethtool method: ethtool -C ethX rx-usecs 4

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    8 +++++---
 drivers/net/e1000/e1000_main.c    |   18 +++++++++++++++++-
 drivers/net/e1000/e1000_param.c   |   10 ++++++++--
 drivers/net/e1000e/ethtool.c      |    8 +++++---
 drivers/net/e1000e/netdev.c       |   18 +++++++++++++++++-
 drivers/net/e1000e/param.c        |    5 +++++
 6 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index d6931ca..2a3b2dc 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1808,7 +1808,7 @@ static int e1000_get_coalesce(struct net_device *netdev,
 	if (adapter->hw.mac_type < e1000_82545)
 		return -EOPNOTSUPP;
 
-	if (adapter->itr_setting <= 3)
+	if (adapter->itr_setting <= 4)
 		ec->rx_coalesce_usecs = adapter->itr_setting;
 	else
 		ec->rx_coalesce_usecs = 1000000 / adapter->itr_setting;
@@ -1826,12 +1826,14 @@ static int e1000_set_coalesce(struct net_device *netdev,
 		return -EOPNOTSUPP;
 
 	if ((ec->rx_coalesce_usecs > E1000_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs > 3) &&
+	    ((ec->rx_coalesce_usecs > 4) &&
 	     (ec->rx_coalesce_usecs < E1000_MIN_ITR_USECS)) ||
 	    (ec->rx_coalesce_usecs == 2))
 		return -EINVAL;
 
-	if (ec->rx_coalesce_usecs <= 3) {
+	if (ec->rx_coalesce_usecs == 4) {
+		adapter->itr = adapter->itr_setting = 4;
+	} else if (ec->rx_coalesce_usecs <= 3) {
 		adapter->itr = 20000;
 		adapter->itr_setting = ec->rx_coalesce_usecs;
 	} else {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e6ebc22..4dd2c23 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,7 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#define DRV_VERSION "7.3.21-k5-NAPI"
+#define DRV_VERSION "7.3.21-k6-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -2386,6 +2386,22 @@ link_up:
 		}
 	}
 
+	/* Simple mode for Interrupt Throttle Rate (ITR) */
+	if (hw->mac_type >= e1000_82540 && adapter->itr_setting == 4) {
+		/*
+		 * Symmetric Tx/Rx gets a reduced ITR=2000;
+		 * Total asymmetrical Tx or Rx gets ITR=8000;
+		 * everyone else is between 2000-8000.
+		 */
+		u32 goc = (adapter->gotcl + adapter->gorcl) / 10000;
+		u32 dif = (adapter->gotcl > adapter->gorcl ?
+			    adapter->gotcl - adapter->gorcl :
+			    adapter->gorcl - adapter->gotcl) / 10000;
+		u32 itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
+
+		ew32(ITR, 1000000000 / (itr * 256));
+	}
+
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	ew32(ICS, E1000_ICS_RXDMT0);
 
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 543c6d1..9fbb562 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -484,11 +484,17 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
+			case 4:
+				e_dev_info("%s set to simplified "
+				           "(2000-8000) ints mode\n", opt.name);
+				adapter->itr_setting = adapter->itr;
+				break;
 			default:
 				e1000_validate_option(&adapter->itr, &opt,
 				        adapter);
-				/* save the setting, because the dynamic bits change itr */
-				/* clear the lower two bits because they are
+				/* save the setting, because the dynamic bits
+				 * change itr.
+				 * clear the lower two bits because they are
 				 * used as control */
 				adapter->itr_setting = adapter->itr & ~3;
 				break;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 7f9915c..c81118a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1891,7 +1891,7 @@ static int e1000_get_coalesce(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->itr_setting <= 3)
+	if (adapter->itr_setting <= 4)
 		ec->rx_coalesce_usecs = adapter->itr_setting;
 	else
 		ec->rx_coalesce_usecs = 1000000 / adapter->itr_setting;
@@ -1906,12 +1906,14 @@ static int e1000_set_coalesce(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 
 	if ((ec->rx_coalesce_usecs > E1000_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs > 3) &&
+	    ((ec->rx_coalesce_usecs > 4) &&
 	     (ec->rx_coalesce_usecs < E1000_MIN_ITR_USECS)) ||
 	    (ec->rx_coalesce_usecs == 2))
 		return -EINVAL;
 
-	if (ec->rx_coalesce_usecs <= 3) {
+	if (ec->rx_coalesce_usecs == 4) {
+		adapter->itr = adapter->itr_setting = 4;
+	} else if (ec->rx_coalesce_usecs <= 3) {
 		adapter->itr = 20000;
 		adapter->itr_setting = ec->rx_coalesce_usecs;
 	} else {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d13760d..0a16465 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -52,7 +52,7 @@
 
 #include "e1000.h"
 
-#define DRV_VERSION "1.0.2-k2"
+#define DRV_VERSION "1.0.2-k4"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -4087,6 +4087,22 @@ link_up:
 		}
 	}
 
+	/* Simple mode for Interrupt Throttle Rate (ITR) */
+	if (adapter->itr_setting == 4) {
+		/*
+		 * Symmetric Tx/Rx gets a reduced ITR=2000;
+		 * Total asymmetrical Tx or Rx gets ITR=8000;
+		 * everyone else is between 2000-8000.
+		 */
+		u32 goc = (adapter->gotc + adapter->gorc) / 10000;
+		u32 dif = (adapter->gotc > adapter->gorc ?
+			    adapter->gotc - adapter->gorc :
+			    adapter->gorc - adapter->gotc) / 10000;
+		u32 itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
+
+		ew32(ITR, 1000000000 / (itr * 256));
+	}
+
 	/* Cause software interrupt to ensure Rx ring is cleaned */
 	if (adapter->msix_entries)
 		ew32(ICS, adapter->rx_ring->ims_val);
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index f775a48..0f4077c 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -351,6 +351,11 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
+			case 4:
+				e_info("%s set to simplified (2000-8000 ints) "
+				       "mode\n", opt.name);
+				adapter->itr_setting = 4;
+				break;
 			default:
 				/*
 				 * Save the setting, because the dynamic bits

