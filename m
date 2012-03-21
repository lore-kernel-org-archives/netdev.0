From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 13:30:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1203211328320.1369-100000@iolanthe.rowland.org>
References: <CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2012, Ming Lei wrote:

> So looks the correct fix should be below:
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 4b8b52c..e36a821 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -588,7 +588,7 @@ static int unlink_urbs (struct usbnet *dev, struct
> sk_buff_head *q)
> 
>  		entry = (struct skb_data *) skb->cb;
>  		urb = entry->urb;
> -
> +		usb_get_urb(urb);
>  		spin_unlock_irqrestore(&q->lock, flags);
>  		// during some PM-driven resume scenarios,
>  		// these (async) unlinks complete immediately
> @@ -597,6 +597,7 @@ static int unlink_urbs (struct usbnet *dev, struct
> sk_buff_head *q)
>  			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
>  		else
>  			count++;
> +		usb_put_urb(urb);
>  		spin_lock_irqsave(&q->lock, flags);
>  	}
>  	spin_unlock_irqrestore (&q->lock, flags);
> @@ -1028,7 +1029,6 @@ static void tx_complete (struct urb *urb)
>  	}
> 
>  	usb_autopm_put_interface_async(dev->intf);
> -	urb->dev = NULL;
>  	entry->state = tx_done;
>  	defer_bh(dev, skb, &dev->txq);
>  }

Yes, that looks about right.  But I'm not familiar with the details of 
usbnet.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
