From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 3/7] net: netcp: move netcp_register_interface() to after attach module
Date: Wed, 23 Sep 2015 13:37:07 -0400
Message-ID: <1443029831-22035-4-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netcp interface is not fully initialized before attach the module
to the interface. For example, the tx pipe/rx pipe is initialized
in ethss module as part of attach(). So until this is complete, the
interface can't be registered.  So move registration of interface to
net device outside the current loop that attaches the modules to the
interface.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c0bc4b9..cf693de 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -291,13 +291,6 @@ static int netcp_module_probe(struct netcp_device *netcp_device,
 			    interface_list) {
 		struct netcp_intf_modpriv *intf_modpriv;
 
-		/* If interface not registered then register now */
-		if (!netcp_intf->netdev_registered)
-			ret = netcp_register_interface(netcp_intf);
-
-		if (ret)
-			return -ENODEV;
-
 		intf_modpriv = devm_kzalloc(dev, sizeof(*intf_modpriv),
 					    GFP_KERNEL);
 		if (!intf_modpriv)
@@ -323,6 +316,18 @@ static int netcp_module_probe(struct netcp_device *netcp_device,
 			continue;
 		}
 	}
+
+	/* Now register the interface with netdev */
+	list_for_each_entry(netcp_intf,
+			    &netcp_device->interface_head,
+			    interface_list) {
+		/* If interface not registered then register now */
+		if (!netcp_intf->netdev_registered) {
+			ret = netcp_register_interface(netcp_intf);
+			if (ret)
+				return -ENODEV;
+		}
+	}
 	return 0;
 }
 
-- 
1.9.1
