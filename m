From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: utilize of_find_net_device_by_node
Date: Mon,  9 Mar 2015 12:02:30 -0700
Message-ID: <1425927750-23901-3-git-send-email-f.fainelli@gmail.com>
References: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:44434 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803AbbCITDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:03:19 -0400
Received: by padet14 with SMTP id et14so50826136pad.11
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 12:03:19 -0700 (PDT)
In-Reply-To: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using of_find_device_by_node() restricts the search to platform_device that
match the specified device_node pointer. This is not even remotely true for
network devices backed by a pci_device for instance.

of_find_net_device_by_node() allows us to do a more thorough lookup to find the
struct net_device corresponding to a particular device_node pointer.

For symetry with the non-OF code path, we hold the net_device pointer in
dsa_probe() just like what dev_to_net_dev() does when we call this
function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  1 +
 net/dsa/dsa.c     | 16 +++++++++++-----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b525ac516559..47917e5e1e12 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -72,6 +72,7 @@ struct dsa_platform_data {
 	 * to the root switch chip of the tree.
 	 */
 	struct device	*netdev;
+	struct net_device *of_netdev;
 
 	/*
 	 * Info structs describing each of the switch chips
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b40f11bb419c..899772108ee3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -20,6 +20,7 @@
 #include <linux/of.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
+#include <linux/of_net.h>
 #include <linux/sysfs.h>
 #include "dsa_priv.h"
 
@@ -583,7 +584,7 @@ static int dsa_of_probe(struct device *dev)
 	struct device_node *np = dev->of_node;
 	struct device_node *child, *mdio, *ethernet, *port, *link;
 	struct mii_bus *mdio_bus;
-	struct platform_device *ethernet_dev;
+	struct net_device *ethernet_dev;
 	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
 	const char *port_name;
@@ -604,7 +605,7 @@ static int dsa_of_probe(struct device *dev)
 	if (!ethernet)
 		return -EINVAL;
 
-	ethernet_dev = of_find_device_by_node(ethernet);
+	ethernet_dev = of_find_net_device_by_node(ethernet);
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
@@ -613,7 +614,7 @@ static int dsa_of_probe(struct device *dev)
 		return -ENOMEM;
 
 	dev->platform_data = pd;
-	pd->netdev = &ethernet_dev->dev;
+	pd->of_netdev = ethernet_dev;
 	pd->nr_chips = of_get_available_child_count(np);
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
 		pd->nr_chips = DSA_MAX_SWITCHES;
@@ -771,10 +772,15 @@ static int dsa_probe(struct platform_device *pdev)
 		pd = pdev->dev.platform_data;
 	}
 
-	if (pd == NULL || pd->netdev == NULL)
+	if (pd == NULL || (pd->netdev == NULL && pd->of_netdev == NULL))
 		return -EINVAL;
 
-	dev = dev_to_net_device(pd->netdev);
+	if (pd->of_netdev) {
+		dev = pd->of_netdev;
+		dev_hold(dev);
+	} else {
+		dev = dev_to_net_device(pd->netdev);
+	}
 	if (dev == NULL) {
 		ret = -EPROBE_DEFER;
 		goto out;
-- 
2.1.0
