From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [PATCH 1/2] ipw2100: register pm_qos request on hardware activation
Date: Wed, 11 Aug 2010 21:31:03 +0200
Message-ID: <1281555063.4367.1.camel@lovely.krouter>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@suse.de>,
	Zhu Yi <yi.zhu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56478 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363Ab0HKT1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 15:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function pm_qos_add_request() has to be called before first
pm_qos_update_request().  This was found out due to a change in pm_qos
(commit 82f682514a5df89ffb3890627eebf0897b7a84ec "pm_qos: Get rid of
the allocation in pm_qos_add_request()"). The warning call trace is below.

This patch is similar to c128ec29208d410568469bd8bb373b4cdc10912a "e1000e:
register pm_qos request on hardware activation".

WARNING: at kernel/pm_qos_params.c:264 pm_qos_update_request+0x5e/0x70()
pm_qos_update_request() called for unknown object
Call Trace:
[<c1024088>] ? warn_slowpath_common+0x78/0xb0
[<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
[<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
[<c1024153>] ? warn_slowpath_fmt+0x33/0x40
[<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
[<f89fe15f>] ? ipw2100_up+0x3f/0xf10 [ipw2100]
[<c11961c9>] ? vsnprintf+0xc9/0x530
[<f89ff36c>] ? ipw2100_net_init+0x2c/0x1c0 [ipw2100]
[<c12f542d>] ? register_netdevice+0x7d/0x3c0
[<f89f9b00>] ? ipw2100_irq_tasklet+0x910/0x9a0 [ipw2100]
[<c12f579f>] ? register_netdev+0x2f/0x40
[<f89fd471>] ? ipw2100_pci_init_one+0xd21/0x1060 [ipw2100]
[<c11a5ebb>] ? local_pci_probe+0xb/0x10
[<c11a6d49>] ? pci_device_probe+0x69/0x90
[<c1224704>] ? driver_probe_device+0x74/0x180
[<c10dd15a>] ? sysfs_create_dir+0x6a/0xb0
[<c1224889>] ? __driver_attach+0x79/0x80
[<c1224810>] ? __driver_attach+0x0/0x80
[<c1223fa2>] ? bus_for_each_dev+0x52/0x80
[<c1224586>] ? driver_attach+0x16/0x20
[<c1224810>] ? __driver_attach+0x0/0x80
[<c122395f>] ? bus_add_driver+0x17f/0x250
[<c11a5ec0>] ? pci_device_shutdown+0x0/0x20
[<c11a6c80>] ? pci_device_remove+0x0/0x40
[<c1224b13>] ? driver_register+0x63/0x120
[<c11a6f96>] ? __pci_register_driver+0x36/0xa0
[<f84f9048>] ? ipw2100_init+0x48/0x67 [ipw2100]
[<c1001122>] ? do_one_initcall+0x32/0x170
[<c1087078>] ? __vunmap+0xb8/0xf0
[<f84f9000>] ? ipw2100_init+0x0/0x67 [ipw2100]
[<c10510c1>] ? sys_init_module+0x161/0x1000
[<c108f847>] ? sys_close+0x67/0xe0
[<c13647c1>] ? syscall_call+0x7/0xb

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 16bbfa3..df8e535 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1909,6 +1909,9 @@ static int ipw2100_net_init(struct net_device *dev)
 	int ret;
 	int i;
 
+	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+			   PM_QOS_DEFAULT_VALUE);
+
 	ret = ipw2100_up(priv, 1);
 	if (ret)
 		return ret;
@@ -1962,6 +1965,12 @@ static int ipw2100_net_init(struct net_device *dev)
 	return 0;
 }
 
+/* Called by unregister_netdev() */
+static void ipw2100_net_uninit(struct net_device *dev)
+{
+	pm_qos_remove_request(&ipw2100_pm_qos_req);
+}
+
 static void ipw2100_reset_adapter(struct work_struct *work)
 {
 	struct ipw2100_priv *priv =
@@ -6092,11 +6101,12 @@ static void ipw2100_rf_kill(struct work_struct *work)
 static void ipw2100_irq_tasklet(struct ipw2100_priv *priv);
 
 static const struct net_device_ops ipw2100_netdev_ops = {
+	.ndo_init		= ipw2100_net_init,
+	.ndo_uninit		= ipw2100_net_uninit,
 	.ndo_open		= ipw2100_open,
 	.ndo_stop		= ipw2100_close,
 	.ndo_start_xmit		= libipw_xmit,
 	.ndo_change_mtu		= libipw_change_mtu,
-	.ndo_init		= ipw2100_net_init,
 	.ndo_tx_timeout		= ipw2100_tx_timeout,
 	.ndo_set_mac_address	= ipw2100_set_address,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -6669,8 +6679,6 @@ static int __init ipw2100_init(void)
 	if (ret)
 		goto out;
 
-	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
-			   PM_QOS_DEFAULT_VALUE);
 #ifdef CONFIG_IPW2100_DEBUG
 	ipw2100_debug_level = debug;
 	ret = driver_create_file(&ipw2100_pci_driver.driver,
@@ -6692,7 +6700,6 @@ static void __exit ipw2100_exit(void)
 			   &driver_attr_debug_level);
 #endif
 	pci_unregister_driver(&ipw2100_pci_driver);
-	pm_qos_remove_request(&ipw2100_pm_qos_req);
 }
 
 module_init(ipw2100_init);
-- 
1.7.1



