From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH] net: gianfar: correctly determine the number of queue groups
Date: Thu, 5 Mar 2015 14:48:23 +0100
Message-ID: <20150305134800.GA23653@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:44628 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522AbbCENsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 08:48:41 -0500
Received: by lbiv13 with SMTP id v13so32595125lbi.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 05:48:39 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id yr17sm1286559lbb.33.2015.03.05.05.48.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 05:48:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eTSEC of-nodes may have children which are not queue-group nodes. For
example new-style fixed-phy declarations. These where incorrectly
assumed to be additional queue-groups.

Change the search to filter out any nodes which are not queue-groups,
or have been disabled.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 43df788..4e80def 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -747,6 +747,18 @@ static int gfar_parse_group(struct device_node *np,
 	return 0;
 }
 
+static int gfar_of_group_count(struct device_node *np)
+{
+	struct device_node *child;
+	int num = 0;
+
+	for_each_available_child_of_node(np, child)
+		if (!of_node_cmp(child->name, "queue-group"))
+			num++;
+
+	return num;
+}
+
 static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 {
 	const char *model;
@@ -784,7 +796,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		num_rx_qs = 1;
 	} else { /* MQ_MG_MODE */
 		/* get the actual number of supported groups */
-		unsigned int num_grps = of_get_available_child_count(np);
+		unsigned int num_grps = gfar_of_group_count(np);
 
 		if (num_grps == 0 || num_grps > MAXGROUPS) {
 			dev_err(&ofdev->dev, "Invalid # of int groups(%d)\n",
@@ -851,7 +863,10 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 
 	/* Parse and initialize group specific information */
 	if (priv->mode == MQ_MG_MODE) {
-		for_each_child_of_node(np, child) {
+		for_each_available_child_of_node(np, child) {
+			if (of_node_cmp(child->name, "queue-group"))
+				continue;
+
 			err = gfar_parse_group(child, priv, model);
 			if (err)
 				goto err_grp_init;
-- 
1.8.4.357.g8d83871.dirty
