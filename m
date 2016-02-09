From: "Avargil, Raanan" <raanan.avargil@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next V2 6/6] e1000e: call
 ndo_stop()	instead of dev_close() when running offline selftest
Date: Tue, 9 Feb 2016 12:30:38 +0000
Message-ID: <8F4C390AFA9F4444A4AA77F4A3BEC78A18FFCF13@HASMSX110.ger.corp.intel.com>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
 <1454487652-1545-7-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7977 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbcBIMa6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 07:30:58 -0500
In-Reply-To: <1454487652-1545-7-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Raanan Avargil <Raanan.avargil@intel.com>

--
Regards,
Raanan


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Stefan Assmann
Sent: Wednesday, February 03, 2016 10:21
To: intel-wired-lan@lists.osuosl.org
Cc: netdev@vger.kernel.org; davem@davemloft.net; sassmann@kpanic.de
Subject: [Intel-wired-lan] [PATCH net-next V2 6/6] e1000e: call ndo_stop() instead of dev_close() when running offline selftest
Importance: High

Calling dev_close() causes IFF_UP to be cleared which will remove the interfaces routes and some addresses. That's probably not what the user intended when running the offline selftest. Besides this does not happen if the interface is brought down before the test, so the current behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid touching IFF_UP at all.

V2: rename e1000_open(), e1000_close() to e1000e_open(), e1000e_close() to avoid name clash with e1000.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |  2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c |  4 ++--  drivers/net/ethernet/intel/e1000e/netdev.c  | 12 ++++++------
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1dc293b..52eb641 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -480,6 +480,8 @@ extern const char e1000e_driver_version[];  void e1000e_check_options(struct e1000_adapter *adapter);  void e1000e_set_ethtool_ops(struct net_device *netdev);
 
+int e1000e_open(struct net_device *netdev); int e1000e_close(struct 
+net_device *netdev);
 void e1000e_up(struct e1000_adapter *adapter);  void e1000e_down(struct e1000_adapter *adapter, bool reset);  void e1000e_reinit_locked(struct e1000_adapter *adapter); diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6cab1f3..1e3973a 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1816,7 +1816,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			e1000e_close(netdev);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED; @@ -1849,7 +1849,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			e1000e_open(netdev);
 	} else {
 		/* Online tests */
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c71ba1b..02449a0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4495,7 +4495,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)  }
 
 /**
- * e1000_open - Called when a network interface is made active
+ * e1000e_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
  * Returns 0 on success, negative value on failure @@ -4506,7 +4506,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int e1000_open(struct net_device *netdev)
+int e1000e_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4604,7 +4604,7 @@ err_setup_tx:
 }
 
 /**
- * e1000_close - Disables a network interface
+ * e1000e_close - Disables a network interface
  * @netdev: network interface device structure
  *
  * Returns 0, this is not allowed to fail @@ -4614,7 +4614,7 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int e1000_close(struct net_device *netdev)
+int e1000e_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
@@ -6920,8 +6920,8 @@ static int e1000_set_features(struct net_device *netdev,  }
 
 static const struct net_device_ops e1000e_netdev_ops = {
-	.ndo_open		= e1000_open,
-	.ndo_stop		= e1000_close,
+	.ndo_open		= e1000e_open,
+	.ndo_stop		= e1000e_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
 	.ndo_get_stats64	= e1000e_get_stats64,
 	.ndo_set_rx_mode	= e1000e_set_rx_mode,
