From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 2/9] net: dsa: fix of_mdio_find_bus() device refcount leak
Date: Tue, 22 Sep 2015 17:18:07 +0100
Message-ID: <E1ZeQGd-0006XT-VN@rmk-PC.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:39587 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932920AbbIVQSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:18:16 -0400
In-Reply-To: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current users of of_mdio_find_bus() leak a struct device refcount, as
they fail to clean up the reference obtained inside class_find_device().

Fix the DSA code to properly refcount the returned MDIO bus by:
1. taking a reference on the struct device whenever we assign it to
   pd->chip[x].host_dev.
2. dropping the reference when we overwrite the existing reference.
3. dropping the reference when we free the data structure.
4. dropping the initial reference we obtained after setting up the
   platform data structure, or on failure.

In step 2 above, where we obtain a new MDIO bus, there is no need to
take a reference on it as we would only have to drop it immediately
after assignment again, iow:

	put_device(cd->host_dev);	/* drop original assignment ref */
	cd->host_dev = get_device(&mdio_bus_switch->dev); /* get our ref */
	put_device(&mdio_bus_switch->dev); /* drop of_mdio_find_bus ref */

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 net/dsa/dsa.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 76e3800765f8..bf4ba15fb780 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -634,6 +634,10 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 			port_index++;
 		}
 		kfree(pd->chip[i].rtable);
+
+		/* Drop our reference to the MDIO bus device */
+		if (pd->chip[i].host_dev)
+			put_device(pd->chip[i].host_dev);
 	}
 	kfree(pd->chip);
 }
@@ -661,16 +665,22 @@ static int dsa_of_probe(struct device *dev)
 		return -EPROBE_DEFER;
 
 	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
-	if (!ethernet)
-		return -EINVAL;
+	if (!ethernet) {
+		ret = -EINVAL;
+		goto out_put_mdio;
+	}
 
 	ethernet_dev = of_find_net_device_by_node(ethernet);
-	if (!ethernet_dev)
-		return -EPROBE_DEFER;
+	if (!ethernet_dev) {
+		ret = -EPROBE_DEFER;
+		goto out_put_mdio;
+	}
 
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
-	if (!pd)
-		return -ENOMEM;
+	if (!pd) {
+		ret = -ENOMEM;
+		goto out_put_mdio;
+	}
 
 	dev->platform_data = pd;
 	pd->of_netdev = ethernet_dev;
@@ -691,7 +701,9 @@ static int dsa_of_probe(struct device *dev)
 		cd = &pd->chip[chip_index];
 
 		cd->of_node = child;
-		cd->host_dev = &mdio_bus->dev;
+
+		/* When assigning the host device, increment its refcount */
+		cd->host_dev = get_device(&mdio_bus->dev);
 
 		sw_addr = of_get_property(child, "reg", NULL);
 		if (!sw_addr)
@@ -711,6 +723,12 @@ static int dsa_of_probe(struct device *dev)
 				ret = -EPROBE_DEFER;
 				goto out_free_chip;
 			}
+
+			/* Drop the mdio_bus device ref, replacing the host
+			 * device with the mdio_bus_switch device, keeping
+			 * the refcount from of_mdio_find_bus() above.
+			 */
+			put_device(cd->host_dev);
 			cd->host_dev = &mdio_bus_switch->dev;
 		}
 
@@ -744,6 +762,10 @@ static int dsa_of_probe(struct device *dev)
 		}
 	}
 
+	/* The individual chips hold their own refcount on the mdio bus,
+	 * so drop ours */
+	put_device(&mdio_bus->dev);
+
 	return 0;
 
 out_free_chip:
@@ -751,6 +773,8 @@ static int dsa_of_probe(struct device *dev)
 out_free:
 	kfree(pd);
 	dev->platform_data = NULL;
+out_put_mdio:
+	put_device(&mdio_bus->dev);
 	return ret;
 }
 
-- 
2.1.0
