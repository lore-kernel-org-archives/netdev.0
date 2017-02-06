From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH net 2/4] rtl8150: Use heap buffers for all register
 access
Date: Mon, 6 Feb 2017 16:09:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
To: 'Ben Hutchings' <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170204165631.GW3442-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings
> Sent: 04 February 2017 16:57
> Allocating USB buffers on the stack is not portable, and no longer
> works on x86_64 (with VMAP_STACK enabled as per default).
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
> ---
>  drivers/net/usb/rtl8150.c | 34 +++++++++++++++++++++++++++-------
>  1 file changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index 95b7bd0d7abc..c81c79110cef 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
> @@ -155,16 +155,36 @@ static const char driver_name [] = "rtl8150";
>  */
>  static int get_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
>  {
> -	return usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> -			       RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
> -			       indx, 0, data, size, 500);
> +	void *buf;
> +	int ret;
> +
> +	buf = kmalloc(size, GFP_NOIO);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> +			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
> +			      indx, 0, buf, size, 500);
> +	if (ret > 0 && ret <= size)
> +		memcpy(data, buf, ret);

If ret > size something is horridly wrong.
Silently not updating the callers buffer at all cannot be right.

> +	kfree(buf);
> +	return ret;

I can't help feeling that it would be better to add a wrapper to
usb_control_msg() that does the kmalloc() and memcpy()s and
drop that into all the call sites.

	David

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
