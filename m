From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V4 PATCH 4/6] device property: Introduces device_dma_is_coherent()
Date: Fri, 15 May 2015 16:23:12 -0500
Message-ID: <1431724994-21601-5-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	"Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <bhelgaas@google.com>,
	<thomas.lendacky@amd.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0143.outbound.protection.outlook.com ([207.46.100.143]:37088
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946049AbbEOVX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 17:23:57 -0400
In-Reply-To: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, device drivers, which support both OF and ACPI,
need to call two separate APIs, of_dma_is_coherent() and
acpi_dma_is_coherent()) to determine device coherency attribute.

This patch simplifies this process by introducing a new device
property API, device_dma_is_coherent(), which calls the appropriate
interface based on the booting architecture.

Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
CC: Rafael J. Wysocki <rjw@rjwysocki.net>
---
 drivers/base/property.c  | 12 ++++++++++++
 include/linux/property.h |  2 ++
 2 files changed, 14 insertions(+)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index 1d0b116..8123c6e 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -14,6 +14,7 @@
 #include <linux/export.h>
 #include <linux/kernel.h>
 #include <linux/of.h>
+#include <linux/of_address.h>
 #include <linux/property.h>
 
 /**
@@ -519,3 +520,14 @@ unsigned int device_get_child_node_count(struct device *dev)
 	return count;
 }
 EXPORT_SYMBOL_GPL(device_get_child_node_count);
+
+bool device_dma_is_coherent(struct device *dev)
+{
+	if (IS_ENABLED(CONFIG_OF) && dev->of_node)
+		return of_dma_is_coherent(dev->of_node);
+	else if (has_acpi_companion(dev))
+		return acpi_dma_is_coherent(acpi_node(dev->fwnode));
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(device_dma_is_coherent);
diff --git a/include/linux/property.h b/include/linux/property.h
index de8bdf4..76ebde9 100644
--- a/include/linux/property.h
+++ b/include/linux/property.h
@@ -164,4 +164,6 @@ struct property_set {
 
 void device_add_property_set(struct device *dev, struct property_set *pset);
 
+bool device_dma_is_coherent(struct device *dev);
+
 #endif /* _LINUX_PROPERTY_H_ */
-- 
2.1.0
