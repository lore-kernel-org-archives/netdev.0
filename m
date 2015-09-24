From: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH RESEND v3 2/9] net: dsa: fix of_mdio_find_bus() device
 refcount leak
Date: Thu, 24 Sep 2015 20:35:57 +0100
Message-ID: <E1ZfCJB-0004PG-Qa@rmk-PC.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Robert Richter <rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Soren Brinkmann" <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Sunil Goutham <sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150922161710.GA21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
