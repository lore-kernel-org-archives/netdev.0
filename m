From: Stephane Grosjean <s.grosjean@peak-system.com>
Subject: Re: [PATCH 3/3] net: can: peak_usb: Do not do dma on the stack
Date: Thu, 12 Dec 2013 15:44:17 +0100
Message-ID: <52A9CBC1.4080809@peak-system.com>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
 <1370261733-22935-4-git-send-email-mkl@pengutronix.de>
Reply-To: Stephane Grosjean <s.grosjean@peak-system.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1370261733-22935-4-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

Going back into linux-can peak_usb, and I'm currently having a quick=20
look to what has changed during these several past months.
I agree with the below patch that fixes the "DMAusage with USB core"=20
issue, but - maybe I'm wrong - isn't there now amemory leak issue in=20
"pcan_usb_pro_init()" function below?

I mean, you now allocate "fi" and "bi" memory objects but, AFAIK, they=20
aren't freed anywhere in the function, don't they?

Regards,

St=E9phane

Le 03/06/2013 14:15, Marc Kleine-Budde a =E9crit :
> smatch reports the following warnings:
> drivers/net/can/usb/peak_usb/pcan_usb_pro.c:514 pcan_usb_pro_drv_load=
ed() error: doing dma on the stack (buffer)
> drivers/net/can/usb/peak_usb/pcan_usb_pro.c:878 pcan_usb_pro_init() e=
rror: doing dma on the stack (&fi)
> drivers/net/can/usb/peak_usb/pcan_usb_pro.c:889 pcan_usb_pro_init() e=
rror: doing dma on the stack (&bi)
>
> See "Documentation/DMA-API-HOWTO.txt" section "What memory is DMA'abl=
e?"
>
> Cc: Stephane Grosjean <s.grosjean@peak-system.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>   drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 61 ++++++++++++++++++=
+----------
>   drivers/net/can/usb/peak_usb/pcan_usb_pro.h |  1 +
>   2 files changed, 41 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/ne=
t/can/usb/peak_usb/pcan_usb_pro.c
> index 30d79bf..8ee9d15 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
> @@ -504,15 +504,24 @@ static int pcan_usb_pro_restart_async(struct pe=
ak_usb_device *dev,
>   	return usb_submit_urb(urb, GFP_ATOMIC);
>   }
>  =20
> -static void pcan_usb_pro_drv_loaded(struct peak_usb_device *dev, int=
 loaded)
> +static int pcan_usb_pro_drv_loaded(struct peak_usb_device *dev, int =
loaded)
>   {
> -	u8 buffer[16];
> +	u8 *buffer;
> +	int err;
> +
> +	buffer =3D kmalloc(PCAN_USBPRO_FCT_DRVLD_REQ_LEN, GFP_KERNEL);
> +	if (!buffer)
> +		return -ENOMEM;
>  =20
>   	buffer[0] =3D 0;
>   	buffer[1] =3D !!loaded;
>  =20
> -	pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_FCT,
> -			      PCAN_USBPRO_FCT_DRVLD, buffer, sizeof(buffer));
> +	err =3D pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_FCT,
> +				    PCAN_USBPRO_FCT_DRVLD, buffer,
> +				    PCAN_USBPRO_FCT_DRVLD_REQ_LEN);
> +	kfree(buffer);
> +
> +	return err;
>   }
>  =20
>   static inline
> @@ -851,21 +860,24 @@ static int pcan_usb_pro_stop(struct peak_usb_de=
vice *dev)
>    */
>   static int pcan_usb_pro_init(struct peak_usb_device *dev)
>   {
> -	struct pcan_usb_pro_interface *usb_if;
>   	struct pcan_usb_pro_device *pdev =3D
>   			container_of(dev, struct pcan_usb_pro_device, dev);
> +	struct pcan_usb_pro_interface *usb_if =3D NULL;
> +	struct pcan_usb_pro_fwinfo *fi =3D NULL;
> +	struct pcan_usb_pro_blinfo *bi =3D NULL;
> +	int err;
>  =20
>   	/* do this for 1st channel only */
>   	if (!dev->prev_siblings) {
> -		struct pcan_usb_pro_fwinfo fi;
> -		struct pcan_usb_pro_blinfo bi;
> -		int err;
> -
>   		/* allocate netdevices common structure attached to first one */
>   		usb_if =3D kzalloc(sizeof(struct pcan_usb_pro_interface),
>   				 GFP_KERNEL);
> -		if (!usb_if)
> -			return -ENOMEM;
> +		fi =3D kmalloc(sizeof(struct pcan_usb_pro_fwinfo), GFP_KERNEL);
> +		bi =3D kmalloc(sizeof(struct pcan_usb_pro_blinfo), GFP_KERNEL);
> +		if (!usb_if || !fi || !bi) {
> +			err =3D -ENOMEM;
> +			goto err_out;
> +		}
>  =20
>   		/* number of ts msgs to ignore before taking one into account */
>   		usb_if->cm_ignore_count =3D 5;
> @@ -877,34 +889,34 @@ static int pcan_usb_pro_init(struct peak_usb_de=
vice *dev)
>   		 */
>   		err =3D pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
>   					    PCAN_USBPRO_INFO_FW,
> -					    &fi, sizeof(fi));
> +					    fi, sizeof(*fi));
>   		if (err) {
> -			kfree(usb_if);
>   			dev_err(dev->netdev->dev.parent,
>   				"unable to read %s firmware info (err %d)\n",
>   				pcan_usb_pro.name, err);
> -			return err;
> +			goto err_out;
>   		}
>  =20
>   		err =3D pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
>   					    PCAN_USBPRO_INFO_BL,
> -					    &bi, sizeof(bi));
> +					    bi, sizeof(*bi));
>   		if (err) {
> -			kfree(usb_if);
>   			dev_err(dev->netdev->dev.parent,
>   				"unable to read %s bootloader info (err %d)\n",
>   				pcan_usb_pro.name, err);
> -			return err;
> +			goto err_out;
>   		}
>  =20
> +		/* tell the device the can driver is running */
> +		err =3D pcan_usb_pro_drv_loaded(dev, 1);
> +		if (err)
> +			goto err_out;
> +
>   		dev_info(dev->netdev->dev.parent,
>   		     "PEAK-System %s hwrev %u serial %08X.%08X (%u channels)\n",
>   		     pcan_usb_pro.name,
> -		     bi.hw_rev, bi.serial_num_hi, bi.serial_num_lo,
> +		     bi->hw_rev, bi->serial_num_hi, bi->serial_num_lo,
>   		     pcan_usb_pro.ctrl_count);
> -
> -		/* tell the device the can driver is running */
> -		pcan_usb_pro_drv_loaded(dev, 1);
>   	} else {
>   		usb_if =3D pcan_usb_pro_dev_if(dev->prev_siblings);
>   	}
> @@ -916,6 +928,13 @@ static int pcan_usb_pro_init(struct peak_usb_dev=
ice *dev)
>   	pcan_usb_pro_set_led(dev, 0, 1);
>  =20
>   	return 0;
> +
> + err_out:
> +	kfree(bi);
> +	kfree(fi);
> +	kfree(usb_if);
> +
> +	return err;
>   }
>  =20
>   static void pcan_usb_pro_exit(struct peak_usb_device *dev)
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h b/drivers/ne=
t/can/usb/peak_usb/pcan_usb_pro.h
> index a869918..32275af 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
> @@ -29,6 +29,7 @@
>  =20
>   /* Vendor Request value for XXX_FCT */
>   #define PCAN_USBPRO_FCT_DRVLD		5 /* tell device driver is loaded */
> +#define PCAN_USBPRO_FCT_DRVLD_REQ_LEN	16
>  =20
>   /* PCAN_USBPRO_INFO_BL vendor request record type */
>   struct __packed pcan_usb_pro_blinfo {

--
PEAK-System Technik GmbH, Otto-Roehm-Strasse 69, D-64293 Darmstadt=20
Geschaeftsleitung: A.Gach/U.Wilhelm,St.Nr.:007/241/13586 FA Darmstadt=20
HRB-9183 Darmstadt, Ust.IdNr.:DE 202220078, WEE-Reg.-Nr.: DE39305391=20
Tel.+49 (0)6151-817320 / Fax:+49 (0)6151-817329, info@peak-system.com
