From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [[PATCH stable <3.12]] xen-netback: fix refcnt unbalance for
 3.11 and earlier versions
Date: Mon, 2 Dec 2013 17:49:54 +0000
Message-ID: <20131202174954.GD14293@zion.uk.xensource.com>
References: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
 <20131201044835.GB19516@kroah.com>
 <20131202120134.GA14293@zion.uk.xensource.com>
 <20131202171958.GA661@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	<tomasz.wroblewski@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131202171958.GA661@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 02, 2013 at 09:19:58AM -0800, Greg KH wrote:
[...]
> As 3.11.y is now dead, there's not much I can do with that one, but I
> could use a backport for 3.10.y, as this patch does not apply there,
> thanks.
> 

Here it is.

---8<---
>From f92adc90042cb725cf6351141f52e9fc71639a89 Mon Sep 17 00:00:00 2001
From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 2 Dec 2013 17:44:09 +0000
Subject: [PATCH] xen-netback: fix refcnt unbalance for 3.10

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
---
 drivers/net/xen-netback/interface.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index c4a2eb2..540a796 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -365,17 +365,19 @@ void xenvif_disconnect(struct xenvif *vif)
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
-- 
1.7.10.4


> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
