From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH] try parent numa_node at first before using default v2
Date: Fri, 13 Jul 2007 12:27:05 -0700
Message-ID: <200707131227.07856.yinghai.lu@sun.com>
References: <200707101641.17672.yinghai.lu@sun.com>
 <200707121059.54320.yinghai.lu@sun.com>
 <20070713074806.6a641528@gondolin.boeblingen.de.ibm.com>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:61520 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759669AbXGMTXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 15:23:45 -0400
In-reply-to: <20070713074806.6a641528@gondolin.boeblingen.de.ibm.com>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] try parent numa_node at first before using default v2

For pci_device, pcibios_scan_root and pci_scan_root will call pci_device_add.
pci_device_add will call device_initialize and set_dev_node(&dev->dev,
pcibus_to_node(bus)).
other device such as netdev, and usb_device, set_dev_node is never be
used. So that field numa_node always is -1.

So for netdev, it will need to use dev->parent to get pci_device to
use it's numa_node. esp in netdev_alloc_skb()
not sure how other device such as infiniband do that.

Actually before patch
[PATCH 1/2] x86_64: get mp_bus_to_node as early
there is a bug about squence of bus->sysdata and using pcibus_to_node.
the numa_node of pci_dev->dev is never set correctly...always 0.

So some device have to use pcibus_to_node(to_pci_dev(dev)->bus) directly
such as dma_alloc_pages in arch/x86_64/kernel/pci-dma.c.
or hwif_to_node in include/linux/ide.h

According to Stefan Richter
  - Change all subsystems to set dev->parent before device_initialize().
    *Document* that the device_initialize() API has this requirement.
    This is counter-intuitive, amounts to some work across the kernel,
    and could be gotten wrong again in future code because it's a
    counter-intuitive API.

  - Move your code from device_initialize() to device_add().  One minor
    drawback is that node-specific allocations based on the device's
    numa_node would not be optimized before device_add(), but there is
    probably no need for this.  Driver probes come after device_add().

  - Let subsystems explicitly call set_dev_node() on their own.

this patch is using second method.

Also we don't need call set_dev_node in pci_device_add anymore. but need to
make sure every pci root bus's bridge device numa is set.

with this patch, we could use device->numa_node direclty for all device.

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index e48fcf0..c029ffc 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -935,7 +938,6 @@ void pci_device_add(struct pci_dev *dev, struct pci_bus *bus)
 	dev->dev.release = pci_release_dev;
 	pci_dev_get(dev);
 
-	set_dev_node(&dev->dev, pcibus_to_node(bus));
 	dev->dev.dma_mask = &dev->dma_mask;
 	dev->dev.coherent_dma_mask = 0xffffffffull;
 
@@ -1096,6 +1098,9 @@ struct pci_bus * pci_create_bus(struct device *parent,
 		goto dev_reg_err;
 	b->bridge = get_device(dev);
 
+	if (!parent)
+		set_dev_node(b->bridge, pcibus_to_node(b));
+
 	b->class_dev.class = &pcibus_class;
 	sprintf(b->class_dev.class_id, "%04x:%02x", pci_domain_nr(b), bus);
 	error = class_device_register(&b->class_dev);
diff --git a/drivers/base/core.c b/drivers/base/core.c
index 0455aa7..d8b063b 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -672,6 +672,11 @@ int device_add(struct device *dev)
 	if (error)
 		goto Error;
 
+	/* use parent numa_node */
+	if (parent) {
+		set_dev_node(dev, dev_to_node(parent));
+	}
+
 	/* first, register with generic layer. */
 	kobject_set_name(&dev->kobj, "%s", dev->bus_id);
 	error = kobject_add(&dev->kobj);
@@ -1269,8 +1274,11 @@ int device_move(struct device *dev, struct device *new_parent)
 	dev->parent = new_parent;
 	if (old_parent)
 		klist_remove(&dev->knode_parent);
-	if (new_parent)
+	if (new_parent) {
 		klist_add_tail(&dev->knode_parent, &new_parent->klist_children);
+		set_dev_node(dev, dev_to_node(new_parent));
+	}
+
 	if (!dev->class)
 		goto out_put;
 	error = device_move_class_links(dev, old_parent, new_parent);
@@ -1280,9 +1288,12 @@ int device_move(struct device *dev, struct device *new_parent)
 		if (!kobject_move(&dev->kobj, &old_parent->kobj)) {
 			if (new_parent)
 				klist_remove(&dev->knode_parent);
-			if (old_parent)
+			dev->parent = old_parent;
+			if (old_parent) {
 				klist_add_tail(&dev->knode_parent,
 					       &old_parent->klist_children);
+				set_dev_node(dev, dev_to_node(old_parent));
+			}
 		}
 		put_device(new_parent);
 		goto out;
