From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 11:54:47 +0300
Message-ID: <55A37CD7.9050104@yandex-team.ru>
References: <20150710115141.12980.88829.stgit@buzz> <20150713072352.GA8485@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:51258 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbbGMI4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:56:50 -0400
In-Reply-To: <20150713072352.GA8485@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.07.2015 10:23, Herbert Xu wrote:
> On Fri, Jul 10, 2015 at 02:51:41PM +0300, Konstantin Khlebnikov wrote:
>> This fixes race between non-atomic updates of adjacent bit-fields:
>> skb->cloned could be lost because netlink broadcast clones skb after
>> sending it to the first listener who sets skb->peeked at the same skb.
>> As a result atomic refcounting of skb header stays disabled and
>> skb_release_data() frees it twice. Race leads to double-free in kmalloc-xxx.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Fixes: b19372273164 ("net: reorganize sk_buff for faster __copy_skb_header()")
>> ---
>>   net/netlink/af_netlink.c |    6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index dea925388a5b..921e0d8dfe3a 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -2028,6 +2028,12 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
>>   	info.tx_filter = filter;
>>   	info.tx_data = filter_data;
>>
>> +	/* Enable atomic refcounting in skb_release_data() before first send:
>> +	 * non-atomic set of that bit-field in __skb_clone() could race with
>> +	 * __skb_recv_datagram() which touches the same set of bit-fields.
>> +	 */
>> +	skb->cloned = 1;
>> +
>>   	/* While we sleep in clone, do not allow to change socket list */
>>
>>   	netlink_lock_table();
>
> Your effort in finding this bug is wonderful.  However I think
> the fix is a bit dirty.
>
> The real issue here is that the recv path no longer handles shared
> skbs.  So either we need to fix the recv path to not touch skbs
> without cloning them, or we need to get rid of the use of shared
> skbs in netlink.

I don't think that recv path should care about shared skb -- skb can be
delivered into only one socket anyway.


Less dirty fix for that: do not send original skb.
That adds one extra clone but makes code much cleaner.


--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1957,17 +1957,16 @@ static void do_one_broadcast(struct sock *sk,
         }

         sock_hold(sk);
-       if (p->skb2 == NULL) {
-               if (skb_shared(p->skb)) {
-                       p->skb2 = skb_clone(p->skb, p->allocation);
-               } else {
-                       p->skb2 = skb_get(p->skb);
-                       /*
-                        * skb ownership may have been set when
-                        * delivered to a previous socket.
-                        */
-                       skb_orphan(p->skb2);
-               }
+       if (p->skb2 == NULL || skb_shared(p->skb2)) {
+               kfree_skb(p->skb2);
+               p->skb2 = skb_clone(p->skb, p->allocation);
+       } else {
+               skb_get(p->skb2);
+               /*
+                * skb ownership may have been set when
+                * delivered to a previous socket.
+                */
+               skb_orphan(p->skb2);
         }
         if (p->skb2 == NULL) {
                 netlink_overrun(sk);
@@ -1997,7 +1996,6 @@ static void do_one_broadcast(struct sock *sk,
         } else {
                 p->congested |= val;
                 p->delivered = 1;
-               p->skb2 = NULL;
         }
  out:
         sock_put(sk);



>
> In fact it looks I introduced the bug way back in
>
> commit a59322be07c964e916d15be3df473fb7ba20c41e
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Wed Dec 5 01:53:40 2007 -0800
>
>      [UDP]: Only increment counter on first peek/recv
>
> I will try to mend this error :)
>
> Cheers,
>


-- 
Konstantin
