From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/14] rocker: set default world on port probe and clean world on remove
Date: Sun,  4 Oct 2015 23:25:43 +0200
Message-ID: <1443993949-3915-9-git-send-email-jiri@resnulli.us>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35802 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbJDV0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:26:03 -0400
Received: by wicge5 with SMTP id ge5so95546231wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 14:26:01 -0700 (PDT)
In-Reply-To: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, there is only OF-DPA world supported in HW. So make this
would the default one for newly created rocker ports.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index e00c831..2dda7f9 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2175,6 +2175,7 @@ static struct rocker_world_ops *rocker_world_ops[] = {
 };
 
 #define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
+#define ROCKER_DEFAULT_WORLD_OPS rocker_world_ops[0]
 
 static const struct rocker_world_ops *__rocker_world_ops_find(const char *kind)
 {
@@ -5242,6 +5243,7 @@ static void rocker_remove_ports(const struct rocker *rocker)
 			continue;
 		rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
+		__rocker_port_change_world(rocker_port, NULL);
 		free_netdev(rocker_port->dev);
 	}
 	kfree(rocker->ports);
@@ -5292,6 +5294,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_SG;
 
+	err = __rocker_port_change_world(rocker_port, ROCKER_DEFAULT_WORLD_OPS);
+	if (err) {
+		dev_err(&pdev->dev, "failed to set default world\n");
+		goto err_port_change_world;
+	}
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "register_netdev failed\n");
@@ -5326,6 +5334,8 @@ err_port_ig_tbl:
 	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
 err_register_netdev:
+	__rocker_port_change_world(rocker_port, NULL);
+err_port_change_world:
 	free_netdev(dev);
 	return err;
 }
-- 
1.9.3
