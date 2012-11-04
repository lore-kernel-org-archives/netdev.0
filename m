From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH v2 5/5] usbnet: make device out of suspend before calling
 usbnet_read[write]_cmd
Date: Sun, 04 Nov 2012 17:55:17 +0400
Message-ID: <509673C5.1090005@mvista.com>
References: <1352027793-6608-1-git-send-email-ming.lei@canonical.com> <1352027793-6608-6-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42510 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab2KDN4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 08:56:31 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so3606347lag.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 05:56:29 -0800 (PST)
In-Reply-To: <1352027793-6608-6-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-11-2012 15:16, Ming Lei wrote:

    s/make/wake/ in the subject?

> This patche gets the runtime PM reference count before calling

    s/patche/patch/

> usbnet_read[write]_cmd, and puts it after completion of the
> usbnet_read[write]_cmd, so that the usb control message can always

    You probably meant usbnet_{read|write}_cmd() here and in the subject?

> be sent to one active device in the non-PM context.

> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>   drivers/net/usb/usbnet.c |   18 ++++++++++++++----
>   1 file changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index a7fb074..74caa67 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1673,8 +1673,13 @@ out:
>   int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
>   		    u16 value, u16 index, void *data, u16 size)
>   {
> -	return __usbnet_read_cmd(dev, cmd, reqtype, value, index,
> -				 data, size);
> +	int ret;

    Empty line wouldn't hurt here, after declaration block.

> +	if (usb_autopm_get_interface(dev->intf) < 0)
> +		return -ENODEV;
> +	ret = __usbnet_read_cmd(dev, cmd, reqtype, value, index,
> +				data, size);
> +	usb_autopm_put_interface(dev->intf);
> +	return ret;
>   }
>   EXPORT_SYMBOL_GPL(usbnet_read_cmd);
>
> @@ -1685,8 +1690,13 @@ EXPORT_SYMBOL_GPL(usbnet_read_cmd);
>   int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
>   		     u16 value, u16 index, const void *data, u16 size)
>   {
> -	return __usbnet_write_cmd(dev, cmd, reqtype, value, index,
> -				  data, size);
> +	int ret;

    And here too...

> +	if (usb_autopm_get_interface(dev->intf) < 0)
> +		return -ENODEV;
> +	ret = __usbnet_write_cmd(dev, cmd, reqtype, value, index,
> +				 data, size);
> +	usb_autopm_put_interface(dev->intf);
> +	return ret;
>   }
>   EXPORT_SYMBOL_GPL(usbnet_write_cmd);

WBR, Sergei
