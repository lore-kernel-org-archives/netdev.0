From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] wl12xx: fix DMA-API-related warnings
Date: Sat, 17 Mar 2012 16:44:14 +0000
Message-ID: <201203171644.14573.arnd@arndb.de>
References: <1332001592-17074-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mircea Gherzan <mgherzan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1332001592-17074-1-git-send-email-mgherzan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 17 March 2012, Mircea Gherzan wrote:
>  int wl1271_event_handle(struct wl1271 *wl, u8 mbox_num)
>  {
> -       struct event_mailbox mbox;
> -       int ret;
> +       struct event_mailbox *mbox;
> +       int ret = 0;
>  
>         wl1271_debug(DEBUG_EVENT, "EVENT on mbox %d", mbox_num);
>  
>         if (mbox_num > 1)
>                 return -EINVAL;
>  
> +       /* no GFP_ATOMIC: we're called from the threaded IRQ handler */
> +       mbox = kmalloc(sizeof(*mbox), GFP_DMA);
> +
>         /* first we read the mbox descriptor */
> -       wl1271_read(wl, wl->mbox_ptr[mbox_num], &mbox,
> -                   sizeof(struct event_mailbox), false);
> +       wl1271_read(wl, wl->mbox_ptr[mbox_num], mbox, sizeof(*mbox), false);
>  
>         /* process the descriptor */
> -       ret = wl1271_event_process(wl, &mbox);
> +       ret = wl1271_event_process(wl, mbox);
>         if (ret < 0)
> -               return ret;
> +               goto out;
>  
>         /* then we let the firmware know it can go on...*/
>         wl1271_write32(wl, ACX_REG_INTERRUPT_TRIG, INTR_TRIG_EVENT_ACK);
>  
> -       return 0;
> +out:
> +       kfree(mbox);
> +       return ret;
>  }

I think it would be better here to put another field into struct wl1271 to hold
the mailbox. There is no point allocating and freeing the field every time
you get into the interrupt handler.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
