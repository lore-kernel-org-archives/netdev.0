From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Mon, 8 Aug 2005 10:16:00 +0200
Message-ID: <20050808081600.GB7801@rama.de.gnumonks.org>
References: <20050730110353.GD6620@rama.de.gnumonks.org>
	<20050730.210423.111177162.davem@davemloft.net>
	<20050731070509.GD3835@rama.de.gnumonks.org>
	<1123241167.3377.15.camel@localhost.localdomain>
	<20050805163709.GF4033@rama.de.gnumonks.org>
	<20050805171028.GA7855@rama.de.gnumonks.org>
	<1123450076.3378.18.camel@localhost.localdomain>
	<20050807213340.GA4508@rama.de.gnumonks.org>
	<1123484260.3686.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Izn7cH1Com+I3R9J"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1123484260.3686.1.camel@localhost.localdomain>
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


--Izn7cH1Com+I3R9J
Content-Type: multipart/mixed; boundary="wzJLGUyc3ArbnUjN"
Content-Disposition: inline


--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[removing kaber and davem from cc list]

On Mon, Aug 08, 2005 at 06:57:40AM +0000, Bart De Schuymer wrote:
> > So I think it should reflect exactly what you currently do in ebt_ulog.
> > The only diference is that you now get the ifindex and not the device
> > name string.
>=20
> These two code fragments do not do the same thing. If indev is a bridge
> port (meaning indev->br_port !=3D NULL), then the NFULA_IFINDEX_PHYSINDEV
> must be indev, while the NFULA_IFINDEX_INDEV must be in->br_port->br-
> >dev->name.
> If indev is not a bridge port, the ebt_ulog code makes
> NFULA_IFINDEX_PHYSINDEV and NFULA_IFINDEX_INDEV the same (indev).

Ok, so this is actually the opposite problem of the ipt_physdev.c
problem.  Here we have the physical device, but not the bridge group.

This means we have to handle two separate cases:

1) when nf_log_packet() gets called from the bridging code
	indev =3D=3D eth0
	outdev =3D=3D eth1
		-> we need to resolve br0 from dev->br_port member

2) when nf_log_packet() gets called from the ipv4 code:
	indev =3D=3D br0
	outdev =3D=3D br0
		-> we need to resolve ethX from skb->nf_bridge member

If I'm now correct, what about the following [reverse] patch (also
attached the whole resulting file for your reference, since you don't
have access to the tree).

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bridge2.diff"
Content-Transfer-Encoding: quoted-printable

diff --git a/include/linux/netfilter/nfnetlink_log.h b/include/linux/netfil=
ter/nfnetlink_log.h
--- a/include/linux/netfilter/nfnetlink_log.h
+++ b/include/linux/netfilter/nfnetlink_log.h
@@ -40,8 +40,6 @@ enum nfulnl_attr_type {
 	NFULA_TIMESTAMP,		/* nfulnl_msg_packet_timestamp */
 	NFULA_IFINDEX_INDEV,		/* u_int32_t ifindex */
 	NFULA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
-	NFULA_IFINDEX_PHYSINDEV,	/* u_int32_t ifindex */
-	NFULA_IFINDEX_PHYSOUTDEV,	/* u_int32_t ifindex */
 	NFULA_HWADDR,			/* nfulnl_msg_packet_hw */
 	NFULA_PAYLOAD,			/* opaque data payload */
 	NFULA_PREFIX,			/* string prefix */
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -36,8 +36,6 @@ enum nfqnl_attr_type {
 	NFQA_TIMESTAMP,			/* nfqnl_msg_packet_timestamp */
 	NFQA_IFINDEX_INDEV,		/* u_int32_t ifindex */
 	NFQA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
-	NFQA_IFINDEX_PHYSINDEV,		/* u_int32_t ifindex */
-	NFQA_IFINDEX_PHYSOUTDEV,	/* u_int32_t ifindex */
 	NFQA_HWADDR,			/* nfqnl_msg_packet_hw */
 	NFQA_PAYLOAD,			/* opaque data payload */
=20
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -33,10 +33,6 @@
=20
 #include <asm/atomic.h>
=20
-#ifdef CONFIG_BRIDGE_NETFILTER
-#include "../bridge/br_private.h"
-#endif
-
 #define NFULNL_NLBUFSIZ_DEFAULT	4096
 #define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
@@ -416,64 +412,14 @@ __build_packet_message(struct nfulnl_ins
=20
 	if (indev) {
 		tmp_uint =3D htonl(indev->ifindex);
-#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV, sizeof(tmp_uint),
 			&tmp_uint);
-#else
-		if (indev->br_port) {
-			/* Case 1: indev is physical input device, we need to
-			 * look for bridge group (when called from=20
-			 * netfilter_bridge) */
-			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
-				sizeof(tmp_uint), &tmp_uint);
-			/* this is the bridge group "brX" */
-			tmp_uint =3D htonl(indev->br_port->br->dev->ifindex);
-			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
-				sizeof(tmp_uint), &tmp_uint);
-		} else {
-			/* Case 2: indev is bridge group, we need to look for
-			 * physical device (when called from ipv4) */
-			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
-				sizeof(tmp_uint), &tmp_uint);
-			if (skb->nf_bridge && skb->nf_bridge->physindev) {
-				tmp_uint =3D=20
-				    htonl(skb->nf_bridge->physindev->ifindex);
-				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
-					sizeof(tmp_uint), &tmp_uint);
-			}
-		}
-#endif
 	}
=20
 	if (outdev) {
 		tmp_uint =3D htonl(outdev->ifindex);
-#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV, sizeof(tmp_uint),
 			&tmp_uint);
-#else
-		if (outdev->br_port) {
-			/* Case 1: outdev is physical output device, we need to
-			 * look for bridge group (when called from
-			 * netfilter_bridge) */
-			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
-				sizeof(tmp_uint), &tmp_uint);
-			/* this is the bridge group "brX" */
-			tmp_uint =3D htonl(outdev->br_port->br->dev->ifindex);
-			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
-				sizeof(tmp_uint), &tmp_uint);
-		} else {
-			/* Case 2: indev is a bridge group, we need to look
-			 * for physical device (when called from ipv4) */
-			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
-				sizeof(tmp_uint), &tmp_uint);
-			if (skb->nf_bridge) {
-				tmp_uint =3D=20
-				    htonl(skb->nf_bridge->physoutdev->ifindex);
-				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
-					sizeof(tmp_uint), &tmp_uint);
-			}
-		}
-#endif
 	}
=20
 	if (skb->nfmark) {
@@ -590,10 +536,6 @@ nfulnl_log_packet(unsigned int pf,
 		+ NFA_SPACE(sizeof(struct nfulnl_msg_packet_hdr))
 		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
 		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
-#ifdef CONFIG_BRIDGE_NETFILTER
-		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
-		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
-#endif
 		+ NFA_SPACE(sizeof(u_int32_t))	/* mark */
 		+ NFA_SPACE(sizeof(u_int32_t))	/* uid */
 		+ NFA_SPACE(NFULNL_PREFIXLEN)	/* prefix */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -30,10 +30,6 @@
=20
 #include <asm/atomic.h>
=20
-#ifdef CONFIG_BRIDGE_NETFILTER
-#include "../bridge/br_private.h"
-#endif
-
 #define NFQNL_QMAX_DEFAULT 1024
=20
 #if 0
@@ -365,10 +361,6 @@ nfqnl_build_packet_message(struct nfqnl_
 	size =3D    NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hdr))
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
-#ifdef CONFIG_BRIDGE_NETFILTER
-		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
-		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
-#endif
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* mark */
 		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hw))
 		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_timestamp));
@@ -420,62 +412,12 @@ nfqnl_build_packet_message(struct nfqnl_
=20
 	if (entry->info->indev) {
 		tmp_uint =3D htonl(entry->info->indev->ifindex);
-#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint), &tmp_uint);
-#else
-		if (entry->info->indev->br_port) {
-			/* Case 1: indev is physical input device, we need to
-			 * look for bridge group (when called from=20
-			 * netfilter_bridge) */
-			NFA_PUT(skb, NFQA_IFINDEX_PHYSINDEV, sizeof(tmp_uint),=20
-				&tmp_uint);
-			/* this is the bridge group "brX" */
-			tmp_uint =3D htonl(entry->info->indev->br_port->br->dev->ifindex);
-			NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint),
-				&tmp_uint);
-		} else {
-			/* Case 2: indev is bridge group, we need to look for
-			 * physical device (when called from ipv4) */
-			NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint),
-				&tmp_uint);
-			if (entry->skb->nf_bridge
-			    && entry->skb->nf_bridge->physindev) {
-				tmp_uint =3D htonl(entry->skb->nf_bridge->physindev->ifindex);
-				NFA_PUT(skb, NFQA_IFINDEX_PHYSINDEV,
-					sizeof(tmp_uint), &tmp_uint);
-			}
-		}
-#endif
 	}
=20
 	if (entry->info->outdev) {
 		tmp_uint =3D htonl(entry->info->outdev->ifindex);
-#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint), &tmp_uint);
-#else
-		if (entry->info->outdev->br_port) {
-			/* Case 1: outdev is physical output device, we need to
-			 * look for bridge group (when called from=20
-			 * netfilter_bridge) */
-			NFA_PUT(skb, NFQA_IFINDEX_PHYSOUTDEV, sizeof(tmp_uint),
-				&tmp_uint);
-			/* this is the bridge group "brX" */
-			tmp_uint =3D htonl(entry->info->outdev->br_port->br->dev->ifindex);
-			NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint),
-				&tmp_uint);
-		} else {
-			/* Case 2: outdev is bridge group, we need to look for
-			 * physical output device (when called from ipv4) */
-			NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint),
-				&tmp_uint);
-			if (entry->skb->nf_bridge
-			    && entry->skb->nf_bridge->physoutdev) {
-				tmp_uint =3D htonl(entry->skb->nf_bridge->physoutdev->ifindex);
-				NFA_PUT(skb, NFQA_IFINDEX_PHYSOUTDEV,
-					sizeof(tmp_uint), &tmp_uint);
-			}
-		}
-#endif
 	}
=20
 	if (entry->skb->nfmark) {

--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfnetlink_log.c"
Content-Transfer-Encoding: quoted-printable

/*
 * This is a module which is used for logging packets to userspace via
 * nfetlink.
 *
 * (C) 2005 by Harald Welte <laforge@netfilter.org>
 *
 * Based on the old ipv4-only ipt_ULOG.c:
 * (C) 2000-2004 by Harald Welte <laforge@netfilter.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */
#include <linux/module.h>
#include <linux/skbuff.h>
#include <linux/init.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/netdevice.h>
#include <linux/netfilter.h>
#include <linux/netlink.h>
#include <linux/netfilter/nfnetlink.h>
#include <linux/netfilter/nfnetlink_log.h>
#include <linux/spinlock.h>
#include <linux/sysctl.h>
#include <linux/proc_fs.h>
#include <linux/security.h>
#include <linux/list.h>
#include <linux/jhash.h>
#include <linux/random.h>
#include <net/sock.h>

#include <asm/atomic.h>

#ifdef CONFIG_BRIDGE_NETFILTER
#include "../bridge/br_private.h"
#endif

#define NFULNL_NLBUFSIZ_DEFAULT	4096
#define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
#define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */

#define PRINTR(x, args...)	do { if (net_ratelimit()) \
				     printk(x, ## args); } while (0);

#if 0
#define UDEBUG(x, args ...)	printk(KERN_DEBUG "%s(%d):%s():	" x, 	   \
					__FILE__, __LINE__, __FUNCTION__,  \
					## args)
#else
#define UDEBUG(x, ...)
#endif

struct nfulnl_instance {
	struct hlist_node hlist;	/* global list of instances */
	spinlock_t lock;
	atomic_t use;			/* use count */

	unsigned int qlen;		/* number of nlmsgs in skb */
	struct sk_buff *skb;		/* pre-allocatd skb */
	struct nlmsghdr *lastnlh;	/* netlink header of last msg in skb */
	struct timer_list timer;
	int peer_pid;			/* PID of the peer process */

	/* configurable parameters */
	unsigned int flushtimeout;	/* timeout until queue flush */
	unsigned int nlbufsiz;		/* netlink buffer allocation size */
	unsigned int qthreshold;	/* threshold of the queue */
	u_int32_t copy_range;
	u_int16_t group_num;		/* number of this queue */
	u_int8_t copy_mode;=09
};

static DEFINE_RWLOCK(instances_lock);

#define INSTANCE_BUCKETS	16
static struct hlist_head instance_table[INSTANCE_BUCKETS];
static unsigned int hash_init;

static inline u_int8_t instance_hashfn(u_int16_t group_num)
{
	return ((group_num & 0xff) % INSTANCE_BUCKETS);
}

static struct nfulnl_instance *
__instance_lookup(u_int16_t group_num)
{
	struct hlist_head *head;
	struct hlist_node *pos;
	struct nfulnl_instance *inst;

	UDEBUG("entering (group_num=3D%u)\n", group_num);

	head =3D &instance_table[instance_hashfn(group_num)];
	hlist_for_each_entry(inst, pos, head, hlist) {
		if (inst->group_num =3D=3D group_num)
			return inst;
	}
	return NULL;
}

static inline void
instance_get(struct nfulnl_instance *inst)
{
	atomic_inc(&inst->use);
}

static struct nfulnl_instance *
instance_lookup_get(u_int16_t group_num)
{
	struct nfulnl_instance *inst;

	read_lock_bh(&instances_lock);
	inst =3D __instance_lookup(group_num);
	if (inst)
		instance_get(inst);
	read_unlock_bh(&instances_lock);

	return inst;
}

static void
instance_put(struct nfulnl_instance *inst)
{
	if (inst && atomic_dec_and_test(&inst->use)) {
		UDEBUG("kfree(inst=3D%p)\n", inst);
		kfree(inst);
	}
}

static void nfulnl_timer(unsigned long data);

static struct nfulnl_instance *
instance_create(u_int16_t group_num, int pid)
{
	struct nfulnl_instance *inst;

	UDEBUG("entering (group_num=3D%u, pid=3D%d)\n", group_num,
		pid);

	write_lock_bh(&instances_lock);=09
	if (__instance_lookup(group_num)) {
		inst =3D NULL;
		UDEBUG("aborting, instance already exists\n");
		goto out_unlock;
	}

	inst =3D kmalloc(sizeof(*inst), GFP_ATOMIC);
	if (!inst)
		goto out_unlock;

	memset(inst, 0, sizeof(*inst));
	INIT_HLIST_NODE(&inst->hlist);
	inst->lock =3D SPIN_LOCK_UNLOCKED;
	/* needs to be two, since we _put() after creation */
	atomic_set(&inst->use, 2);

	init_timer(&inst->timer);
	inst->timer.function =3D nfulnl_timer;
	inst->timer.data =3D (unsigned long)inst;
	/* don't start timer yet. (re)start it  with every packet */

	inst->peer_pid =3D pid;
	inst->group_num =3D group_num;

	inst->qthreshold 	=3D NFULNL_QTHRESH_DEFAULT;
	inst->flushtimeout 	=3D NFULNL_TIMEOUT_DEFAULT;
	inst->nlbufsiz 		=3D NFULNL_NLBUFSIZ_DEFAULT;
	inst->copy_mode 	=3D NFULNL_COPY_PACKET;
	inst->copy_range 	=3D 0xffff;

	if (!try_module_get(THIS_MODULE))
		goto out_free;

	hlist_add_head(&inst->hlist,=20
		       &instance_table[instance_hashfn(group_num)]);

	UDEBUG("newly added node: %p, next=3D%p\n", &inst->hlist,=20
		inst->hlist.next);

	write_unlock_bh(&instances_lock);

	return inst;

out_free:
	instance_put(inst);
out_unlock:
	write_unlock_bh(&instances_lock);
	return NULL;
}

static int __nfulnl_send(struct nfulnl_instance *inst);

static void
_instance_destroy2(struct nfulnl_instance *inst, int lock)
{
	/* first pull it out of the global list */
	if (lock)
		write_lock_bh(&instances_lock);

	UDEBUG("removing instance %p (queuenum=3D%u) from hash\n",
		inst, inst->group_num);

	hlist_del(&inst->hlist);

	if (lock)
		write_unlock_bh(&instances_lock);

	/* then flush all pending packets from skb */

	spin_lock_bh(&inst->lock);
	if (inst->skb) {
		if (inst->qlen)
			__nfulnl_send(inst);
		if (inst->skb) {
			kfree_skb(inst->skb);
			inst->skb =3D NULL;
		}
	}
	spin_unlock_bh(&inst->lock);

	/* and finally put the refcount */
	instance_put(inst);

	module_put(THIS_MODULE);
}

static inline void
__instance_destroy(struct nfulnl_instance *inst)
{
	_instance_destroy2(inst, 0);
}

static inline void
instance_destroy(struct nfulnl_instance *inst)
{
	_instance_destroy2(inst, 1);
}

static int
nfulnl_set_mode(struct nfulnl_instance *inst, u_int8_t mode,
		  unsigned int range)
{
	int status =3D 0;

	spin_lock_bh(&inst->lock);
=09
	switch (mode) {
	case NFULNL_COPY_NONE:
	case NFULNL_COPY_META:
		inst->copy_mode =3D mode;
		inst->copy_range =3D 0;
		break;
	=09
	case NFULNL_COPY_PACKET:
		inst->copy_mode =3D mode;
		/* we're using struct nfattr which has 16bit nfa_len */
		if (range > 0xffff)
			inst->copy_range =3D 0xffff;
		else
			inst->copy_range =3D range;
		break;
	=09
	default:
		status =3D -EINVAL;
		break;
	}

	spin_unlock_bh(&inst->lock);

	return status;
}

static int
nfulnl_set_nlbufsiz(struct nfulnl_instance *inst, u_int32_t nlbufsiz)
{
	int status;

	spin_lock_bh(&inst->lock);
	if (nlbufsiz < NFULNL_NLBUFSIZ_DEFAULT)
		status =3D -ERANGE;
	else if (nlbufsiz > 131072)
		status =3D -ERANGE;
	else {
		inst->nlbufsiz =3D nlbufsiz;
		status =3D 0;
	}
	spin_unlock_bh(&inst->lock);

	return status;
}

static int
nfulnl_set_timeout(struct nfulnl_instance *inst, u_int32_t timeout)
{
	spin_lock_bh(&inst->lock);
	inst->flushtimeout =3D timeout;
	spin_unlock_bh(&inst->lock);

	return 0;
}

static int
nfulnl_set_qthresh(struct nfulnl_instance *inst, u_int32_t qthresh)
{
	spin_lock_bh(&inst->lock);
	inst->qthreshold =3D qthresh;
	spin_unlock_bh(&inst->lock);

	return 0;
}

static struct sk_buff *nfulnl_alloc_skb(unsigned int inst_size,=20
					unsigned int pkt_size)
{
	struct sk_buff *skb;

	UDEBUG("entered (%u, %u)\n", inst_size, pkt_size);

	/* alloc skb which should be big enough for a whole multipart
	 * message.  WARNING: has to be <=3D 128k due to slab restrictions */

	skb =3D alloc_skb(inst_size, GFP_ATOMIC);
	if (!skb) {
		PRINTR("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
			inst_size);

		/* try to allocate only as much as we need for current
		 * packet */

		skb =3D alloc_skb(pkt_size, GFP_ATOMIC);
		if (!skb)
			PRINTR("nfnetlink_log: can't even alloc %u bytes\n",
				pkt_size);
	}

	return skb;
}

static int
__nfulnl_send(struct nfulnl_instance *inst)
{
	int status;

	if (timer_pending(&inst->timer))
		del_timer(&inst->timer);

	if (inst->qlen > 1)
		inst->lastnlh->nlmsg_type =3D NLMSG_DONE;

	status =3D nfnetlink_unicast(inst->skb, inst->peer_pid, MSG_DONTWAIT);
	if (status < 0) {
		UDEBUG("netlink_unicast() failed\n");
		/* FIXME: statistics */
	}

	inst->qlen =3D 0;
	inst->skb =3D NULL;
	inst->lastnlh =3D NULL;

	return status;
}

static void nfulnl_timer(unsigned long data)
{
	struct nfulnl_instance *inst =3D (struct nfulnl_instance *)data;=20

	UDEBUG("timer function called, flushing buffer\n");

	spin_lock_bh(&inst->lock);
	__nfulnl_send(inst);
	instance_put(inst);
	spin_unlock_bh(&inst->lock);
}

static inline int=20
__build_packet_message(struct nfulnl_instance *inst,
			const struct sk_buff *skb,=20
			unsigned int data_len,
			unsigned int pf,
			unsigned int hooknum,
			const struct net_device *indev,
			const struct net_device *outdev,
			const struct nf_loginfo *li,
			const char *prefix)
{
	unsigned char *old_tail;
	struct nfulnl_msg_packet_hdr pmsg;
	struct nlmsghdr *nlh;
	struct nfgenmsg *nfmsg;
	u_int32_t tmp_uint;

	UDEBUG("entered\n");
	=09
	old_tail =3D inst->skb->tail;
	nlh =3D NLMSG_PUT(inst->skb, 0, 0,=20
			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
			sizeof(struct nfgenmsg));
	nfmsg =3D NLMSG_DATA(nlh);
	nfmsg->nfgen_family =3D pf;
	nfmsg->version =3D NFNETLINK_V0;
	nfmsg->res_id =3D htons(inst->group_num);

	pmsg.hw_protocol	=3D htons(skb->protocol);
	pmsg.hook		=3D hooknum;

	NFA_PUT(inst->skb, NFULA_PACKET_HDR, sizeof(pmsg), &pmsg);

	if (prefix) {
		int slen =3D strlen(prefix);
		if (slen > NFULNL_PREFIXLEN)
			slen =3D NFULNL_PREFIXLEN;
		NFA_PUT(inst->skb, NFULA_PREFIX, slen, prefix);
	}

	if (indev) {
		tmp_uint =3D htonl(indev->ifindex);
#ifndef CONFIG_BRIDGE_NETFILTER
		NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV, sizeof(tmp_uint),
			&tmp_uint);
#else
		if (indev->br_port) {
			/* Case 1: indev is physical input device, we need to
			 * look for bridge group (when called from=20
			 * netfilter_bridge) */
			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
				sizeof(tmp_uint), &tmp_uint);
			/* this is the bridge group "brX" */
			tmp_uint =3D htonl(indev->br_port->br->dev->ifindex);
			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
				sizeof(tmp_uint), &tmp_uint);
		} else {
			/* Case 2: indev is bridge group, we need to look for
			 * physical device (when called from ipv4) */
			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
				sizeof(tmp_uint), &tmp_uint);
			if (skb->nf_bridge && skb->nf_bridge->physindev) {
				tmp_uint =3D=20
				    htonl(skb->nf_bridge->physindev->ifindex);
				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
					sizeof(tmp_uint), &tmp_uint);
			}
		}
#endif
	}

	if (outdev) {
		tmp_uint =3D htonl(outdev->ifindex);
#ifndef CONFIG_BRIDGE_NETFILTER
		NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV, sizeof(tmp_uint),
			&tmp_uint);
#else
		if (outdev->br_port) {
			/* Case 1: outdev is physical output device, we need to
			 * look for bridge group (when called from
			 * netfilter_bridge) */
			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
				sizeof(tmp_uint), &tmp_uint);
			/* this is the bridge group "brX" */
			tmp_uint =3D htonl(outdev->br_port->br->dev->ifindex);
			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
				sizeof(tmp_uint), &tmp_uint);
		} else {
			/* Case 2: indev is a bridge group, we need to look
			 * for physical device (when called from ipv4) */
			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
				sizeof(tmp_uint), &tmp_uint);
			if (skb->nf_bridge) {
				tmp_uint =3D=20
				    htonl(skb->nf_bridge->physoutdev->ifindex);
				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
					sizeof(tmp_uint), &tmp_uint);
			}
		}
#endif
	}

	if (skb->nfmark) {
		tmp_uint =3D htonl(skb->nfmark);
		NFA_PUT(inst->skb, NFULA_MARK, sizeof(tmp_uint), &tmp_uint);
	}

	if (indev && skb->dev && skb->dev->hard_header_parse) {
		struct nfulnl_msg_packet_hw phw;

		phw.hw_addrlen =3D=20
			skb->dev->hard_header_parse((struct sk_buff *)skb,=20
						    phw.hw_addr);
		phw.hw_addrlen =3D htons(phw.hw_addrlen);
		NFA_PUT(inst->skb, NFULA_HWADDR, sizeof(phw), &phw);
	}

	if (skb->stamp.tv_sec) {
		struct nfulnl_msg_packet_timestamp ts;

		ts.sec =3D cpu_to_be64(skb->stamp.tv_sec);
		ts.usec =3D cpu_to_be64(skb->stamp.tv_usec);

		NFA_PUT(inst->skb, NFULA_TIMESTAMP, sizeof(ts), &ts);
	}

	/* UID */
	if (skb->sk) {
		read_lock_bh(&skb->sk->sk_callback_lock);
		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
			u_int32_t uid =3D htonl(skb->sk->sk_socket->file->f_uid);
			/* need to unlock here since NFA_PUT may goto */
			read_unlock_bh(&skb->sk->sk_callback_lock);
			NFA_PUT(inst->skb, NFULA_UID, sizeof(uid), &uid);
		} else
			read_unlock_bh(&skb->sk->sk_callback_lock);
	}

	if (data_len) {
		struct nfattr *nfa;
		int size =3D NFA_LENGTH(data_len);

		if (skb_tailroom(inst->skb) < (int)NFA_SPACE(data_len)) {
			printk(KERN_WARNING "nfnetlink_log: no tailroom!\n");
			goto nlmsg_failure;
		}

		nfa =3D (struct nfattr *)skb_put(inst->skb, NFA_ALIGN(size));
		nfa->nfa_type =3D NFULA_PAYLOAD;
		nfa->nfa_len =3D size;

		if (skb_copy_bits(skb, 0, NFA_DATA(nfa), data_len))
			BUG();
	}
	=09
	nlh->nlmsg_len =3D inst->skb->tail - old_tail;
	return 0;

nlmsg_failure:
	UDEBUG("nlmsg_failure\n");
nfattr_failure:
	PRINTR(KERN_ERR "nfnetlink_log: error creating log nlmsg\n");
	return -1;
}

#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } whil=
e (0)

static struct nf_loginfo default_loginfo =3D {
	.type =3D		NF_LOG_TYPE_ULOG,
	.u =3D {
		.ulog =3D {
			.copy_len	=3D 0xffff,
			.group		=3D 0,
			.qthreshold	=3D 1,
		},
	},
};

/* log handler for internal netfilter logging api */
static void
nfulnl_log_packet(unsigned int pf,
		  unsigned int hooknum,
		  const struct sk_buff *skb,
		  const struct net_device *in,
		  const struct net_device *out,
		  const struct nf_loginfo *li_user,
		  const char *prefix)
{
	unsigned int size, data_len;
	struct nfulnl_instance *inst;
	const struct nf_loginfo *li;
	unsigned int qthreshold;
	unsigned int nlbufsiz;

	if (li_user && li_user->type =3D=3D NF_LOG_TYPE_ULOG)=20
		li =3D li_user;
	else
		li =3D &default_loginfo;

	inst =3D instance_lookup_get(li->u.ulog.group);
	if (!inst)
		inst =3D instance_lookup_get(0);
	if (!inst) {
		PRINTR("nfnetlink_log: trying to log packet, "
			"but no instance for group %u\n", li->u.ulog.group);
		return;
	}

	/* all macros expand to constant values at compile time */
	/* FIXME: do we want to make the size calculation conditional based on
	 * what is actually present?  way more branches and checks, but more
	 * memory efficient... */
	size =3D    NLMSG_SPACE(sizeof(struct nfgenmsg))
		+ NFA_SPACE(sizeof(struct nfulnl_msg_packet_hdr))
		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
#ifdef CONFIG_BRIDGE_NETFILTER
		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
#endif
		+ NFA_SPACE(sizeof(u_int32_t))	/* mark */
		+ NFA_SPACE(sizeof(u_int32_t))	/* uid */
		+ NFA_SPACE(NFULNL_PREFIXLEN)	/* prefix */
		+ NFA_SPACE(sizeof(struct nfulnl_msg_packet_hw))
		+ NFA_SPACE(sizeof(struct nfulnl_msg_packet_timestamp));

	UDEBUG("initial size=3D%u\n", size);

	spin_lock_bh(&inst->lock);

	qthreshold =3D inst->qthreshold;
	/* per-rule qthreshold overrides per-instance */
	if (qthreshold > li->u.ulog.qthreshold)
		qthreshold =3D li->u.ulog.qthreshold;
=09
	switch (inst->copy_mode) {
	case NFULNL_COPY_META:
	case NFULNL_COPY_NONE:
		data_len =3D 0;
		break;
=09
	case NFULNL_COPY_PACKET:
		if (inst->copy_range =3D=3D 0=20
		    || inst->copy_range > skb->len)
			data_len =3D skb->len;
		else
			data_len =3D inst->copy_range;
	=09
		size +=3D NFA_SPACE(data_len);
		UDEBUG("copy_packet, therefore size now %u\n", size);
		break;
=09
	default:
		spin_unlock_bh(&inst->lock);
		instance_put(inst);
		return;
	}

	if (size > inst->nlbufsiz)
		nlbufsiz =3D size;
	else
		nlbufsiz =3D inst->nlbufsiz;

	if (!inst->skb) {
		if (!(inst->skb =3D nfulnl_alloc_skb(nlbufsiz, size))) {
			UDEBUG("error in nfulnl_alloc_skb(%u, %u)\n",
				inst->nlbufsiz, size);
			goto alloc_failure;
		}
	} else if (inst->qlen >=3D qthreshold ||
		   size > skb_tailroom(inst->skb)) {
		/* either the queue len is too high or we don't have
		 * enough room in the skb left. flush to userspace. */
		UDEBUG("flushing old skb\n");

		__nfulnl_send(inst);

		if (!(inst->skb =3D nfulnl_alloc_skb(nlbufsiz, size))) {
			UDEBUG("error in nfulnl_alloc_skb(%u, %u)\n",
				inst->nlbufsiz, size);
			goto alloc_failure;
		}
	}

	UDEBUG("qlen %d, qthreshold %d\n", inst->qlen, qthreshold);
	inst->qlen++;

	__build_packet_message(inst, skb, data_len, pf,
				hooknum, in, out, li, prefix);

	/* timer_pending always called within inst->lock, so there
	 * is no chance of a race here */
	if (!timer_pending(&inst->timer)) {
		instance_get(inst);
		inst->timer.expires =3D jiffies + (inst->flushtimeout*HZ/100);
		add_timer(&inst->timer);
	}
	spin_unlock_bh(&inst->lock);

	return;

alloc_failure:
	spin_unlock_bh(&inst->lock);
	instance_put(inst);
	UDEBUG("error allocating skb\n");
	/* FIXME: statistics */
}

static int
nfulnl_rcv_nl_event(struct notifier_block *this,
		   unsigned long event, void *ptr)
{
	struct netlink_notify *n =3D ptr;

	if (event =3D=3D NETLINK_URELEASE &&
	    n->protocol =3D=3D NETLINK_NETFILTER && n->pid) {
		int i;

		/* destroy all instances for this pid */
		write_lock_bh(&instances_lock);
		for  (i =3D 0; i < INSTANCE_BUCKETS; i++) {
			struct hlist_node *tmp, *t2;
			struct nfulnl_instance *inst;
			struct hlist_head *head =3D &instance_table[i];

			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
				UDEBUG("node =3D %p\n", inst);
				if (n->pid =3D=3D inst->peer_pid)
					__instance_destroy(inst);
			}
		}
		write_unlock_bh(&instances_lock);
	}
	return NOTIFY_DONE;
}

static struct notifier_block nfulnl_rtnl_notifier =3D {
	.notifier_call	=3D nfulnl_rcv_nl_event,
};

static int
nfulnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
{
	return -ENOTSUPP;
}

static struct nf_logger nfulnl_logger =3D {
	.name	=3D "nfnetlink_log",
	.logfn	=3D &nfulnl_log_packet,
	.me	=3D THIS_MODULE,
};

static const int nfula_min[NFULA_MAX] =3D {
	[NFULA_PACKET_HDR-1]	=3D sizeof(struct nfulnl_msg_packet_hdr),
	[NFULA_MARK-1]		=3D sizeof(u_int32_t),
	[NFULA_TIMESTAMP-1]	=3D sizeof(struct nfulnl_msg_packet_timestamp),
	[NFULA_IFINDEX_INDEV-1]	=3D sizeof(u_int32_t),
	[NFULA_IFINDEX_OUTDEV-1]=3D sizeof(u_int32_t),
	[NFULA_HWADDR-1]	=3D sizeof(struct nfulnl_msg_packet_hw),
	[NFULA_PAYLOAD-1]	=3D 0,
	[NFULA_PREFIX-1]	=3D 0,
	[NFULA_UID-1]		=3D sizeof(u_int32_t),
};

static const int nfula_cfg_min[NFULA_CFG_MAX] =3D {
	[NFULA_CFG_CMD-1]	=3D sizeof(struct nfulnl_msg_config_cmd),
	[NFULA_CFG_MODE-1]	=3D sizeof(struct nfulnl_msg_config_mode),
	[NFULA_CFG_TIMEOUT-1]	=3D sizeof(u_int32_t),
	[NFULA_CFG_QTHRESH-1]	=3D sizeof(u_int32_t),
	[NFULA_CFG_NLBUFSIZ-1]	=3D sizeof(u_int32_t),
};

static int
nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
		   struct nlmsghdr *nlh, struct nfattr *nfula[], int *errp)
{
	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
	u_int16_t group_num =3D ntohs(nfmsg->res_id);
	struct nfulnl_instance *inst;
	int ret =3D 0;

	UDEBUG("entering for msg %u\n", NFNL_MSG_TYPE(nlh->nlmsg_type));

	if (nfattr_bad_size(nfula, NFULA_CFG_MAX, nfula_cfg_min)) {
		UDEBUG("bad attribute size\n");
		return -EINVAL;
	}

	inst =3D instance_lookup_get(group_num);
	if (nfula[NFULA_CFG_CMD-1]) {
		u_int8_t pf =3D nfmsg->nfgen_family;
		struct nfulnl_msg_config_cmd *cmd;
		cmd =3D NFA_DATA(nfula[NFULA_CFG_CMD-1]);
		UDEBUG("found CFG_CMD for\n");

		switch (cmd->command) {
		case NFULNL_CFG_CMD_BIND:
			if (inst) {
				ret =3D -EBUSY;
				goto out_put;
			}

			inst =3D instance_create(group_num,
					       NETLINK_CB(skb).pid);
			if (!inst) {
				ret =3D -EINVAL;
				goto out_put;
			}
			break;
		case NFULNL_CFG_CMD_UNBIND:
			if (!inst) {
				ret =3D -ENODEV;
				goto out_put;
			}

			if (inst->peer_pid !=3D NETLINK_CB(skb).pid) {
				ret =3D -EPERM;
				goto out_put;
			}

			instance_destroy(inst);
			break;
		case NFULNL_CFG_CMD_PF_BIND:
			UDEBUG("registering log handler for pf=3D%u\n", pf);
			ret =3D nf_log_register(pf, &nfulnl_logger);
			break;
		case NFULNL_CFG_CMD_PF_UNBIND:
			UDEBUG("unregistering log handler for pf=3D%u\n", pf);
			/* This is a bug and a feature.  We cannot unregister
			 * other handlers, like nfnetlink_inst can */
			nf_log_unregister_pf(pf);
			break;
		default:
			ret =3D -EINVAL;
			break;
		}
	} else {
		if (!inst) {
			UDEBUG("no config command, and no instance for "
				"group=3D%u pid=3D%u =3D>ENOENT\n",
				group_num, NETLINK_CB(skb).pid);
			ret =3D -ENOENT;
			goto out_put;
		}

		if (inst->peer_pid !=3D NETLINK_CB(skb).pid) {
			UDEBUG("no config command, and wrong pid\n");
			ret =3D -EPERM;
			goto out_put;
		}
	}

	if (nfula[NFULA_CFG_MODE-1]) {
		struct nfulnl_msg_config_mode *params;
		params =3D NFA_DATA(nfula[NFULA_CFG_MODE-1]);

		nfulnl_set_mode(inst, params->copy_mode,
				ntohs(params->copy_range));
	}

	if (nfula[NFULA_CFG_TIMEOUT-1]) {
		u_int32_t timeout =3D=20
			*(u_int32_t *)NFA_DATA(nfula[NFULA_CFG_TIMEOUT-1]);

		nfulnl_set_timeout(inst, ntohl(timeout));
	}

	if (nfula[NFULA_CFG_NLBUFSIZ-1]) {
		u_int32_t nlbufsiz =3D=20
			*(u_int32_t *)NFA_DATA(nfula[NFULA_CFG_NLBUFSIZ-1]);

		nfulnl_set_nlbufsiz(inst, ntohl(nlbufsiz));
	}

	if (nfula[NFULA_CFG_QTHRESH-1]) {
		u_int32_t qthresh =3D=20
			*(u_int16_t *)NFA_DATA(nfula[NFULA_CFG_QTHRESH-1]);

		nfulnl_set_qthresh(inst, ntohl(qthresh));
	}

out_put:
	instance_put(inst);
	return ret;
}

static struct nfnl_callback nfulnl_cb[NFULNL_MSG_MAX] =3D {
	[NFULNL_MSG_PACKET]	=3D { .call =3D nfulnl_recv_unsupp,
				    .attr_count =3D NFULA_MAX,
				    .cap_required =3D CAP_NET_ADMIN, },
	[NFULNL_MSG_CONFIG]	=3D { .call =3D nfulnl_recv_config,
				    .attr_count =3D NFULA_CFG_MAX,
				    .cap_required =3D CAP_NET_ADMIN },
};

static struct nfnetlink_subsystem nfulnl_subsys =3D {
	.name		=3D "log",
	.subsys_id	=3D NFNL_SUBSYS_ULOG,
	.cb_count	=3D NFULNL_MSG_MAX,
	.cb		=3D nfulnl_cb,
};

#ifdef CONFIG_PROC_FS
struct iter_state {
	unsigned int bucket;
};

static struct hlist_node *get_first(struct seq_file *seq)
{
	struct iter_state *st =3D seq->private;

	if (!st)
		return NULL;

	for (st->bucket =3D 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
		if (!hlist_empty(&instance_table[st->bucket]))
			return instance_table[st->bucket].first;
	}
	return NULL;
}

static struct hlist_node *get_next(struct seq_file *seq, struct hlist_node =
*h)
{
	struct iter_state *st =3D seq->private;

	h =3D h->next;
	while (!h) {
		if (++st->bucket >=3D INSTANCE_BUCKETS)
			return NULL;

		h =3D instance_table[st->bucket].first;
	}
	return h;
}

static struct hlist_node *get_idx(struct seq_file *seq, loff_t pos)
{
	struct hlist_node *head;
	head =3D get_first(seq);

	if (head)
		while (pos && (head =3D get_next(seq, head)))
			pos--;
	return pos ? NULL : head;
}

static void *seq_start(struct seq_file *seq, loff_t *pos)
{
	read_lock_bh(&instances_lock);
	return get_idx(seq, *pos);
}

static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
{
	(*pos)++;
	return get_next(s, v);
}

static void seq_stop(struct seq_file *s, void *v)
{
	read_unlock_bh(&instances_lock);
}

static int seq_show(struct seq_file *s, void *v)
{
	const struct nfulnl_instance *inst =3D v;

	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",=20
			  inst->group_num,
			  inst->peer_pid, inst->qlen,=20
			  inst->copy_mode, inst->copy_range,
			  inst->flushtimeout, atomic_read(&inst->use));
}

static struct seq_operations nful_seq_ops =3D {
	.start	=3D seq_start,
	.next	=3D seq_next,
	.stop	=3D seq_stop,
	.show	=3D seq_show,
};

static int nful_open(struct inode *inode, struct file *file)
{
	struct seq_file *seq;
	struct iter_state *is;
	int ret;

	is =3D kmalloc(sizeof(*is), GFP_KERNEL);
	if (!is)
		return -ENOMEM;
	memset(is, 0, sizeof(*is));
	ret =3D seq_open(file, &nful_seq_ops);
	if (ret < 0)
		goto out_free;
	seq =3D file->private_data;
	seq->private =3D is;
	return ret;
out_free:
	kfree(is);
	return ret;
}

static struct file_operations nful_file_ops =3D {
	.owner	 =3D THIS_MODULE,
	.open	 =3D nful_open,
	.read	 =3D seq_read,
	.llseek	 =3D seq_lseek,
	.release =3D seq_release_private,
};

#endif /* PROC_FS */

static int
init_or_cleanup(int init)
{
	int i, status =3D -ENOMEM;
#ifdef CONFIG_PROC_FS
	struct proc_dir_entry *proc_nful;
#endif
=09
	if (!init)
		goto cleanup;

	for (i =3D 0; i < INSTANCE_BUCKETS; i++)
		INIT_HLIST_HEAD(&instance_table[i]);
=09
	/* it's not really all that important to have a random value, so
	 * we can do this from the init function, even if there hasn't
	 * been that much entropy yet */
	get_random_bytes(&hash_init, sizeof(hash_init));

	netlink_register_notifier(&nfulnl_rtnl_notifier);
	status =3D nfnetlink_subsys_register(&nfulnl_subsys);
	if (status < 0) {
		printk(KERN_ERR "log: failed to create netlink socket\n");
		goto cleanup_netlink_notifier;
	}

#ifdef CONFIG_PROC_FS
	proc_nful =3D create_proc_entry("nfnetlink_log", 0440,
				      proc_net_netfilter);
	if (!proc_nful)
		goto cleanup_subsys;
	proc_nful->proc_fops =3D &nful_file_ops;
#endif

	return status;

cleanup:
	nf_log_unregister_logger(&nfulnl_logger);
#ifdef CONFIG_PROC_FS
	remove_proc_entry("nfnetlink_log", proc_net_netfilter);
cleanup_subsys:
#endif
	nfnetlink_subsys_unregister(&nfulnl_subsys);
cleanup_netlink_notifier:
	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
	return status;
}

static int __init init(void)
{
=09
	return init_or_cleanup(1);
}

static void __exit fini(void)
{
	init_or_cleanup(0);
}

MODULE_DESCRIPTION("netfilter userspace logging");
MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
MODULE_LICENSE("GPL");
MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_ULOG);

module_init(init);
module_exit(fini);

--wzJLGUyc3ArbnUjN--

--Izn7cH1Com+I3R9J
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9xS/XaXGVTD0i/8RAopZAJ9HO29PszNcCA2SIaLkRxdx5EdDAACfemge
pkHkkjiH+gPV5jam2mD/qSs=
=ZEDX
-----END PGP SIGNATURE-----

--Izn7cH1Com+I3R9J--
