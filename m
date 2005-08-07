From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] split net/core/netfilter.c into net/netfilter/*.c
Date: Mon, 8 Aug 2005 00:17:20 +0200
Message-ID: <20050807221720.GD4508@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gw4vLALk08fVJy3V"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--gw4vLALk08fVJy3V
Content-Type: multipart/mixed; boundary="RD6GsZsdEJvsf78O"
Content-Disposition: inline


--RD6GsZsdEJvsf78O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

please apply to net-2.6.14

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--RD6GsZsdEJvsf78O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="34-netfilter-dirmove.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] split net/core/netfilter.c into net/netfilter/*.c

This patch doesn't introduce any code changes, but merely splits the core
netfilter code into four separate files.  It also moves it from it's old
location in net/core/ to the recently-created net/netfilter/ directory.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit cfac4409abdf624846d1b97495c4e9c0e4a63658
tree c3b7526dd4aeca3fe6b80e8b0953698881c2ddd8
parent 7e42bac6926c9ab54033ddc4695e9a3d30b6b453
author Harald Welte <laforge@netfilter.org> So, 07 Aug 2005 22:05:00 +0200
committer Harald Welte <laforge@netfilter.org> So, 07 Aug 2005 22:05:00 +02=
00

 net/core/Makefile            |    1=20
 net/core/netfilter.c         |  737 --------------------------------------=
----
 net/netfilter/Makefile       |    4=20
 net/netfilter/core.c         |  216 ++++++++++++
 net/netfilter/nf_internals.h |   39 ++
 net/netfilter/nf_log.c       |  165 +++++++++
 net/netfilter/nf_queue.c     |  273 ++++++++++++++++
 net/netfilter/nf_sockopt.c   |  132 ++++++++
 8 files changed, 829 insertions(+), 738 deletions(-)

diff --git a/net/core/Makefile b/net/core/Makefile
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -12,7 +12,6 @@ obj-y		     +=3D dev.o ethtool.o dev_mcast
=20
 obj-$(CONFIG_XFRM) +=3D flow.o
 obj-$(CONFIG_SYSFS) +=3D net-sysfs.o
-obj-$(CONFIG_NETFILTER) +=3D netfilter.o
 obj-$(CONFIG_NET_DIVERT) +=3D dv.o
 obj-$(CONFIG_NET_PKTGEN) +=3D pktgen.o
 obj-$(CONFIG_NET_RADIO) +=3D wireless.o
diff --git a/net/core/netfilter.c b/net/core/netfilter.c
deleted file mode 100644
--- a/net/core/netfilter.c
+++ /dev/null
@@ -1,737 +0,0 @@
-/* netfilter.c: look after the filters for various protocols.=20
- * Heavily influenced by the old firewall.c by David Bonn and Alan Cox.
- *
- * Thanks to Rob `CmdrTaco' Malda for not influencing this code in any
- * way.
- *
- * Rusty Russell (C)2000 -- This code is GPL.
- *
- * February 2000: Modified by James Morris to have 1 queue per protocol.
- * 15-Mar-2000:   Added NF_REPEAT --RR.
- * 08-May-2003:	  Internal logging interface added by Jozsef Kadlecsik.
- */
-#include <linux/config.h>
-#include <linux/kernel.h>
-#include <linux/netfilter.h>
-#include <net/protocol.h>
-#include <linux/init.h>
-#include <linux/skbuff.h>
-#include <linux/wait.h>
-#include <linux/module.h>
-#include <linux/interrupt.h>
-#include <linux/if.h>
-#include <linux/netdevice.h>
-#include <linux/inetdevice.h>
-#include <linux/proc_fs.h>
-#include <net/sock.h>
-
-/* In this code, we can be waiting indefinitely for userspace to
- * service a packet if a hook returns NF_QUEUE.  We could keep a count
- * of skbuffs queued for userspace, and not deregister a hook unless
- * this is zero, but that sucks.  Now, we simply check when the
- * packets come back: if the hook is gone, the packet is discarded. */
-#ifdef CONFIG_NETFILTER_DEBUG
-#define NFDEBUG(format, args...)  printk(format , ## args)
-#else
-#define NFDEBUG(format, args...)
-#endif
-
-/* Sockopts only registered and called from user context, so
-   net locking would be overkill.  Also, [gs]etsockopt calls may
-   sleep. */
-static DECLARE_MUTEX(nf_sockopt_mutex);
-
-struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS];
-static LIST_HEAD(nf_sockopts);
-static DEFINE_SPINLOCK(nf_hook_lock);
-
-/*=20
- * A queue handler may be registered for each protocol.  Each is protected=
 by
- * long term mutex.  The handler must provide an an outfn() to accept pack=
ets
- * for queueing and must reinject all packets it receives, no matter what.
- */
-static struct nf_queue_handler_t {
-	nf_queue_outfn_t outfn;
-	void *data;
-} queue_handler[NPROTO];
-
-static struct nf_queue_rerouter *queue_rerouter;
-
-static DEFINE_RWLOCK(queue_handler_lock);
-
-int nf_register_hook(struct nf_hook_ops *reg)
-{
-	struct list_head *i;
-
-	spin_lock_bh(&nf_hook_lock);
-	list_for_each(i, &nf_hooks[reg->pf][reg->hooknum]) {
-		if (reg->priority < ((struct nf_hook_ops *)i)->priority)
-			break;
-	}
-	list_add_rcu(&reg->list, i->prev);
-	spin_unlock_bh(&nf_hook_lock);
-
-	synchronize_net();
-	return 0;
-}
-
-void nf_unregister_hook(struct nf_hook_ops *reg)
-{
-	spin_lock_bh(&nf_hook_lock);
-	list_del_rcu(&reg->list);
-	spin_unlock_bh(&nf_hook_lock);
-
-	synchronize_net();
-}
-
-/* Do exclusive ranges overlap? */
-static inline int overlap(int min1, int max1, int min2, int max2)
-{
-	return max1 > min2 && min1 < max2;
-}
-
-/* Functions to register sockopt ranges (exclusive). */
-int nf_register_sockopt(struct nf_sockopt_ops *reg)
-{
-	struct list_head *i;
-	int ret =3D 0;
-
-	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
-		return -EINTR;
-
-	list_for_each(i, &nf_sockopts) {
-		struct nf_sockopt_ops *ops =3D (struct nf_sockopt_ops *)i;
-		if (ops->pf =3D=3D reg->pf
-		    && (overlap(ops->set_optmin, ops->set_optmax,=20
-				reg->set_optmin, reg->set_optmax)
-			|| overlap(ops->get_optmin, ops->get_optmax,=20
-				   reg->get_optmin, reg->get_optmax))) {
-			NFDEBUG("nf_sock overlap: %u-%u/%u-%u v %u-%u/%u-%u\n",
-				ops->set_optmin, ops->set_optmax,=20
-				ops->get_optmin, ops->get_optmax,=20
-				reg->set_optmin, reg->set_optmax,
-				reg->get_optmin, reg->get_optmax);
-			ret =3D -EBUSY;
-			goto out;
-		}
-	}
-
-	list_add(&reg->list, &nf_sockopts);
-out:
-	up(&nf_sockopt_mutex);
-	return ret;
-}
-
-void nf_unregister_sockopt(struct nf_sockopt_ops *reg)
-{
-	/* No point being interruptible: we're probably in cleanup_module() */
- restart:
-	down(&nf_sockopt_mutex);
-	if (reg->use !=3D 0) {
-		/* To be woken by nf_sockopt call... */
-		/* FIXME: Stuart Young's name appears gratuitously. */
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		reg->cleanup_task =3D current;
-		up(&nf_sockopt_mutex);
-		schedule();
-		goto restart;
-	}
-	list_del(&reg->list);
-	up(&nf_sockopt_mutex);
-}
-
-/* Call get/setsockopt() */
-static int nf_sockopt(struct sock *sk, int pf, int val,=20
-		      char __user *opt, int *len, int get)
-{
-	struct list_head *i;
-	struct nf_sockopt_ops *ops;
-	int ret;
-
-	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
-		return -EINTR;
-
-	list_for_each(i, &nf_sockopts) {
-		ops =3D (struct nf_sockopt_ops *)i;
-		if (ops->pf =3D=3D pf) {
-			if (get) {
-				if (val >=3D ops->get_optmin
-				    && val < ops->get_optmax) {
-					ops->use++;
-					up(&nf_sockopt_mutex);
-					ret =3D ops->get(sk, val, opt, len);
-					goto out;
-				}
-			} else {
-				if (val >=3D ops->set_optmin
-				    && val < ops->set_optmax) {
-					ops->use++;
-					up(&nf_sockopt_mutex);
-					ret =3D ops->set(sk, val, opt, *len);
-					goto out;
-				}
-			}
-		}
-	}
-	up(&nf_sockopt_mutex);
-	return -ENOPROTOOPT;
-=09
- out:
-	down(&nf_sockopt_mutex);
-	ops->use--;
-	if (ops->cleanup_task)
-		wake_up_process(ops->cleanup_task);
-	up(&nf_sockopt_mutex);
-	return ret;
-}
-
-int nf_setsockopt(struct sock *sk, int pf, int val, char __user *opt,
-		  int len)
-{
-	return nf_sockopt(sk, pf, val, opt, &len, 0);
-}
-
-int nf_getsockopt(struct sock *sk, int pf, int val, char __user *opt, int =
*len)
-{
-	return nf_sockopt(sk, pf, val, opt, len, 1);
-}
-
-static unsigned int nf_iterate(struct list_head *head,
-			       struct sk_buff **skb,
-			       int hook,
-			       const struct net_device *indev,
-			       const struct net_device *outdev,
-			       struct list_head **i,
-			       int (*okfn)(struct sk_buff *),
-			       int hook_thresh)
-{
-	unsigned int verdict;
-
-	/*
-	 * The caller must not block between calls to this
-	 * function because of risk of continuing from deleted element.
-	 */
-	list_for_each_continue_rcu(*i, head) {
-		struct nf_hook_ops *elem =3D (struct nf_hook_ops *)*i;
-
-		if (hook_thresh > elem->priority)
-			continue;
-
-		/* Optimization: we don't need to hold module
-                   reference here, since function can't sleep. --RR */
-		verdict =3D elem->hook(hook, skb, indev, outdev, okfn);
-		if (verdict !=3D NF_ACCEPT) {
-#ifdef CONFIG_NETFILTER_DEBUG
-			if (unlikely((verdict & NF_VERDICT_MASK)
-							> NF_MAX_VERDICT)) {
-				NFDEBUG("Evil return from %p(%u).\n",
-				        elem->hook, hook);
-				continue;
-			}
-#endif
-			if (verdict !=3D NF_REPEAT)
-				return verdict;
-			*i =3D (*i)->prev;
-		}
-	}
-	return NF_ACCEPT;
-}
-
-int nf_register_queue_handler(int pf, nf_queue_outfn_t outfn, void *data)
-{     =20
-	int ret;
-
-	if (pf >=3D NPROTO)
-		return -EINVAL;
-
-	write_lock_bh(&queue_handler_lock);
-	if (queue_handler[pf].outfn)
-		ret =3D -EBUSY;
-	else {
-		queue_handler[pf].outfn =3D outfn;
-		queue_handler[pf].data =3D data;
-		ret =3D 0;
-	}
-	write_unlock_bh(&queue_handler_lock);
-
-	return ret;
-}
-
-/* The caller must flush their queue before this */
-int nf_unregister_queue_handler(int pf)
-{
-	if (pf >=3D NPROTO)
-		return -EINVAL;
-
-	write_lock_bh(&queue_handler_lock);
-	queue_handler[pf].outfn =3D NULL;
-	queue_handler[pf].data =3D NULL;
-	write_unlock_bh(&queue_handler_lock);
-=09
-	return 0;
-}
-
-int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *rer)
-{
-	if (pf >=3D NPROTO)
-		return -EINVAL;
-
-	write_lock_bh(&queue_handler_lock);
-	memcpy(&queue_rerouter[pf], rer, sizeof(queue_rerouter[pf]));
-	write_unlock_bh(&queue_handler_lock);
-
-	return 0;
-}
-
-int nf_unregister_queue_rerouter(int pf)
-{
-	if (pf >=3D NPROTO)
-		return -EINVAL;
-
-	write_lock_bh(&queue_handler_lock);
-	memset(&queue_rerouter[pf], 0, sizeof(queue_rerouter[pf]));
-	write_unlock_bh(&queue_handler_lock);
-	return 0;
-}
-
-void nf_unregister_queue_handlers(nf_queue_outfn_t outfn)
-{
-	int pf;
-
-	write_lock_bh(&queue_handler_lock);
-	for (pf =3D 0; pf < NPROTO; pf++)  {
-		if (queue_handler[pf].outfn =3D=3D outfn) {
-			queue_handler[pf].outfn =3D NULL;
-			queue_handler[pf].data =3D NULL;
-		}
-	}
-	write_unlock_bh(&queue_handler_lock);
-}
-
-/*=20
- * Any packet that leaves via this function must come back=20
- * through nf_reinject().
- */
-static int nf_queue(struct sk_buff **skb,=20
-		    struct list_head *elem,=20
-		    int pf, unsigned int hook,
-		    struct net_device *indev,
-		    struct net_device *outdev,
-		    int (*okfn)(struct sk_buff *),
-		    unsigned int queuenum)
-{
-	int status;
-	struct nf_info *info;
-#ifdef CONFIG_BRIDGE_NETFILTER
-	struct net_device *physindev =3D NULL;
-	struct net_device *physoutdev =3D NULL;
-#endif
-
-	/* QUEUE =3D=3D DROP if noone is waiting, to be safe. */
-	read_lock(&queue_handler_lock);
-	if (!queue_handler[pf].outfn) {
-		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
-		return 1;
-	}
-
-	info =3D kmalloc(sizeof(*info)+queue_rerouter[pf].rer_size, GFP_ATOMIC);
-	if (!info) {
-		if (net_ratelimit())
-			printk(KERN_ERR "OOM queueing packet %p\n",
-			       *skb);
-		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
-		return 1;
-	}
-
-	*info =3D (struct nf_info) {=20
-		(struct nf_hook_ops *)elem, pf, hook, indev, outdev, okfn };
-
-	/* If it's going away, ignore hook. */
-	if (!try_module_get(info->elem->owner)) {
-		read_unlock(&queue_handler_lock);
-		kfree(info);
-		return 0;
-	}
-
-	/* Bump dev refs so they don't vanish while packet is out */
-	if (indev) dev_hold(indev);
-	if (outdev) dev_hold(outdev);
-
-#ifdef CONFIG_BRIDGE_NETFILTER
-	if ((*skb)->nf_bridge) {
-		physindev =3D (*skb)->nf_bridge->physindev;
-		if (physindev) dev_hold(physindev);
-		physoutdev =3D (*skb)->nf_bridge->physoutdev;
-		if (physoutdev) dev_hold(physoutdev);
-	}
-#endif
-	if (queue_rerouter[pf].save)
-		queue_rerouter[pf].save(*skb, info);
-
-	status =3D queue_handler[pf].outfn(*skb, info, queuenum,
-					 queue_handler[pf].data);
-
-	if (status >=3D 0 && queue_rerouter[pf].reroute)
-		status =3D queue_rerouter[pf].reroute(skb, info);
-
-	read_unlock(&queue_handler_lock);
-
-	if (status < 0) {
-		/* James M doesn't say fuck enough. */
-		if (indev) dev_put(indev);
-		if (outdev) dev_put(outdev);
-#ifdef CONFIG_BRIDGE_NETFILTER
-		if (physindev) dev_put(physindev);
-		if (physoutdev) dev_put(physoutdev);
-#endif
-		module_put(info->elem->owner);
-		kfree(info);
-		kfree_skb(*skb);
-
-		return 1;
-	}
-
-	return 1;
-}
-
-/* Returns 1 if okfn() needs to be executed by the caller,
- * -EPERM for NF_DROP, 0 otherwise. */
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
-		 struct net_device *indev,
-		 struct net_device *outdev,
-		 int (*okfn)(struct sk_buff *),
-		 int hook_thresh)
-{
-	struct list_head *elem;
-	unsigned int verdict;
-	int ret =3D 0;
-
-	/* We may already have this, but read-locks nest anyway */
-	rcu_read_lock();
-
-	elem =3D &nf_hooks[pf][hook];
-next_hook:
-	verdict =3D nf_iterate(&nf_hooks[pf][hook], pskb, hook, indev,
-			     outdev, &elem, okfn, hook_thresh);
-	if (verdict =3D=3D NF_ACCEPT || verdict =3D=3D NF_STOP) {
-		ret =3D 1;
-		goto unlock;
-	} else if (verdict =3D=3D NF_DROP) {
-		kfree_skb(*pskb);
-		ret =3D -EPERM;
-	} else if ((verdict & NF_VERDICT_MASK)  =3D=3D NF_QUEUE) {
-		NFDEBUG("nf_hook: Verdict =3D QUEUE.\n");
-		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn,
-			      verdict >> NF_VERDICT_BITS))
-			goto next_hook;
-	}
-unlock:
-	rcu_read_unlock();
-	return ret;
-}
-
-void nf_reinject(struct sk_buff *skb, struct nf_info *info,
-		 unsigned int verdict)
-{
-	struct list_head *elem =3D &info->elem->list;
-	struct list_head *i;
-
-	rcu_read_lock();
-
-	/* Release those devices we held, or Alexey will kill me. */
-	if (info->indev) dev_put(info->indev);
-	if (info->outdev) dev_put(info->outdev);
-#ifdef CONFIG_BRIDGE_NETFILTER
-	if (skb->nf_bridge) {
-		if (skb->nf_bridge->physindev)
-			dev_put(skb->nf_bridge->physindev);
-		if (skb->nf_bridge->physoutdev)
-			dev_put(skb->nf_bridge->physoutdev);
-	}
-#endif
-
-	/* Drop reference to owner of hook which queued us. */
-	module_put(info->elem->owner);
-
-	list_for_each_rcu(i, &nf_hooks[info->pf][info->hook]) {
-		if (i =3D=3D elem)=20
-  			break;
-  	}
- =20
-	if (elem =3D=3D &nf_hooks[info->pf][info->hook]) {
-		/* The module which sent it to userspace is gone. */
-		NFDEBUG("%s: module disappeared, dropping packet.\n",
-			__FUNCTION__);
-		verdict =3D NF_DROP;
-	}
-
-	/* Continue traversal iff userspace said ok... */
-	if (verdict =3D=3D NF_REPEAT) {
-		elem =3D elem->prev;
-		verdict =3D NF_ACCEPT;
-	}
-
-	if (verdict =3D=3D NF_ACCEPT) {
-	next_hook:
-		verdict =3D nf_iterate(&nf_hooks[info->pf][info->hook],
-				     &skb, info->hook,=20
-				     info->indev, info->outdev, &elem,
-				     info->okfn, INT_MIN);
-	}
-
-	switch (verdict & NF_VERDICT_MASK) {
-	case NF_ACCEPT:
-		info->okfn(skb);
-		break;
-
-	case NF_QUEUE:
-		if (!nf_queue(&skb, elem, info->pf, info->hook,=20
-			      info->indev, info->outdev, info->okfn,
-			      verdict >> NF_VERDICT_BITS))
-			goto next_hook;
-		break;
-	}
-	rcu_read_unlock();
-
-	if (verdict =3D=3D NF_DROP)
-		kfree_skb(skb);
-
-	kfree(info);
-	return;
-}
-
-int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len)
-{
-	struct sk_buff *nskb;
-
-	if (writable_len > (*pskb)->len)
-		return 0;
-
-	/* Not exclusive use of packet?  Must copy. */
-	if (skb_shared(*pskb) || skb_cloned(*pskb))
-		goto copy_skb;
-
-	return pskb_may_pull(*pskb, writable_len);
-
-copy_skb:
-	nskb =3D skb_copy(*pskb, GFP_ATOMIC);
-	if (!nskb)
-		return 0;
-	BUG_ON(skb_is_nonlinear(nskb));
-
-	/* Rest of kernel will get very unhappy if we pass it a
-	   suddenly-orphaned skbuff */
-	if ((*pskb)->sk)
-		skb_set_owner_w(nskb, (*pskb)->sk);
-	kfree_skb(*pskb);
-	*pskb =3D nskb;
-	return 1;
-}
-EXPORT_SYMBOL(skb_make_writable);
-
-/* Internal logging interface, which relies on the real=20
-   LOG target modules */
-
-#define NF_LOG_PREFIXLEN		128
-
-static struct nf_logger *nf_logging[NPROTO]; /* =3D NULL */
-static DEFINE_SPINLOCK(nf_log_lock);
-
-int nf_log_register(int pf, struct nf_logger *logger)
-{
-	int ret =3D -EBUSY;
-
-	/* Any setup of logging members must be done before
-	 * substituting pointer. */
-	spin_lock(&nf_log_lock);
-	if (!nf_logging[pf]) {
-		rcu_assign_pointer(nf_logging[pf], logger);
-		ret =3D 0;
-	}
-	spin_unlock(&nf_log_lock);
-	return ret;
-}	=09
-
-void nf_log_unregister_pf(int pf)
-{
-	spin_lock(&nf_log_lock);
-	nf_logging[pf] =3D NULL;
-	spin_unlock(&nf_log_lock);
-
-	/* Give time to concurrent readers. */
-	synchronize_net();
-}
-
-void nf_log_unregister_logger(struct nf_logger *logger)
-{
-	int i;
-
-	spin_lock(&nf_log_lock);
-	for (i =3D 0; i < NPROTO; i++) {
-		if (nf_logging[i] =3D=3D logger)
-			nf_logging[i] =3D NULL;
-	}
-	spin_unlock(&nf_log_lock);
-
-	synchronize_net();
-}
-
-void nf_log_packet(int pf,
-		   unsigned int hooknum,
-		   const struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   struct nf_loginfo *loginfo,
-		   const char *fmt, ...)
-{
-	va_list args;
-	char prefix[NF_LOG_PREFIXLEN];
-	struct nf_logger *logger;
-=09
-	rcu_read_lock();
-	logger =3D rcu_dereference(nf_logging[pf]);
-	if (logger) {
-		va_start(args, fmt);
-		vsnprintf(prefix, sizeof(prefix), fmt, args);
-		va_end(args);
-		/* We must read logging before nf_logfn[pf] */
-		logger->logfn(pf, hooknum, skb, in, out, loginfo, prefix);
-	} else if (net_ratelimit()) {
-		printk(KERN_WARNING "nf_log_packet: can\'t log since "
-		       "no backend logging module loaded in! Please either "
-		       "load one, or disable logging explicitly\n");
-	}
-	rcu_read_unlock();
-}
-EXPORT_SYMBOL(nf_log_register);
-EXPORT_SYMBOL(nf_log_unregister_pf);
-EXPORT_SYMBOL(nf_log_unregister_logger);
-EXPORT_SYMBOL(nf_log_packet);
-
-#ifdef CONFIG_PROC_FS
-struct proc_dir_entry *proc_net_netfilter;
-EXPORT_SYMBOL(proc_net_netfilter);
-
-static void *seq_start(struct seq_file *seq, loff_t *pos)
-{
-	rcu_read_lock();
-
-	if (*pos >=3D NPROTO)
-		return NULL;
-
-	return pos;
-}
-
-static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
-{
-	(*pos)++;
-
-	if (*pos >=3D NPROTO)
-		return NULL;
-
-	return pos;
-}
-
-static void seq_stop(struct seq_file *s, void *v)
-{
-	rcu_read_unlock();
-}
-
-static int seq_show(struct seq_file *s, void *v)
-{
-	loff_t *pos =3D v;
-	const struct nf_logger *logger;
-
-	logger =3D rcu_dereference(nf_logging[*pos]);
-
-	if (!logger)
-		return seq_printf(s, "%2lld NONE\n", *pos);
-=09
-	return seq_printf(s, "%2lld %s\n", *pos, logger->name);
-}
-
-static struct seq_operations nflog_seq_ops =3D {
-	.start	=3D seq_start,
-	.next	=3D seq_next,
-	.stop	=3D seq_stop,
-	.show	=3D seq_show,
-};
-
-static int nflog_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &nflog_seq_ops);
-}
-
-static struct file_operations nflog_file_ops =3D {
-	.owner	 =3D THIS_MODULE,
-	.open	 =3D nflog_open,
-	.read	 =3D seq_read,
-	.llseek	 =3D seq_lseek,
-	.release =3D seq_release,
-};
-
-#endif /* PROC_FS */
-
-
-/* This does not belong here, but locally generated errors need it if conn=
ection
-   tracking in use: without this, connection may not be in hash table, and=
 hence
-   manufactured ICMP or RST packets will not be associated with it. */
-void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *);
-
-void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb)
-{
-	void (*attach)(struct sk_buff *, struct sk_buff *);
-
-	if (skb->nfct && (attach =3D ip_ct_attach) !=3D NULL) {
-		mb(); /* Just to be sure: must be read before executing this */
-		attach(new, skb);
-	}
-}
-
-void __init netfilter_init(void)
-{
-	int i, h;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *pde;
-#endif
-
-	queue_rerouter =3D kmalloc(NPROTO * sizeof(struct nf_queue_rerouter),
-				 GFP_KERNEL);
-	if (!queue_rerouter)
-		panic("netfilter: cannot allocate queue rerouter array\n");
-	memset(queue_rerouter, 0, NPROTO * sizeof(struct nf_queue_rerouter));
-
-	for (i =3D 0; i < NPROTO; i++) {
-		for (h =3D 0; h < NF_MAX_HOOKS; h++)
-			INIT_LIST_HEAD(&nf_hooks[i][h]);
-	}
-
-#ifdef CONFIG_PROC_FS
-	proc_net_netfilter =3D proc_mkdir("netfilter", proc_net);
-	if (!proc_net_netfilter)
-		panic("cannot create netfilter proc entry");
-	pde =3D create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
-	if (!pde)
-		panic("cannot create /proc/net/netfilter/nf_log");
-	pde->proc_fops =3D &nflog_file_ops;
-#endif
-}
-
-EXPORT_SYMBOL(ip_ct_attach);
-EXPORT_SYMBOL(nf_ct_attach);
-EXPORT_SYMBOL(nf_getsockopt);
-EXPORT_SYMBOL(nf_hook_slow);
-EXPORT_SYMBOL(nf_hooks);
-EXPORT_SYMBOL(nf_register_hook);
-EXPORT_SYMBOL(nf_register_queue_handler);
-EXPORT_SYMBOL(nf_register_sockopt);
-EXPORT_SYMBOL(nf_reinject);
-EXPORT_SYMBOL(nf_setsockopt);
-EXPORT_SYMBOL(nf_unregister_hook);
-EXPORT_SYMBOL(nf_unregister_queue_handler);
-EXPORT_SYMBOL_GPL(nf_unregister_queue_handlers);
-EXPORT_SYMBOL_GPL(nf_register_queue_rerouter);
-EXPORT_SYMBOL_GPL(nf_unregister_queue_rerouter);
-EXPORT_SYMBOL(nf_unregister_sockopt);
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,3 +1,7 @@
+netfilter-objs :=3D core.o nf_log.o nf_queue.o nf_sockopt.o
+
+obj-$(CONFIG_NETFILTER) =3D netfilter.o
+
 obj-$(CONFIG_NETFILTER_NETLINK) +=3D nfnetlink.o
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) +=3D nfnetlink_log.o
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/core.c
@@ -0,0 +1,216 @@
+/* netfilter.c: look after the filters for various protocols.=20
+ * Heavily influenced by the old firewall.c by David Bonn and Alan Cox.
+ *
+ * Thanks to Rob `CmdrTaco' Malda for not influencing this code in any
+ * way.
+ *
+ * Rusty Russell (C)2000 -- This code is GPL.
+ *
+ * February 2000: Modified by James Morris to have 1 queue per protocol.
+ * 15-Mar-2000:   Added NF_REPEAT --RR.
+ * 08-May-2003:	  Internal logging interface added by Jozsef Kadlecsik.
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/netfilter.h>
+#include <net/protocol.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/wait.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/if.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/proc_fs.h>
+#include <net/sock.h>
+
+#include "nf_internals.h"
+
+/* In this code, we can be waiting indefinitely for userspace to
+ * service a packet if a hook returns NF_QUEUE.  We could keep a count
+ * of skbuffs queued for userspace, and not deregister a hook unless
+ * this is zero, but that sucks.  Now, we simply check when the
+ * packets come back: if the hook is gone, the packet is discarded. */
+struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS];
+EXPORT_SYMBOL(nf_hooks);
+static DEFINE_SPINLOCK(nf_hook_lock);
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	struct list_head *i;
+
+	spin_lock_bh(&nf_hook_lock);
+	list_for_each(i, &nf_hooks[reg->pf][reg->hooknum]) {
+		if (reg->priority < ((struct nf_hook_ops *)i)->priority)
+			break;
+	}
+	list_add_rcu(&reg->list, i->prev);
+	spin_unlock_bh(&nf_hook_lock);
+
+	synchronize_net();
+	return 0;
+}
+EXPORT_SYMBOL(nf_register_hook);
+
+void nf_unregister_hook(struct nf_hook_ops *reg)
+{
+	spin_lock_bh(&nf_hook_lock);
+	list_del_rcu(&reg->list);
+	spin_unlock_bh(&nf_hook_lock);
+
+	synchronize_net();
+}
+EXPORT_SYMBOL(nf_unregister_hook);
+
+unsigned int nf_iterate(struct list_head *head,
+			struct sk_buff **skb,
+			int hook,
+			const struct net_device *indev,
+			const struct net_device *outdev,
+			struct list_head **i,
+			int (*okfn)(struct sk_buff *),
+			int hook_thresh)
+{
+	unsigned int verdict;
+
+	/*
+	 * The caller must not block between calls to this
+	 * function because of risk of continuing from deleted element.
+	 */
+	list_for_each_continue_rcu(*i, head) {
+		struct nf_hook_ops *elem =3D (struct nf_hook_ops *)*i;
+
+		if (hook_thresh > elem->priority)
+			continue;
+
+		/* Optimization: we don't need to hold module
+                   reference here, since function can't sleep. --RR */
+		verdict =3D elem->hook(hook, skb, indev, outdev, okfn);
+		if (verdict !=3D NF_ACCEPT) {
+#ifdef CONFIG_NETFILTER_DEBUG
+			if (unlikely((verdict & NF_VERDICT_MASK)
+							> NF_MAX_VERDICT)) {
+				NFDEBUG("Evil return from %p(%u).\n",
+				        elem->hook, hook);
+				continue;
+			}
+#endif
+			if (verdict !=3D NF_REPEAT)
+				return verdict;
+			*i =3D (*i)->prev;
+		}
+	}
+	return NF_ACCEPT;
+}
+
+
+/* Returns 1 if okfn() needs to be executed by the caller,
+ * -EPERM for NF_DROP, 0 otherwise. */
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
+		 struct net_device *indev,
+		 struct net_device *outdev,
+		 int (*okfn)(struct sk_buff *),
+		 int hook_thresh)
+{
+	struct list_head *elem;
+	unsigned int verdict;
+	int ret =3D 0;
+
+	/* We may already have this, but read-locks nest anyway */
+	rcu_read_lock();
+
+	elem =3D &nf_hooks[pf][hook];
+next_hook:
+	verdict =3D nf_iterate(&nf_hooks[pf][hook], pskb, hook, indev,
+			     outdev, &elem, okfn, hook_thresh);
+	if (verdict =3D=3D NF_ACCEPT || verdict =3D=3D NF_STOP) {
+		ret =3D 1;
+		goto unlock;
+	} else if (verdict =3D=3D NF_DROP) {
+		kfree_skb(*pskb);
+		ret =3D -EPERM;
+	} else if ((verdict & NF_VERDICT_MASK)  =3D=3D NF_QUEUE) {
+		NFDEBUG("nf_hook: Verdict =3D QUEUE.\n");
+		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn,
+			      verdict >> NF_VERDICT_BITS))
+			goto next_hook;
+	}
+unlock:
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(nf_hook_slow);
+
+
+int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len)
+{
+	struct sk_buff *nskb;
+
+	if (writable_len > (*pskb)->len)
+		return 0;
+
+	/* Not exclusive use of packet?  Must copy. */
+	if (skb_shared(*pskb) || skb_cloned(*pskb))
+		goto copy_skb;
+
+	return pskb_may_pull(*pskb, writable_len);
+
+copy_skb:
+	nskb =3D skb_copy(*pskb, GFP_ATOMIC);
+	if (!nskb)
+		return 0;
+	BUG_ON(skb_is_nonlinear(nskb));
+
+	/* Rest of kernel will get very unhappy if we pass it a
+	   suddenly-orphaned skbuff */
+	if ((*pskb)->sk)
+		skb_set_owner_w(nskb, (*pskb)->sk);
+	kfree_skb(*pskb);
+	*pskb =3D nskb;
+	return 1;
+}
+EXPORT_SYMBOL(skb_make_writable);
+
+
+/* This does not belong here, but locally generated errors need it if conn=
ection
+   tracking in use: without this, connection may not be in hash table, and=
 hence
+   manufactured ICMP or RST packets will not be associated with it. */
+void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *);
+EXPORT_SYMBOL(ip_ct_attach);
+
+void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb)
+{
+	void (*attach)(struct sk_buff *, struct sk_buff *);
+
+	if (skb->nfct && (attach =3D ip_ct_attach) !=3D NULL) {
+		mb(); /* Just to be sure: must be read before executing this */
+		attach(new, skb);
+	}
+}
+EXPORT_SYMBOL(nf_ct_attach);
+
+#ifdef CONFIG_PROC_FS
+struct proc_dir_entry *proc_net_netfilter;
+EXPORT_SYMBOL(proc_net_netfilter);
+#endif
+
+void __init netfilter_init(void)
+{
+	int i, h;
+	for (i =3D 0; i < NPROTO; i++) {
+		for (h =3D 0; h < NF_MAX_HOOKS; h++)
+			INIT_LIST_HEAD(&nf_hooks[i][h]);
+	}
+
+#ifdef CONFIG_PROC_FS
+	proc_net_netfilter =3D proc_mkdir("netfilter", proc_net);
+	if (!proc_net_netfilter)
+		panic("cannot create netfilter proc entry");
+#endif
+
+	if (netfilter_queue_init() < 0)
+		panic("cannot initialize nf_queue");
+	if (netfilter_log_init() < 0)
+		panic("cannot initialize nf_log");
+}
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nf_internals.h
@@ -0,0 +1,39 @@
+#ifndef _NF_INTERNALS_H
+#define _NF_INTERNALS_H
+
+#include <linux/config.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NETFILTER_DEBUG
+#define NFDEBUG(format, args...)  printk(format , ## args)
+#else
+#define NFDEBUG(format, args...)
+#endif
+
+
+/* core.c */
+extern unsigned int nf_iterate(struct list_head *head,
+				struct sk_buff **skb,
+				int hook,
+				const struct net_device *indev,
+				const struct net_device *outdev,
+				struct list_head **i,
+				int (*okfn)(struct sk_buff *),
+				int hook_thresh);
+
+/* nf_queue.c */
+extern int nf_queue(struct sk_buff **skb,=20
+		    struct list_head *elem,=20
+		    int pf, unsigned int hook,
+		    struct net_device *indev,
+		    struct net_device *outdev,
+		    int (*okfn)(struct sk_buff *),
+		    unsigned int queuenum);
+extern int __init netfilter_queue_init(void);
+
+/* nf_log.c */
+extern int __init netfilter_log_init(void);
+
+#endif
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nf_log.c
@@ -0,0 +1,165 @@
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <net/protocol.h>
+
+#include "nf_internals.h"
+
+/* Internal logging interface, which relies on the real=20
+   LOG target modules */
+
+#define NF_LOG_PREFIXLEN		128
+
+static struct nf_logger *nf_logging[NPROTO]; /* =3D NULL */
+static DEFINE_SPINLOCK(nf_log_lock);
+
+int nf_log_register(int pf, struct nf_logger *logger)
+{
+	int ret =3D -EBUSY;
+
+	/* Any setup of logging members must be done before
+	 * substituting pointer. */
+	spin_lock(&nf_log_lock);
+	if (!nf_logging[pf]) {
+		rcu_assign_pointer(nf_logging[pf], logger);
+		ret =3D 0;
+	}
+	spin_unlock(&nf_log_lock);
+	return ret;
+}	=09
+EXPORT_SYMBOL(nf_log_register);
+
+void nf_log_unregister_pf(int pf)
+{
+	spin_lock(&nf_log_lock);
+	nf_logging[pf] =3D NULL;
+	spin_unlock(&nf_log_lock);
+
+	/* Give time to concurrent readers. */
+	synchronize_net();
+}
+EXPORT_SYMBOL(nf_log_unregister_pf);
+
+void nf_log_unregister_logger(struct nf_logger *logger)
+{
+	int i;
+
+	spin_lock(&nf_log_lock);
+	for (i =3D 0; i < NPROTO; i++) {
+		if (nf_logging[i] =3D=3D logger)
+			nf_logging[i] =3D NULL;
+	}
+	spin_unlock(&nf_log_lock);
+
+	synchronize_net();
+}
+EXPORT_SYMBOL(nf_log_unregister_logger);
+
+void nf_log_packet(int pf,
+		   unsigned int hooknum,
+		   const struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   struct nf_loginfo *loginfo,
+		   const char *fmt, ...)
+{
+	va_list args;
+	char prefix[NF_LOG_PREFIXLEN];
+	struct nf_logger *logger;
+=09
+	rcu_read_lock();
+	logger =3D rcu_dereference(nf_logging[pf]);
+	if (logger) {
+		va_start(args, fmt);
+		vsnprintf(prefix, sizeof(prefix), fmt, args);
+		va_end(args);
+		/* We must read logging before nf_logfn[pf] */
+		logger->logfn(pf, hooknum, skb, in, out, loginfo, prefix);
+	} else if (net_ratelimit()) {
+		printk(KERN_WARNING "nf_log_packet: can\'t log since "
+		       "no backend logging module loaded in! Please either "
+		       "load one, or disable logging explicitly\n");
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(nf_log_packet);
+
+#ifdef CONFIG_PROC_FS
+static void *seq_start(struct seq_file *seq, loff_t *pos)
+{
+	rcu_read_lock();
+
+	if (*pos >=3D NPROTO)
+		return NULL;
+
+	return pos;
+}
+
+static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	(*pos)++;
+
+	if (*pos >=3D NPROTO)
+		return NULL;
+
+	return pos;
+}
+
+static void seq_stop(struct seq_file *s, void *v)
+{
+	rcu_read_unlock();
+}
+
+static int seq_show(struct seq_file *s, void *v)
+{
+	loff_t *pos =3D v;
+	const struct nf_logger *logger;
+
+	logger =3D rcu_dereference(nf_logging[*pos]);
+
+	if (!logger)
+		return seq_printf(s, "%2lld NONE\n", *pos);
+=09
+	return seq_printf(s, "%2lld %s\n", *pos, logger->name);
+}
+
+static struct seq_operations nflog_seq_ops =3D {
+	.start	=3D seq_start,
+	.next	=3D seq_next,
+	.stop	=3D seq_stop,
+	.show	=3D seq_show,
+};
+
+static int nflog_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &nflog_seq_ops);
+}
+
+static struct file_operations nflog_file_ops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D nflog_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release,
+};
+
+#endif /* PROC_FS */
+
+
+int __init netfilter_log_init(void)
+{
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *pde;
+	pde =3D create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
+#endif
+	if (!pde)
+		return -1;
+
+	pde->proc_fops =3D &nflog_file_ops;
+
+	return 0;
+}
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nf_queue.c
@@ -0,0 +1,273 @@
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <net/protocol.h>
+
+#include "nf_internals.h"
+
+/*=20
+ * A queue handler may be registered for each protocol.  Each is protected=
 by
+ * long term mutex.  The handler must provide an an outfn() to accept pack=
ets
+ * for queueing and must reinject all packets it receives, no matter what.
+ */
+static struct nf_queue_handler_t {
+	nf_queue_outfn_t outfn;
+	void *data;
+} queue_handler[NPROTO];
+
+static struct nf_queue_rerouter *queue_rerouter;
+
+static DEFINE_RWLOCK(queue_handler_lock);
+
+
+int nf_register_queue_handler(int pf, nf_queue_outfn_t outfn, void *data)
+{     =20
+	int ret;
+
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	if (queue_handler[pf].outfn)
+		ret =3D -EBUSY;
+	else {
+		queue_handler[pf].outfn =3D outfn;
+		queue_handler[pf].data =3D data;
+		ret =3D 0;
+	}
+	write_unlock_bh(&queue_handler_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(nf_register_queue_handler);
+
+/* The caller must flush their queue before this */
+int nf_unregister_queue_handler(int pf)
+{
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	queue_handler[pf].outfn =3D NULL;
+	queue_handler[pf].data =3D NULL;
+	write_unlock_bh(&queue_handler_lock);
+=09
+	return 0;
+}
+EXPORT_SYMBOL(nf_unregister_queue_handler);
+
+int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *rer)
+{
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	memcpy(&queue_rerouter[pf], rer, sizeof(queue_rerouter[pf]));
+	write_unlock_bh(&queue_handler_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_register_queue_rerouter);
+
+int nf_unregister_queue_rerouter(int pf)
+{
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	memset(&queue_rerouter[pf], 0, sizeof(queue_rerouter[pf]));
+	write_unlock_bh(&queue_handler_lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_unregister_queue_rerouter);
+
+void nf_unregister_queue_handlers(nf_queue_outfn_t outfn)
+{
+	int pf;
+
+	write_lock_bh(&queue_handler_lock);
+	for (pf =3D 0; pf < NPROTO; pf++)  {
+		if (queue_handler[pf].outfn =3D=3D outfn) {
+			queue_handler[pf].outfn =3D NULL;
+			queue_handler[pf].data =3D NULL;
+		}
+	}
+	write_unlock_bh(&queue_handler_lock);
+}
+EXPORT_SYMBOL_GPL(nf_unregister_queue_handlers);
+
+/*=20
+ * Any packet that leaves via this function must come back=20
+ * through nf_reinject().
+ */
+int nf_queue(struct sk_buff **skb,=20
+	     struct list_head *elem,=20
+	     int pf, unsigned int hook,
+	     struct net_device *indev,
+	     struct net_device *outdev,
+	     int (*okfn)(struct sk_buff *),
+	     unsigned int queuenum)
+{
+	int status;
+	struct nf_info *info;
+#ifdef CONFIG_BRIDGE_NETFILTER
+	struct net_device *physindev =3D NULL;
+	struct net_device *physoutdev =3D NULL;
+#endif
+
+	/* QUEUE =3D=3D DROP if noone is waiting, to be safe. */
+	read_lock(&queue_handler_lock);
+	if (!queue_handler[pf].outfn) {
+		read_unlock(&queue_handler_lock);
+		kfree_skb(*skb);
+		return 1;
+	}
+
+	info =3D kmalloc(sizeof(*info)+queue_rerouter[pf].rer_size, GFP_ATOMIC);
+	if (!info) {
+		if (net_ratelimit())
+			printk(KERN_ERR "OOM queueing packet %p\n",
+			       *skb);
+		read_unlock(&queue_handler_lock);
+		kfree_skb(*skb);
+		return 1;
+	}
+
+	*info =3D (struct nf_info) {=20
+		(struct nf_hook_ops *)elem, pf, hook, indev, outdev, okfn };
+
+	/* If it's going away, ignore hook. */
+	if (!try_module_get(info->elem->owner)) {
+		read_unlock(&queue_handler_lock);
+		kfree(info);
+		return 0;
+	}
+
+	/* Bump dev refs so they don't vanish while packet is out */
+	if (indev) dev_hold(indev);
+	if (outdev) dev_hold(outdev);
+
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if ((*skb)->nf_bridge) {
+		physindev =3D (*skb)->nf_bridge->physindev;
+		if (physindev) dev_hold(physindev);
+		physoutdev =3D (*skb)->nf_bridge->physoutdev;
+		if (physoutdev) dev_hold(physoutdev);
+	}
+#endif
+	if (queue_rerouter[pf].save)
+		queue_rerouter[pf].save(*skb, info);
+
+	status =3D queue_handler[pf].outfn(*skb, info, queuenum,
+					 queue_handler[pf].data);
+
+	if (status >=3D 0 && queue_rerouter[pf].reroute)
+		status =3D queue_rerouter[pf].reroute(skb, info);
+
+	read_unlock(&queue_handler_lock);
+
+	if (status < 0) {
+		/* James M doesn't say fuck enough. */
+		if (indev) dev_put(indev);
+		if (outdev) dev_put(outdev);
+#ifdef CONFIG_BRIDGE_NETFILTER
+		if (physindev) dev_put(physindev);
+		if (physoutdev) dev_put(physoutdev);
+#endif
+		module_put(info->elem->owner);
+		kfree(info);
+		kfree_skb(*skb);
+
+		return 1;
+	}
+
+	return 1;
+}
+
+void nf_reinject(struct sk_buff *skb, struct nf_info *info,
+		 unsigned int verdict)
+{
+	struct list_head *elem =3D &info->elem->list;
+	struct list_head *i;
+
+	rcu_read_lock();
+
+	/* Release those devices we held, or Alexey will kill me. */
+	if (info->indev) dev_put(info->indev);
+	if (info->outdev) dev_put(info->outdev);
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge) {
+		if (skb->nf_bridge->physindev)
+			dev_put(skb->nf_bridge->physindev);
+		if (skb->nf_bridge->physoutdev)
+			dev_put(skb->nf_bridge->physoutdev);
+	}
+#endif
+
+	/* Drop reference to owner of hook which queued us. */
+	module_put(info->elem->owner);
+
+	list_for_each_rcu(i, &nf_hooks[info->pf][info->hook]) {
+		if (i =3D=3D elem)=20
+  			break;
+  	}
+ =20
+	if (elem =3D=3D &nf_hooks[info->pf][info->hook]) {
+		/* The module which sent it to userspace is gone. */
+		NFDEBUG("%s: module disappeared, dropping packet.\n",
+			__FUNCTION__);
+		verdict =3D NF_DROP;
+	}
+
+	/* Continue traversal iff userspace said ok... */
+	if (verdict =3D=3D NF_REPEAT) {
+		elem =3D elem->prev;
+		verdict =3D NF_ACCEPT;
+	}
+
+	if (verdict =3D=3D NF_ACCEPT) {
+	next_hook:
+		verdict =3D nf_iterate(&nf_hooks[info->pf][info->hook],
+				     &skb, info->hook,=20
+				     info->indev, info->outdev, &elem,
+				     info->okfn, INT_MIN);
+	}
+
+	switch (verdict & NF_VERDICT_MASK) {
+	case NF_ACCEPT:
+		info->okfn(skb);
+		break;
+
+	case NF_QUEUE:
+		if (!nf_queue(&skb, elem, info->pf, info->hook,=20
+			      info->indev, info->outdev, info->okfn,
+			      verdict >> NF_VERDICT_BITS))
+			goto next_hook;
+		break;
+	}
+	rcu_read_unlock();
+
+	if (verdict =3D=3D NF_DROP)
+		kfree_skb(skb);
+
+	kfree(info);
+	return;
+}
+EXPORT_SYMBOL(nf_reinject);
+
+int __init netfilter_queue_init(void)
+{
+	queue_rerouter =3D kmalloc(NPROTO * sizeof(struct nf_queue_rerouter),
+				 GFP_KERNEL);
+	if (!queue_rerouter)
+		return -ENOMEM;
+
+	memset(queue_rerouter, 0, NPROTO * sizeof(struct nf_queue_rerouter));
+
+	return 0;
+}
+
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nf_sockopt.c
@@ -0,0 +1,132 @@
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <net/sock.h>
+
+#include "nf_internals.h"
+
+/* Sockopts only registered and called from user context, so
+   net locking would be overkill.  Also, [gs]etsockopt calls may
+   sleep. */
+static DECLARE_MUTEX(nf_sockopt_mutex);
+static LIST_HEAD(nf_sockopts);
+
+/* Do exclusive ranges overlap? */
+static inline int overlap(int min1, int max1, int min2, int max2)
+{
+	return max1 > min2 && min1 < max2;
+}
+
+/* Functions to register sockopt ranges (exclusive). */
+int nf_register_sockopt(struct nf_sockopt_ops *reg)
+{
+	struct list_head *i;
+	int ret =3D 0;
+
+	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
+		return -EINTR;
+
+	list_for_each(i, &nf_sockopts) {
+		struct nf_sockopt_ops *ops =3D (struct nf_sockopt_ops *)i;
+		if (ops->pf =3D=3D reg->pf
+		    && (overlap(ops->set_optmin, ops->set_optmax,=20
+				reg->set_optmin, reg->set_optmax)
+			|| overlap(ops->get_optmin, ops->get_optmax,=20
+				   reg->get_optmin, reg->get_optmax))) {
+			NFDEBUG("nf_sock overlap: %u-%u/%u-%u v %u-%u/%u-%u\n",
+				ops->set_optmin, ops->set_optmax,=20
+				ops->get_optmin, ops->get_optmax,=20
+				reg->set_optmin, reg->set_optmax,
+				reg->get_optmin, reg->get_optmax);
+			ret =3D -EBUSY;
+			goto out;
+		}
+	}
+
+	list_add(&reg->list, &nf_sockopts);
+out:
+	up(&nf_sockopt_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(nf_register_sockopt);
+
+void nf_unregister_sockopt(struct nf_sockopt_ops *reg)
+{
+	/* No point being interruptible: we're probably in cleanup_module() */
+ restart:
+	down(&nf_sockopt_mutex);
+	if (reg->use !=3D 0) {
+		/* To be woken by nf_sockopt call... */
+		/* FIXME: Stuart Young's name appears gratuitously. */
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		reg->cleanup_task =3D current;
+		up(&nf_sockopt_mutex);
+		schedule();
+		goto restart;
+	}
+	list_del(&reg->list);
+	up(&nf_sockopt_mutex);
+}
+EXPORT_SYMBOL(nf_unregister_sockopt);
+
+/* Call get/setsockopt() */
+static int nf_sockopt(struct sock *sk, int pf, int val,=20
+		      char __user *opt, int *len, int get)
+{
+	struct list_head *i;
+	struct nf_sockopt_ops *ops;
+	int ret;
+
+	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
+		return -EINTR;
+
+	list_for_each(i, &nf_sockopts) {
+		ops =3D (struct nf_sockopt_ops *)i;
+		if (ops->pf =3D=3D pf) {
+			if (get) {
+				if (val >=3D ops->get_optmin
+				    && val < ops->get_optmax) {
+					ops->use++;
+					up(&nf_sockopt_mutex);
+					ret =3D ops->get(sk, val, opt, len);
+					goto out;
+				}
+			} else {
+				if (val >=3D ops->set_optmin
+				    && val < ops->set_optmax) {
+					ops->use++;
+					up(&nf_sockopt_mutex);
+					ret =3D ops->set(sk, val, opt, *len);
+					goto out;
+				}
+			}
+		}
+	}
+	up(&nf_sockopt_mutex);
+	return -ENOPROTOOPT;
+=09
+ out:
+	down(&nf_sockopt_mutex);
+	ops->use--;
+	if (ops->cleanup_task)
+		wake_up_process(ops->cleanup_task);
+	up(&nf_sockopt_mutex);
+	return ret;
+}
+
+int nf_setsockopt(struct sock *sk, int pf, int val, char __user *opt,
+		  int len)
+{
+	return nf_sockopt(sk, pf, val, opt, &len, 0);
+}
+EXPORT_SYMBOL(nf_setsockopt);
+
+int nf_getsockopt(struct sock *sk, int pf, int val, char __user *opt, int =
*len)
+{
+	return nf_sockopt(sk, pf, val, opt, len, 1);
+}
+EXPORT_SYMBOL(nf_getsockopt);
+

--RD6GsZsdEJvsf78O--

--gw4vLALk08fVJy3V
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9ohvXaXGVTD0i/8RAhPzAKCDXzw3ZSD4DXqGFk9WPu22suw4ywCgq7ie
+PzysJJ8iRnTFXml0s3d/Bg=
=nQNb
-----END PGP SIGNATURE-----

--gw4vLALk08fVJy3V--
