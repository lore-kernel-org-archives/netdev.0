From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/2] xen-netback: correctly return errors from netbk_count_requests()
Date: Thu, 14 Feb 2013 13:18:57 +0000
Message-ID: <1360847938-11185-2-git-send-email-david.vrabel@citrix.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jan Beulich <jbeulich@suse.com>, Wei Liu <wei.liu@citrix.com>,
	<netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
	Jan Beulich <JBeulich@suse.com>
To: <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49690 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934509Ab3BNNT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 08:19:29 -0500
In-Reply-To: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

netbk_count_requests() could detect an error, call
netbk_fatal_tx_error() but return 0.  The vif may then be used
afterwards (e.g., in a call to netbk_tx_error().

Since netbk_fatal_tx_error() could set vif->refcnt to 1, the vif may
be freed immediately after the call to netbk_fatal_tx_error() (e.g.,
if the vif is also removed).

Netback thread              Xenwatch thread
-------------------------------------------
netbk_fatal_tx_err()        netback_remove()
                              xenvif_disconnect()
                                ...
                                free_netdev()
netbk_tx_err() Oops!

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Signed-off-by: Jan Beulich <JBeulich@suse.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2b9520c..cd49ba9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -911,13 +911,13 @@ static int netbk_count_requests(struct xenvif *vif,
 		if (frags >= work_to_do) {
 			netdev_err(vif->dev, "Need more frags\n");
 			netbk_fatal_tx_err(vif);
-			return -frags;
+			return -ENODATA;
 		}
 
 		if (unlikely(frags >= MAX_SKB_FRAGS)) {
 			netdev_err(vif->dev, "Too many frags\n");
 			netbk_fatal_tx_err(vif);
-			return -frags;
+			return -E2BIG;
 		}
 
 		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
@@ -925,7 +925,7 @@ static int netbk_count_requests(struct xenvif *vif,
 		if (txp->size > first->size) {
 			netdev_err(vif->dev, "Frag is bigger than frame.\n");
 			netbk_fatal_tx_err(vif);
-			return -frags;
+			return -EIO;
 		}
 
 		first->size -= txp->size;
@@ -935,7 +935,7 @@ static int netbk_count_requests(struct xenvif *vif,
 			netdev_err(vif->dev, "txp->offset: %x, size: %u\n",
 				 txp->offset, txp->size);
 			netbk_fatal_tx_err(vif);
-			return -frags;
+			return -EINVAL;
 		}
 	} while ((txp++)->flags & XEN_NETTXF_more_data);
 	return frags;
-- 
1.7.2.5
