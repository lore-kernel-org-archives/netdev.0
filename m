From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 3 Mar 2008 08:22:04 +0000
Message-ID: <20080303082204.GA4066@ff.dom.local>
References: <20080226200033.GA6550@ami.dom.local> <47CB0E46.9000806@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:23569 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbYCCIUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 03:20:54 -0500
Received: by nf-out-0910.google.com with SMTP id g13so3290842nfb.21
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 00:20:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47CB0E46.9000806@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 02, 2008 at 08:29:58PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> James Chapman wrote, On 02/26/2008 01:14 PM:
...
>
> I tried your patch but the result is the same.
>
>>
>> Jarek P.
>> ---
>>
>>  drivers/net/pppol2tp.c |   16 ++++++++--------
>>  1 files changed, 8 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
>> index e0b072d..7c6fcb9 100644
>> --- a/drivers/net/pppol2tp.c
>> +++ b/drivers/net/pppol2tp.c
>> @@ -363,18 +363,17 @@ out:
>>  	spin_unlock(&session->reorder_q.lock);
>>  }
>>  -/* Dequeue a single skb.
>> +/* Requeue a single skb.
>>   */
>> -static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
>> +static void pppol2tp_recv_requeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
>>  {
>>  	struct pppol2tp_tunnel *tunnel = session->tunnel;
>>  	int length = PPPOL2TP_SKB_CB(skb)->length;
>>  	struct sock *session_sock = NULL;
>>  -	/* We're about to requeue the skb, so unlink it and return resources
>> +	/* We're about to requeue the skb, so return resources
>>  	 * to its current owner (a socket receive buffer).
>>  	 */
>> -	skb_unlink(skb, &session->reorder_q);
>>  	skb_orphan(skb);
>>   	tunnel->stats.rx_packets++;
>> @@ -436,14 +435,14 @@ static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct s
>>  static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
>>  {
>>  	struct sk_buff *skb;
>> -	struct sk_buff *tmp;
>>   	/* If the pkt at the head of the queue has the nr that we
>>  	 * expect to send up next, dequeue it and any other
>>  	 * in-sequence packets behind it.
>>  	 */
>> +again:
>>  	spin_lock(&session->reorder_q.lock);
>> -	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
>> +	skb_queue_walk(&session->reorder_q, skb) {
>
> I think this needs the _safe() call because the list may be modified in  
> the loop body.

And you are very right.

>
>>  		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
>>  			session->stats.rx_seq_discards++;
>>  			session->stats.rx_errors++;
>> @@ -469,9 +468,10 @@ static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
>>  				goto out;
>>  			}
>>  		}
>> +		__skb_unlink(skb, &session->reorder_q);
>>  		spin_unlock(&session->reorder_q.lock);
>> -		pppol2tp_recv_dequeue_skb(session, skb);
>> -		spin_lock(&session->reorder_q.lock);
>> +		pppol2tp_recv_requeue_skb(session, skb);
>> +		goto again;
>
> I'd prefer to take the spinlock again after the recv_dequeue_skb() call  
> to avoid the goto.

IMHO we have to do something like goto here because during the unlock
there could be everything changed (including tmp) in this list, but
maybe I miss something.

Anyway, this place seems to need more locking, e.g.: session->nr++ or
some other session accesses in pppol2tp_recv_dequeue_skb() are done
without locking. Maybe it would be interesting to try (in a test only)
with calling this with reorder_q.lock held (so without unlocking
inside this pppol2tp_recv_dequeue's loop at all: at least to see
possible lockdep report. I can't see how this irq disabling could
help for anything but some recursion during those misterious lockups.

BTW, since this bug is so hard to trigger, and it can take some time
yet, I think it would be better to merge to David's 2.6.26 tree at
least some parts of your "bh" patch and maybe other changes, which
don't seem to make it worse at least, to try new things on some common
base?

Regards,
Jarek P.
