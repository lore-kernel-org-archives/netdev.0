From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH 3/4] drivers/net: enic: Make ASIC information available to USNIC
Date: Fri,  9 Aug 2013 11:38:54 -0700
Message-ID: <1376073535-17154-4-git-send-email-neepatel@cisco.com>
References: <1376073535-17154-1-git-send-email-neepatel@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:5390 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968068Ab3HISi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:38:59 -0400
In-Reply-To: <1376073535-17154-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides asic information via ethtool.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/ethernet/cisco/enic/driver_utils.h | 49 ++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  4 +++
 2 files changed, 53 insertions(+)
 create mode 100644 drivers/net/ethernet/cisco/enic/driver_utils.h

diff --git a/drivers/net/ethernet/cisco/enic/driver_utils.h b/drivers/net/ethernet/cisco/enic/driver_utils.h
new file mode 100644
index 0000000..e654b4d
--- /dev/null
+++ b/drivers/net/ethernet/cisco/enic/driver_utils.h
@@ -0,0 +1,49 @@
+/**
+ * Copyright 2013 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __DRIVER_UTILS_H__
+#define __DRIVER_UTILS_H__
+
+#include <linux/string.h>
+
+static inline int driver_encode_asic_info(char *str, int strlen, u16 asic_type,
+				u16 asic_rev)
+{
+	if (strlen < sizeof(asic_type) + sizeof(asic_rev))
+		return -EINVAL;
+
+	memcpy(str, &asic_type, sizeof(asic_type));
+	memcpy(str + sizeof(asic_type), &asic_rev, sizeof(asic_rev));
+
+	return 0;
+}
+
+static inline int driver_decode_asic_info(char *str, int strlen, u16 *asic_type,
+						u16 *asic_rev)
+{
+	if (strlen < sizeof(*asic_type) + sizeof(*asic_rev))
+		return -EINVAL;
+
+	if (asic_type)
+		memcpy(asic_type, str, sizeof(*asic_type));
+	if (asic_rev)
+		memcpy(asic_rev, str + sizeof(*asic_type), sizeof(*asic_rev));
+	return 0;
+}
+
+#endif /*!__DRIVER_UTILS_H__*/
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 47e3562..c5d938a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -19,6 +19,7 @@
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 
+#include "driver_utils.h"
 #include "enic_res.h"
 #include "enic.h"
 #include "enic_dev.h"
@@ -116,6 +117,9 @@ static void enic_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
 		sizeof(drvinfo->bus_info));
+	memset(drvinfo->reserved1, 0, sizeof(drvinfo->reserved1));
+	driver_encode_asic_info(drvinfo->reserved1, sizeof(drvinfo->reserved1),
+		fw_info->asic_type, fw_info->asic_rev);
 }
 
 static void enic_get_strings(struct net_device *netdev, u32 stringset,
-- 
1.8.4-rc0
