From: Bill Nottingham <notting@redhat.com>
Subject: [PATCH] Fix NULL pointer dereference on firmware name for early calls to get_drvinfo.
Date: Fri, 30 Mar 2012 16:24:05 -0400
Message-ID: <1333139045-18170-1-git-send-email-notting@redhat.com>
To: inaky.perez-gonzalez@intel.com, wimax@linuxwimax.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759210Ab2C3UZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2012 16:25:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver comments show an initialization sequence of:
 * i2400m_setup()
 *   i2400m->bus_setup()
 *   i2400m_bootrom_init()
 *   register_netdev()
 *   wimax_dev_add()
 *   i2400m_dev_start()
 *     __i2400m_dev_start()
 *       i2400m_dev_bootstrap()

dev_bootstrap() is where the firmware is loaded. So, if something calls
get_drvinfo() from a register_netdevice_notifier (such as the cnic driver),
we won't have a firmware name, and strncpy will crash.

https://bugzilla.redhat.com/show_bug.cgi?id=808603

Signed-off-by: Bill Nottingham <notting@redhat.com>
---
 drivers/net/wimax/i2400m/netdev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 63e4b70..e44f4e2 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -597,7 +597,8 @@ static void i2400m_get_drvinfo(struct net_device *net_dev,
 	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 
 	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
-	strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
+	if (i2400m->fw_name)
+		strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
 	if (net_dev->dev.parent)
 		strncpy(info->bus_info, dev_name(net_dev->dev.parent),
 			sizeof(info->bus_info) - 1);
-- 
1.7.9.3
