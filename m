From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 08/14] rocker: set default world on port probe and clean world on remove
Date: Tue,  6 Oct 2015 09:51:47 +0200
Message-ID: <1444117913-10386-9-git-send-email-jiri@resnulli.us>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34146 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbbJFHwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:52:08 -0400
Received: by wicfx3 with SMTP id fx3so153285196wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:52:07 -0700 (PDT)
In-Reply-To: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, there is only OF-DPA world supported in HW. So make this
would the default one for newly created rocker ports.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - s/__rocker_port_change_world/rocker_port_change_world/
---
 drivers/net/ethernet/rocker/rocker_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 55e8ed6..10fa7df 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2175,6 +2175,7 @@ static struct rocker_world_ops *rocker_world_ops[] = {
 };
 
 #define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
+#define ROCKER_DEFAULT_WORLD_OPS rocker_world_ops[0]
 
 struct rocker_world {
 	struct list_head list;
@@ -5198,6 +5199,7 @@ static void rocker_remove_ports(const struct rocker *rocker)
 			continue;
 		rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
+		rocker_port_change_world(rocker_port, NULL);
 		free_netdev(rocker_port->dev);
 	}
 	kfree(rocker->ports);
@@ -5248,6 +5250,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_SG;
 
+	err = rocker_port_change_world(rocker_port, ROCKER_DEFAULT_WORLD_OPS);
+	if (err) {
+		dev_err(&pdev->dev, "failed to set default world\n");
+		goto err_port_change_world;
+	}
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "register_netdev failed\n");
@@ -5282,6 +5290,8 @@ err_port_ig_tbl:
 	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
 err_register_netdev:
+	rocker_port_change_world(rocker_port, NULL);
+err_port_change_world:
 	free_netdev(dev);
 	return err;
 }
-- 
1.9.3
