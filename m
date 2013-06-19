From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/5] SLIP: Handle error codes from the TTY layer
Date: Wed, 19 Jun 2013 22:00:37 +0400
Message-ID: <51C1F1C5.6080901@cogentembedded.com>
References: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com> <1371656071-27754-3-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:63088 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933869Ab3FSSAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:00:35 -0400
Received: by mail-lb0-f171.google.com with SMTP id 13so5070957lba.30
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:00:34 -0700 (PDT)
In-Reply-To: <1371656071-27754-3-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dean.

On 06/19/2013 07:34 PM, Dean Jenkins wrote:

> It appears that SLIP does not handle error codes from the TTY layer.
> This will result in a malfunction because the remaining length of
> data will be corrupted by the negative error code values from the TTY
> layer.

> Therefore, add error code checks in sl_encaps() and sl_encaps_wakeup()
> to prevent the corruption of the sent data length.

> Note that SLIP is connectionless so on TTY error indicate that all data
> was sent. It seems SLIP does not return error codes to the network
> layer.

> Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
> ---
>   drivers/net/slip/slip.c | 26 ++++++++++++++++++++++----
>   1 file changed, 22 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
> index a34d6bf..bed819f 100644
> --- a/drivers/net/slip/slip.c
> +++ b/drivers/net/slip/slip.c
[...]
> @@ -404,7 +404,16 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
>   	 *       14 Oct 1994  Dmitry Gorodchanin.
>   	 */
>   	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
> -	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
> +	err = sl->tty->ops->write(sl->tty, sl->xbuff, count);
> +

    I don't think empty line is needed here.

> +	if (err < 0) {
> +		/* error case, say all was sent as connectionless */
> +		actual = count;
> +	} else {
> +		/* good case, err contains the number sent */
> +		actual = err;
> +	}
> +
>   #ifdef SL_CHECK_TRANSMIT
>   	sl->dev->trans_start = jiffies;
>   #endif
[...]
> @@ -438,7 +447,16 @@ static void slip_write_wakeup(struct tty_struct *tty)
>   		return;
>   	}
>
> -	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
> +	err = tty->ops->write(tty, sl->xhead, sl->xleft);
> +

    Neither here.

> +	if (err < 0) {
> +		/* error case, say all was sent as connectionless */
> +		actual = sl->xleft;
> +	} else {
> +		/* good case, err contains the number sent */
> +		actual = err;
> +	}
> +

WBR, Sergei
