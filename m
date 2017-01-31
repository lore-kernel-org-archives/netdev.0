From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] r8152: Allocate interrupt buffer as part of struct r8152
Date: Tue, 31 Jan 2017 11:53:31 -0800
Message-ID: <1485892411.6360.139.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485889577-4389-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485889577-4389-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-01-31 at 11:06 -0800, Guenter Roeck wrote:
> When unloading the r8152 driver using the 'unbind' sysfs attribute
> in a system with KASAN enabled, the following error message is seen
> on a regular basis.

>  
>  static int alloc_all_mem(struct r8152 *tp)
> @@ -1423,10 +1420,6 @@ static int alloc_all_mem(struct r8152 *tp)
>  	if (!tp->intr_urb)
>  		goto err1;
>  
> -	tp->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
> -	if (!tp->intr_buff)
> -		goto err1;
> -
>  	tp->intr_interval = (int)ep_intr->desc.bInterval;
>  	usb_fill_int_urb(tp->intr_urb, tp->udev, usb_rcvintpipe(tp->udev, 3),
>  			 tp->intr_buff, INTBUFSIZE, intr_callback,

This might lead to intr_buff being backed by vzalloc() instead of
kzalloc() (check alloc_netdev_mqs())

It looks like it could cause a bug.



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
