From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] e1000e: tweak irq allocation messages
Date: Thu, 31 Jan 2008 18:06:20 -0500
Message-ID: <20080131230620.GC856@gospo.usersys.redhat.com>
References: <20080131225639.GB856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbYAaXGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 18:06:24 -0500
Content-Disposition: inline
In-Reply-To: <20080131225639.GB856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 05:56:39PM -0500, Andy Gospodarek wrote:
> 
> There's too much noise on systems that don't support MSI.  Let's get rid
> of the unneeded message and make the real error message more specific.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
> 
>  netdev.c |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 0a2cb79..0c8cd1c 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -945,11 +945,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
>  	int irq_flags = IRQF_SHARED;
>  	int err;
>  
> -	err = pci_enable_msi(adapter->pdev);
> -	if (err) {
> -		ndev_warn(netdev,
> -		 "Unable to allocate MSI interrupt Error: %d\n", err);
> -	} else {
> +	if (!pci_enable_msi(adapter->pdev)) {
>  		adapter->flags |= FLAG_MSI_ENABLED;
>  		handler = e1000_intr_msi;
>  		irq_flags = 0;
> @@ -958,10 +954,12 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
>  	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
>  			  netdev);
>  	if (err) {
> +		ndev_err(netdev,
> +		       "Unable to allocate %s interrupt (return: %d)\n",
> +			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx"
> +			err);
>  		if (adapter->flags & FLAG_MSI_ENABLED)
>  			pci_disable_msi(adapter->pdev);
> -		ndev_err(netdev,
> -		       "Unable to allocate interrupt Error: %d\n", err);
>  	}
>  
>  	return err;


(Reposted with the version I intended -- added ',' so it compiles!)

There's too much noise on systems that don't support MSI.  Let's get rid
of a few and make the real error message more specific.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 netdev.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0a2cb79..0c8cd1c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -945,11 +945,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	err = pci_enable_msi(adapter->pdev);
-	if (err) {
-		ndev_warn(netdev,
-		 "Unable to allocate MSI interrupt Error: %d\n", err);
-	} else {
+	if (!pci_enable_msi(adapter->pdev)) {
 		adapter->flags |= FLAG_MSI_ENABLED;
 		handler = e1000_intr_msi;
 		irq_flags = 0;
@@ -958,10 +954,12 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
 	if (err) {
+		ndev_err(netdev,
+		       "Unable to allocate %s interrupt (return: %d)\n",
+			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
+			err);
 		if (adapter->flags & FLAG_MSI_ENABLED)
 			pci_disable_msi(adapter->pdev);
-		ndev_err(netdev,
-		       "Unable to allocate interrupt Error: %d\n", err);
 	}
 
 	return err;
