From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Sun, 02 Mar 2008 20:29:58 +0000
Message-ID: <47CB0E46.9000806@katalix.com>
References: <20080226200033.GA6550@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37625 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205AbYCBUaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 15:30:02 -0500
In-Reply-To: <20080226200033.GA6550@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> James Chapman wrote, On 02/26/2008 01:14 PM:
> ...
>> Luckily, I'm in the lab where my two borrowed servers are today so I 
>> have access to their consoles. Hopefully I'll be able to find out why 
>> there are hanging. Btw, they don't hang if I disable irqs around the 
>> ppp_input() call.
> 
> Maybe you've found the same, or there is some other reason yet, but
> IMHO this locking break around ppp_input() is wrong. Probably there
> is needed more advanced solution, but this should fix the problem if
> it really exists (isn't there possible a race e.g. between receive
> from socket and from network card?).

I tried your patch but the result is the same.

> 
> Jarek P.
> ---
> 
>  drivers/net/pppol2tp.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> index e0b072d..7c6fcb9 100644
> --- a/drivers/net/pppol2tp.c
> +++ b/drivers/net/pppol2tp.c
> @@ -363,18 +363,17 @@ out:
>  	spin_unlock(&session->reorder_q.lock);
>  }
>  
> -/* Dequeue a single skb.
> +/* Requeue a single skb.
>   */
> -static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
> +static void pppol2tp_recv_requeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
>  {
>  	struct pppol2tp_tunnel *tunnel = session->tunnel;
>  	int length = PPPOL2TP_SKB_CB(skb)->length;
>  	struct sock *session_sock = NULL;
>  
> -	/* We're about to requeue the skb, so unlink it and return resources
> +	/* We're about to requeue the skb, so return resources
>  	 * to its current owner (a socket receive buffer).
>  	 */
> -	skb_unlink(skb, &session->reorder_q);
>  	skb_orphan(skb);
>  
>  	tunnel->stats.rx_packets++;
> @@ -436,14 +435,14 @@ static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct s
>  static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
>  {
>  	struct sk_buff *skb;
> -	struct sk_buff *tmp;
>  
>  	/* If the pkt at the head of the queue has the nr that we
>  	 * expect to send up next, dequeue it and any other
>  	 * in-sequence packets behind it.
>  	 */
> +again:
>  	spin_lock(&session->reorder_q.lock);
> -	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
> +	skb_queue_walk(&session->reorder_q, skb) {

I think this needs the _safe() call because the list may be modified in 
the loop body.

>  		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
>  			session->stats.rx_seq_discards++;
>  			session->stats.rx_errors++;
> @@ -469,9 +468,10 @@ static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
>  				goto out;
>  			}
>  		}
> +		__skb_unlink(skb, &session->reorder_q);
>  		spin_unlock(&session->reorder_q.lock);
> -		pppol2tp_recv_dequeue_skb(session, skb);
> -		spin_lock(&session->reorder_q.lock);
> +		pppol2tp_recv_requeue_skb(session, skb);
> +		goto again;

I'd prefer to take the spinlock again after the recv_dequeue_skb() call 
to avoid the goto.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

