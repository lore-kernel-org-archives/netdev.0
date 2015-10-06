From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 5/5] net: dsa: exit probe if no switch were found
Date: Tue, 6 Oct 2015 15:40:43 +0100
Message-ID: <5613DD6B.5050404@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If no switch were found in dsa_setup_dst, return -ENODEV and
exit the dsa_probe cleanly.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d5a162c..adb5325 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -837,10 +837,11 @@ static inline void dsa_of_remove(struct device *dev)
 }
 #endif

-static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
-			  struct device *parent, struct dsa_platform_data *pd)
+static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
+			 struct device *parent, struct dsa_platform_data *pd)
 {
 	int i;
+	unsigned configured = 0;

 	dst->pd = pd;
 	dst->master_netdev = dev;
@@ -860,9 +861,17 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
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
+		return -EPROBE_DEFER;
+
+	/*
 	 * If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
@@ -878,6 +887,8 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
 		add_timer(&dst->link_poll_timer);
 	}
+
+	return 0;
 }

 static int dsa_probe(struct platform_device *pdev)
@@ -927,7 +938,9 @@ static int dsa_probe(struct platform_device *pdev)

 	platform_set_drvdata(pdev, dst);

-	dsa_setup_dst(dst, dev, &pdev->dev, pd);
+	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
+	if (ret)
+		goto out;

 	return 0;

-- 
1.9.1
