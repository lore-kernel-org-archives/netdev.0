From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Mon, 06 Oct 2008 17:07:11 -0500
Message-ID: <48EA8C0F.5060802@acm.org>
References: <20081006185026.GA10383@minyard.local>
 <48EA8197.6080502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:33132 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbYJFWH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:07:28 -0400
In-reply-to: <48EA8197.6080502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Corey Minyard a =E9crit :
>> Change the UDP hash lock from an rwlock to RCU.
>>
>> Signed-off-by: Corey Minyard <cminyard@mvista.com>
>> ---
>>  include/net/udp.h |    9 +++++----
>>  net/ipv4/udp.c    |   47=20
>> +++++++++++++++++++++++++++--------------------
>>  net/ipv6/udp.c    |   17 +++++++++--------
>>  3 files changed, 41 insertions(+), 32 deletions(-)
>>
>> diff --git a/include/net/udp.h b/include/net/udp.h
>> index addcdc6..35aa104 100644
>> --- a/include/net/udp.h
>> +++ b/include/net/udp.h
>> @@ -51,7 +51,7 @@ struct udp_skb_cb {
>>  #define UDP_SKB_CB(__skb)    ((struct udp_skb_cb *)((__skb)->cb))
>> =20
>>  extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
>> -extern rwlock_t udp_hash_lock;
>> +extern spinlock_t udp_hash_wlock;
>> =20
>> =20
>>  /* Note: this must match 'valbool' in sock_setsockopt */
>> @@ -112,12 +112,13 @@ static inline void udp_lib_hash(struct sock *s=
k)
>> =20
>>  static inline void udp_lib_unhash(struct sock *sk)
>>  {
>> -    write_lock_bh(&udp_hash_lock);
>> -    if (sk_del_node_init(sk)) {
>> +    spin_lock_bh(&udp_hash_wlock);
>> +    if (sk_del_node_init_rcu(sk)) {
>>          inet_sk(sk)->num =3D 0;
>>          sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>>      }
>> -    write_unlock_bh(&udp_hash_lock);
>> +    spin_unlock_bh(&udp_hash_wlock);
>> +    synchronize_rcu();
>
> UDP central rwlock can hurt performance, because of cache line ping p=
ong,
> so your patch really makes sense.
>
> Me wondering what impact this synchronize_rcu() can have on mono-thre=
aded
> VOIP applications using lot of UDP sockets. What is the maximum delay=
 of
> this function ?
It delays until all currently executing RCU read-side sections have=20
executed (new ones don't count, just currently executing ones).  I'm no=
t=20
sure what this delay is, but I would expect it to be fairly small.  Thi=
s=20
function is only called when a socket is closed, too, so it's not a=20
high-runner.  Paul would certainly know better than me.

>
> For "struct file" freeing, we chose call_rcu() instead of=20
> synchronize_rcu()
I'd prefer that, too, but that would mean adding another member to the=20
socket structure.

>
> Maybe we could add a generic rcu head to struct sock, and use=20
> call_rcu() in
> sk_prot_free() for sockets needing RCU (udp after your patch is=20
> applied, maybe
> tcp on future patches, while I believe previous work on the subject=20
> concluded
> RCU was not giving good results for short lived http sessions) ?
RCU probably wouldn't be a good choice for short-lived http sessions,=20
since you will only get a couple of messages that would matter.  I'm no=
t=20
against adding an item to struct sock, but this is not a common thing=20
and struct sock was already big and ugly.

>
> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free() done=
=20
> in sk_prot_free() can defer freeing to RCU...
That's an interesting thought; I didn't know that capability was there.=
 =20
I can look at that.  With this, the short-lived TCP sessions might not=20
matter, though that's a different issue.

-corey
