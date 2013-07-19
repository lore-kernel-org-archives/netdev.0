From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [RFC] qlcnic: Enhance ethtool to display board temperature.
Date: Thu, 18 Jul 2013 23:57:17 -0400
Message-ID: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:50561 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752774Ab3GSEYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 00:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

We need to provide a mechanism for a user space application to query
adapter temperature. This RFC patch is to request input on which of the
following approach would be appropriate way to export this information.

Here are the two approaches that I am exploring. Please review and
provide your recommendation.

1. Enhance ethtool to add capability for driver to advertise its
   board temperature as part of "ethtool -i <ethX>"

    For example, following would be output for an interface which
    has board temperature field populated via ethtool

    "#ethtool -i p10p1"
    driver: qlcnic
    version: 5.2.44
    bus-info: 0000:08:00.0
    supports-statistics: yes
    supports-test: yes
    supports-eeprom-access: yes
    supports-register-dump: yes
    supports-priv-flags: no
    board-temperature: 34

    There will be update required for ethtool.c in the repository
    git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
    maintained by Ben Hutchings.

    if we decide to go with ethtool modification approach, I will send
    patch to update ethtool repository. Attached patch at the end of this
    email is for driver implementation for this approach.

2. Add a sysfs hook "brd_temp" which will be used by the application
   to query board temperature specific to the particular interface

   for example, driver with "brd_temp" sysfs hook will show temperature

   "#cat /sys/class/net/p10p1/device/brd_temp"
   34

Thank you for the comments.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 7 +++++++
 include/uapi/linux/ethtool.h                        | 1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 700a463..5335a71 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -235,6 +235,7 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 fw_major, fw_minor, fw_build;
+	u32 temp_val = 0;
 	fw_major = QLC_SHARED_REG_RD32(adapter, QLCNIC_FW_VERSION_MAJOR);
 	fw_minor = QLC_SHARED_REG_RD32(adapter, QLCNIC_FW_VERSION_MINOR);
 	fw_build = QLC_SHARED_REG_RD32(adapter, QLCNIC_FW_VERSION_SUB);
@@ -246,6 +247,12 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	strlcpy(drvinfo->driver, qlcnic_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, QLCNIC_LINUX_VERSIONID,
 		sizeof(drvinfo->version));
+	if (qlcnic_82xx_check(adapter))
+		temp_val = QLC_SHARED_REG_RD32(adapter, QLCNIC_ASIC_TEMP);
+	else if (qlcnic_83xx_check(adapter))
+		temp_val = QLCRDX(adapter->ahw, QLC_83XX_ASIC_TEMP);
+
+	drvinfo->board_temp = qlcnic_get_temp_val(temp_val);
 }
 
 static int
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 38dbafa..2012015 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -101,6 +101,7 @@ struct ethtool_drvinfo {
 	__u32	testinfo_len;
 	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
 	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
+	__u32	board_temp;     /* board temperature */
 };
 
 #define SOPASS_MAX	6
-- 
1.8.1.4
