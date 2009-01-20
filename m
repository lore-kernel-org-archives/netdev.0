From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH 2/5] net: pppoe - introduce net-namespace functionality
Date: Tue, 20 Jan 2009 14:17:45 +0000 (UTC)
Message-ID: <4975dc12.0637560a.214c.34ce__49705.2707746208$1232461143$gmane$org__532.530217763849$1232461144$gmane$org@mx.google.com>
References: <20090120140510.228815074@gmail.com>>
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: davem@davemloft.net, jchapman@katalix.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761205AbZATOQY@vger.kernel.org>
Date: Thu, 01 Jan 1970 03:00:02 +0300
Content-Disposition: inline; filename=net-pppoe-namespace
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- each net-namespace for pppoe module is having own
  hash table and appropriate locks wich are allocated
  at time of namespace intialization. It requires about
  140 bytes of memory for every new namespace but such
  approach allow us to escape from hash chains growing
  and additional lock contends (especially in SMP environment).

- pppox code allows to create per-namespace sockets for
  PX_PROTO_OE protocol only (since at this moment support
  for pppol2tp net-namespace is not implemented yet).

CC: Michal Ostrowski <mostrows@gmail.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/pppoe.c |  377 +++++++++++++++++++++++++++++++++-------------------
 drivers/net/pppox.c |    7 
 2 files changed, 248 insertions(+), 136 deletions(-)

Index: linux-2.6.git/drivers/net/pppoe.c
===================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -78,7 +78,9 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+#include <linux/nsproxy.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include <net/sock.h>
 
 #include <asm/uaccess.h>
@@ -93,7 +95,24 @@ static int __pppoe_xmit(struct sock *sk,
 
 static const struct proto_ops pppoe_ops;
 static struct ppp_channel_ops pppoe_chan_ops;
-static DEFINE_RWLOCK(pppoe_hash_lock);
+
+/* per-net private data for this module */
+static unsigned int pppoe_net_id;
+struct pppoe_net {
+	/*
+	 * we could use _single_ hash table for all
+	 * nets by injecting net id into the hash but
+	 * it would increase hash chains and add
+	 * a few additional math comparations messy
+	 * as well, moreover in case of SMP less locking
+	 * controversy here
+	 */
+	struct pppox_sock *hash_table[PPPOE_HASH_SIZE];
+	rwlock_t hash_lock;
+};
+
+/* to eliminate a race btw pppoe_flush_dev and pppoe_release */
+static DEFINE_SPINLOCK(flush_lock);
 
 /*
  * PPPoE could be in the following stages:
@@ -108,16 +127,21 @@ static inline bool stage_session(__be16 
 	return sid != 0;
 }
 
+static inline struct pppoe_net *pppoe_pernet(struct net *net)
+{
+	BUG_ON(!net);
+
+	return net_generic(net, pppoe_net_id);
+}
+
 static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
 {
-	return a->sid == b->sid &&
-		(memcmp(a->remote, b->remote, ETH_ALEN) == 0);
+	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
 }
 
 static inline int cmp_addr(struct pppoe_addr *a, __be16 sid, char *addr)
 {
-	return a->sid == sid &&
-		(memcmp(a->remote, addr, ETH_ALEN) == 0);
+	return a->sid == sid && !memcmp(a->remote, addr, ETH_ALEN);
 }
 
 #if 8 % PPPOE_HASH_BITS
@@ -139,21 +163,18 @@ static int hash_item(__be16 sid, unsigne
 	return hash & PPPOE_HASH_MASK;
 }
 
-/* zeroed because its in .bss */
-static struct pppox_sock *item_hash_table[PPPOE_HASH_SIZE];
-
 /**********************************************************************
  *
  *  Set/get/delete/rehash items  (internal versions)
  *
  **********************************************************************/
-static struct pppox_sock *__get_item(__be16 sid, unsigned char *addr, int ifindex)
+static struct pppox_sock *__get_item(struct pppoe_net *pn, __be16 sid,
+				unsigned char *addr, int ifindex)
 {
 	int hash = hash_item(sid, addr);
 	struct pppox_sock *ret;
 
-	ret = item_hash_table[hash];
-
+	ret = pn->hash_table[hash];
 	while (ret) {
 		if (cmp_addr(&ret->pppoe_pa, sid, addr) &&
 		    ret->pppoe_ifindex == ifindex)
@@ -165,12 +186,12 @@ static struct pppox_sock *__get_item(__b
 	return NULL;
 }
 
-static int __set_item(struct pppox_sock *po)
+static int __set_item(struct pppoe_net *pn, struct pppox_sock *po)
 {
 	int hash = hash_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
 	struct pppox_sock *ret;
 
-	ret = item_hash_table[hash];
+	ret = pn->hash_table[hash];
 	while (ret) {
 		if (cmp_2_addr(&ret->pppoe_pa, &po->pppoe_pa) &&
 		    ret->pppoe_ifindex == po->pppoe_ifindex)
@@ -179,19 +200,20 @@ static int __set_item(struct pppox_sock 
 		ret = ret->next;
 	}
 
-	po->next = item_hash_table[hash];
-	item_hash_table[hash] = po;
+	po->next = pn->hash_table[hash];
+	pn->hash_table[hash] = po;
 
 	return 0;
 }
 
-static struct pppox_sock *__delete_item(__be16 sid, char *addr, int ifindex)
+static struct pppox_sock *__delete_item(struct pppoe_net *pn, __be16 sid,
+					char *addr, int ifindex)
 {
 	int hash = hash_item(sid, addr);
 	struct pppox_sock *ret, **src;
 
-	ret = item_hash_table[hash];
-	src = &item_hash_table[hash];
+	ret = pn->hash_table[hash];
+	src = &pn->hash_table[hash];
 
 	while (ret) {
 		if (cmp_addr(&ret->pppoe_pa, sid, addr) &&
@@ -212,46 +234,54 @@ static struct pppox_sock *__delete_item(
  *  Set/get/delete/rehash items
  *
  **********************************************************************/
-static inline struct pppox_sock *get_item(__be16 sid,
-					 unsigned char *addr, int ifindex)
+static inline struct pppox_sock *get_item(struct pppoe_net *pn, __be16 sid,
+					unsigned char *addr, int ifindex)
 {
 	struct pppox_sock *po;
 
-	read_lock_bh(&pppoe_hash_lock);
-	po = __get_item(sid, addr, ifindex);
+	read_lock_bh(&pn->hash_lock);
+	po = __get_item(pn, sid, addr, ifindex);
 	if (po)
 		sock_hold(sk_pppox(po));
-	read_unlock_bh(&pppoe_hash_lock);
+	read_unlock_bh(&pn->hash_lock);
 
 	return po;
 }
 
-static inline struct pppox_sock *get_item_by_addr(struct sockaddr_pppox *sp)
+static inline struct pppox_sock *get_item_by_addr(struct net *net,
+						struct sockaddr_pppox *sp)
 {
 	struct net_device *dev;
+	struct pppoe_net *pn;
+	struct pppox_sock *pppox_sock;
+
 	int ifindex;
 
-	dev = dev_get_by_name(&init_net, sp->sa_addr.pppoe.dev);
+	dev = dev_get_by_name(net, sp->sa_addr.pppoe.dev);
 	if (!dev)
 		return NULL;
+
 	ifindex = dev->ifindex;
+	pn = net_generic(net, pppoe_net_id);
+	pppox_sock = get_item(pn, sp->sa_addr.pppoe.sid,
+				sp->sa_addr.pppoe.remote, ifindex);
 	dev_put(dev);
-	return get_item(sp->sa_addr.pppoe.sid, sp->sa_addr.pppoe.remote, ifindex);
+
+	return pppox_sock;
 }
 
-static inline struct pppox_sock *delete_item(__be16 sid, char *addr, int ifindex)
+static inline struct pppox_sock *delete_item(struct pppoe_net *pn, __be16 sid,
+					char *addr, int ifindex)
 {
 	struct pppox_sock *ret;
 
-	write_lock_bh(&pppoe_hash_lock);
-	ret = __delete_item(sid, addr, ifindex);
-	write_unlock_bh(&pppoe_hash_lock);
+	write_lock_bh(&pn->hash_lock);
+	ret = __delete_item(pn, sid, addr, ifindex);
+	write_unlock_bh(&pn->hash_lock);
 
 	return ret;
 }
 
-
-
 /***************************************************************************
  *
  *  Handler for device events.
@@ -261,25 +291,33 @@ static inline struct pppox_sock *delete_
 
 static void pppoe_flush_dev(struct net_device *dev)
 {
-	int hash;
+	struct pppoe_net *pn;
+	int i;
+
 	BUG_ON(dev == NULL);
 
-	write_lock_bh(&pppoe_hash_lock);
-	for (hash = 0; hash < PPPOE_HASH_SIZE; hash++) {
-		struct pppox_sock *po = item_hash_table[hash];
+	pn = pppoe_pernet(dev_net(dev));
+	if (!pn) /* already freed */
+		return;
+
+	write_lock_bh(&pn->hash_lock);
+	for (i = 0; i < PPPOE_HASH_SIZE; i++) {
+		struct pppox_sock *po = pn->hash_table[i];
 
 		while (po != NULL) {
-			struct sock *sk = sk_pppox(po);
+			struct sock *sk;
 			if (po->pppoe_dev != dev) {
 				po = po->next;
 				continue;
 			}
+			sk = sk_pppox(po);
+			spin_lock(&flush_lock);
 			po->pppoe_dev = NULL;
+			spin_unlock(&flush_lock);
 			dev_put(dev);
 
-
 			/* We always grab the socket lock, followed by the
-			 * pppoe_hash_lock, in that order.  Since we should
+			 * hash_lock, in that order.  Since we should
 			 * hold the sock lock while doing any unbinding,
 			 * we need to release the lock we're holding.
 			 * Hold a reference to the sock so it doesn't disappear
@@ -288,7 +326,7 @@ static void pppoe_flush_dev(struct net_d
 
 			sock_hold(sk);
 
-			write_unlock_bh(&pppoe_hash_lock);
+			write_unlock_bh(&pn->hash_lock);
 			lock_sock(sk);
 
 			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
@@ -304,20 +342,17 @@ static void pppoe_flush_dev(struct net_d
 			 * While the lock was dropped the chain contents may
 			 * have changed.
 			 */
-			write_lock_bh(&pppoe_hash_lock);
-			po = item_hash_table[hash];
+			write_lock_bh(&pn->hash_lock);
+			po = pn->hash_table[i];
 		}
 	}
-	write_unlock_bh(&pppoe_hash_lock);
+	write_unlock_bh(&pn->hash_lock);
 }
 
 static int pppoe_device_event(struct notifier_block *this,
 			      unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *) ptr;
-
-	if (dev_net(dev) != &init_net)
-		return NOTIFY_DONE;
+	struct net_device *dev = (struct net_device *)ptr;
 
 	/* Only look at sockets that are using this specific device. */
 	switch (event) {
@@ -339,7 +374,6 @@ static int pppoe_device_event(struct not
 	return NOTIFY_DONE;
 }
 
-
 static struct notifier_block pppoe_notifier = {
 	.notifier_call = pppoe_device_event,
 };
@@ -357,8 +391,8 @@ static int pppoe_rcv_core(struct sock *s
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
-		relay_po = get_item_by_addr(&po->pppoe_relay);
-
+		relay_po = get_item_by_addr(dev_net(po->pppoe_dev),
+						&po->pppoe_relay);
 		if (relay_po == NULL)
 			goto abort_kfree;
 
@@ -387,23 +421,18 @@ abort_kfree:
  * Receive wrapper called in BH context.
  *
  ***********************************************************************/
-static int pppoe_rcv(struct sk_buff *skb,
-		     struct net_device *dev,
-		     struct packet_type *pt,
-		     struct net_device *orig_dev)
-
+static int pppoe_rcv(struct sk_buff *skb, struct net_device *dev,
+		     struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct pppoe_hdr *ph;
 	struct pppox_sock *po;
+	struct pppoe_net *pn;
 	int len;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
 		goto out;
 
-	if (dev_net(dev) != &init_net)
-		goto drop;
-
 	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
 		goto drop;
 
@@ -417,7 +446,8 @@ static int pppoe_rcv(struct sk_buff *skb
 	if (pskb_trim_rcsum(skb, len))
 		goto drop;
 
-	po = get_item(ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
+	pn = pppoe_pernet(dev_net(dev));
+	po = get_item(pn, ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
 	if (!po)
 		goto drop;
 
@@ -435,17 +465,13 @@ out:
  * This is solely for detection of PADT frames
  *
  ***********************************************************************/
-static int pppoe_disc_rcv(struct sk_buff *skb,
-			  struct net_device *dev,
-			  struct packet_type *pt,
-			  struct net_device *orig_dev)
+static int pppoe_disc_rcv(struct sk_buff *skb, struct net_device *dev,
+			  struct packet_type *pt, struct net_device *orig_dev)
 
 {
 	struct pppoe_hdr *ph;
 	struct pppox_sock *po;
-
-	if (dev_net(dev) != &init_net)
-		goto abort;
+	struct pppoe_net *pn;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
@@ -458,7 +484,8 @@ static int pppoe_disc_rcv(struct sk_buff
 	if (ph->code != PADT_CODE)
 		goto abort;
 
-	po = get_item(ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
+	pn = pppoe_pernet(dev_net(dev));
+	po = get_item(pn, ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
 	if (po) {
 		struct sock *sk = sk_pppox(po);
 
@@ -517,14 +544,14 @@ static int pppoe_create(struct net *net,
 
 	sock_init_data(sock, sk);
 
-	sock->state = SS_UNCONNECTED;
-	sock->ops   = &pppoe_ops;
+	sock->state	= SS_UNCONNECTED;
+	sock->ops	= &pppoe_ops;
 
-	sk->sk_backlog_rcv = pppoe_rcv_core;
-	sk->sk_state	   = PPPOX_NONE;
-	sk->sk_type	   = SOCK_STREAM;
-	sk->sk_family	   = PF_PPPOX;
-	sk->sk_protocol	   = PX_PROTO_OE;
+	sk->sk_backlog_rcv	= pppoe_rcv_core;
+	sk->sk_state		= PPPOX_NONE;
+	sk->sk_type		= SOCK_STREAM;
+	sk->sk_family		= PF_PPPOX;
+	sk->sk_protocol		= PX_PROTO_OE;
 
 	return 0;
 }
@@ -533,6 +560,7 @@ static int pppoe_release(struct socket *
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po;
+	struct pppoe_net *pn;
 
 	if (!sk)
 		return 0;
@@ -548,26 +576,39 @@ static int pppoe_release(struct socket *
 	/* Signal the death of the socket. */
 	sk->sk_state = PPPOX_DEAD;
 
+	/*
+	 * pppoe_flush_dev could lead to a race with
+	 * this routine so we use flush_lock to eliminate
+	 * such a case (we only need per-net specific data)
+	 */
+	spin_lock(&flush_lock);
+	po = pppox_sk(sk);
+	if (!po->pppoe_dev) {
+		spin_unlock(&flush_lock);
+		goto out;
+	}
+	pn = pppoe_pernet(dev_net(po->pppoe_dev));
+	spin_unlock(&flush_lock);
 
-	/* Write lock on hash lock protects the entire "po" struct from
-	 * concurrent updates via pppoe_flush_dev. The "po" struct should
-	 * be considered part of the hash table contents, thus protected
-	 * by the hash table lock */
-	write_lock_bh(&pppoe_hash_lock);
+	/*
+	 * protect "po" from concurrent updates
+	 * on pppoe_flush_dev
+	 */
+	write_lock_bh(&pn->hash_lock);
 
 	po = pppox_sk(sk);
-	if (stage_session(po->pppoe_pa.sid)) {
-		__delete_item(po->pppoe_pa.sid,
-			      po->pppoe_pa.remote, po->pppoe_ifindex);
-	}
+	if (stage_session(po->pppoe_pa.sid))
+		__delete_item(pn, po->pppoe_pa.sid, po->pppoe_pa.remote,
+				po->pppoe_ifindex);
 
 	if (po->pppoe_dev) {
 		dev_put(po->pppoe_dev);
 		po->pppoe_dev = NULL;
 	}
 
-	write_unlock_bh(&pppoe_hash_lock);
+	write_unlock_bh(&pn->hash_lock);
 
+out:
 	sock_orphan(sk);
 	sock->sk = NULL;
 
@@ -582,9 +623,10 @@ static int pppoe_connect(struct socket *
 		  int sockaddr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct net_device *dev;
-	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
+	struct sockaddr_pppox *sp = (struct sockaddr_pppox *)uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
+	struct net_device *dev;
+	struct pppoe_net *pn;
 	int error;
 
 	lock_sock(sk);
@@ -610,9 +652,12 @@ static int pppoe_connect(struct socket *
 	/* Delete the old binding */
 	if (stage_session(po->pppoe_pa.sid)) {
 		pppox_unbind_sock(sk);
-		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote, po->pppoe_ifindex);
-		if (po->pppoe_dev)
+		if (po->pppoe_dev) {
+			pn = pppoe_pernet(dev_net(po->pppoe_dev));
+			delete_item(pn, po->pppoe_pa.sid,
+				po->pppoe_pa.remote, po->pppoe_ifindex);
 			dev_put(po->pppoe_dev);
+		}
 		memset(sk_pppox(po) + 1, 0,
 		       sizeof(struct pppox_sock) - sizeof(struct sock));
 		sk->sk_state = PPPOX_NONE;
@@ -620,18 +665,17 @@ static int pppoe_connect(struct socket *
 
 	/* Re-bind in session stage only */
 	if (stage_session(sp->sa_addr.pppoe.sid)) {
-		dev = dev_get_by_name(&init_net, sp->sa_addr.pppoe.dev);
-
 		error = -ENODEV;
+		dev = dev_get_by_name(sock_net(sk), sp->sa_addr.pppoe.dev);
 		if (!dev)
 			goto end;
 
 		po->pppoe_dev = dev;
 		po->pppoe_ifindex = dev->ifindex;
-
-		write_lock_bh(&pppoe_hash_lock);
+		pn = pppoe_pernet(dev_net(dev));
+		write_lock_bh(&pn->hash_lock);
 		if (!(dev->flags & IFF_UP)) {
-			write_unlock_bh(&pppoe_hash_lock);
+			write_unlock_bh(&pn->hash_lock);
 			goto err_put;
 		}
 
@@ -639,8 +683,8 @@ static int pppoe_connect(struct socket *
 		       &sp->sa_addr.pppoe,
 		       sizeof(struct pppoe_addr));
 
-		error = __set_item(po);
-		write_unlock_bh(&pppoe_hash_lock);
+		error = __set_item(pn, po);
+		write_unlock_bh(&pn->hash_lock);
 		if (error < 0)
 			goto err_put;
 
@@ -700,7 +744,6 @@ static int pppoe_ioctl(struct socket *so
 	switch (cmd) {
 	case PPPIOCGMRU:
 		err = -ENXIO;
-
 		if (!(sk->sk_state & PPPOX_CONNECTED))
 			break;
 
@@ -708,7 +751,7 @@ static int pppoe_ioctl(struct socket *so
 		if (put_user(po->pppoe_dev->mtu -
 			     sizeof(struct pppoe_hdr) -
 			     PPP_HDRLEN,
-			     (int __user *) arg))
+			     (int __user *)arg))
 			break;
 		err = 0;
 		break;
@@ -764,8 +807,7 @@ static int pppoe_ioctl(struct socket *so
 
 		/* Check that the socket referenced by the address
 		   actually exists. */
-		relay_po = get_item_by_addr(&po->pppoe_relay);
-
+		relay_po = get_item_by_addr(sock_net(sk), &po->pppoe_relay);
 		if (!relay_po)
 			break;
 
@@ -837,11 +879,10 @@ static int pppoe_sendmsg(struct kiocb *i
 	skb->priority = sk->sk_priority;
 	skb->protocol = __constant_htons(ETH_P_PPP_SES);
 
-	ph = (struct pppoe_hdr *) skb_put(skb, total_len + sizeof(struct pppoe_hdr));
-	start = (char *) &ph->tag[0];
+	ph = (struct pppoe_hdr *)skb_put(skb, total_len + sizeof(struct pppoe_hdr));
+	start = (char *)&ph->tag[0];
 
 	error = memcpy_fromiovec(start, m->msg_iov, total_len);
-
 	if (error < 0) {
 		kfree_skb(skb);
 		goto end;
@@ -919,7 +960,7 @@ abort:
  ***********************************************************************/
 static int pppoe_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
-	struct sock *sk = (struct sock *) chan->private;
+	struct sock *sk = (struct sock *)chan->private;
 	return __pppoe_xmit(sk, skb);
 }
 
@@ -941,7 +982,6 @@ static int pppoe_recvmsg(struct kiocb *i
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &error);
-
 	if (error < 0)
 		goto end;
 
@@ -964,6 +1004,7 @@ static int pppoe_seq_show(struct seq_fil
 {
 	struct pppox_sock *po;
 	char *dev_name;
+	DECLARE_MAC_BUF(mac);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Id       Address              Device\n");
@@ -974,44 +1015,47 @@ static int pppoe_seq_show(struct seq_fil
 	dev_name = po->pppoe_pa.dev;
 
 	seq_printf(seq, "%08X %pM %8s\n",
-		   po->pppoe_pa.sid, po->pppoe_pa.remote, dev_name);
+		po->pppoe_pa.sid, po->pppoe_pa.remote, dev_name);
 out:
 	return 0;
 }
 
-static __inline__ struct pppox_sock *pppoe_get_idx(loff_t pos)
+static inline struct pppox_sock *pppoe_get_idx(struct pppoe_net *pn, loff_t pos)
 {
 	struct pppox_sock *po;
 	int i;
 
 	for (i = 0; i < PPPOE_HASH_SIZE; i++) {
-		po = item_hash_table[i];
+		po = pn->hash_table[i];
 		while (po) {
 			if (!pos--)
 				goto out;
 			po = po->next;
 		}
 	}
+
 out:
 	return po;
 }
 
 static void *pppoe_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(pppoe_hash_lock)
+	__acquires(pn->hash_lock)
 {
+	struct pppoe_net *pn = pppoe_pernet(seq->private);
 	loff_t l = *pos;
 
-	read_lock_bh(&pppoe_hash_lock);
-	return l ? pppoe_get_idx(--l) : SEQ_START_TOKEN;
+	read_lock_bh(&pn->hash_lock);
+	return l ? pppoe_get_idx(pn, --l) : SEQ_START_TOKEN;
 }
 
 static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct pppoe_net *pn = pppoe_pernet(seq->private);
 	struct pppox_sock *po;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN) {
-		po = pppoe_get_idx(0);
+		po = pppoe_get_idx(pn, 0);
 		goto out;
 	}
 	po = v;
@@ -1021,19 +1065,21 @@ static void *pppoe_seq_next(struct seq_f
 		int hash = hash_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
 
 		while (++hash < PPPOE_HASH_SIZE) {
-			po = item_hash_table[hash];
+			po = pn->hash_table[hash];
 			if (po)
 				break;
 		}
 	}
+
 out:
 	return po;
 }
 
 static void pppoe_seq_stop(struct seq_file *seq, void *v)
-	__releases(pppoe_hash_lock)
+	__releases(pn->hash_lock)
 {
-	read_unlock_bh(&pppoe_hash_lock);
+	struct pppoe_net *pn = pppoe_pernet(seq->private);
+	read_unlock_bh(&pn->hash_lock);
 }
 
 static struct seq_operations pppoe_seq_ops = {
@@ -1045,7 +1091,30 @@ static struct seq_operations pppoe_seq_o
 
 static int pppoe_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &pppoe_seq_ops);
+	struct seq_file *m;
+	struct net *net;
+	int err;
+
+	err = seq_open(file, &pppoe_seq_ops);
+	if (err)
+		return err;
+
+	m = file->private_data;
+	net = maybe_get_net(PDE_NET(PDE(inode)));
+	BUG_ON(!net);
+	m->private = net;
+
+	return err;
+}
+
+static int pppoe_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m;
+
+	m = file->private_data;
+	put_net((struct net*)m->private);
+
+	return seq_release(inode, file);
 }
 
 static const struct file_operations pppoe_seq_fops = {
@@ -1053,20 +1122,9 @@ static const struct file_operations pppo
 	.open		= pppoe_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release,
+	.release	= pppoe_seq_release,
 };
 
-static int __init pppoe_proc_init(void)
-{
-	struct proc_dir_entry *p;
-
-	p = proc_net_fops_create(&init_net, "pppoe", S_IRUGO, &pppoe_seq_fops);
-	if (!p)
-		return -ENOMEM;
-	return 0;
-}
-#else /* CONFIG_PROC_FS */
-static inline int pppoe_proc_init(void) { return 0; }
 #endif /* CONFIG_PROC_FS */
 
 static const struct proto_ops pppoe_ops = {
@@ -1095,10 +1153,61 @@ static struct pppox_proto pppoe_proto = 
 	.owner	= THIS_MODULE,
 };
 
+static __net_init int pppoe_init_net(struct net *net)
+{
+	struct pppoe_net *pn;
+	struct proc_dir_entry *pde;
+	int err;
+
+	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
+	if (!pn)
+		return -ENOMEM;
+
+	rwlock_init(&pn->hash_lock);
+
+	err = net_assign_generic(net, pppoe_net_id, pn);
+	if (err)
+		goto out;
+
+	pde = proc_net_fops_create(net, "pppoe", S_IRUGO, &pppoe_seq_fops);
+#ifdef CONFIG_PROC_FS
+	if (!pde) {
+		err = -ENOMEM;
+		goto out;
+	}
+#endif
+
+	return 0;
+
+out:
+	kfree(pn);
+	return err;
+}
+
+static __net_exit void pppoe_exit_net(struct net *net)
+{
+	struct pppoe_net *pn;
+
+	proc_net_remove(net, "pppoe");
+	pn = net_generic(net, pppoe_net_id);
+	/*
+	 * if someone has cached our net then
+	 * further net_generic call will return NULL
+	 */
+	net_assign_generic(net, pppoe_net_id, NULL);
+	kfree(pn);
+}
+
+static __net_initdata struct pernet_operations pppoe_net_ops = {
+	.init = pppoe_init_net,
+	.exit = pppoe_exit_net,
+};
+
 static int __init pppoe_init(void)
 {
-	int err = proto_register(&pppoe_sk_proto, 0);
+	int err;
 
+	err = proto_register(&pppoe_sk_proto, 0);
 	if (err)
 		goto out;
 
@@ -1106,20 +1215,22 @@ static int __init pppoe_init(void)
 	if (err)
 		goto out_unregister_pppoe_proto;
 
-	err = pppoe_proc_init();
+	err = register_pernet_gen_device(&pppoe_net_id, &pppoe_net_ops);
 	if (err)
 		goto out_unregister_pppox_proto;
 
 	dev_add_pack(&pppoes_ptype);
 	dev_add_pack(&pppoed_ptype);
 	register_netdevice_notifier(&pppoe_notifier);
-out:
-	return err;
+
+	return 0;
+
 out_unregister_pppox_proto:
 	unregister_pppox_proto(PX_PROTO_OE);
 out_unregister_pppoe_proto:
 	proto_unregister(&pppoe_sk_proto);
-	goto out;
+out:
+	return err;
 }
 
 static void __exit pppoe_exit(void)
@@ -1128,7 +1239,7 @@ static void __exit pppoe_exit(void)
 	dev_remove_pack(&pppoes_ptype);
 	dev_remove_pack(&pppoed_ptype);
 	unregister_netdevice_notifier(&pppoe_notifier);
-	remove_proc_entry("pppoe", init_net.proc_net);
+	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
 	proto_unregister(&pppoe_sk_proto);
 }
 
Index: linux-2.6.git/drivers/net/pppox.c
===================================================================
--- linux-2.6.git.orig/drivers/net/pppox.c
+++ linux-2.6.git/drivers/net/pppox.c
@@ -108,12 +108,13 @@ static int pppox_create(struct net *net,
 {
 	int rc = -EPROTOTYPE;
 
-	if (net != &init_net)
-		return -EAFNOSUPPORT;
-
 	if (protocol < 0 || protocol > PX_MAX_PROTO)
 		goto out;
 
+	/* we support net-namespaces for PPPoE only (yet) */
+	if (protocol != PX_PROTO_OE && net != &init_net)
+		return -EAFNOSUPPORT;
+
 	rc = -EPROTONOSUPPORT;
 	if (!pppox_protos[protocol])
 		request_module("pppox-proto-%d", protocol);

-- 
