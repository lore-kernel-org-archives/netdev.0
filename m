From: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Subject: Re: [Patch 1/1]: libertas/sdio: fix releasing memory twice.
Date: Sun, 13 Oct 2013 09:09:55 +0200
Message-ID: <47ACD120-9393-41EA-BF8A-4E5E316A0C79@goldelico.com>
References: <D5BD8103-A6A6-4070-878B-99FC5883725F@goldelico.com> <1381607911.21655.7.camel@dcbw.foobar.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>, Harro Haan <hrhaan@gmail.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Belisko Marek <marek@goldelico.com>,
	NeilBrown Brown <neilb@suse.de>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381607911.21655.7.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

Am 12.10.2013 um 21:58 schrieb Dan Williams:

> On Sat, 2013-10-12 at 18:02 +0200, Dr. H. Nikolaus Schaller wrote:
>> While upgrading the GTA04 kernel to 3.12-rc4 we came across
>> an issue with libertas/sdio referencing stale memory on ifconfig up
>> when trying to load the firmware (for a second time).
>> 
>> I am not at all sure if the patch is how it should be done and the right
>> location, but it appears to work for us with resetting priv->helper_fw to NULL
>> before asynchronously loading the firmware again.
> 
> How about we go even simpler?  helper_fw is *only* used inside
> firmware.c anyway, and that's probably where its lifetime should be
> handled.  Same for the main firmware.  I have no idea why the bus code
> is responsible for releasing the firmware anyway, when it originates
> from firmware.c and control returns back there after the firmware loaded
> callback is done.  Does the following patch fix your problem too?

Yes, it works!

I think your approach is much better from software architecture point
of view than our hack.

Thank you,
Nikolaus

> 
> Dan
> 
> ---
> diff --git a/drivers/net/wireless/libertas/firmware.c b/drivers/net/wireless/libertas/firmware.c
> index c0f9e7e..51b92b5 100644
> --- a/drivers/net/wireless/libertas/firmware.c
> +++ b/drivers/net/wireless/libertas/firmware.c
> @@ -49,14 +49,19 @@ static void main_firmware_cb(const struct firmware *firmware, void *context)
> 		/* Failed to find firmware: try next table entry */
> 		load_next_firmware_from_table(priv);
> 		return;
> 	}
> 
> 	/* Firmware found! */
> 	lbs_fw_loaded(priv, 0, priv->helper_fw, firmware);
> +	if (priv->helper_fw) {
> +		release_firmware (priv->helper_fw);
> +		priv->helper_fw = NULL;
> +	}
> +	release_firmware (firmware);
> }
> 
> static void helper_firmware_cb(const struct firmware *firmware, void *context)
> {
> 	struct lbs_private *priv = context;
> 
> 	if (!firmware) {
> diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
> index c94dd68..ef8c98e 100644
> --- a/drivers/net/wireless/libertas/if_cs.c
> +++ b/drivers/net/wireless/libertas/if_cs.c
> @@ -750,22 +750,22 @@ static void if_cs_prog_firmware(struct lbs_private *priv, int ret,
> 	}
> 
> 	/* Load the firmware */
> 	ret = if_cs_prog_helper(card, helper);
> 	if (ret == 0 && (card->model != MODEL_8305))
> 		ret = if_cs_prog_real(card, mainfw);
> 	if (ret)
> -		goto out;
> +		return;
> 
> 	/* Now actually get the IRQ */
> 	ret = request_irq(card->p_dev->irq, if_cs_interrupt,
> 		IRQF_SHARED, DRV_NAME, card);
> 	if (ret) {
> 		pr_err("error in request_irq\n");
> -		goto out;
> +		return;
> 	}
> 
> 	/*
> 	 * Clear any interrupt cause that happened while sending
> 	 * firmware/initializing card
> 	 */
> 	if_cs_write16(card, IF_CS_CARD_INT_CAUSE, IF_CS_BIT_MASK);
> @@ -773,18 +773,14 @@ static void if_cs_prog_firmware(struct lbs_private *priv, int ret,
> 
> 	/* And finally bring the card up */
> 	priv->fw_ready = 1;
> 	if (lbs_start_card(priv) != 0) {
> 		pr_err("could not activate card\n");
> 		free_irq(card->p_dev->irq, card);
> 	}
> -
> -out:
> -	release_firmware(helper);
> -	release_firmware(mainfw);
> }
> 
> 
> /********************************************************************/
> /* Callback functions for libertas.ko                               */
> /********************************************************************/
> 
> diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> index 4557833..991238a 100644
> --- a/drivers/net/wireless/libertas/if_sdio.c
> +++ b/drivers/net/wireless/libertas/if_sdio.c
> @@ -704,28 +704,24 @@ static void if_sdio_do_prog_firmware(struct lbs_private *priv, int ret,
> 	if (ret) {
> 		pr_err("failed to find firmware (%d)\n", ret);
> 		return;
> 	}
> 
> 	ret = if_sdio_prog_helper(card, helper);
> 	if (ret)
> -		goto out;
> +		return;
> 
> 	lbs_deb_sdio("Helper firmware loaded\n");
> 
> 	ret = if_sdio_prog_real(card, mainfw);
> 	if (ret)
> -		goto out;
> +		return;
> 
> 	lbs_deb_sdio("Firmware loaded\n");
> 	if_sdio_finish_power_on(card);
> -
> -out:
> -	release_firmware(helper);
> -	release_firmware(mainfw);
> }
> 
> static int if_sdio_prog_firmware(struct if_sdio_card *card)
> {
> 	int ret;
> 	u16 scratch;
> 
> diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
> index 4bb6574..87ff0ca 100644
> --- a/drivers/net/wireless/libertas/if_spi.c
> +++ b/drivers/net/wireless/libertas/if_spi.c
> @@ -1090,19 +1090,15 @@ static int if_spi_init_card(struct if_spi_card *card)
> 	}
> 
> 	err = spu_set_interrupt_mode(card, 0, 1);
> 	if (err)
> 		goto out;
> 
> out:
> -	release_firmware(helper);
> -	release_firmware(mainfw);
> -
> 	lbs_deb_leave_args(LBS_DEB_SPI, "err %d\n", err);
> -
> 	return err;
> }
> 
> static void if_spi_resume_worker(struct work_struct *work)
> {
> 	struct if_spi_card *card;
> 
> diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
> index 2798077..dff08a2 100644
> --- a/drivers/net/wireless/libertas/if_usb.c
> +++ b/drivers/net/wireless/libertas/if_usb.c
> @@ -840,15 +840,15 @@ static void if_usb_prog_firmware(struct lbs_private *priv, int ret,
> 		pr_err("failed to find firmware (%d)\n", ret);
> 		goto done;
> 	}
> 
> 	cardp->fw = fw;
> 	if (check_fwfile_format(cardp->fw->data, cardp->fw->size)) {
> 		ret = -EINVAL;
> -		goto release_fw;
> +		goto done;
> 	}
> 
> 	/* Cancel any pending usb business */
> 	usb_kill_urb(cardp->rx_urb);
> 	usb_kill_urb(cardp->tx_urb);
> 
> 	cardp->fwlastblksent = 0;
> @@ -857,15 +857,15 @@ static void if_usb_prog_firmware(struct lbs_private *priv, int ret,
> 	cardp->fwfinalblk = 0;
> 	cardp->bootcmdresp = 0;
> 
> restart:
> 	if (if_usb_submit_rx_urb_fwload(cardp) < 0) {
> 		lbs_deb_usbd(&cardp->udev->dev, "URB submission is failed\n");
> 		ret = -EIO;
> -		goto release_fw;
> +		goto done;
> 	}
> 
> 	cardp->bootcmdresp = 0;
> 	do {
> 		int j = 0;
> 		i++;
> 		if_usb_issue_boot_command(cardp, BOOT_CMD_FW_BY_USB);
> @@ -879,22 +879,22 @@ restart:
> 	if (cardp->bootcmdresp == BOOT_CMD_RESP_NOT_SUPPORTED) {
> 		/* Return to normal operation */
> 		ret = -EOPNOTSUPP;
> 		usb_kill_urb(cardp->rx_urb);
> 		usb_kill_urb(cardp->tx_urb);
> 		if (if_usb_submit_rx_urb(cardp) < 0)
> 			ret = -EIO;
> -		goto release_fw;
> +		goto done;
> 	} else if (cardp->bootcmdresp <= 0) {
> 		if (--reset_count >= 0) {
> 			if_usb_reset_device(cardp);
> 			goto restart;
> 		}
> 		ret = -EIO;
> -		goto release_fw;
> +		goto done;
> 	}
> 
> 	i = 0;
> 
> 	cardp->totalbytes = 0;
> 	cardp->fwlastblksent = 0;
> 	cardp->CRC_OK = 1;
> @@ -917,37 +917,34 @@ restart:
> 		if (--reset_count >= 0) {
> 			if_usb_reset_device(cardp);
> 			goto restart;
> 		}
> 
> 		pr_info("FW download failure, time = %d ms\n", i * 100);
> 		ret = -EIO;
> -		goto release_fw;
> +		goto done;
> 	}
> 
> 	cardp->priv->fw_ready = 1;
> 	if_usb_submit_rx_urb(cardp);
> 
> 	if (lbs_start_card(priv))
> -		goto release_fw;
> +		goto done;
> 
> 	if_usb_setup_firmware(priv);
> 
> 	/*
> 	 * EHS_REMOVE_WAKEUP is not supported on all versions of the firmware.
> 	 */
> 	priv->wol_criteria = EHS_REMOVE_WAKEUP;
> 	if (lbs_host_sleep_cfg(priv, priv->wol_criteria, NULL))
> 		priv->ehs_remove_supported = false;
> 
> - release_fw:
> -	release_firmware(cardp->fw);
> -	cardp->fw = NULL;
> -
>  done:
> +	cardp->fw = NULL;
> 	lbs_deb_leave(LBS_DEB_USB);
> }
> 
> 
> #ifdef CONFIG_PM
> static int if_usb_suspend(struct usb_interface *intf, pm_message_t message)
> {
> 
> 
