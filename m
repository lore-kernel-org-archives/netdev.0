From: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH RESEND v3 9/9] net: fix net_device refcounting
Date: Thu, 24 Sep 2015 20:36:33 +0100
Message-ID: <E1ZfCJl-0004S9-Qq@rmk-PC.arm.linux.org.uk>
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

of_find_net_device_by_node() uses class_find_device() internally to
lookup the corresponding network device.  class_find_device() returns
a reference to the embedded struct device, with its refcount
incremented.

Add a comment to the definition in net/core/net-sysfs.c indicating the
need to drop this refcount, and fix the DSA code to drop this refcount
when the OF-generated platform data is cleaned up and freed.  Also
arrange for the ref to be dropped when handling errors.

Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
---
 net/core/net-sysfs.c | 9 +++++++++
 net/dsa/dsa.c        | 5 ++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b279077c3089..805a95a48107 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1481,6 +1481,15 @@ static int of_dev_node_match(struct device *dev, const void *data)
 	return ret == 0 ? dev->of_node == data : ret;
 }
 
+/*
+ * of_find_net_device_by_node - lookup the net device for the device node
+ * @np: OF device node
+ *
+ * Looks up the net_device structure corresponding with the device node.
+ * If successful, returns a pointer to the net_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure. The
+ * refcount must be dropped when done with the net_device.
+ */
 struct net_device *of_find_net_device_by_node(struct device_node *np)
 {
 	struct device *dev;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index bf4ba15fb780..c59fa5d9c22c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -679,7 +679,7 @@ static int dsa_of_probe(struct device *dev)
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (!pd) {
 		ret = -ENOMEM;
-		goto out_put_mdio;
+		goto out_put_ethernet;
 	}
 
 	dev->platform_data = pd;
@@ -773,6 +773,8 @@ static int dsa_of_probe(struct device *dev)
 out_free:
 	kfree(pd);
 	dev->platform_data = NULL;
+out_put_ethernet:
+	put_device(&ethernet_dev->dev);
 out_put_mdio:
 	put_device(&mdio_bus->dev);
 	return ret;
@@ -786,6 +788,7 @@ static void dsa_of_remove(struct device *dev)
 		return;
 
 	dsa_of_free_platform_data(pd);
+	put_device(&pd->of_netdev->dev);
 	kfree(pd);
 }
 #else
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
