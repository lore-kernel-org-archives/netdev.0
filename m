From: Imre Palik <imrep.amz@gmail.com>
Subject: [PATCH] xen-netback: fix a BUG() during initialization
Date: Fri, 19 Jun 2015 14:21:51 +0200
Message-ID: <1434716511-25657-1-git-send-email-imrep.amz@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Palik, Imre" <imrep@amazon.de>, Matt Wilson <msw@amazon.com>
To: xen-devel@lists.xenproject.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34502 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbFSMWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 08:22:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Palik, Imre" <imrep@amazon.de>

Commit edafc132baac ("xen-netback: making the bandwidth limiter runtime settable")
introduced the capability to change the bandwidth rate limit at runtime.
But it also introduced a possible crashing bug.

If netback receives two XenbusStateConnected without getting the
hotplug-status watch firing in between, then it will try to register the
watches for the rate limiter again.  But this triggers a BUG() in the watch
registration code.

The fix modifies connect() to remove the possibly existing packet-rate
watches before trying to install those watches.  This behaviour is in line
with how connect() deals with the hotplug-status watch.

Signed-off-by: Imre Palik <imrep@amazon.de>
Cc: Matt Wilson <msw@amazon.com>
---
 drivers/net/xen-netback/xenbus.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 968787a..ec383b0 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -681,6 +681,9 @@ static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
 	char *node;
 	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
 
+	if (vif->credit_watch.node)
+		return -EADDRINUSE;
+
 	node = kmalloc(maxlen, GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
@@ -770,6 +773,7 @@ static void connect(struct backend_info *be)
 	}
 
 	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
+	xen_unregister_watchers(be->vif);
 	xen_register_watchers(dev, be->vif);
 	read_xenbus_vif_flags(be);
 
-- 
1.7.9.5
