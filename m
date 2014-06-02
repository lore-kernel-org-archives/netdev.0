From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v9 1/7] xen-netback: Move grant_copy_op array back into
 struct xenvif.
Date: Mon, 2 Jun 2014 14:00:10 +0100
Message-ID: <20140602130010.GC6043@zion.uk.xensource.com>
References: <1401706212-8208-1-git-send-email-wei.liu2@citrix.com>
 <1401706212-8208-2-git-send-email-wei.liu2@citrix.com>
 <538C72F9.5040809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>,
	<paul.durrant@citrix.com>, <a.j.bennieston@gmail.com>,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:28576 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267AbaFBNAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 09:00:12 -0400
Content-Disposition: inline
In-Reply-To: <538C72F9.5040809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2014 at 04:50:01PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 02-06-2014 14:50, Wei Liu wrote:
> 
> >From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> >This array was allocated separately in commit ac3d5ac2 due to it being
> 
>    Please also specify that commit's summary in parens.
> 

Thanks Sergei.

David, can you use this one instead. It has the commit summary added in.
Nothing else is changed.

Wei.

---8<---
>From 5eac75eb850a5b411636d23aa8b771017ff6659a Mon Sep 17 00:00:00 2001
From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Date: Wed, 14 May 2014 14:52:25 +0100
Subject: [PATCH v9 1/7] xen-netback: Move grant_copy_op array back into struct
 xenvif.

This array was allocated separately in commit ac3d5ac2 ("xen-netback:
fix guest-receive-side array sizes") due to it being very large, and a
struct xenvif is allocated as the netdev_priv part of a struct
net_device, i.e. via kmalloc() but falling back to vmalloc() if the
initial alloc. fails.

In preparation for the multi-queue patches, where this array becomes
part of struct xenvif_queue and is always allocated through vzalloc(),
move this back into the struct xenvif.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |    3 +--
 drivers/net/xen-netback/interface.c |    9 ---------
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 0d4a285..2c283d6 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -158,8 +158,7 @@ struct xenvif {
 
 	struct timer_list wake_queue;
 
-	/* This array is allocated seperately as it is large */
-	struct gnttab_copy *grant_copy_op;
+	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
 
 	/* We create one meta structure per ring request we consume, so
 	 * the maximum number is the same as the ring size.
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 53cdcdf..8fdedac 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -334,14 +334,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	vif = netdev_priv(dev);
 
-	vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
-				     MAX_GRANT_COPY_OPS);
-	if (vif->grant_copy_op == NULL) {
-		pr_warn("Could not allocate grant copy space for %s\n", name);
-		free_netdev(dev);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	vif->domid  = domid;
 	vif->handle = handle;
 	vif->can_sg = 1;
@@ -601,7 +593,6 @@ void xenvif_free(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	vfree(vif->grant_copy_op);
 	free_netdev(vif->dev);
 
 	module_put(THIS_MODULE);
-- 
1.7.10.4
