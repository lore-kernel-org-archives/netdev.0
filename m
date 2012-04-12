From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 16:23:19 -0300
Message-ID: <20120412162319.377ae3cf@asterix.rh>
References: <1334244396-6978-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sboyd@codeaurora.org, ben@simtec.co.uk,
	netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754139Ab2DLTXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 15:23:34 -0400
In-Reply-To: <1334244396-6978-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Apr 2012 10:26:36 -0500 mjr@cs.wisc.edu wrote:

> From: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> All calls to ks8851_rdreg* and ks8851_wrreg* should be protected
> with the driver's lock mutex.  A spurious interrupt may otherwise cause a
> crash.
> 
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
> Hello,
> 
> I'm new to the kernel development process so I hope I've not screwed
> this up with this extra text.  We found a potential issue using a new
> driver testing tool called SymDrive.  It looks legitimate to me, so
> I'm reporting it.  We hope to make this tool available in the future.
> Please let me know if I should modify the patch or re-send without
> this commentary.  Thanks in advance for your patience.
> 

It is recommended to put the driver name in the subject,
for instance: 

[PATCH] ks8851: Fix missing mutex_lock/unlock

See the driver log for more examples.

>  drivers/net/ethernet/micrel/ks8851.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index c722aa6..fa2001a 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1515,11 +1515,15 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  		goto err_netdev;
>  	}
>  
> +	mutex_lock(&ks->lock);
> +
>  	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
>  		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
>  		    ndev->dev_addr, ndev->irq,
>  		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
>  
> +	mutex_unlock(&ks->lock);
> +
>  	return 0;


It's weird to look a mutex being hold to call netdev_info().
Perhaps change it to look like below as the netdev_info()
does a lot more things and holding the lock during that
seems to be a waste.

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..20237dc 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1417,6 +1417,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 {
 	struct net_device *ndev;
 	struct ks8851_net *ks;
+	int result;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
@@ -1515,9 +1516,12 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
+	mutex_lock(&ks->lock);
+	result = CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER));
+	mutex_unlock(&ks->lock);
+
 	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
-		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
-		    ndev->dev_addr, ndev->irq,
+		    result, ndev->dev_addr, ndev->irq,
 		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
 	return 0;

fbl
