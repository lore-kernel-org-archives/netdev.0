From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 3/3] net: dsa: exit probe if no switch were found
Date: Wed, 30 Sep 2015 10:21:16 +0200
Message-ID: <560B9B7C.9080406@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34267 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbbI3IVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 04:21:23 -0400
Received: by wicfx3 with SMTP id fx3so184987311wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 01:21:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no switch were found in dsa_setup_dst, return -ENODEV and
exit the dsa_probe cleanly.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0c104af..6ae1ab9 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -844,10 +844,11 @@ static inline void dsa_of_remove(struct device *dev)
 }
 #endif

-static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
+static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			  struct device *parent, struct dsa_platform_data *pd)
 {
 	int i;
+	unsigned configured = 0;

 	dst->pd = pd;
 	dst->master_netdev = dev;
@@ -867,9 +868,17 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		dst->ds[i] = ds;
 		if (ds->drv->poll_link != NULL)
 			dst->link_poll_needed = 1;
+
+		++configured;
 	}

 	/*
+	 * If no switch was found, exit cleanly
+	 */
+	if (!configured)
+		return -ENODEV;
+
+	/*
 	 * If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
@@ -885,6 +894,8 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
 		add_timer(&dst->link_poll_timer);
 	}
+
+	return 0;
 }

 static int dsa_probe(struct platform_device *pdev)
@@ -934,9 +945,9 @@ static int dsa_probe(struct platform_device *pdev)

 	platform_set_drvdata(pdev, dst);

-	dsa_setup_dst(dst, dev, &pdev->dev, pd);
-
-	return 0;
+	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
+	if (!ret)
+		return 0;

 out:
 	dsa_of_remove(&pdev->dev);
-- 
1.9.1
