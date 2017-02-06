From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Mon, 6 Feb 2017 10:10:07 +0200
Message-ID: <20170206081007.3isiato45t7fnzre@p310>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:54198 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751247AbdBFIyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 03:54:44 -0500
Content-Disposition: inline
In-Reply-To: <20170204165631.GW3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-04 16:56:32, Ben Hutchings wrote:
> Allocating USB buffers on the stack is not portable, and no longer
> works on x86_64 (with VMAP_STACK enabled as per default).
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
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
> +	kfree(buf);
> +	return ret;
>  }
>  
> -static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
> +static int set_registers(rtl8150_t * dev, u16 indx, u16 size, const void *data)
>  {
> -	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> -			       RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
> -			       indx, 0, data, size, 500);
> +	void *buf;
> +	int ret;
> +
> +	buf = kmemdup(data, size, GFP_NOIO);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	ret = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> +			      RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
> +			      indx, 0, buf, size, 500);
> +	kfree(buf);
> +	return ret;
>  }
>  
>  static void async_set_reg_cb(struct urb *urb)
> 


ACK.


cheers,
Petko
