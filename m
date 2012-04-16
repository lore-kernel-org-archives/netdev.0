From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] arcnet: rimi: Fix device name in debug output
Date: Mon, 16 Apr 2012 14:02:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204161335420.16373@pobox.suse.cz>
References: <20120415153220.GA11631@vt220.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steven Young <sdyoung@vt220.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46281 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab2DPMCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 08:02:50 -0400
In-Reply-To: <20120415153220.GA11631@vt220.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Apr 2012, Steven Young wrote:

> 
> This patch corrects an incorrectly-used format string that causes messages
> like:
>   
>   arc%d: Given: node 00h, shmem 0h, irq 0
> 
> to appear in dmesg at boot/modprobe time for the arcnet-rimi driver and
> others.  This applies to linux-3.3.
> 
> Signed-off-by: Steven Young <sdyoung@vt220.org>
> 
> ---
> 
> --- linux-3.3-orig/drivers/net/arcnet/arcnet.c	2012-03-18 23:15:34.000000000 +0000
> +++ linux-3.3/drivers/net/arcnet/arcnet.c	2012-04-15 15:50:24.000000000 +0100
> @@ -346,7 +346,7 @@ struct net_device *alloc_arcdev(const ch
>  	struct net_device *dev;
>  
>  	dev = alloc_netdev(sizeof(struct arcnet_local),
> -			   name && *name ? name : "arc%d", arcdev_setup);
> +			   name && *name ? name : "arcnet", arcdev_setup);
>  	if(dev) {
>  		struct arcnet_local *lp = netdev_priv(dev);
>  		spin_lock_init(&lp->lock);

I don't think this is correct. The only problem with you seeing the 
message above is that it's printed before register_netdev() happpens 
(which is where the resolution of the name in the formatstring happens).

But your change will alter the naming of the devices completely ....

I propose the minimalistic fix instead ... it'd be better to just drop the 
BUGMSG() thing altogether and convert it to dev_printk(), but that'd be 
larger revamp of the driver, and such effort is questionable for something 
like Arcnet :)

Adding proper CCs.




From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] arcnet: rimi: Fix device name in debug output

arcrimi_probe() calls BUGMSG() before register_netdev() happens. BUGMSG()
itself prints dev->name, but as the format string hasn't been expanded by
register_netdev() yet, the output contains bogus device name such as

	arc%d: Given: node 00h, shmem 0h, irq 0

As we don't know the device name yet, just drop the prefix completely from
the debugging messages.

Reported-by: Steven Young <sdyoung@vt220.org>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 drivers/net/arcnet/arc-rimi.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 25197b6..b8b4c7b 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -89,16 +89,16 @@ static int __init arcrimi_probe(struct net_device *dev)
 	BUGLVL(D_NORMAL) printk(VERSION);
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test the RIM I driver, please!\n");
 
-	BUGMSG(D_NORMAL, "Given: node %02Xh, shmem %lXh, irq %d\n",
+	BUGLVL(D_NORMAL) printk("Given: node %02Xh, shmem %lXh, irq %d\n",
 	       dev->dev_addr[0], dev->mem_start, dev->irq);
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
-		BUGMSG(D_NORMAL, "No autoprobe for RIM I; you "
+		BUGLVL(D_NORMAL) printk("No autoprobe for RIM I; you "
 		       "must specify the shmem and irq!\n");
 		return -ENODEV;
 	}
 	if (dev->dev_addr[0] == 0) {
-		BUGMSG(D_NORMAL, "You need to specify your card's station "
+		BUGLVL(D_NORMAL) printk("You need to specify your card's station "
 		       "ID!\n");
 		return -ENODEV;
 	}
@@ -109,7 +109,7 @@ static int __init arcrimi_probe(struct net_device *dev)
 	 * will be taken.
 	 */
 	if (!request_mem_region(dev->mem_start, MIRROR_SIZE, "arcnet (90xx)")) {
-		BUGMSG(D_NORMAL, "Card memory already allocated\n");
+		BUGLVL(D_NORMAL) printk("Card memory already allocated\n");
 		return -ENODEV;
 	}
 	return arcrimi_found(dev);

-- 
Jiri Kosina
SUSE Labs
