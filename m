From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Mon, 10 Dec 2012 14:18:21 +0000
Message-ID: <CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w@mail.gmail.com>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
	<1355140301-10518-1-git-send-email-steve.glendinning@shawell.net>
	<1404210.ufpq7a3oeI@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>,
	Ming Lei <ming.lei@canonical.com>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:50461 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2LJOSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 09:18:23 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1106821eaa.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 06:18:21 -0800 (PST)
In-Reply-To: <1404210.ufpq7a3oeI@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 December 2012 12:09, Oliver Neukum <oliver@neukum.org> wrote:
> So this is a problem with remote wakeup on older hardware?

Exactly, the older hardware revisions can't reliably do it.

>> Unfortunately we don't know if the connected device supports
>> this feature until we query its ID register at runtime.
>>
>> Suggestions on how best to indicate this capability at runtime
>> instead of compile-time would be appreciated, so we don't have
>> to repeatedly fail if accidentally enabled.  Or maybe this is
>> actually the best way?
>
> If this is a problem with remote wakeup, you should up the
> pm counter (usb_autopm_get_noresume()) in .manage_power
> That was the reason I implemented this is a callback and not as
> a helper in usbnet.

Thanks, so something like this should do the job?

static int smsc95xx_manage_power(struct usbnet *dev, int on)
{
struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);

dev->intf->needs_remote_wakeup = on;

if (pdata->features & FEATURE_AUTOSUSPEND)
return 0;

/* this chip revision doesn't support autosuspend */
netdev_info(dev->net, "hardware doesn't support USB autosuspend\n");

if (on)
usb_autopm_get_interface_no_resume(dev->intf);
else
usb_autopm_put_interface_no_suspend(dev->intf);

return 0;
}
