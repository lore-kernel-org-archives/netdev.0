From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 3/6] MIPS: Octeon: Add platform devices MGMT Ethernet ports.
Date: Wed,  7 Oct 2009 16:10:12 -0700
Message-ID: <1254957015-7633-3-git-send-email-ddaney@caviumnetworks.com>
References: <4ACD1F4E.8090603@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4ACD1F4E.8090603@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 arch/mips/cavium-octeon/octeon-platform.c |   58 +++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-platform.c b/arch/mips/cavium-octeon/octeon-platform.c
index febfdd7..cfdb4c2 100644
--- a/arch/mips/cavium-octeon/octeon-platform.c
+++ b/arch/mips/cavium-octeon/octeon-platform.c
@@ -189,6 +189,64 @@ out:
 }
 device_initcall(octeon_mdiobus_device_init);
 
+/* Octeon mgmt port Ethernet interface.  */
+static int __init octeon_mgmt_device_init(void)
+{
+	struct platform_device *pd;
+	int ret = 0;
+	int port, num_ports;
+
+	struct resource mgmt_port_resource = {
+		.flags	= IORESOURCE_IRQ,
+		.start	= -1,
+		.end	= -1
+	};
+
+	if (!OCTEON_IS_MODEL(OCTEON_CN56XX) && !OCTEON_IS_MODEL(OCTEON_CN52XX))
+		return 0;
+
+	if (OCTEON_IS_MODEL(OCTEON_CN56XX))
+		num_ports = 1;
+	else
+		num_ports = 2;
+
+	for (port = 0; port < num_ports; port++) {
+		pd = platform_device_alloc("octeon_mgmt", port);
+		if (!pd) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		switch (port) {
+		case 0:
+			mgmt_port_resource.start = OCTEON_IRQ_MII0;
+			break;
+		case 1:
+			mgmt_port_resource.start = OCTEON_IRQ_MII1;
+			break;
+		default:
+			BUG();
+		}
+		mgmt_port_resource.end = mgmt_port_resource.start;
+
+		ret = platform_device_add_resources(pd, &mgmt_port_resource, 1);
+
+		if (ret)
+			goto fail;
+
+		ret = platform_device_add(pd);
+		if (ret)
+			goto fail;
+	}
+	return ret;
+fail:
+	platform_device_put(pd);
+
+out:
+	return ret;
+
+}
+device_initcall(octeon_mgmt_device_init);
+
 MODULE_AUTHOR("David Daney <ddaney@caviumnetworks.com>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Platform driver for Octeon SOC");
-- 
1.6.0.6
