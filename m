From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 12/13] netfront: multi page ring support.
Date: Wed, 15 Feb 2012 17:42:53 -0500
Message-ID: <20120215224253.GA18762@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-13-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:27591 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab2BOWqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 17:46:03 -0500
Content-Disposition: inline
In-Reply-To: <1328201363-13915-13-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2012 at 04:49:22PM +0000, Wei Liu wrote:
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

It also needs this:

>From 4cf97c025792cf073edc4d312b962ecc0b3b67ab Mon Sep 17 00:00:00 2001
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Wed, 15 Feb 2012 17:39:46 -0500
Subject: [PATCH] xen/net: Don't try to use all of the rings if we are not
 built for it.

Otherwise we end up:

BUG: unable to handle kernel paging request at ffff88004000c0c8
IP: [<ffffffff810f1ee4>] free_one_page+0x144/0x410
PGD 1806063 PUD 0
22:22:34 tst007 logger: /etc/xen/scripts/vif-bridge: offline XENBUS_PATH=backend/vif/1/0
00 [#1] SMP
CPU 0
Modules linked in:

Pid: 17, comm: xenwatch Not tainted 3.2.0upstream #2 Xen HVM domU
RIP: 0010:[<ffffffff810f1ee4>]  [<ffffffff810f1ee4>] free_one_page+0x144/0x410
RSP: 0018:ffff88003bea3c40  EFLAGS: 00010046
.. snip.
Call Trace:
 [<ffffffff810f2c7f>] __free_pages_ok+0x9f/0xe0
 [<ffffffff810f4eab>] __free_pages+0x1b/0x40
 [<ffffffff810f4f1a>] free_pages+0x4a/0x60
 [<ffffffff8138b33d>] xennet_disconnect_backend+0xbd/0x130
 [<ffffffff8138bd88>] talk_to_netback+0x8e8/0x1160
 [<ffffffff812f4e28>] ? xenbus_gather+0xd8/0x170
 [<ffffffff8138e3bd>] netback_changed+0xcd/0x550
 [<ffffffff812f5bb8>] xenbus_otherend_changed+0xa8/0xb0

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 0223552..1eadd90 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -29,6 +29,8 @@
  * IN THE SOFTWARE.
  */
 
+#define DEBUG 1
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -66,7 +68,7 @@ struct netfront_cb {
 
 #define GRANT_INVALID_REF	0
 
-#define XENNET_MAX_RING_PAGE_ORDER 2
+#define XENNET_MAX_RING_PAGE_ORDER 4
 #define XENNET_MAX_RING_PAGES      (1U << XENNET_MAX_RING_PAGE_ORDER)
 
 #define NET_TX_RING_SIZE(_nr_pages)					\
@@ -1611,6 +1613,11 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		info->tx_ring_page_order = 0;
 		dev_info(&dev->dev, "single tx ring\n");
 	} else {
+		if (max_tx_ring_page_order > XENNET_MAX_RING_PAGE_ORDER) {
+			dev_warn(&dev->dev, "Backend can do %d pages but we can only do %d!\n",
+				max_tx_ring_page_order, XENNET_MAX_RING_PAGE_ORDER);
+			max_tx_ring_page_order = XENNET_MAX_RING_PAGE_ORDER;
+		}
 		info->tx_ring_page_order = max_tx_ring_page_order;
 		dev_info(&dev->dev, "multi page tx ring, order = %d\n",
 			 max_tx_ring_page_order);
@@ -1642,6 +1649,11 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		dev_info(&dev->dev, "single rx ring\n");
 	} else {
 		info->rx_ring_page_order = max_rx_ring_page_order;
+		if (max_rx_ring_page_order > XENNET_MAX_RING_PAGE_ORDER) {
+			dev_warn(&dev->dev, "Backend can do %d pages but we can only do %d!\n",
+				max_rx_ring_page_order, XENNET_MAX_RING_PAGE_ORDER);
+			max_rx_ring_page_order = XENNET_MAX_RING_PAGE_ORDER;
+		}
 		dev_info(&dev->dev, "multi page rx ring, order = %d\n",
 			 max_rx_ring_page_order);
 	}
-- 
1.7.9.48.g85da4d
