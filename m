From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tuntap: Fix for a race in accessing numqueue
Date: Fri, 17 Jan 2014 17:30:19 -0800
Message-ID: <1390008619.31367.503.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390004815-7052-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Maxim Krasnyansky <maxk@qualcomm.com>
To: Dominic Curran <dominic.curran@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:63141 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaARBaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:30:22 -0500
Received: by mail-yk0-f169.google.com with SMTP id q9so2562911ykb.0
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 17:30:22 -0800 (PST)
In-Reply-To: <1390004815-7052-1-git-send-email-dominic.curran@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-18 at 00:26 +0000, Dominic Curran wrote:
> A patch for fixing a race between queue selection and changing queues
> was introduced in commit 92bb73ea2c434618a68a5.
> 
> The fix was to prevent the driver from re-reading the tun->numqueues
> more than once within tun_select_queue().
> 
> We have been experiancing  'Divide-by-zero' errors in 
> tun_net_xmit() since we moved from 3.6 to 3.10, and believe that they 
> come from a simular source where the value of tun->numqueues changes 
> to zero between the first and second read of tun->numqueues.
> 
> Signed-off-by: Dominic Curran <dominic.curran@citrix.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Maxim Krasnyansky <maxk@qualcomm.com>
> 
> ---
>  drivers/net/tun.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: net-next/drivers/net/tun.c
> ===================================================================
> --- net-next.orig/drivers/net/tun.c	2014-01-17 23:41:54.000000000 +0000
> +++ net-next/drivers/net/tun.c	2014-01-17 23:51:55.000000000 +0000
> @@ -738,12 +738,14 @@ static netdev_tx_t tun_net_xmit(struct s
>  	struct tun_struct *tun = netdev_priv(dev);
>  	int txq = skb->queue_mapping;
>  	struct tun_file *tfile;
> +	u32 numqueues = 0;
>  
>  	rcu_read_lock();
>  	tfile = rcu_dereference(tun->tfiles[txq]);
> +	numqueues = ACCESS_ONCE(tun->numqueues);
>  
>  	/* Drop packet if interface is not attached */
> -	if (txq >= tun->numqueues)
> +	if (txq >= numqueues)
>  		goto drop;
>  
>  	if (tun->numqueues == 1) {

This is net-next tree, not net tree

(This part was added in commit 9bc8893937c83)

You might change this "tun->numqueues" as well.

> @@ -780,7 +782,7 @@ static netdev_tx_t tun_net_xmit(struct s
>  	 * number of queues.
>  	 */
>  	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
> -			  >= dev->tx_queue_len / tun->numqueues)
> +			  >= dev->tx_queue_len / numqueues)
>  		goto drop;

Could use a multiply instead....

if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues >=
dev->tx_queue_len )


Please submit this patch on net tree, since its a bug fix.
