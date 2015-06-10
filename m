From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V6 PATCH 3/7] device property: Introduces device_dma_is_coherent()
Date: Wed, 10 Jun 2015 11:08:54 -0500
Message-ID: <1433952538-22455-4-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1433952538-22455-1-git-send-email-Suravee.Suthikulpanit@amd.com>
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
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<arnd@arndb.de>, <kashyap.desai@avagotech.com>,
	<sumit.saxena@avagotech.com>, <uday.lingala@avagotech.com>,
	<vinholikatti@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1433952538-22455-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, device drivers, which support both OF and ACPI,
need to call two separate APIs, of_dma_is_coherent() and
acpi_dma_is_coherent()) to determine device coherency attribute.

This patch simplifies this process by introducing a new device
property API, device_dma_is_coherent(), which calls the appropriate
interface based on the booting architecture.

Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
---
 drivers/base/property.c  | 14 ++++++++++++++
 include/linux/property.h |  2 ++
 2 files changed, 16 insertions(+)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index 1d0b116..e645852 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -14,6 +14,7 @@
 #include <linux/export.h>
 #include <linux/kernel.h>
 #include <linux/of.h>
+#include <linux/of_address.h>
 #include <linux/property.h>
 
 /**
@@ -519,3 +520,16 @@ unsigned int device_get_child_node_count(struct device *dev)
 	return count;
 }
 EXPORT_SYMBOL_GPL(device_get_child_node_count);
+
+bool device_dma_is_coherent(struct device *dev)
+{
+	bool coherent = false;
+
+	if (IS_ENABLED(CONFIG_OF) && dev->of_node)
+		coherent = of_dma_is_coherent(dev->of_node);
+	else
+		acpi_check_dma(ACPI_COMPANION(dev), &coherent);
+
+	return coherent;
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
