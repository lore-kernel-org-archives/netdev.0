From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: PCI: make pci_restore_state return void
Date: Thu, 2 Dec 2010 09:15:46 -0700
Message-ID: <201012020915.50049.bjorn.helgaas@hp.com>
References: <1291160606-31494-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, linux-pci@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>, linux-media@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>, netdev@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	linux-wireless@vger.kernel.org, Brian King <brking@us.ibm.com>,
	Anil Ravindranath <anil_ravindranath@pmc-sierra.com>,
	linux-scsi@vger.kernel.org, Jaya Kumar <jayakumar.alsa@gmail.com>,
	boyod.yang@siliconmotion.com.cn
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:48243 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757073Ab0LBQP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 11:15:57 -0500
In-Reply-To: <1291160606-31494-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 30, 2010 04:43:26 pm Jon Mason wrote:
> pci_restore_state only ever returns 0, thus there is no benefit in
> having it return any value.  Also, a large majority of the callers do
> not check the return code of pci_restore_state.  Make the
> pci_restore_state a void return and avoid the overhead.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>

Looks reasonable to me, but doesn't appear to be a regression fix or
anything urgent that needs to be in .37, so I'll wait and let Jesse
handle this when he returns from vacation.  OK?

Bjorn

> ---
>  drivers/media/video/cafe_ccic.c         |    4 +---
>  drivers/net/myri10ge/myri10ge.c         |    4 +---
>  drivers/net/sfc/falcon.c                |   25 +++++--------------------
>  drivers/net/skge.c                      |    4 +---
>  drivers/net/sky2.c                      |    5 +----
>  drivers/net/wireless/rt2x00/rt2x00pci.c |    4 ++--
>  drivers/pci/pci-driver.c                |    3 ++-
>  drivers/pci/pci.c                       |    7 ++-----
>  drivers/scsi/ipr.c                      |    8 +-------
>  drivers/scsi/pmcraid.c                  |    7 +------
>  drivers/staging/sm7xx/smtcfb.c          |    2 +-
>  include/linux/pci.h                     |    8 +++-----
>  sound/pci/cs5535audio/cs5535audio_pm.c  |    7 +------
>  13 files changed, 22 insertions(+), 66 deletions(-)
> 
> diff --git a/drivers/media/video/cafe_ccic.c b/drivers/media/video/cafe_ccic.c
> index 2934770..3e653f3 100644
> --- a/drivers/media/video/cafe_ccic.c
> +++ b/drivers/media/video/cafe_ccic.c
> @@ -2186,9 +2186,7 @@ static int cafe_pci_resume(struct pci_dev *pdev)
>  	struct cafe_camera *cam = to_cam(v4l2_dev);
>  	int ret = 0;
>  
> -	ret = pci_restore_state(pdev);
> -	if (ret)
> -		return ret;
> +	pci_restore_state(pdev);
>  	ret = pci_enable_device(pdev);
>  
>  	if (ret) {
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
> index 8524cc4..d3c4a37 100644
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -3403,9 +3403,7 @@ static int myri10ge_resume(struct pci_dev *pdev)
>  		return -EIO;
>  	}
>  
> -	status = pci_restore_state(pdev);
> -	if (status)
> -		return status;
> +	pci_restore_state(pdev);
>  
>  	status = pci_enable_device(pdev);
>  	if (status) {
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index 267019b..1763b9a 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> @@ -1066,22 +1066,9 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
>  
>  	/* Restore PCI configuration if needed */
>  	if (method == RESET_TYPE_WORLD) {
> -		if (efx_nic_is_dual_func(efx)) {
> -			rc = pci_restore_state(nic_data->pci_dev2);
> -			if (rc) {
> -				netif_err(efx, drv, efx->net_dev,
> -					  "failed to restore PCI config for "
> -					  "the secondary function\n");
> -				goto fail3;
> -			}
> -		}
> -		rc = pci_restore_state(efx->pci_dev);
> -		if (rc) {
> -			netif_err(efx, drv, efx->net_dev,
> -				  "failed to restore PCI config for the "
> -				  "primary function\n");
> -			goto fail4;
> -		}
> +		if (efx_nic_is_dual_func(efx))
> +			pci_restore_state(nic_data->pci_dev2);
> +		pci_restore_state(efx->pci_dev);
>  		netif_dbg(efx, drv, efx->net_dev,
>  			  "successfully restored PCI config\n");
>  	}
> @@ -1092,7 +1079,7 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
>  		rc = -ETIMEDOUT;
>  		netif_err(efx, hw, efx->net_dev,
>  			  "timed out waiting for hardware reset\n");
> -		goto fail5;
> +		goto fail3;
>  	}
>  	netif_dbg(efx, hw, efx->net_dev, "hardware reset complete\n");
>  
> @@ -1100,11 +1087,9 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
>  
>  	/* pci_save_state() and pci_restore_state() MUST be called in pairs */
>  fail2:
> -fail3:
>  	pci_restore_state(efx->pci_dev);
>  fail1:
> -fail4:
> -fail5:
> +fail3:
>  	return rc;
>  }
>  
> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index 220e039..61553af 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -4087,9 +4087,7 @@ static int skge_resume(struct pci_dev *pdev)
>  	if (err)
>  		goto out;
>  
> -	err = pci_restore_state(pdev);
> -	if (err)
> -		goto out;
> +	pci_restore_state(pdev);
>  
>  	err = skge_reset(hw);
>  	if (err)
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index d657708..be3aee7 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -4969,10 +4969,7 @@ static int sky2_resume(struct pci_dev *pdev)
>  	if (err)
>  		goto out;
>  
> -	err = pci_restore_state(pdev);
> -	if (err)
> -		goto out;
> -
> +	pci_restore_state(pdev);
>  	pci_enable_wake(pdev, PCI_D0, 0);
>  
>  	/* Re-enable all clocks */
> diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
> index 868ca19..5e3c46f 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
> @@ -356,12 +356,12 @@ int rt2x00pci_resume(struct pci_dev *pci_dev)
>  	struct rt2x00_dev *rt2x00dev = hw->priv;
>  
>  	if (pci_set_power_state(pci_dev, PCI_D0) ||
> -	    pci_enable_device(pci_dev) ||
> -	    pci_restore_state(pci_dev)) {
> +	    pci_enable_device(pci_dev)) {
>  		ERROR(rt2x00dev, "Failed to resume device.\n");
>  		return -EIO;
>  	}
>  
> +	pci_restore_state(pci_dev);
>  	return rt2x00lib_resume(rt2x00dev);
>  }
>  EXPORT_SYMBOL_GPL(rt2x00pci_resume);
> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
> index 8a6f797..80e551e 100644
> --- a/drivers/pci/pci-driver.c
> +++ b/drivers/pci/pci-driver.c
> @@ -449,7 +449,8 @@ static int pci_restore_standard_config(struct pci_dev *pci_dev)
>  			return error;
>  	}
>  
> -	return pci_restore_state(pci_dev);
> +	pci_restore_state(pci_dev);
> +	return 0;
>  }
>  
>  static void pci_pm_default_resume_early(struct pci_dev *pci_dev)
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index e98c810..c711d1b 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -937,14 +937,13 @@ pci_save_state(struct pci_dev *dev)
>   * pci_restore_state - Restore the saved state of a PCI device
>   * @dev: - PCI device that we're dealing with
>   */
> -int 
> -pci_restore_state(struct pci_dev *dev)
> +void pci_restore_state(struct pci_dev *dev)
>  {
>  	int i;
>  	u32 val;
>  
>  	if (!dev->state_saved)
> -		return 0;
> +		return;
>  
>  	/* PCI Express register must be restored first */
>  	pci_restore_pcie_state(dev);
> @@ -968,8 +967,6 @@ pci_restore_state(struct pci_dev *dev)
>  	pci_restore_iov_state(dev);
>  
>  	dev->state_saved = false;
> -
> -	return 0;
>  }
>  
>  static int do_pci_enable_device(struct pci_dev *dev, int bars)
> diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
> index fa60d7d..1d7dbe6 100644
> --- a/drivers/scsi/ipr.c
> +++ b/drivers/scsi/ipr.c
> @@ -7485,16 +7485,10 @@ static int ipr_reset_restore_cfg_space(struct ipr_cmnd *ipr_cmd)
>  {
>  	struct ipr_ioa_cfg *ioa_cfg = ipr_cmd->ioa_cfg;
>  	volatile u32 int_reg;
> -	int rc;
>  
>  	ENTER;
>  	ioa_cfg->pdev->state_saved = true;
> -	rc = pci_restore_state(ioa_cfg->pdev);
> -
> -	if (rc != PCIBIOS_SUCCESSFUL) {
> -		ipr_cmd->s.ioasa.hdr.ioasc = cpu_to_be32(IPR_IOASC_PCI_ACCESS_ERROR);
> -		return IPR_RC_JOB_CONTINUE;
> -	}
> +	pci_restore_state(ioa_cfg->pdev);
>  
>  	if (ipr_set_pcix_cmd_reg(ioa_cfg)) {
>  		ipr_cmd->s.ioasa.hdr.ioasc = cpu_to_be32(IPR_IOASC_PCI_ACCESS_ERROR);
> diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
> index cf89091..091baf2 100644
> --- a/drivers/scsi/pmcraid.c
> +++ b/drivers/scsi/pmcraid.c
> @@ -2227,12 +2227,7 @@ static void pmcraid_ioa_reset(struct pmcraid_cmd *cmd)
>  		/* Once either bist or pci reset is done, restore PCI config
>  		 * space. If this fails, proceed with hard reset again
>  		 */
> -		if (pci_restore_state(pinstance->pdev)) {
> -			pmcraid_info("config-space error resetting again\n");
> -			pinstance->ioa_state = IOA_STATE_IN_RESET_ALERT;
> -			pmcraid_reset_alert(cmd);
> -			break;
> -		}
> +		pci_restore_state(pinstance->pdev);
>  
>  		/* fail all pending commands */
>  		pmcraid_fail_outstanding_cmds(pinstance);
> diff --git a/drivers/staging/sm7xx/smtcfb.c b/drivers/staging/sm7xx/smtcfb.c
> index 24f47d6..7162dee 100644
> --- a/drivers/staging/sm7xx/smtcfb.c
> +++ b/drivers/staging/sm7xx/smtcfb.c
> @@ -1071,7 +1071,7 @@ static int __maybe_unused smtcfb_resume(struct pci_dev *pdev)
>  	/* when resuming, restore pci data and fb cursor */
>  	if (pdev->dev.power.power_state.event != PM_EVENT_FREEZE) {
>  		retv = pci_set_power_state(pdev, PCI_D0);
> -		retv = pci_restore_state(pdev);
> +		pci_restore_state(pdev);
>  		if (pci_enable_device(pdev))
>  			return -1;
>  		pci_set_master(pdev);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 7454408..63cbadc 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -806,7 +806,7 @@ size_t pci_get_rom_size(struct pci_dev *pdev, void __iomem *rom, size_t size);
>  
>  /* Power management related routines */
>  int pci_save_state(struct pci_dev *dev);
> -int pci_restore_state(struct pci_dev *dev);
> +void pci_restore_state(struct pci_dev *dev);
>  int __pci_complete_power_transition(struct pci_dev *dev, pci_power_t state);
>  int pci_set_power_state(struct pci_dev *dev, pci_power_t state);
>  pci_power_t pci_choose_state(struct pci_dev *dev, pm_message_t state);
> @@ -1168,10 +1168,8 @@ static inline int pci_save_state(struct pci_dev *dev)
>  	return 0;
>  }
>  
> -static inline int pci_restore_state(struct pci_dev *dev)
> -{
> -	return 0;
> -}
> +static inline void pci_restore_state(struct pci_dev *dev)
> +{ }
>  
>  static inline int pci_set_power_state(struct pci_dev *dev, pci_power_t state)
>  {
> diff --git a/sound/pci/cs5535audio/cs5535audio_pm.c b/sound/pci/cs5535audio/cs5535audio_pm.c
> index a3301cc..185b000 100644
> --- a/sound/pci/cs5535audio/cs5535audio_pm.c
> +++ b/sound/pci/cs5535audio/cs5535audio_pm.c
> @@ -90,12 +90,7 @@ int snd_cs5535audio_resume(struct pci_dev *pci)
>  	int i;
>  
>  	pci_set_power_state(pci, PCI_D0);
> -	if (pci_restore_state(pci) < 0) {
> -		printk(KERN_ERR "cs5535audio: pci_restore_state failed, "
> -		       "disabling device\n");
> -		snd_card_disconnect(card);
> -		return -EIO;
> -	}
> +	pci_restore_state(pci);
>  	if (pci_enable_device(pci) < 0) {
>  		printk(KERN_ERR "cs5535audio: pci_enable_device failed, "
>  		       "disabling device\n");
> 
