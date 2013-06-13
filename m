From: Dave Kilroy <kilroyd-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] orinoco_usb: fix memory leak in ezusb_access_ltv() when
 device disconnected
Date: Thu, 13 Jun 2013 23:12:44 +0100
Message-ID: <51BA43DC.7050805@gmail.com>
References: <1371155171-15398-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1371155171-15398-1-git-send-email-khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/06/2013 21:26, Alexey Khoroshilov wrote:
> If "device is disconnected" check occurs to be true in ezusb_access_ltv(),
> it just return -ENODEV. But that means request_context is leaked since
> there are no any references to it anymore.
> The patch adds a call to ezusb_request_context_put() before return.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
> ---
>   drivers/net/wireless/orinoco/orinoco_usb.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
> index 1f9cb55..bdfe637 100644
> --- a/drivers/net/wireless/orinoco/orinoco_usb.c
> +++ b/drivers/net/wireless/orinoco/orinoco_usb.c
> @@ -881,7 +881,8 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
>   
>   	if (!upriv->udev) {
>   		dbg("Device disconnected");
> -		return -ENODEV;
> +		retval = -ENODEV;
> +		goto exit;
>   	}
>   
>   	if (upriv->read_urb->status != -EINPROGRESS)
It looks like there is also loss of a request_context in
ezusb_xmit after orinoco_process_xmit_skb fails. Something like
the following should resolve it.

The remaining request_context allocations look ok to me.


Dave.
---
Apologies, this is cut+paste from an old tree and mangled to be
diff-like. Untested. Uncompiled.

diff a/drivers/net/wireless/orinoco/orinoco_usb.c 
b/drivers/net/wireless/orinoco/orinoco_usb.c
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -1194,8 +1194,10 @@ static netdev_tx_t ezusb_xmit(struct sk_buff 
*skb, struct net_device *dev)

     err = orinoco_process_xmit_skb(skb, dev, priv, &tx_control,
                        &mic[0]);
-    if (err)
+    if (err) {
+        ezusb_request_context_put(ctx);
         goto drop;
+    }

     {
         __le16 *tx_cntl = (__le16 *)buf;

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
