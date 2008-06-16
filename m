From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 5/5] xen: Avoid allocations causing swap activity on the resume
 path
Date: Mon, 16 Jun 2008 14:45:08 -0700
Message-ID: <4856DEE4.40603@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>,
	NetDev <netdev@vger.kernel.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:45433 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758049AbYFPVpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 17:45:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>

Avoid allocations causing swap activity on the resume path by
preventing the allocations from doing IO and allowing them
to access the emergency pools.

These paths are used when a frontend device is trying to connect
to its backend driver over Xenbus.  These reconnections are triggered
on demand by IO, so by definition there is already IO underway,
and further IO would naturally deadlock.  On resume, this path
is triggered when the running system tries to continue using its
devices.  If it cannot then the resume will fail; to try to avoid this
we let it dip into the emergency pools.

[ linux-2.6.18-xen changesets e8b49cfbdac, fdb998e79aba ]

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 drivers/block/xen-blkfront.c       |    5 +++--
 drivers/net/xen-netfront.c         |    4 ++--
 drivers/xen/xenbus/xenbus_client.c |    2 +-
 drivers/xen/xenbus/xenbus_xs.c     |   10 +++++-----
 4 files changed, 11 insertions(+), 10 deletions(-)

===================================================================
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -584,7 +584,7 @@
 
 	info->ring_ref = GRANT_INVALID_REF;
 
-	sring = (struct blkif_sring *)__get_free_page(GFP_KERNEL);
+	sring = (struct blkif_sring *)__get_free_page(GFP_NOIO | __GFP_HIGH);
 	if (!sring) {
 		xenbus_dev_fatal(dev, -ENOMEM, "allocating shared ring");
 		return -ENOMEM;
@@ -741,7 +741,8 @@
 	int j;
 
 	/* Stage 1: Make a safe copy of the shadow state. */
-	copy = kmalloc(sizeof(info->shadow), GFP_KERNEL);
+	copy = kmalloc(sizeof(info->shadow),
+		       GFP_NOIO | __GFP_REPEAT | __GFP_HIGH);
 	if (!copy)
 		return -ENOMEM;
 	memcpy(copy, info->shadow, sizeof(info->shadow));
===================================================================
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1324,7 +1324,7 @@
 		goto fail;
 	}
 
-	txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_KERNEL);
+	txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
 	if (!txs) {
 		err = -ENOMEM;
 		xenbus_dev_fatal(dev, err, "allocating tx ring page");
@@ -1340,7 +1340,7 @@
 	}
 
 	info->tx_ring_ref = err;
-	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_KERNEL);
+	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
 	if (!rxs) {
 		err = -ENOMEM;
 		xenbus_dev_fatal(dev, err, "allocating rx ring page");
===================================================================
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -117,7 +117,7 @@
 	char *path;
 
 	va_start(ap, pathfmt);
-	path = kvasprintf(GFP_KERNEL, pathfmt, ap);
+	path = kvasprintf(GFP_NOIO | __GFP_HIGH, pathfmt, ap);
 	va_end(ap);
 
 	if (!path) {
===================================================================
--- a/drivers/xen/xenbus/xenbus_xs.c
+++ b/drivers/xen/xenbus/xenbus_xs.c
@@ -283,9 +283,9 @@
 	char *buffer;
 
 	if (strlen(name) == 0)
-		buffer = kasprintf(GFP_KERNEL, "%s", dir);
+		buffer = kasprintf(GFP_NOIO | __GFP_HIGH, "%s", dir);
 	else
-		buffer = kasprintf(GFP_KERNEL, "%s/%s", dir, name);
+		buffer = kasprintf(GFP_NOIO | __GFP_HIGH, "%s/%s", dir, name);
 	return (!buffer) ? ERR_PTR(-ENOMEM) : buffer;
 }
 
@@ -297,7 +297,7 @@
 	*num = count_strings(strings, len);
 
 	/* Transfer to one big alloc for easy freeing. */
-	ret = kmalloc(*num * sizeof(char *) + len, GFP_KERNEL);
+	ret = kmalloc(*num * sizeof(char *) + len, GFP_NOIO | __GFP_HIGH);
 	if (!ret) {
 		kfree(strings);
 		return ERR_PTR(-ENOMEM);
@@ -751,7 +751,7 @@
 	}
 
 
-	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	msg = kmalloc(sizeof(*msg), GFP_NOIO | __GFP_HIGH);
 	if (msg == NULL) {
 		err = -ENOMEM;
 		goto out;
@@ -763,7 +763,7 @@
 		goto out;
 	}
 
-	body = kmalloc(msg->hdr.len + 1, GFP_KERNEL);
+	body = kmalloc(msg->hdr.len + 1, GFP_NOIO | __GFP_HIGH);
 	if (body == NULL) {
 		kfree(msg);
 		err = -ENOMEM;


