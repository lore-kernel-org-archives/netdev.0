From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Fix locking in flush_backlog
Date: Tue, 23 Mar 2010 08:56:17 -0700
Message-ID: <65634d661003230856v3d1737dehf64a883c1e785333@mail.gmail.com>
References: <alpine.DEB.1.00.1003222257470.3718@pokey.mtv.corp.google.com>
	 <1269325757.3043.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36681 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850Ab0CWP4W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 11:56:22 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o2NFuLY1020245
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 08:56:21 -0700
Received: from fg-out-1718.google.com (fge22.prod.google.com [10.86.5.22])
	by kpbe20.cbf.corp.google.com with ESMTP id o2NFuIkq022854
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 08:56:20 -0700
Received: by fg-out-1718.google.com with SMTP id 22so1301404fge.11
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 08:56:17 -0700 (PDT)
In-Reply-To: <1269325757.3043.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 11:29 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 22 mars 2010 =E0 23:04 -0700, Tom Herbert a =E9crit :
>> Need to take spinlocks when dequeuing from input_pkt_queue in
>> flush_backlog. =A0Also, with the spinlock the backlog queues can
>> be flushed directly from netdev_run_todo.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a03aab4..e7db656 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2765,20 +2765,6 @@ int netif_receive_skb(struct sk_buff *skb)
>> =A0}
>> =A0EXPORT_SYMBOL(netif_receive_skb);
>>
>> -/* Network device is going away, flush any packets still pending =A0=
*/
>> -static void flush_backlog(void *arg)
>> -{
>> - =A0 =A0 struct net_device *dev =3D arg;
>> - =A0 =A0 struct softnet_data *queue =3D &__get_cpu_var(softnet_data=
);
>> - =A0 =A0 struct sk_buff *skb, *tmp;
>> -
>> - =A0 =A0 skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (skb->dev =3D=3D dev) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_unlink(skb, &queue->=
input_pkt_queue);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> -}
>> -
>> =A0static int napi_gro_complete(struct sk_buff *skb)
>> =A0{
>> =A0 =A0 =A0 struct packet_type *ptype;
>> @@ -5545,6 +5531,7 @@ void netdev_run_todo(void)
>> =A0 =A0 =A0 while (!list_empty(&list)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct net_device *dev
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D list_first_entry(&li=
st, struct net_device, todo_list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int i;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&dev->todo_list);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(dev->reg_state !=3D NETREG_=
UNREGISTERING)) {
>> @@ -5556,7 +5543,22 @@ void netdev_run_todo(void)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->reg_state =3D NETREG_UNREGISTERED;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(flush_backlog, dev, 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Flush backlog queues of any pending pac=
kets */
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(i) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *queue=
 =3D &per_cpu(softnet_data, i);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb, *tmp;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&queue->=
input_pkt_queue.lock, flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk_safe(&queue=
->input_pkt_queue, skb, tmp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->d=
ev =3D=3D dev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 __skb_unlink(skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &queue->input_pkt_queue);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 kfree_skb(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&qu=
eue->input_pkt_queue.lock,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_wait_allrefs(dev);
>>
>
> OK (this is a patch for net-next-2.6)
>
> Could you please keep the function, to ease netdev_run_todo() review =
?
>

Eric,

I'm not sure what you're asking.  Do you just want to add spinlocks in
the flush_backlog function without changing the mechanism to call the
function on each CPU, or keep flush_backlog but call it from
netdev_run_todo for each queue?

Tom
