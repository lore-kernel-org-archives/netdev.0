From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 5/5] net: mdio-mux: fix unbalanced put_device
Date: Wed, 30 Aug 2017 19:46:51 +0200
Message-ID: <20170830174651.30325-6-clabbe.montjoie@gmail.com>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35064 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdH3RtF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:49:05 -0400
In-Reply-To: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdio_mux_uninit() call put_device (unconditionally) because of
of_mdio_find_bus() in mdio_mux_init.
But of_mdio_find_bus is only called if mux_bus is empty.
If mux_bus is set, mdio_mux_uninit will print a "refcount_t: underflow"
trace.

This patch add a get_device in the other branch of "if (mux_bus)".

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/phy/mdio-mux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 9a889a529b9c..0b7d3d30ae97 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -117,6 +117,7 @@ int mdio_mux_init(struct device *dev,
 	} else {
 		parent_bus_node = NULL;
 		parent_bus = mux_bus;
+		get_device(&parent_bus->dev);
 	}
 
 	pb = devm_kzalloc(dev, sizeof(*pb), GFP_KERNEL);
@@ -186,8 +187,7 @@ int mdio_mux_init(struct device *dev,
 	devm_kfree(dev, pb);
 err_pb_kz:
 	/* balance the reference of_mdio_find_bus() took */
-	if (!mux_bus)
-		put_device(&parent_bus->dev);
+	put_device(&parent_bus->dev);
 err_parent_bus:
 	of_node_put(parent_bus_node);
 	return ret_val;
-- 
2.13.5
