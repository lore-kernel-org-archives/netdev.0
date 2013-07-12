From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Fri, 12 Jul 2013 11:14:03 -0700
Message-ID: <CAP6odjiviidL87Tijg1+H4Z6E+WVNP4nPx=7YR-1=a8_rpJtbA@mail.gmail.com>
References: <CAP6odjhsL8QPKwurP_H88M3kAoBW-z_jGHtEhL0Tj7AfZNutHA@mail.gmail.com>
	<20130712180116.21176.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54591 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964778Ab3GLSOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 14:14:04 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd20so11749324obb.33
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 11:14:04 -0700 (PDT)
In-Reply-To: <20130712180116.21176.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 11:01 AM, George Spelvin <linux@horizon.com> wrote:
>> Hi George,
>> While you are right that functionally it doesn't matter, my preference
>> would be to have nothing between the wmb() and iowrite() that kicks
>> off the TX. This marginally helps kick off the TX process consistently
>> slightly sooner. On modern HW, probably irrelevant, but not on the HW
>> these chips are used on.
>
> I'll revise it.  It just made sense to me to put it next to the other
> bookkeeping line of tp->cur_tx++.  Should I move them both below the
> iowrite()?

I would prefer that. I agree it's better to keep those two lines of
code together.

Just keep in mind this is a nit and it's not critical to accepting your change.
So whatever you submit, I'll probably ACK.

>  As in:
>
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -702,11 +702,11 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
>         tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
>         wmb();
>
> -       tp->cur_tx++;
> -
>         /* Trigger an immediate transmit demand. */
>         iowrite32(0, tp->base_addr + CSR1);
>
> +       tp->cur_tx++;
> +       netdev_sent_queue(dev, skb->len);
>         spin_unlock_irqrestore(&tp->lock, flags);
>
>         return NETDEV_TX_OK;

Yup - looks good.

>> Lastly, given I haven't powered up a system in two years which has
>> tulip, any one want to take over maintainer for tulip driver?
>> It's basically obsolete with a few rare patches like this one coming in.
>
> I'm not up to it myself, sorry.

No worries. Just wanted to advertise to anyone who bothers to read
about tulip patches. :)

cheers,
grant
