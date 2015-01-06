From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net-next] tg3: move init/deinit from open/close to
 probe/remove
Date: Tue, 6 Jan 2015 13:57:27 -0800
Message-ID: <1420581447.10407.11.camel@prashant>
References: <1420576122-23618-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:15267 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbbAFWOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:14:48 -0500
In-Reply-To: <1420576122-23618-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 21:28 +0100, Ivan Vecera wrote:
> Move init and deinit of PTP support from open/close functions
> to probe/remove funcs to avoid removing/re-adding of associated PTP
> device(s) during ifup/ifdown.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 553dcd8..e86bee4 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -11681,13 +11681,6 @@ static int tg3_open(struct net_device *dev)
>  		pci_set_power_state(tp->pdev, PCI_D3hot);
>  	}
>  
> -	if (tg3_flag(tp, PTP_CAPABLE)) {
> -		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
> -						   &tp->pdev->dev);
> -		if (IS_ERR(tp->ptp_clock))
> -			tp->ptp_clock = NULL;
> -	}
> -
>  	return err;
>  }
>  
> @@ -11701,8 +11694,6 @@ static int tg3_close(struct net_device *dev)
>  		return -EAGAIN;
>  	}
>  
> -	tg3_ptp_fini(tp);
> -
>  	tg3_stop(tp);
>  
>  	/* Clear stats across close / open calls */
> @@ -17880,6 +17871,13 @@ static int tg3_init_one(struct pci_dev *pdev,
>  		goto err_out_apeunmap;
>  	}
>  
> +	if (tg3_flag(tp, PTP_CAPABLE)) {
> +		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
> +						   &tp->pdev->dev);
> +		if (IS_ERR(tp->ptp_clock))
> +			tp->ptp_clock = NULL;
> +	}
> +
>  	netdev_info(dev, "Tigon3 [partno(%s) rev %04x] (%s) MAC address %pM\n",
>  		    tp->board_part_number,
>  		    tg3_chip_rev_id(tp),
> @@ -17955,6 +17953,8 @@ static void tg3_remove_one(struct pci_dev *pdev)
>  	if (dev) {
>  		struct tg3 *tp = netdev_priv(dev);
>  
> +		tg3_ptp_fini(tp);
> +
>  		release_firmware(tp->fw);
>  
>  		tg3_reset_task_cancel(tp);

tg3_ptp_init() needs to be called before ptp_clock_register() to
initialize the HW and poplulate the ptp_clock_info structure. Could you
please test after making this change. Thanks.
