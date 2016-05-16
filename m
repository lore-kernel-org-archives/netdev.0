From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Mon, 16 May 2016 11:08:57 +0300
Message-ID: <20160516105434-mutt-send-email-mst@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <20160516070012-mutt-send-email-mst@redhat.com>
 <57397C2B.7000603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921AbcEPIJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 04:09:00 -0400
Content-Disposition: inline
In-Reply-To: <57397C2B.7000603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 03:52:11PM +0800, Jason Wang wrote:
>=20
>=20
> On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 12:23, Michael S. Tsirkin wrot=
e:
> >On Mon, May 16, 2016 at 09:17:01AM +0800, Jason Wang wrote:
> >>We used to queue tx packets in sk_receive_queue, this is less
> >>efficient since it requires spinlocks to synchronize between produc=
er
> >>and consumer.
> >>
> >>This patch tries to address this by using circular buffer which all=
ows
> >>lockless synchronization. This is done by switching from
> >>sk_receive_queue to a tx skb ring with a new flag IFF_TX_RING and w=
hen
> >>this is set:
> >Why do we need a new flag? Is there a userspace-visible
> >behaviour change?
>=20
> Probably yes since tx_queue_length does not work.

So the flag name should reflect the behaviour somehow, not
the implementation.

> >
> >>- store pointer to skb in circular buffer in tun_net_xmit(), and re=
ad
> >>   it from the circular buffer in tun_do_read().
> >>- introduce a new proto_ops peek which could be implemented by
> >>   specific socket which does not use sk_receive_queue.
> >>- store skb length in circular buffer too, and implement a lockless
> >>   peek for tuntap.
> >>- change vhost_net to use proto_ops->peek() instead
> >>- new spinlocks were introduced to synchronize among producers (and=
 so
> >>   did for consumers).
> >>
> >>Pktgen test shows about 9% improvement on guest receiving pps:
> >>
> >>Before: ~1480000pps
> >>After : ~1610000pps
> >>
> >>(I'm not sure noblocking read is still needed, so it was not includ=
ed
> >>  in this patch)
> >How do you mean? Of course we must support blocking and non-blocking
> >read - userspace uses it.
>=20
> Ok, will add this.
>=20
> >
> >>Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>---
> >>---
> >>  drivers/net/tun.c           | 157 +++++++++++++++++++++++++++++++=
++++++++++---
> >>  drivers/vhost/net.c         |  16 ++++-
> >>  include/linux/net.h         |   1 +
> >>  include/uapi/linux/if_tun.h |   1 +
> >>  4 files changed, 165 insertions(+), 10 deletions(-)
> >>
> >>diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>index 425e983..6001ece 100644
> >>--- a/drivers/net/tun.c
> >>+++ b/drivers/net/tun.c
> >>@@ -71,6 +71,7 @@
> >>  #include <net/sock.h>
> >>  #include <linux/seq_file.h>
> >>  #include <linux/uio.h>
> >>+#include <linux/circ_buf.h>
> >>  #include <asm/uaccess.h>
> >>@@ -130,6 +131,8 @@ struct tap_filter {
> >>  #define MAX_TAP_FLOWS  4096
> >>  #define TUN_FLOW_EXPIRE (3 * HZ)
> >>+#define TUN_RING_SIZE 256
> >Can we resize this according to tx_queue_len set by user?
>=20
> We can, but it needs lots of other changes, e.g being notified when
> tx_queue_len was changed by user.

Some kind of notifier?
Probably better than a new user interface.

> And if tx_queue_length is not power of 2,
> we probably need modulus to calculate the capacity.

Is that really that important for speed?
If yes, round it up to next power of two.
You can also probably wrap it with a conditional instead.

> >
> >>+#define TUN_RING_MASK (TUN_RING_SIZE - 1)
> >>  struct tun_pcpu_stats {
> >>  	u64 rx_packets;
> >>@@ -142,6 +145,11 @@ struct tun_pcpu_stats {
> >>  	u32 rx_frame_errors;
> >>  };
> >>+struct tun_desc {
> >>+	struct sk_buff *skb;
> >>+	int len; /* Cached skb len for peeking */
> >>+};
> >>+
> >>  /* A tun_file connects an open character device to a tuntap netde=
vice. It
> >>   * also contains all socket related structures (except sock_fprog=
 and tap_filter)
> >>   * to serve as one transmit queue for tuntap device. The sock_fpr=
og and
> >>@@ -167,6 +175,13 @@ struct tun_file {
> >>  	};
> >>  	struct list_head next;
> >>  	struct tun_struct *detached;
> >>+	/* reader lock */
> >>+	spinlock_t rlock;
> >>+	unsigned long tail;
> >>+	struct tun_desc tx_descs[TUN_RING_SIZE];
> >>+	/* writer lock */
> >>+	spinlock_t wlock;
> >>+	unsigned long head;
> >>  };
> >>  struct tun_flow_entry {
> >>@@ -515,7 +530,27 @@ static struct tun_struct *tun_enable_queue(str=
uct tun_file *tfile)
> >>  static void tun_queue_purge(struct tun_file *tfile)
> >>  {
> >>+	unsigned long head, tail;
> >>+	struct tun_desc *desc;
> >>+	struct sk_buff *skb;
> >>  	skb_queue_purge(&tfile->sk.sk_receive_queue);
> >>+	spin_lock(&tfile->rlock);
> >>+
> >>+	head =3D ACCESS_ONCE(tfile->head);
> >>+	tail =3D tfile->tail;
> >>+
> >>+	/* read tail before reading descriptor at tail */
> >>+	smp_rmb();
> >I think you mean read *head* here
>=20
> Right.
>=20
> >
> >
> >>+
> >>+	while (CIRC_CNT(head, tail, TUN_RING_SIZE) >=3D 1) {
> >>+		desc =3D &tfile->tx_descs[tail];
> >>+		skb =3D desc->skb;
> >>+		kfree_skb(skb);
> >>+		tail =3D (tail + 1) & TUN_RING_MASK;
> >>+		/* read descriptor before incrementing tail. */
> >>+		smp_store_release(&tfile->tail, tail & TUN_RING_MASK);
> >>+	}
> >>+	spin_unlock(&tfile->rlock);
> >>  	skb_queue_purge(&tfile->sk.sk_error_queue);
> >>  }
> >>
> >Barrier pairing seems messed up. Could you tag
> >each barrier with its pair pls?
> >E.g. add /* Barrier A for pairing */ Before barrier and
> >its pair.
>=20
> Ok.
>=20
> for both tun_queue_purge() and tun_do_read():
>=20
> smp_rmb() is paired with smp_store_release() in tun_net_xmit().

this seems at least an overkill. rmb would normally be paired with wmb,
not a full mb within release.

> smp_store_release() is paired with spin_unlock()/spin_lock() in
> tun_net_xmit().

release can't be paired with unlock since that's also a release.
lock is an acquire but from what I have seen you keep it around
operations not in the middle.

>=20
> >>@@ -824,6 +859,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff =
*skb, struct net_device *dev)
> >>  	int txq =3D skb->queue_mapping;
> >>  	struct tun_file *tfile;
> >>  	u32 numqueues =3D 0;
> >>+	unsigned long flags;
> >>  	rcu_read_lock();
> >>  	tfile =3D rcu_dereference(tun->tfiles[txq]);
> >>@@ -888,8 +924,35 @@ static netdev_tx_t tun_net_xmit(struct sk_buff=
 *skb, struct net_device *dev)
> >>  	nf_reset(skb);
> >>-	/* Enqueue packet */
> >>-	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
> >>+	if (tun->flags & IFF_TX_RING) {
> >>+		unsigned long head, tail;
> >>+
> >>+		spin_lock_irqsave(&tfile->wlock, flags);
> >>+
> >>+		head =3D tfile->head;
> >>+		tail =3D ACCESS_ONCE(tfile->tail);
> >this should be acquire
>=20
> Consider there's always one slot left empty, so we need to produced t=
wo skbs
> here before we could corrupt consumer. So the spin_unlock()/spin_lock=
()
> provides ordering here?

It's better to just follow memory barrier rules.


> >
> >>+ > >>+		if (CIRC_SPACE(head, tail, TUN_RING_SIZE) >=3D 1) {
> >>+			struct tun_desc *desc =3D &tfile->tx_descs[head];
> >>+
> >>+			desc->skb =3D skb;
> >>+			desc->len =3D skb->len;
> >>+			if (skb_vlan_tag_present(skb))
> >>+				desc->len +=3D VLAN_HLEN;
> >>+
> >>+			/* read descriptor before incrementing head. */
> >write descriptor.
>=20
> Right.
>=20
> >  so smp_wmb is enough.
>=20
> I thought smp_store_release() was more lightweight than smp_wmb()?

Why do you think this?  On which architecture?

> >
> >>+			smp_store_release(&tfile->head,
> >>+					  (head + 1) & TUN_RING_MASK);
> >>+		} else {
> >>+			spin_unlock_irqrestore(&tfile->wlock, flags);
> >>+			goto drop;
> >>+		}
> >>+
> >>+		spin_unlock_irqrestore(&tfile->wlock, flags);
> >>+	} else {
> >>+		/* Enqueue packet */
> >>+		skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
> >>+	}
> >>  	/* Notify and wake up reader process */
> >>  	if (tfile->flags & TUN_FASYNC)
> >>@@ -1085,6 +1148,13 @@ static void tun_net_init(struct net_device *=
dev)
> >>  	}
> >>  }
> >>+static bool tun_queue_not_empty(struct tun_file *tfile)
> >>+{
> >>+	struct sock *sk =3D tfile->socket.sk;
> >>+
> >>+	return (!skb_queue_empty(&sk->sk_receive_queue) ||
> >>+		ACCESS_ONCE(tfile->head) !=3D ACCESS_ONCE(tfile->tail));
> >>+}
> >>  /* Character device part */
> >>  /* Poll */
> >>@@ -1104,7 +1174,7 @@ static unsigned int tun_chr_poll(struct file =
*file, poll_table *wait)
> >>  	poll_wait(file, sk_sleep(sk), wait);
> >>-	if (!skb_queue_empty(&sk->sk_receive_queue))
> >>+	if (tun_queue_not_empty(tfile))
> >>  		mask |=3D POLLIN | POLLRDNORM;
> >>  	if (sock_writeable(sk) ||
> >>@@ -1494,11 +1564,36 @@ static ssize_t tun_do_read(struct tun_struc=
t *tun, struct tun_file *tfile,
> >>  	if (tun->dev->reg_state !=3D NETREG_REGISTERED)
> >>  		return -EIO;
> >>-	/* Read frames from queue */
> >>-	skb =3D __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTW=
AIT : 0,
> >>-				  &peeked, &off, &err);
> >>-	if (!skb)
> >>-		return err;
> >>+	if (tun->flags & IFF_TX_RING) {
> >>+		unsigned long head, tail;
> >>+		struct tun_desc *desc;
> >>+
> >>+		spin_lock(&tfile->rlock);
> >>+		head =3D ACCESS_ONCE(tfile->head);
> >>+		tail =3D tfile->tail;
> >>+
> >>+		if (CIRC_CNT(head, tail, TUN_RING_SIZE) >=3D 1) {
> >>+			/* read tail before reading descriptor at tail */
> >>+			smp_rmb();
> >>+			desc =3D &tfile->tx_descs[tail];
> >>+			skb =3D desc->skb;
> >>+			/* read descriptor before incrementing tail. */
> >>+			smp_store_release(&tfile->tail,
> >>+					  (tail + 1) & TUN_RING_MASK);
> >same comments as purge, also - pls order code consistently.
>=20
> Ok.
>=20
> >
> >>+		} else {
> >>+			spin_unlock(&tfile->rlock);
> >>+			return -EAGAIN;
> >>+		}
> >>+
> >>+		spin_unlock(&tfile->rlock);
> >>+	} else {
> >>+		/* Read frames from queue */
> >>+		skb =3D __skb_recv_datagram(tfile->socket.sk,
> >>+					  noblock ? MSG_DONTWAIT : 0,
> >>+					  &peeked, &off, &err);
> >>+		if (!skb)
> >>+			return err;
> >>+	}
> >>  	ret =3D tun_put_user(tun, tfile, skb, to);
> >>  	if (unlikely(ret < 0))
> >>@@ -1629,8 +1724,47 @@ out:
> >>  	return ret;
> >>  }
> >>+static int tun_peek(struct socket *sock, bool exact)
> >>+{
> >>+	struct tun_file *tfile =3D container_of(sock, struct tun_file, so=
cket);
> >>+	struct sock *sk =3D sock->sk;
> >>+	struct tun_struct *tun;
> >>+	int ret =3D 0;
> >>+
> >>+	if (!exact)
> >>+		return tun_queue_not_empty(tfile);
> >>+
> >>+	tun =3D __tun_get(tfile);
> >>+	if (!tun)
> >>+		return 0;
> >>+
> >>+	if (tun->flags & IFF_TX_RING) {
> >>+		unsigned long head =3D ACCESS_ONCE(tfile->head);
> >>+		unsigned long tail =3D ACCESS_ONCE(tfile->tail);
> >>+
> >>+		if (head !=3D tail)
> >>+			ret =3D tfile->tx_descs[tail].len;
> >no ordering at all here?
>=20
> Seems yes, we can't be accurate if there's are more consumers.
>=20
> >
> >>+	} else {
> >>+		struct sk_buff *head;
> >>+		unsigned long flags;
> >>+
> >>+		spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
> >>+		head =3D skb_peek(&sk->sk_receive_queue);
> >>+		if (likely(head)) {
> >>+			ret =3D head->len;
> >>+			if (skb_vlan_tag_present(head))
> >>+				ret +=3D VLAN_HLEN;
> >>+		}
> >>+		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
> >>+	}
> >>+
> >>+	tun_put(tun);
> >>+	return ret;
> >>+}
> >>+
> >>  /* Ops structure to mimic raw sockets with tun */
> >>  static const struct proto_ops tun_socket_ops =3D {
> >>+	.peek    =3D tun_peek,
> >>  	.sendmsg =3D tun_sendmsg,
> >>  	.recvmsg =3D tun_recvmsg,
> >>  };
> >>@@ -2306,13 +2440,13 @@ static int tun_chr_open(struct inode *inode=
, struct file * file)
> >>  {
> >>  	struct net *net =3D current->nsproxy->net_ns;
> >>  	struct tun_file *tfile;
> >>-
> >>  	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
> >>  	tfile =3D (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL=
,
> >>  					    &tun_proto, 0);
> >>  	if (!tfile)
> >>  		return -ENOMEM;
> >>+
> >>  	RCU_INIT_POINTER(tfile->tun, NULL);
> >>  	tfile->flags =3D 0;
> >>  	tfile->ifindex =3D 0;
> >>@@ -2332,6 +2466,11 @@ static int tun_chr_open(struct inode *inode,=
 struct file * file)
> >>  	INIT_LIST_HEAD(&tfile->next);
> >>  	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
> >>+	tfile->head =3D 0;
> >>+	tfile->tail =3D 0;
> >>+
> >>+	spin_lock_init(&tfile->rlock);
> >>+	spin_lock_init(&tfile->wlock);
> >>  	return 0;
> >>  }
> >>diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >>index f744eeb..10ff494 100644
> >>--- a/drivers/vhost/net.c
> >>+++ b/drivers/vhost/net.c
> >>@@ -455,10 +455,14 @@ out:
> >>  static int peek_head_len(struct sock *sk)
> >>  {
> >>+	struct socket *sock =3D sk->sk_socket;
> >>  	struct sk_buff *head;
> >>  	int len =3D 0;
> >>  	unsigned long flags;
> >>+	if (sock->ops->peek)
> >>+		return sock->ops->peek(sock, true);
> >>+
> >>  	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
> >>  	head =3D skb_peek(&sk->sk_receive_queue);
> >>  	if (likely(head)) {
> >>@@ -471,6 +475,16 @@ static int peek_head_len(struct sock *sk)
> >>  	return len;
> >>  }
> >>+static int sk_has_rx_data(struct sock *sk)
> >>+{
> >>+	struct socket *sock =3D sk->sk_socket;
> >>+
> >>+	if (sock->ops->peek)
> >>+		return sock->ops->peek(sock, false);
> >>+
> >>+	return skb_queue_empty(&sk->sk_receive_queue);
> >>+}
> >>+
> >>  static int vhost_net_rx_peek_head_len(struct vhost_net *net, stru=
ct sock *sk)
> >>  {
> >>  	struct vhost_net_virtqueue *nvq =3D &net->vqs[VHOST_NET_VQ_TX];
> >>@@ -487,7 +501,7 @@ static int vhost_net_rx_peek_head_len(struct vh=
ost_net *net, struct sock *sk)
> >>  		endtime =3D busy_clock() + vq->busyloop_timeout;
> >>  		while (vhost_can_busy_poll(&net->dev, endtime) &&
> >>-		       skb_queue_empty(&sk->sk_receive_queue) &&
> >>+		       !sk_has_rx_data(sk) &&
> >>  		       vhost_vq_avail_empty(&net->dev, vq))
> >>  			cpu_relax_lowlatency();
> >>diff --git a/include/linux/net.h b/include/linux/net.h
> >>index 72c1e06..3c4ecd5 100644
> >>--- a/include/linux/net.h
> >>+++ b/include/linux/net.h
> >>@@ -132,6 +132,7 @@ struct module;
> >>  struct proto_ops {
> >>  	int		family;
> >>  	struct module	*owner;
> >>+	int		(*peek) (struct socket *sock, bool exact);
> >>  	int		(*release)   (struct socket *sock);
> >>  	int		(*bind)	     (struct socket *sock,
> >>  				      struct sockaddr *myaddr,
> >>diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tu=
n.h
> >>index 3cb5e1d..d64ddc1 100644
> >>--- a/include/uapi/linux/if_tun.h
> >>+++ b/include/uapi/linux/if_tun.h
> >>@@ -61,6 +61,7 @@
> >>  #define IFF_TUN		0x0001
> >>  #define IFF_TAP		0x0002
> >>  #define IFF_NO_PI	0x1000
> >>+#define IFF_TX_RING	0x0010
> >>  /* This flag has no real effect */
> >>  #define IFF_ONE_QUEUE	0x2000
> >>  #define IFF_VNET_HDR	0x4000
> >>--=20
> >>2.7.4
