From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 10:24:57 +0800
Message-ID: <CACVXFVOBgwoSyUDzxD+ghjkpFu5PL7MuaS5UJOZYvVnV0dwhGg@mail.gmail.com>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
	<1355140301-10518-1-git-send-email-steve.glendinning@shawell.net>
	<1404210.ufpq7a3oeI@linux-lqwf.site>
	<CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 10, 2012 at 10:18 PM, Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org> wrote:
> On 10 December 2012 12:09, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
>> So this is a problem with remote wakeup on older hardware?
>
> Exactly, the older hardware revisions can't reliably do it.
>
>>> Unfortunately we don't know if the connected device supports
>>> this feature until we query its ID register at runtime.
>>>
>>> Suggestions on how best to indicate this capability at runtime
>>> instead of compile-time would be appreciated, so we don't have
>>> to repeatedly fail if accidentally enabled.  Or maybe this is
>>> actually the best way?
>>
>> If this is a problem with remote wakeup, you should up the
>> pm counter (usb_autopm_get_noresume()) in .manage_power
>> That was the reason I implemented this is a callback and not as
>> a helper in usbnet.
>
> Thanks, so something like this should do the job?

This will do, but not simple as clearing .manage_power function
pointer in bind(), and still disable runtime suspend for link off case
since these devices which don't support suspend 3 can generate
remote wakeup for link change event.

I suggest to introduce link-off triggered runtime suspend for these
usbnet devices(non-LAN9500A device, devices which don't support
USB auto-suspend), and I have posted one patch set before[1].
If no one objects that, I'd like to post them again with some fix and
update for checking link after link_reset().

[1], http://marc.info/?w=2&r=1&s=usbnet%3A+support+runtime+PM+triggered+by+&q=t

>
> static int smsc95xx_manage_power(struct usbnet *dev, int on)
> {
> struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
>
> dev->intf->needs_remote_wakeup = on;
>
> if (pdata->features & FEATURE_AUTOSUSPEND)
> return 0;
>
> /* this chip revision doesn't support autosuspend */
> netdev_info(dev->net, "hardware doesn't support USB autosuspend\n");
>
> if (on)
> usb_autopm_get_interface_no_resume(dev->intf);
> else
> usb_autopm_put_interface_no_suspend(dev->intf);
>
> return 0;
> }

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
