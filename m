From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: fix waitqueue_active without memory barrier
 in brcmfmac driver
Date: Sat, 10 Oct 2015 09:42:23 +0200
Message-ID: <5618C15F.2030706@broadcom.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A02874785@BPXM09GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kosuke Tatsukawa <tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A02874785-9lrffkYxhwTt6d3pZDjeaEtBU8KWyXPq@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/09/2015 02:35 AM, Kosuke Tatsukawa wrote:
> brcmf_msgbuf_ioctl_resp_wake() seems to be missing a memory barrier
> which might cause the waker to not notice the waiter and miss sending a
> wake_up as in the following figure.
> 
>    brcmf_msgbuf_ioctl_resp_wake		    brcmf_msgbuf_ioctl_resp_wait
> ------------------------------------------------------------------------
> if (waitqueue_active(&msgbuf->ioctl_resp_wait))
> /* The CPU might reorder the test for
>     the waitqueue up here, before
>     prior writes complete */
>     	   	     	 	       /* wait_event_timeout */
> 				        /* __wait_event_timeout */
> 					 /* ___wait_event */
> 					 prepare_to_wait_event(&wq, &__wait,
> 					   state);
> 					 if (msgbuf->ctl_completed)
> 					 ...
> msgbuf->ctl_completed = true;
> 					 schedule_timeout(__ret))
> ------------------------------------------------------------------------
> 
> There are three other place in drivers/net/wireless/brcm80211/brcmfmac/
> which have similar code.  The attached patch removes the call to
> waitqueue_active() leaving just wake_up() behind.  This fixes the
> problem because the call to spin_lock_irqsave() in wake_up() will be an
> ACQUIRE operation.
> 
> I found this issue when I was looking through the linux source code
> for places calling waitqueue_active() before wake_up*(), but without
> preceding memory barriers, after sending a patch to fix a similar
> issue in drivers/tty/n_tty.c  (Details about the original issue can be
> found here: https://lkml.org/lkml/2015/9/28/849).

I prefer to add proper barriers instead of removing waitqueue_active()
check. We will review your patch and submit it through our upstream process.

Regards,
Arend

> Signed-off-by: Kosuke Tatsukawa <tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c |    3 +--
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c   |    6 ++----
>   drivers/net/wireless/brcm80211/brcmfmac/usb.c    |    3 +--
>   3 files changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> index 7b2136c..648151e 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> @@ -473,8 +473,7 @@ static int brcmf_msgbuf_ioctl_resp_wait(struct brcmf_msgbuf *msgbuf)
>   static void brcmf_msgbuf_ioctl_resp_wake(struct brcmf_msgbuf *msgbuf)
>   {
>   	msgbuf->ctl_completed = true;
> -	if (waitqueue_active(&msgbuf->ioctl_resp_wait))
> -		wake_up(&msgbuf->ioctl_resp_wait);
> +	wake_up(&msgbuf->ioctl_resp_wait);
>   }
>   
>   
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> index f990e3d..332c4c8 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> @@ -1785,8 +1785,7 @@ static int brcmf_sdio_dcmd_resp_wait(struct brcmf_sdio *bus, uint *condition,
>   
>   static int brcmf_sdio_dcmd_resp_wake(struct brcmf_sdio *bus)
>   {
> -	if (waitqueue_active(&bus->dcmd_resp_wait))
> -		wake_up_interruptible(&bus->dcmd_resp_wait);
> +	wake_up_interruptible(&bus->dcmd_resp_wait);
>   
>   	return 0;
>   }
> @@ -2110,8 +2109,7 @@ static uint brcmf_sdio_readframes(struct brcmf_sdio *bus, uint maxframes)
>   static void
>   brcmf_sdio_wait_event_wakeup(struct brcmf_sdio *bus)
>   {
> -	if (waitqueue_active(&bus->ctrl_wait))
> -		wake_up_interruptible(&bus->ctrl_wait);
> +	wake_up_interruptible(&bus->ctrl_wait);
>   	return;
>   }
>   
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> index daba86d..7f5889c 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> @@ -184,8 +184,7 @@ static int brcmf_usb_ioctl_resp_wait(struct brcmf_usbdev_info *devinfo)
>   
>   static void brcmf_usb_ioctl_resp_wake(struct brcmf_usbdev_info *devinfo)
>   {
> -	if (waitqueue_active(&devinfo->ioctl_resp_wait))
> -		wake_up(&devinfo->ioctl_resp_wait);
> +	wake_up(&devinfo->ioctl_resp_wait);
>   }
>   
>   static void
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
