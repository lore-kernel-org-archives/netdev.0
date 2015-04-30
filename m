From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 1/8] net: dsa: Move dsa_switch_tree final setup in separate function
Date: Wed, 29 Apr 2015 18:57:37 -0700
Message-ID: <1430359064-23454-2-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36079 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbD3B6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:01 -0400
Received: by pabsx10 with SMTP id sx10so44531102pab.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:01 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing a different API to register DSA switches,
move the end portion of dsa_setup_dst(), which binds a net_device with
its dsa_ptr, and setups the optional link polling routine into
dsa_setup_dst_end().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 079a224471e7..58b99ff4591b 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -702,6 +702,26 @@ static inline void dsa_of_remove(struct device *dev)
 }
 #endif
 
+static void dsa_setup_dst_end(struct net_device *dev, struct dsa_switch_tree *dst)
+{
+	/*
+	 * If we use a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point on get
+	 * sent to the tag format's receive function.
+	 */
+	wmb();
+	dev->dsa_ptr = (void *)dst;
+
+	if (dst->link_poll_needed) {
+		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
+		init_timer(&dst->link_poll_timer);
+		dst->link_poll_timer.data = (unsigned long)dst;
+		dst->link_poll_timer.function = dsa_link_poll_timer;
+		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
+		add_timer(&dst->link_poll_timer);
+	}
+}
+
 static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			  struct device *parent, struct dsa_platform_data *pd)
 {
@@ -727,22 +747,7 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			dst->link_poll_needed = 1;
 	}
 
-	/*
-	 * If we use a tagging format that doesn't have an ethertype
-	 * field, make sure that all packets from this point on get
-	 * sent to the tag format's receive function.
-	 */
-	wmb();
-	dev->dsa_ptr = (void *)dst;
-
-	if (dst->link_poll_needed) {
-		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-		init_timer(&dst->link_poll_timer);
-		dst->link_poll_timer.data = (unsigned long)dst;
-		dst->link_poll_timer.function = dsa_link_poll_timer;
-		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&dst->link_poll_timer);
-	}
+	dsa_setup_dst_end(dev, dst);
 }
 
 static int dsa_probe(struct platform_device *pdev)
-- 
2.1.0
