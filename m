From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Tue, 28 Jan 2014 14:28:28 -0800
Message-ID: <1390948108.28432.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E81631.50607@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46842 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422AbaA1W23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 17:28:29 -0500
Received: by mail-pd0-f171.google.com with SMTP id g10so916884pdj.2
        for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 14:28:29 -0800 (PST)
In-Reply-To: <52E81631.50607@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-28 at 21:42 +0100, Oliver Hartkopp wrote:
> Commit 376c7311bdb6 (net: add a temporary sanity check in skb_orphan())
> leads to a BUG in can_put_echo_skb() when skb_orphan() is executed.
> When skbuffs created automatically in bcm_can_tx() in softirq (netrx, timer)
> and userspace context the precise timing has to be met. A sock wmem accouting
> is pointless for this use case.
> 
> This patch introduces an empty skb destructor like in commit 072017b41e49
> (net: sctp: Add rudimentary infrastructure to account for control chunks)
> to make the cyclic transmission of CAN frames work again on real CAN
> netdevices. Virtual CAN interfaces do not need skb_orphan().
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> ---
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 3fc737b..82af1a5 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -237,6 +237,11 @@ static const struct file_operations bcm_proc_fops = {
>  	.release	= single_release,
>  };
>  
> +static void bcm_skb_destructor(struct sk_buff *skb)
> +{
> +	/* no accounting needed for bcm_can_tx() */
> +}
> +
>  /*
>   * bcm_can_tx - send the (next) CAN frame to the appropriate CAN interface
>   *              of the given bcm tx op
> @@ -267,6 +272,7 @@ static void bcm_can_tx(struct bcm_op *op)
>  	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
>  
>  	/* send with loopback */
> +	skb->destructor = bcm_skb_destructor;
>  	skb->dev = dev;
>  	skb->sk = op->sk;
>  	can_send(skb, 1);
> 


You do not explain why its safe to keep a reference on a socket without
incrementing a refcount.

Instead of understanding the issue, it seems this patch exactly shutup
the useful warning.

If you set skb->sk, then you expect a future reader of skb->sk to be
100% sure the socket did not disappear.

I do not see this explained in the changelog.
