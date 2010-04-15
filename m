From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 22:30:32 +0200
Message-ID: <1271363432.16881.3080.camel@edumazet-laptop>
References: <1271318553.16881.2161.camel@edumazet-laptop>
	 <20100415.012607.15449571.davem@davemloft.net>
	 <1271321507.16881.2244.camel@edumazet-laptop>
	 <20100415.020619.00349859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:35508 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756776Ab0DOUao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 16:30:44 -0400
Received: by bwz25 with SMTP id 25so2136338bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 13:30:42 -0700 (PDT)
In-Reply-To: <20100415.020619.00349859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 02:06 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 15 Apr 2010 10:51:47 +0200
>=20
> > In any case, I think there is a fundamental problem with this sk
> > caching. Because one packet can travel in many stacked devices befo=
re
> > hitting the wire.
> >=20
> > (bonding, vlan, ethernet) for example.
> >=20
> > Socket cache is meaningfull for one level only...
>=20
> We were talking the other day about that 'tun' change to orphan the
> SKB on TX, and I mentioned the possibility of just doing this in some
> generic location before we give the packet to the device ->xmit()
> method.
>=20
> Such a scheme could help with this problem too.

Same thing we did with=20

if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
	skb_dst_drop(skb);

in dev_hard_start_xmit() ?

Problem is this skb_tstamp_tx() thing....

One possibility would be to change skb_orphan() to let everything done
by destructor.=20

One more argument would let destructor() know if this is the final
destructor() called from skb_release_head_state()

destructor() would be responsible to set skb->destructor and/or skb->sk
to NULL when possible.=20


All normal destructors would not care of this 2nd argument and just do
what they actually do, plus setting skb->sk =3D NULL, skb->destructor =3D
NULL

=46ast path would stay as today, no extra test.

Only tstamp users would need to setup another destructor, a bit more
complex (it would have to take a look at 2nd argument before really
doing the job)


Completely untested patch to get the idea :
(to be completed for the tstamp thing)


 include/linux/skbuff.h         |    8 +++-----
 include/net/sctp/sctp.h        |    2 +-
 include/net/sock.h             |    4 ++--
 net/caif/caif_socket.c         |    4 +++-
 net/core/dev.c                 |   26 +++++++++-----------------
 net/core/skbuff.c              |    2 +-
 net/core/sock.c                |    8 ++++++--
 net/l2tp/l2tp_core.c           |    4 +++-
 net/netfilter/nf_tproxy_core.c |    2 +-
 net/packet/af_packet.c         |    4 ++--
 net/unix/af_unix.c             |    4 ++--
 11 files changed, 33 insertions(+), 35 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 38501d2..7dfd833 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -353,7 +353,7 @@ struct sk_buff {
 	kmemcheck_bitfield_end(flags1);
 	__be16			protocol;
=20
-	void			(*destructor)(struct sk_buff *skb);
+	void			(*destructor)(struct sk_buff *skb, int final);
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 	struct nf_conntrack	*nfct;
 	struct sk_buff		*nfct_reasm;
@@ -1407,15 +1407,13 @@ static inline void pskb_trim_unique(struct sk_b=
uff *skb, unsigned int len)
  *	@skb: buffer to orphan
  *
  *	If a buffer currently has an owner then we call the owner's
- *	destructor function and make the @skb unowned. The buffer continues
+ *	destructor function. The buffer continues
  *	to exist but is no longer charged to its former owner.
  */
 static inline void skb_orphan(struct sk_buff *skb)
 {
 	if (skb->destructor)
-		skb->destructor(skb);
-	skb->destructor =3D NULL;
-	skb->sk		=3D NULL;
+		skb->destructor(skb, 0);
 }
=20
 /**
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 5915155..49e2162 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -130,7 +130,7 @@ int sctp_inet_listen(struct socket *sock, int backl=
og);
 void sctp_write_space(struct sock *sk);
 unsigned int sctp_poll(struct file *file, struct socket *sock,
 		poll_table *wait);
-void sctp_sock_rfree(struct sk_buff *skb);
+void sctp_sock_rfree(struct sk_buff *skb, int final);
 void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..a042c9d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -988,8 +988,8 @@ extern struct sk_buff		*sock_wmalloc(struct sock *s=
k,
 extern struct sk_buff		*sock_rmalloc(struct sock *sk,
 					      unsigned long size, int force,
 					      gfp_t priority);
-extern void			sock_wfree(struct sk_buff *skb);
-extern void			sock_rfree(struct sk_buff *skb);
+extern void			sock_wfree(struct sk_buff *skb, int final);
+extern void			sock_rfree(struct sk_buff *skb, int final);
=20
 extern int			sock_setsockopt(struct socket *sock, int level,
 						int op, char __user *optval,
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index cdf62b9..4e7276a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -256,10 +256,12 @@ static void caif_sktflowctrl_cb(struct cflayer *l=
ayr,
 	}
 }
=20
-static void skb_destructor(struct sk_buff *skb)
+static void skb_destructor(struct sk_buff *skb, int final)
 {
 	dbfs_atomic_inc(&cnt.skb_free);
 	dbfs_atomic_dec(&cnt.skb_in_use);
+	skb->sk =3D NULL;
+	skb->destructor =3D NULL;
 }
=20
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index 876b111..9bffbe5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1828,12 +1828,12 @@ static int illegal_highdma(struct net_device *d=
ev, struct sk_buff *skb)
 }
=20
 struct dev_gso_cb {
-	void (*destructor)(struct sk_buff *skb);
+	void (*destructor)(struct sk_buff *skb, int final);
 };
=20
 #define DEV_GSO_CB(skb) ((struct dev_gso_cb *)(skb)->cb)
=20
-static void dev_gso_skb_destructor(struct sk_buff *skb)
+static void dev_gso_skb_destructor(struct sk_buff *skb, int final)
 {
 	struct dev_gso_cb *cb;
=20
@@ -1847,7 +1847,9 @@ static void dev_gso_skb_destructor(struct sk_buff=
 *skb)
=20
 	cb =3D DEV_GSO_CB(skb);
 	if (cb->destructor)
-		cb->destructor(skb);
+		cb->destructor(skb, final);
+	skb->sk =3D NULL;
+	skb->destructor =3D NULL;
 }
=20
 /**
@@ -1904,23 +1906,11 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
=20
+		skb_orphan(skb);
+
 		rc =3D ops->ndo_start_xmit(skb, dev);
 		if (rc =3D=3D NETDEV_TX_OK)
 			txq_trans_update(txq);
-		/*
-		 * TODO: if skb_orphan() was called by
-		 * dev->hard_start_xmit() (for example, the unmodified
-		 * igb driver does that; bnx2 doesn't), then
-		 * skb_tx_software_timestamp() will be unable to send
-		 * back the time stamp.
-		 *
-		 * How can this be prevented? Always create another
-		 * reference to the socket before calling
-		 * dev->hard_start_xmit()? Prevent that skb_orphan()
-		 * does anything in dev->hard_start_xmit() by clearing
-		 * the skb destructor before the call and restoring it
-		 * afterwards, then doing the skb_orphan() ourselves?
-		 */
 		return rc;
 	}
=20
@@ -1938,6 +1928,8 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
+		skb_orphan(nskb);
+
 		rc =3D ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bdea0ef..90c171f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -396,7 +396,7 @@ static void skb_release_head_state(struct sk_buff *=
skb)
 #endif
 	if (skb->destructor) {
 		WARN_ON(in_irq());
-		skb->destructor(skb);
+		skb->destructor(skb, 1);
 	}
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 	nf_conntrack_put(skb->nfct);
diff --git a/net/core/sock.c b/net/core/sock.c
index 7effa1e..fcf67ea 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1259,7 +1259,7 @@ void __init sk_init(void)
 /*
  * Write buffer destructor automatically called from kfree_skb.
  */
-void sock_wfree(struct sk_buff *skb)
+void sock_wfree(struct sk_buff *skb, int final)
 {
 	struct sock *sk =3D skb->sk;
 	unsigned int len =3D skb->truesize;
@@ -1279,18 +1279,22 @@ void sock_wfree(struct sk_buff *skb)
 	 */
 	if (atomic_sub_and_test(len, &sk->sk_wmem_alloc))
 		__sk_free(sk);
+	skb->sk =3D NULL;
+	skb->destructor =3D NULL;
 }
 EXPORT_SYMBOL(sock_wfree);
=20
 /*
  * Read buffer destructor automatically called from kfree_skb.
  */
-void sock_rfree(struct sk_buff *skb)
+void sock_rfree(struct sk_buff *skb, int final)
 {
 	struct sock *sk =3D skb->sk;
=20
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_uncharge(skb->sk, skb->truesize);
+	skb->sk =3D NULL;
+	skb->destructor =3D NULL;
 }
 EXPORT_SYMBOL(sock_rfree);
=20
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 98dfcce..a3b0a95 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -973,9 +973,11 @@ EXPORT_SYMBOL_GPL(l2tp_xmit_core);
=20
 /* Automatically called when the skb is freed.
  */
-static void l2tp_sock_wfree(struct sk_buff *skb)
+static void l2tp_sock_wfree(struct sk_buff *skb, int final)
 {
 	sock_put(skb->sk);
+	skb->sk =3D NULL;
+	skb->destructor =3D NULL;
 }
=20
 /* For data skbs that we transmit, we associate with the tunnel socket
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_c=
ore.c
index 5490fc3..17dd2d9 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -55,7 +55,7 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 proto=
col,
 EXPORT_SYMBOL_GPL(nf_tproxy_get_sock_v4);
=20
 static void
-nf_tproxy_destructor(struct sk_buff *skb)
+nf_tproxy_destructor(struct sk_buff *skb, int final)
 {
 	struct sock *sk =3D skb->sk;
=20
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f162d59..dc8e843 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -808,7 +808,7 @@ ring_is_full:
 	goto drop_n_restore;
 }
=20
-static void tpacket_destruct_skb(struct sk_buff *skb)
+static void tpacket_destruct_skb(struct sk_buff *skb, int final)
 {
 	struct packet_sock *po =3D pkt_sk(skb->sk);
 	void *ph;
@@ -823,7 +823,7 @@ static void tpacket_destruct_skb(struct sk_buff *sk=
b)
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
 	}
=20
-	sock_wfree(skb);
+	sock_wfree(skb, final);
 }
=20
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *sk=
b,
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3d9122e..17fca55 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1303,7 +1303,7 @@ static void unix_detach_fds(struct scm_cookie *sc=
m, struct sk_buff *skb)
 		unix_notinflight(scm->fp->fp[i]);
 }
=20
-static void unix_destruct_fds(struct sk_buff *skb)
+static void unix_destruct_fds(struct sk_buff *skb, int final)
 {
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
@@ -1312,7 +1312,7 @@ static void unix_destruct_fds(struct sk_buff *skb=
)
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
 	scm_destroy(&scm);
-	sock_wfree(skb);
+	sock_wfree(skb, final);
 }
=20
 static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb=
)


