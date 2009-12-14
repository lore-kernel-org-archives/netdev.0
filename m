From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Mon, 14 Dec 2009 22:39:38 +0100
Message-ID: <4B26B09A.7050607@gmail.com>
References: <20091214175211.GA5102@nowhere> <4B2690E7.4030303@gmail.com> <20091214205231.GB5037@nowhere> <4B26AD65.1020004@gmail.com> <20091214213002.GA5203@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756374AbZLNVjt@vger.kernel.org>
In-Reply-To: <20091214213002.GA5203@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/12/2009 22:30, Frederic Weisbecker a =E9crit :
> On Mon, Dec 14, 2009 at 10:25:57PM +0100, Eric Dumazet wrote:
>> Le 14/12/2009 21:52, Frederic Weisbecker a =E9crit :
>>>
>>> I also wonder. Are you using PREEMPT_RCU ?
>>
>> Not at all :)
>>
>> But yes, this is illegal to do the memcpy_fromiovec() in rcu_read_lo=
ck() context.
>=20
>=20
> I've just tested, and with rcu preempt it is mute, no warning :)
>=20
>=20
>>> That may explain why you haven't seen this issue because
>>> might_sleep() doesn't see you are in a rcu read locked
>>> section as preemption is not disabled, but it is illegal to
>>> voluntarily sleep in such area (although it's fine with
>>> preempt rcu) as doing so with non-prempt RCU config would barf.
>>>
>>> I'm trying a patch to handle that.
>>
>> As you want, I also have a patch testing right now :)
>=20
>=20
> But mine is to teach might_sleep() to handle rcu preempt case,
> not to fix this net dev thing.
>=20
> But I'll happily test the fix you have :)
>=20

OK here it is, I tested it with PREEMPT_RCU as well

Thanks !

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0205621..bc17351 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -415,7 +415,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, =
struct socket *sock,
 {
 	struct sock *sk =3D sock->sk;
 	struct sockaddr_pkt *saddr =3D (struct sockaddr_pkt *)msg->msg_name;
-	struct sk_buff *skb;
+	struct sk_buff *skb =3D NULL;
 	struct net_device *dev;
 	__be16 proto =3D 0;
 	int err;
@@ -437,6 +437,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, =
struct socket *sock,
 	 */
=20
 	saddr->spkt_device[13] =3D 0;
+retry:
 	rcu_read_lock();
 	dev =3D dev_get_by_name_rcu(sock_net(sk), saddr->spkt_device);
 	err =3D -ENODEV;
@@ -456,58 +457,48 @@ static int packet_sendmsg_spkt(struct kiocb *iocb=
, struct socket *sock,
 	if (len > dev->mtu + dev->hard_header_len)
 		goto out_unlock;
=20
-	err =3D -ENOBUFS;
-	skb =3D sock_wmalloc(sk, len + LL_RESERVED_SPACE(dev), 0, GFP_KERNEL)=
;
-
-	/*
-	 * If the write buffer is full, then tough. At this level the user
-	 * gets to deal with the problem - do your own algorithmic backoffs.
-	 * That's far more flexible.
-	 */
-
-	if (skb =3D=3D NULL)
-		goto out_unlock;
-
-	/*
-	 *	Fill it in
-	 */
-
-	/* FIXME: Save some space for broken drivers that write a
-	 * hard header at transmission time by themselves. PPP is the
-	 * notable one here. This should really be fixed at the driver level.
-	 */
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	skb_reset_network_header(skb);
-
-	/* Try to align data part correctly */
-	if (dev->header_ops) {
-		skb->data -=3D dev->hard_header_len;
-		skb->tail -=3D dev->hard_header_len;
-		if (len < dev->hard_header_len)
-			skb_reset_network_header(skb);
+	if (!skb) {
+		size_t reserved =3D LL_RESERVED_SPACE(dev);
+		unsigned int hhlen =3D dev->header_ops ? dev->hard_header_len : 0;
+
+		rcu_read_unlock();
+		skb =3D sock_wmalloc(sk, len + reserved, 0, GFP_KERNEL);
+		if (skb =3D=3D NULL)
+			return -ENOBUFS;
+		skb_reserve(skb, reserved);
+		/* FIXME: Save some space for broken drivers that write a hard
+		 * header at transmission time by themselves. PPP is the notable
+		 * one here. This should really be fixed at the driver level.
+		 */
+		skb_reset_network_header(skb);
+
+		/* Try to align data part correctly */
+		if (hhlen) {
+			skb->data -=3D hhlen;
+			skb->tail -=3D hhlen;
+			if (len < hhlen)
+				skb_reset_network_header(skb);
+		}
+		err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+		if (err)
+			goto out_free;
+		goto retry;
 	}
=20
-	/* Returns -EFAULT on error */
-	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+
 	skb->protocol =3D proto;
 	skb->dev =3D dev;
 	skb->priority =3D sk->sk_priority;
 	skb->mark =3D sk->sk_mark;
-	if (err)
-		goto out_free;
-
-	/*
-	 *	Now send it
-	 */
=20
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
 	return len;
=20
-out_free:
-	kfree_skb(skb);
 out_unlock:
 	rcu_read_unlock();
+out_free:
+	kfree_skb(skb);
 	return err;
 }
=20
