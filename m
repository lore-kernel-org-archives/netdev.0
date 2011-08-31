From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH RFT] bnx2: don't request firmware when there's no
 userspace.
Date: Tue, 30 Aug 2011 17:11:36 -0700
Message-ID: <1314749496.9556.9.camel@HP1>
References: <20110830073450.GA23858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4374 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753959Ab1HaATV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 20:19:21 -0400
In-Reply-To: <20110830073450.GA23858@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-08-30 at 00:34 -0700, Francois Romieu wrote:
> The firmware is cached during the first successful call to open() and
> released once the network device is unregistered. The driver uses the
> cached firmware between open() and unregister_netdev().
> 
> It's similar to 953a12cc2889d1be92e80a2d0bab5ffef4942300 but the
> firmware is mandatory.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Michael Chan <mchan@broadcom.com>
> ---
> 
>  Tester(s) needed. There should be a difference of behavior when the
>  driver is included in a monolithic kernel and the firmwares are not
>  included in the vmimage.
> 
>  drivers/net/bnx2.c |   60 ++++++++++++++++++++++++++++++++--------------------
>  1 files changed, 37 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 4b2b570..fb54afd 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -3649,8 +3649,15 @@ check_mips_fw_entry(const struct firmware *fw,
>  	return 0;
>  }
>  
> +static void bnx2_release_firmware(struct bnx2 *bp)
> +{
> +	release_firmware(bp->mips_firmware);
> +	release_firmware(bp->rv2p_firmware);
> +	bp->rv2p_firmware = NULL;
> +}
> +
>  static int __devinit

This should not be __devinit any more now that we request firmware in
open().

> -bnx2_request_firmware(struct bnx2 *bp)
> +bnx2_request_uncached_firmware(struct bnx2 *bp)
>  {
>  	const char *mips_fw_file, *rv2p_fw_file;
>  	const struct bnx2_mips_fw_file *mips_fw;
> @@ -3672,13 +3679,13 @@ bnx2_request_firmware(struct bnx2 *bp)
>  	rc = request_firmware(&bp->mips_firmware, mips_fw_file, &bp->pdev->dev);
>  	if (rc) {
>  		pr_err("Can't load firmware file \"%s\"\n", mips_fw_file);
> -		return rc;
> +		goto out;
>  	}
>  
>  	rc = request_firmware(&bp->rv2p_firmware, rv2p_fw_file, &bp->pdev->dev);
>  	if (rc) {
>  		pr_err("Can't load firmware file \"%s\"\n", rv2p_fw_file);
> -		return rc;
> +		goto err_release_mips_firmware;
>  	}
>  	mips_fw = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
>  	rv2p_fw = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
> @@ -3689,16 +3696,30 @@ bnx2_request_firmware(struct bnx2 *bp)
>  	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->tpat) ||
>  	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->txp)) {
>  		pr_err("Firmware file \"%s\" is invalid\n", mips_fw_file);
> -		return -EINVAL;
> +		rc = -EINVAL;
> +		goto err_release_firmware;
>  	}
>  	if (bp->rv2p_firmware->size < sizeof(*rv2p_fw) ||
>  	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc1.rv2p, 8, true) ||
>  	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc2.rv2p, 8, true)) {
>  		pr_err("Firmware file \"%s\" is invalid\n", rv2p_fw_file);
> -		return -EINVAL;
> +		rc = -EINVAL;
> +		goto err_release_firmware;
>  	}
> +out:
> +	return rc;
>  
> -	return 0;
> +err_release_firmware:
> +	release_firmware(bp->rv2p_firmware);
> +	bp->rv2p_firmware = NULL;
> +err_release_mips_firmware:
> +	release_firmware(bp->mips_firmware);

I think we need to set bp->mips_firmware to NULL here.  If it fails
during open() and we release it here, we'll release it again during
remove_one() if it is not NULL.  Same problem in bnx2_release_firmware()
above.  It can be called twice from open_err and remove_one().

> +	goto out;
> +}
> +
> +static int bnx2_request_firmware(struct bnx2 *bp)
> +{
> +	return bp->rv2p_firmware ? 0 : bnx2_request_uncached_firmware(bp);
>  }
>  
>  static u32
> @@ -6266,6 +6287,10 @@ bnx2_open(struct net_device *dev)
>  	struct bnx2 *bp = netdev_priv(dev);
>  	int rc;
>  
> +	rc = bnx2_request_firmware(bp);
> +	if (rc < 0)
> +		goto out;
> +
>  	netif_carrier_off(dev);
>  
>  	bnx2_set_power_state(bp, PCI_D0);
> @@ -6326,8 +6351,8 @@ bnx2_open(struct net_device *dev)
>  		netdev_info(dev, "using MSIX\n");
>  
>  	netif_tx_start_all_queues(dev);
> -
> -	return 0;
> +out:
> +	return rc;
>  
>  open_err:
>  	bnx2_napi_disable(bp);
> @@ -6335,7 +6360,8 @@ open_err:
>  	bnx2_free_irq(bp);
>  	bnx2_free_mem(bp);
>  	bnx2_del_napi(bp);
> -	return rc;
> +	bnx2_release_firmware(bp);
> +	goto out;
>  }
>  
>  static void
> @@ -8353,10 +8379,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	pci_set_drvdata(pdev, dev);
>  
> -	rc = bnx2_request_firmware(bp);
> -	if (rc)
> -		goto error;
> -
>  	memcpy(dev->dev_addr, bp->mac_addr, 6);
>  	memcpy(dev->perm_addr, bp->mac_addr, 6);
>  
> @@ -8387,11 +8409,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	return 0;
>  
>  error:
> -	if (bp->mips_firmware)
> -		release_firmware(bp->mips_firmware);
> -	if (bp->rv2p_firmware)
> -		release_firmware(bp->rv2p_firmware);
> -
>  	if (bp->regview)
>  		iounmap(bp->regview);
>  	pci_release_regions(pdev);
> @@ -8412,11 +8429,6 @@ bnx2_remove_one(struct pci_dev *pdev)
>  	del_timer_sync(&bp->timer);
>  	cancel_work_sync(&bp->reset_task);
>  
> -	if (bp->mips_firmware)
> -		release_firmware(bp->mips_firmware);
> -	if (bp->rv2p_firmware)
> -		release_firmware(bp->rv2p_firmware);
> -
>  	if (bp->regview)
>  		iounmap(bp->regview);
>  
> @@ -8427,6 +8439,8 @@ bnx2_remove_one(struct pci_dev *pdev)
>  		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
>  	}
>  
> +	bnx2_release_firmware(bp);
> +
>  	free_netdev(dev);
>  
>  	pci_release_regions(pdev);
