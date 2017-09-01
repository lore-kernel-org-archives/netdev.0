From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 5/5] net: mdio-mux: fix unbalanced put_device
Date: Fri,  1 Sep 2017 13:56:04 +0200
Message-ID: <20170901115604.27513-6-clabbe.montjoie@gmail.com>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mdio_mux_uninit() call put_device (unconditionally) because of
of_mdio_find_bus() in mdio_mux_init.
But of_mdio_find_bus is only called if mux_bus is empty.
If mux_bus is set, mdio_mux_uninit will print a "refcount_t: underflow"
trace.

This patch add a get_device in the other branch of "if (mux_bus)".

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/phy/mdio-mux.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 282828551bdd..6f75e9f27fed 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -116,6 +116,7 @@ int mdio_mux_init(struct device *dev,
 	} else {
 		parent_bus_node = NULL;
 		parent_bus = mux_bus;
+		get_device(&parent_bus->dev);
 	}
 
 	pb = devm_kzalloc(dev, sizeof(*pb), GFP_KERNEL);
@@ -184,9 +185,7 @@ int mdio_mux_init(struct device *dev,
 	dev_err(dev, "Error: No acceptable child buses found\n");
 	devm_kfree(dev, pb);
 err_pb_kz:
-	/* balance the reference of_mdio_find_bus() took */
-	if (!mux_bus)
-		put_device(&parent_bus->dev);
+	put_device(&parent_bus->dev);
 err_parent_bus:
 	of_node_put(parent_bus_node);
 	return ret_val;
@@ -204,7 +203,6 @@ void mdio_mux_uninit(void *mux_handle)
 		cb = cb->next;
 	}
 
-	/* balance the reference of_mdio_find_bus() in mdio_mux_init() took */
 	put_device(&pb->mii_bus->dev);
 }
 EXPORT_SYMBOL_GPL(mdio_mux_uninit);
-- 
2.13.5
