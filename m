From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: Re: [patch 13/15] irda_device_dongle_init: fix kzalloc(GFP_KERNEL) in spinlock
Date: 26 Apr 2007 08:12:47 -0000
Message-ID: <kjNEPme1.1177575167.3331050.samuel@sortiz.org>
References: <200704260727.l3Q7RZr7023981@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"matthias.kaehlcke@gmail.com" <matthias.kaehlcke@gmail.com>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:45843 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933208AbXDZITc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:19:32 -0400
In-Reply-To: <200704260727.l3Q7RZr7023981@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 4/26/2007, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
wrote:

>From: Andrew Morton <akpm@linux-foundation.org>
>
>Fix http://bugzilla.kernel.org/show_bug.cgi?id=8343
>
>Cc: Samuel Ortiz <samuel@sortiz.org>
>Cc: <matthias.kaehlcke@gmail.com>
>Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
This one was on my pipeline, looks good to me.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>


>---
>
> net/irda/irda_device.c |   21 ++++++++-------------
> 1 file changed, 8 insertions(+), 13 deletions(-)
>
>diff -puN net/irda/irda_device.c~irda_device_dongle_init-fix-kzallocgfp_kernel-in-spinlock net/irda/irda_device.c
>--- a/net/irda/irda_device.c~irda_device_dongle_init-fix-kzallocgfp_kernel-in-spinlock
>+++ a/net/irda/irda_device.c
>@@ -375,7 +375,7 @@ EXPORT_SYMBOL(alloc_irdadev);
> dongle_t *irda_device_dongle_init(struct net_device *dev, int type)
> {
> 	struct dongle_reg *reg;
>-	dongle_t *dongle = NULL;
>+	dongle_t *dongle = kzalloc(sizeof(dongle_t), GFP_KERNEL);
>
> 	might_sleep();
>
>@@ -397,19 +397,14 @@ dongle_t *irda_device_dongle_init(struct
> 	if (!reg || !try_module_get(reg->owner) ) {
> 		IRDA_ERROR("IrDA: Unable to find requested dongle type %x\n",
> 			   type);
>-		goto out;
>+		kfree(dongle);
>+		dongle = NULL;
>+	}
>+	if (dongle) {
>+		/* Bind the registration info to this particular instance */
>+		dongle->issue = reg;
>+		dongle->dev = dev;
> 	}
>-
>-	/* Allocate dongle info for this instance */
>-	dongle = kzalloc(sizeof(dongle_t), GFP_KERNEL);
>-	if (!dongle)
>-		goto out;
>-
>-	/* Bind the registration info to this particular instance */
>-	dongle->issue = reg;
>-	dongle->dev = dev;
>-
>- out:
> 	spin_unlock(&dongles->hb_spinlock);
> 	return dongle;
> }
>_
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
