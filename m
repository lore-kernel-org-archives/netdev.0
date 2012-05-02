From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 01/14 v3] usb/net: rndis: inline the cpu_to_le32() macro
Date: Wed, 2 May 2012 09:44:22 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EFE@saturn3.aculab.com>
References: <1335896100-12469-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jussi Kivilinna" <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	"Haiyang Zhang" <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	"Wei Yongjun" <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	"Ben Hutchings" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Felipe Balbi" <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1335896100-12469-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
> [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Linus Walleij
> Sent: 01 May 2012 19:15
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Greg 
> Kroah-Hartman; David S. Miller; Felipe Balbi
> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben 
> Hutchings; Linus Walleij
> Subject: [PATCH 01/14 v3] usb/net: rndis: inline the 
> cpu_to_le32() macro
> 
> The header file <linux/usb/rndis_host.h> used a number of #defines
> that included the cpu_to_le32() macro to assure the result will be
> in LE endianness. Inlining this into the code instead of using it
> in the code definitions yields consolidation opportunities later
> on as you will see in the following patches. The individual
> drivers also used local defines - all are switched over to the
> pattern of doing the conversion at the call sites instead.
> 
> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/usb/rndis_host.c      |   52 +++++++-------
>  drivers/net/wireless/rndis_wlan.c |  138 
> +++++++++++++++++++------------------
>  include/linux/usb/rndis_host.h    |   84 +++++++++++-----------
>  3 files changed, 139 insertions(+), 135 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c 
> b/drivers/net/usb/rndis_host.c
> index c8f1b5b..05cad0b 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -78,10 +78,10 @@ static void rndis_msg_indicate(struct 
> usbnet *dev, struct rndis_indicate *msg,
>  		dev->driver_info->indication(dev, msg, buflen);
>  	} else {
>  		switch (msg->status) {
> -		case RNDIS_STATUS_MEDIA_CONNECT:
> +		case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
>  			dev_info(udev, "rndis media connect\n");
>  			break;

I don't actually see how this helps!
It seems to make the code more unreadable and more likely to
be wrong (due to typos/coding slipups etc).
I didn't see anything in the earlier versions of the patches
where leaving the constants 'host endian' helped.

I also actually suspect that the generated code for some of the
switch statements would be better if the 'status' were byteswapped.
In particular it might allow the compiler to use a jump table
(when all the case labels are in one set of values).

	David


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
