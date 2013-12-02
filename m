From: <gregkh@linuxfoundation.org>
Subject: Patch "xen-netback: fix refcnt unbalance for 3.10" has been added to the 3.10-stable tree
Date: Mon, 02 Dec 2013 09:59:03 -0800
Message-ID: <13860071432045@kroah.com>
References: <20131202174954.GD14293@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: <stable@vger.kernel.org>, <stable-commits@vger.kernel.org>
To: wei.liu2@citrix.com, david.vrabel@citrix.com,
	gregkh@linuxfoundation.org, ian.campbell@citrix.com,
	konrad.wilk@oracle.com, netdev@vger.kernel.org,
	stable@vger.kernel.org, tomasz.wroblewski@citrix.com,
	xen-devel@lists.xen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37841 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab3LBR7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 12:59:03 -0500
In-Reply-To: <20131202174954.GD14293@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    xen-netback: fix refcnt unbalance for 3.10

to the 3.10-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     xen-netback-fix-refcnt-unbalance-for-3.10.patch
and it can be found in the queue-3.10 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From wei.liu2@citrix.com  Mon Dec  2 09:57:28 2013
From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 2 Dec 2013 17:49:54 +0000
Subject: xen-netback: fix refcnt unbalance for 3.10
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>, <stable@vger.kernel.org>, <tomasz.wroblewski@citrix.com>, Ian Campbell <ian.campbell@citrix.com>, Konrad Wilk <konrad.wilk@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Message-ID: <20131202174954.GD14293@zion.uk.xensource.com>
Content-Disposition: inline

From: Wei Liu <wei.liu2@citrix.com>

With the introduction of "xen-netback: Don't destroy the netdev until
the vif is shut down" (upstream commit id 279f438e36), vif disconnect
and free are separated. However in the backported version reference
counting code was not correctly modified, and the reset of vif->irq
was lost. If frontend goes through vif life cycle more than once the
reference counting is skewed.

This patch adds back the missing vif->irq reset line. It also moves
several lines of the reference counting code to vif_free, so the moved
code corresponds to the counterpart in vif_alloc, thus the reference
counting is balanced.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/xen-netback/interface.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -365,17 +365,19 @@ void xenvif_disconnect(struct xenvif *vi
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
-	atomic_dec(&vif->refcnt);
-	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
-
-	if (vif->irq)
+	if (vif->irq) {
 		unbind_from_irqhandler(vif->irq, vif);
+		vif->irq = 0;
+	}
 
 	xen_netbk_unmap_frontend_rings(vif);
 }
 
 void xenvif_free(struct xenvif *vif)
 {
+	atomic_dec(&vif->refcnt);
+	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
+
 	unregister_netdev(vif->dev);
 
 	free_netdev(vif->dev);


Patches currently in stable-queue which might be from wei.liu2@citrix.com are

queue-3.10/xen-netback-fix-refcnt-unbalance-for-3.10.patch
