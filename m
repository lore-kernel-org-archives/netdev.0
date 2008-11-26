From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: release skb->dst in sock_queue_rcv_skb()
Date: Wed, 26 Nov 2008 01:00:30 +0100
Message-ID: <492C919E.3050108@cosmosbay.com>
References: <492A7E85.3060502@cosmosbay.com>	<20081124.153954.215777060.davem@davemloft.net>	<492B8274.6080609@cosmosbay.com> <20081124.210038.90767194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080204080107080002030204"
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57680 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbYKZAAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 19:00:39 -0500
In-Reply-To: <20081124.210038.90767194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080204080107080002030204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 25 Nov 2008 05:43:32 +0100
>=20
>> Very interesting. So we could try the following path :
>>
>> 1) First try to release dst when queueing skb to various queues
>> (UDP, TCP, ...) while its hot. Reader wont have to release it
>> while its cold.
>>
>> 2) Check if we can handle the input path without any refcount
>>    dirtying ?
>>
>> To make the transition easy, we could use a bit on skb to mark
>> dst being not refcounted (ie no dst_release() should be done on it)
>=20
> It is possible to make this self-auditing.  For example, by
> using the usual trick where we encode a pointer in an
> unsigned long and use the low bits for states.
>=20
> In the first step, make each skb->dst access go through some
> accessor inline function.
>=20
> Next, audit the paths where skb->dst's can "escape" the pure
> packet input path.  Add annotations, in the form of a
> inline function call, for these locations.
>=20
> Also, audit the other locations where we enqueue into a socket
> queue and no longer care about the skb->dst, and annotate
> those with another inline function.
>=20
> Finally, the initial skb->dst assignment in the input path doesn't
> grab a reference, but sets the low bit ("refcount pending") in
> the encoded skb->dst pointer.  The skb->dst "escape" inline
> function performs the deferred refcount grab.  And kfree_skb()
> is taught to not dst_release() on skb->dst's which have the
> low bit set.
>=20
> Anyways, something like that.

I looked this stuff and found it would be difficult to not grab a=20
reference (and more important not writing to dst) in input path.

ip_rcv_finish() calls ip_route_input()
and ip_route_input() calls dst_use(&rth->u.dst, jiffies);

static inline void dst_use(struct dst_entry *dst, unsigned long time)
{
        dst_hold(dst);
        dst->__use++;
        dst->lastuse =3D time;
}

Even if we avoid the refcount increment, I guess we need the lastuse
assignement in order to keep dst in cache. Not sure about the role of
__use field. Hum... for a tcp connection, dst refcount should already
be pinned by a sk->sk_dst_cache. Maybe test refcount value, and if this
value is > 1, dont take a reference. (given rcu_read_lock() is done
before calling ip_rcv_finish())

In the meantime, what do you think of the following patch ?

[PATCH] net: release skb->dst in sock_queue_rcv_skb()

When queuing a skb to sk->sk_receive_queue, we can release its dst, not
anymore needed.
Since current cpu did the dst_hold(), refcount is probably still hot
int this cpu caches.

This avoids readers to access the original dst to decrement its refcount,=

possibly a long time after packet reception. This should speedup UDP
and RAW receive path.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------080204080107080002030204
Content-Type: text/plain;
 name="sock_queue_rcv_skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sock_queue_rcv_skb.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index a4e840e..b287645 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -289,7 +289,11 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
-
+	/*
+	 * release dst right now while its hot
+	 */
+	dst_release(skb->dst);
+	skb->dst = NULL;
 	/* Cache the SKB length before we tack it onto the receive
 	 * queue.  Once it is added it no longer belongs to us and
 	 * may be freed by other threads of control pulling packets

--------------080204080107080002030204--
