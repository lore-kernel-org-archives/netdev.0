From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] ipw2100: register pm_qos request before registering pci driver
Date: Wed, 11 Aug 2010 16:22:30 -0400
Message-ID: <1281558150-1999-1-git-send-email-linville@tuxdriver.com>
References: <1281555063.4367.1.camel@lovely.krouter>
Cc: Christoph Fritz <chf.fritz@googlemail.com>,
	James Bottomley <James.Bottomley@suse.de>,
	Zhu Yi <yi.zhu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32976 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756852Ab0HKU36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 16:29:58 -0400
In-Reply-To: <1281555063.4367.1.camel@lovely.krouter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is necessary to call pm_qos_add_request prior to calling
pm_qos_update_request.  It was revealed that ipw2100 has been
doing this wrong since "pm_qos: Get rid of the allocation in
pm_qos_add_request()" (commit 82f682514a5df89ffb3890627eebf0897b7a84ec)
added a WARN that results in the following backtrace:

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

This patch moves pm_qos_add_request prior to pci_register_driver in
ipw2100 in order to avoid this problem.

Reported-by: Christoph Fritz <chf.fritz@googlemail.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 16bbfa3..1189dbb 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6665,12 +6665,13 @@ static int __init ipw2100_init(void)
 	printk(KERN_INFO DRV_NAME ": %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	printk(KERN_INFO DRV_NAME ": %s\n", DRV_COPYRIGHT);
 
+	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+			   PM_QOS_DEFAULT_VALUE);
+
 	ret = pci_register_driver(&ipw2100_pci_driver);
 	if (ret)
 		goto out;
 
-	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
-			   PM_QOS_DEFAULT_VALUE);
 #ifdef CONFIG_IPW2100_DEBUG
 	ipw2100_debug_level = debug;
 	ret = driver_create_file(&ipw2100_pci_driver.driver,
-- 
1.7.2.1

