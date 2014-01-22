From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v3] tuntap: Fix for a race in accessing numqueues
Date: Wed, 22 Jan 2014 16:53:42 +0800
Message-ID: <52DF8716.2080706@redhat.com>
References: <1390359803-27989-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
To: Dominic Curran <dominic.curran@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbaAVIyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 03:54:17 -0500
In-Reply-To: <1390359803-27989-1-git-send-email-dominic.curran@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 11:03 AM, Dominic Curran wrote:
> A patch for fixing a race between queue selection and changing queues
> was introduced in commit 92bb73ea2("tuntap: fix a possible race between
> queue selection and changing queues").
>
> The fix was to prevent the driver from re-reading the tun->numqueues
> more than once within tun_select_queue() using ACCESS_ONCE().
>
> We have been experiancing 'Divide-by-zero' errors in tun_net_xmit() 
> since we moved from 3.6 to 3.10, and believe that they come from a 
> simular source where the value of tun->numqueues changes to zero 
> between the first and a subsequent read of tun->numqueues.
>
> The fix is a simular use of ACCESS_ONCE(), as well as a multiply
> instead of a divide in the if statement.
>
> Signed-off-by: Dominic Curran <dominic.curran@citrix.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
> ---
> V3: Rebase against net-next. Include all numqueues in function.
> V2: Use multiply instead of divide. Suggested by Eric Dumazet.
>     Fixed email address for maxk. Rebase against net tree.
> ---
>  drivers/net/tun.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> Index: net-next/drivers/net/tun.c
> ===================================================================
> --- net-next.orig/drivers/net/tun.c	2014-01-22 02:50:01.000000000 +0000
> +++ net-next/drivers/net/tun.c	2014-01-22 02:59:42.000000000 +0000
> @@ -738,15 +738,17 @@ static netdev_tx_t tun_net_xmit(struct s
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
> -	if (tun->numqueues == 1) {
> +	if (numqueues == 1) {
>  		/* Select queue was not called for the skbuff, so we extract the
>  		 * RPS hash and save it into the flow_table here.
>  		 */
> @@ -779,8 +781,8 @@ static netdev_tx_t tun_net_xmit(struct s
>  	/* Limit the number of packets queued by dividing txq length with the
>  	 * number of queues.
>  	 */
> -	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
> -			  >= dev->tx_queue_len / tun->numqueues)
> +	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
> +			  >= dev->tx_queue_len)
>  		goto drop;
>  
>  	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))

Acked-by: Jason Wang <jasowang@redhat.com>
