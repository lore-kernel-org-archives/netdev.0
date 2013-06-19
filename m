From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/5] Bluetooth: Add RFCOMM TTY write return error codes
Date: Wed, 19 Jun 2013 22:01:59 +0400
Message-ID: <51C1F217.6050808@cogentembedded.com>
References: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com> <1371656071-27754-2-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:63673 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934815Ab3FSSB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:01:57 -0400
Received: by mail-lb0-f180.google.com with SMTP id o10so5020807lbi.11
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:01:55 -0700 (PDT)
In-Reply-To: <1371656071-27754-2-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 07:34 PM, Dean Jenkins wrote:

> It appears that rfcomm_tty_write() does not check that the
> passed in TTY device_data is not NULL and also does not check
> that the RFCOMM DLC serial data link pointer is not NULL.

> A kernel crash was observed whilst SLIP was bound to /dev/rfcomm0
> but the /dev/rfcomm0 had subsequently disconnected. Unfortunately,
> SLIP attempted to write to the now non-existant RFCOMM TTY device
> which caused a NULL pointer dereference because the device_data
> no longer existed.

> Therefore, add NULL pointer checks for the dev and dlc pointers
> and output kernel error debug to show that NULL had been detected.

> Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
> ---
>   net/bluetooth/rfcomm/tty.c | 14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)

> diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
> index b6e44ad..56d28d1 100644
> --- a/net/bluetooth/rfcomm/tty.c
> +++ b/net/bluetooth/rfcomm/tty.c
> @@ -761,12 +761,24 @@ static void rfcomm_tty_close(struct tty_struct *tty, struct file *filp)
>   static int rfcomm_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
>   {
>   	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
> -	struct rfcomm_dlc *dlc = dev->dlc;
> +	struct rfcomm_dlc *dlc;
>   	struct sk_buff *skb;
>   	int err = 0, sent = 0, size;
>
>   	BT_DBG("tty %p count %d", tty, count);
>
> +	if (!dev) {
> +		BT_ERR("RFCOMM TTY device data structure does not exist");
> +		return -ENODEV;
> +	}
> +
> +	dlc = dev->dlc;
> +

    I don't think empty line is needed here.

> +	if (!dlc) {
> +		BT_ERR("RFCOMM serial data link does not exist");
> +		return -ENOLINK;
> +	}
> +

WBR, Sergei
