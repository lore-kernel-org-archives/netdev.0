From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 32/39]: mac80211: Reimplement WME using
	->select_queue().
Date: Thu, 03 Jul 2008 11:14:08 +0200
Message-ID: <1215076448.13270.30.camel@johannes.berg>
References: <20080703.000521.13130101.davem@davemloft.net>
	 (sfid-20080703_103230_813110_7C480890)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BB/tj6Po59uI8fV7vnDM"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunksi <ron.rindjunski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080703.000521.13130101.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20080703_103230_813110_7C480890)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-BB/tj6Po59uI8fV7vnDM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-07-03 at 00:05 -0700, David Miller wrote:
> Unfortunately it temporarily loses some features, such
> as packet dropping (easy to add) and requeueing (harder).
>=20
> But it is so much incredibly simpler now.

Way cool. I don't think we actually need requeue, afaik that's just
because of hardware trying to reject packets (which we're removing and
handling independently) and because of TX-aggregation queues which won't
matter because we use select_queue now.

Ron, can you take a look at that? I think it should be fine as-is. Best
also check out the git tree
(git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-tx-2.6.git) and
look at the resulting code.

I'll also get rid of the dependency on NET_SCHED and fix up the code a
bit.

> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  net/mac80211/ieee80211_i.h |    6 +
>  net/mac80211/main.c        |   16 +--
>  net/mac80211/wme.c         |  531 ++------------------------------------=
------
>  net/mac80211/wme.h         |   19 +--
>  4 files changed, 34 insertions(+), 538 deletions(-)
>=20
> diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
> index af352c0..0ecc0c0 100644
> --- a/net/mac80211/ieee80211_i.h
> +++ b/net/mac80211/ieee80211_i.h
> @@ -25,6 +25,7 @@
>  #include <linux/etherdevice.h>
>  #include <net/wireless.h>
>  #include <net/iw_handler.h>
> +#include <net/mac80211.h>
>  #include "key.h"
>  #include "sta_info.h"
> =20
> @@ -542,6 +543,9 @@ enum {
>  	IEEE80211_ADDBA_MSG	=3D 4,
>  };
> =20
> +/* maximum number of hardware queues we support. */
> +#define QD_MAX_QUEUES (IEEE80211_MAX_AMPDU_QUEUES + IEEE80211_MAX_QUEUES=
)
> +
>  struct ieee80211_local {
>  	/* embed the driver visible part.
>  	 * don't cast (use the static inlines below), but we keep
> @@ -550,6 +554,8 @@ struct ieee80211_local {
> =20
>  	const struct ieee80211_ops *ops;
> =20
> +	unsigned long queue_pool[BITS_TO_LONGS(QD_MAX_QUEUES)];
> +
>  	struct net_device *mdev; /* wmaster# - "master" 802.11 device */
>  	int open_count;
>  	int monitors, cooked_mntrs;
> diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> index c4d36fe..b78b56e 100644
> --- a/net/mac80211/main.c
> +++ b/net/mac80211/main.c
> @@ -684,7 +684,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw=
 *hw, u8 *ra, u16 tid)
>  		/* No need to requeue the packets in the agg queue, since we
>  		 * held the tx lock: no packet could be enqueued to the newly
>  		 * allocated queue */
> -		 ieee80211_ht_agg_queue_remove(local, sta, tid, 0);
> +		 ieee80211_ht_agg_queue_remove(local, sta, tid);
>  #ifdef CONFIG_MAC80211_HT_DEBUG
>  		printk(KERN_DEBUG "BA request denied - HW unavailable for"
>  					" tid %d\n", tid);
> @@ -693,8 +693,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw=
 *hw, u8 *ra, u16 tid)
>  		goto err_unlock_queue;
>  	}
> =20
> -	/* Will put all the packets in the new SW queue */
> -	ieee80211_requeue(local, ieee802_1d_to_ac[tid]);
>  	unlock_all_queues_bh(local->mdev);
>  	spin_unlock_bh(&sta->lock);
> =20
> @@ -883,7 +881,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw,=
 u8 *ra, u8 tid)
>  	dev_queue =3D netdev_get_tx_queue(local->mdev, 0);
>  	spin_lock_bh(&dev_queue->lock);
>  	/* remove the queue for this aggregation */
> -	ieee80211_ht_agg_queue_remove(local, sta, tid, 1);
> +	ieee80211_ht_agg_queue_remove(local, sta, tid);
>  	spin_unlock_bh(&dev_queue->lock);
> =20
>  	/* we just requeued the all the frames that were in the removed
> @@ -1900,19 +1898,10 @@ static int __init ieee80211_init(void)
>  	if (ret)
>  		goto out;
> =20
> -	ret =3D ieee80211_wme_register();
> -	if (ret) {
> -		printk(KERN_DEBUG "ieee80211_init: failed to "
> -		       "initialize WME (err=3D%d)\n", ret);
> -		goto out_cleanup_pid;
> -	}
> -
>  	ieee80211_debugfs_netdev_init();
> =20
>  	return 0;
> =20
> - out_cleanup_pid:
> -	rc80211_pid_exit();
>   out:
>  	return ret;
>  }
> @@ -1930,7 +1919,6 @@ static void __exit ieee80211_exit(void)
>  	if (mesh_allocated)
>  		ieee80211s_stop();
> =20
> -	ieee80211_wme_unregister();
>  	ieee80211_debugfs_netdev_exit();
>  }
> =20
> diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
> index 42b1fbf..3bbee5a 100644
> --- a/net/mac80211/wme.c
> +++ b/net/mac80211/wme.c
> @@ -18,8 +18,6 @@
>  #include "ieee80211_i.h"
>  #include "wme.h"
> =20
> -/* maximum number of hardware queues we support. */
> -#define QD_MAX_QUEUES (IEEE80211_MAX_AMPDU_QUEUES + IEEE80211_MAX_QUEUES=
)
>  /* current number of hardware queues we support. */
>  #define QD_NUM(hw) ((hw)->queues + (hw)->ampdu_queues)
> =20
> @@ -29,32 +27,14 @@
>   */
>  const int ieee802_1d_to_ac[8] =3D { 2, 3, 3, 2, 1, 1, 0, 0 };
> =20
> -struct ieee80211_sched_data
> -{
> -	unsigned long qdisc_pool[BITS_TO_LONGS(QD_MAX_QUEUES)];
> -	struct tcf_proto *filter_list;
> -	struct Qdisc *queues[QD_MAX_QUEUES];
> -	struct sk_buff_head requeued[QD_MAX_QUEUES];
> -};
> -
>  static const char llc_ip_hdr[8] =3D {0xAA, 0xAA, 0x3, 0, 0, 0, 0x08, 0};
> =20
>  /* given a data frame determine the 802.1p/1d tag to use */
> -static inline unsigned classify_1d(struct sk_buff *skb, struct Qdisc *qd=
)
> +static inline unsigned classify_1d(struct sk_buff *skb, struct net_devic=
e *dev)
>  {
>  	struct iphdr *ip;
> -	int dscp;
>  	int offset;
> -
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct tcf_result res =3D { -1, 0 };
> -
> -	/* if there is a user set filter list, call out to that */
> -	if (q->filter_list) {
> -		tc_classify(skb, q->filter_list, &res);
> -		if (res.class !=3D -1)
> -			return res.class;
> -	}
> +	int dscp;
> =20
>  	/* skb->priority values from 256->263 are magic values to
>  	 * directly indicate a specific 802.1d priority.
> @@ -99,11 +79,10 @@ static inline int wme_downgrade_ac(struct sk_buff *sk=
b)
>  }
> =20
>=20
> -/* positive return value indicates which queue to use
> - * negative return value indicates to drop the frame */
> -static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
> +/* positive return value indicates which queue to use */
> +static u16 classify80211(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> +	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
>  	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
> =20
>  	if (!ieee80211_is_data(hdr->frame_control)) {
> @@ -123,14 +102,12 @@ static int classify80211(struct sk_buff *skb, struc=
t Qdisc *qd)
> =20
>  	/* use the data classifier to determine what 802.1d tag the
>  	 * data frame has */
> -	skb->priority =3D classify_1d(skb, qd);
> +	skb->priority =3D classify_1d(skb, dev);
> =20
>  	/* in case we are a client verify acm is not set for this ac */
>  	while (unlikely(local->wmm_acm & BIT(skb->priority))) {
> -		if (wme_downgrade_ac(skb)) {
> -			/* No AC with lower priority has acm=3D0, drop packet. */
> -			return -1;
> -		}
> +		if (wme_downgrade_ac(skb))
> +			return 0;
>  	}
> =20
>  	/* look up which queue to use for frames with this 1d tag */
> @@ -138,40 +115,17 @@ static int classify80211(struct sk_buff *skb, struc=
t Qdisc *qd)
>  }
> =20
>=20
> -static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
> +static u16 ieee80211_select_queue(struct net_device *dev,
> +				  struct sk_buff *skb)
>  {
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
>  	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
> -	struct Qdisc *qdisc;
> +	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
> +	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
>  	struct sta_info *sta;
> -	int err, queue;
> +	u16 queue;
>  	u8 tid;
> =20
> -	if (info->flags & IEEE80211_TX_CTL_REQUEUE) {
> -		queue =3D skb_get_queue_mapping(skb);
> -		rcu_read_lock();
> -		sta =3D sta_info_get(local, hdr->addr1);
> -		tid =3D skb->priority & QOS_CONTROL_TAG1D_MASK;
> -		if (sta) {
> -			int ampdu_queue =3D sta->tid_to_tx_q[tid];
> -			if ((ampdu_queue < QD_NUM(hw)) &&
> -			    test_bit(ampdu_queue, q->qdisc_pool)) {
> -				queue =3D ampdu_queue;
> -				info->flags |=3D IEEE80211_TX_CTL_AMPDU;
> -			} else {
> -				info->flags &=3D ~IEEE80211_TX_CTL_AMPDU;
> -			}
> -		}
> -		rcu_read_unlock();
> -		skb_queue_tail(&q->requeued[queue], skb);
> -		qd->q.qlen++;
> -		return 0;
> -	}
> -
> -	queue =3D classify80211(skb, qd);
> +	queue =3D classify80211(skb, dev);
> =20
>  	if (unlikely(queue >=3D local->hw.queues))
>  		queue =3D local->hw.queues - 1;
> @@ -193,436 +147,32 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb=
, struct Qdisc* qd)
> =20
>  		sta =3D sta_info_get(local, hdr->addr1);
>  		if (sta) {
> -			int ampdu_queue =3D sta->tid_to_tx_q[tid];
> -			if ((ampdu_queue < QD_NUM(hw)) &&
> -			    test_bit(ampdu_queue, q->qdisc_pool)) {
> -				queue =3D ampdu_queue;
> -				info->flags |=3D IEEE80211_TX_CTL_AMPDU;
> -			} else {
> -				info->flags &=3D ~IEEE80211_TX_CTL_AMPDU;
> -			}
> +			queue =3D sta->tid_to_tx_q[tid];
> +			info->flags |=3D IEEE80211_TX_CTL_AMPDU;
>  		}
> =20
>  		rcu_read_unlock();
>  	}
> =20
> -	if (unlikely(queue < 0)) {
> -			kfree_skb(skb);
> -			err =3D NET_XMIT_DROP;
> -	} else {
> -		tid =3D skb->priority & QOS_CONTROL_TAG1D_MASK;
> -		skb_set_queue_mapping(skb, queue);
> -		qdisc =3D q->queues[queue];
> -		err =3D qdisc->enqueue(skb, qdisc);
> -		if (err =3D=3D NET_XMIT_SUCCESS) {
> -			qd->q.qlen++;
> -			qd->bstats.bytes +=3D skb->len;
> -			qd->bstats.packets++;
> -			return NET_XMIT_SUCCESS;
> -		}
> -	}
> -	qd->qstats.drops++;
> -	return err;
> -}
> -
> -
> -/* TODO: clean up the cases where master_hard_start_xmit
> - * returns non 0 - it shouldn't ever do that. Once done we
> - * can remove this function */
> -static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct Qdisc *qdisc;
> -	int err;
> -
> -	/* we recorded which queue to use earlier! */
> -	qdisc =3D q->queues[skb_get_queue_mapping(skb)];
> -
> -	if ((err =3D qdisc->ops->requeue(skb, qdisc)) =3D=3D 0) {
> -		qd->q.qlen++;
> -		return 0;
> -	}
> -	qd->qstats.drops++;
> -	return err;
> -}
> -
> -
> -static struct sk_buff *wme_qdiscop_dequeue(struct Qdisc* qd)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct net_device *dev =3D qdisc_dev(qd);
> -	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	struct sk_buff *skb;
> -	struct Qdisc *qdisc;
> -	int queue;
> -
> -	/* check all the h/w queues in numeric/priority order */
> -	for (queue =3D 0; queue < QD_NUM(hw); queue++) {
> -		/* see if there is room in this hardware queue */
> -		if (__netif_subqueue_stopped(local->mdev, queue) ||
> -		    !test_bit(queue, q->qdisc_pool))
> -			continue;
> -
> -		/* there is space - try and get a frame */
> -		skb =3D skb_dequeue(&q->requeued[queue]);
> -		if (skb) {
> -			qd->q.qlen--;
> -			return skb;
> -		}
> -
> -		qdisc =3D q->queues[queue];
> -		skb =3D qdisc->dequeue(qdisc);
> -		if (skb) {
> -			qd->q.qlen--;
> -			return skb;
> -		}
> -	}
> -	/* returning a NULL here when all the h/w queues are full means we
> -	 * never need to call netif_stop_queue in the driver */
> -	return NULL;
> -}
> -
> -
> -static void wme_qdiscop_reset(struct Qdisc* qd)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	int queue;
> -
> -	/* QUESTION: should we have some hardware flush functionality here? */
> -
> -	for (queue =3D 0; queue < QD_NUM(hw); queue++) {
> -		skb_queue_purge(&q->requeued[queue]);
> -		qdisc_reset(q->queues[queue]);
> -	}
> -	qd->q.qlen =3D 0;
> -}
> -
> -
> -static void wme_qdiscop_destroy(struct Qdisc* qd)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	int queue;
> -
> -	tcf_destroy_chain(q->filter_list);
> -	q->filter_list =3D NULL;
> -
> -	for (queue =3D 0; queue < QD_NUM(hw); queue++) {
> -		skb_queue_purge(&q->requeued[queue]);
> -		qdisc_destroy(q->queues[queue]);
> -		q->queues[queue] =3D &noop_qdisc;
> -	}
> -}
> -
> -
> -/* called whenever parameters are updated on existing qdisc */
> -static int wme_qdiscop_tune(struct Qdisc *qd, struct nlattr *opt)
> -{
> -	return 0;
> -}
> -
> -
> -/* called during initial creation of qdisc on device */
> -static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct net_device *dev =3D qdisc_dev(qd);
> -	struct ieee80211_local *local;
> -	struct ieee80211_hw *hw;
> -	int err =3D 0, i;
> -
> -	/* check that device is a mac80211 device */
> -	if (!dev->ieee80211_ptr ||
> -	    dev->ieee80211_ptr->wiphy->privid !=3D mac80211_wiphy_privid)
> -		return -EINVAL;
> -
> -	local =3D wdev_priv(dev->ieee80211_ptr);
> -	hw =3D &local->hw;
> -
> -	/* only allow on master dev */
> -	if (dev !=3D local->mdev)
> -		return -EINVAL;
> -
> -	/* ensure that we are root qdisc */
> -	if (qd->parent !=3D TC_H_ROOT)
> -		return -EINVAL;
> -
> -	if (qd->flags & TCQ_F_INGRESS)
> -		return -EINVAL;
> -
> -	/* if options were passed in, set them */
> -	if (opt)
> -		err =3D wme_qdiscop_tune(qd, opt);
> -
> -	/* create child queues */
> -	for (i =3D 0; i < QD_NUM(hw); i++) {
> -		skb_queue_head_init(&q->requeued[i]);
> -		q->queues[i] =3D qdisc_create_dflt(qdisc_dev(qd), qd->dev_queue,
> -						 &pfifo_qdisc_ops,
> -						 qd->handle);
> -		if (!q->queues[i]) {
> -			q->queues[i] =3D &noop_qdisc;
> -			printk(KERN_ERR "%s child qdisc %i creation failed\n",
> -			       dev->name, i);
> -		}
> -	}
> -
> -	/* non-aggregation queues: reserve/mark as used */
> -	for (i =3D 0; i < local->hw.queues; i++)
> -		set_bit(i, q->qdisc_pool);
> -
> -	return err;
> -}
> -
> -static int wme_qdiscop_dump(struct Qdisc *qd, struct sk_buff *skb)
> -{
> -	return -1;
> -}
> -
> -
> -static int wme_classop_graft(struct Qdisc *qd, unsigned long arg,
> -			     struct Qdisc *new, struct Qdisc **old)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	unsigned long queue =3D arg - 1;
> -
> -	if (queue >=3D QD_NUM(hw))
> -		return -EINVAL;
> -
> -	if (!new)
> -		new =3D &noop_qdisc;
> -
> -	sch_tree_lock(qd);
> -	*old =3D q->queues[queue];
> -	q->queues[queue] =3D new;
> -	qdisc_reset(*old);
> -	sch_tree_unlock(qd);
> -
> -	return 0;
> -}
> -
> -
> -static struct Qdisc *
> -wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	unsigned long queue =3D arg - 1;
> -
> -	if (queue >=3D QD_NUM(hw))
> -		return NULL;
> -
> -	return q->queues[queue];
> -}
> -
> -
> -static unsigned long wme_classop_get(struct Qdisc *qd, u32 classid)
> -{
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	unsigned long queue =3D TC_H_MIN(classid);
> -
> -	if (queue - 1 >=3D QD_NUM(hw))
> -		return 0;
> -
>  	return queue;
>  }
> =20
> -
> -static unsigned long wme_classop_bind(struct Qdisc *qd, unsigned long pa=
rent,
> -				      u32 classid)
> -{
> -	return wme_classop_get(qd, classid);
> -}
> -
> -
> -static void wme_classop_put(struct Qdisc *q, unsigned long cl)
> -{
> -}
> -
> -
> -static int wme_classop_change(struct Qdisc *qd, u32 handle, u32 parent,
> -			      struct nlattr **tca, unsigned long *arg)
> -{
> -	unsigned long cl =3D *arg;
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -
> -	if (cl - 1 > QD_NUM(hw))
> -		return -ENOENT;
> -
> -	/* TODO: put code to program hardware queue parameters here,
> -	 * to allow programming from tc command line */
> -
> -	return 0;
> -}
> -
> -
> -/* we don't support deleting hardware queues
> - * when we add WMM-SA support - TSPECs may be deleted here */
> -static int wme_classop_delete(struct Qdisc *qd, unsigned long cl)
> -{
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -
> -	if (cl - 1 > QD_NUM(hw))
> -		return -ENOENT;
> -	return 0;
> -}
> -
> -
> -static int wme_classop_dump_class(struct Qdisc *qd, unsigned long cl,
> -				  struct sk_buff *skb, struct tcmsg *tcm)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -
> -	if (cl - 1 > QD_NUM(hw))
> -		return -ENOENT;
> -	tcm->tcm_handle =3D TC_H_MIN(cl);
> -	tcm->tcm_parent =3D qd->handle;
> -	tcm->tcm_info =3D q->queues[cl-1]->handle; /* do we need this? */
> -	return 0;
> -}
> -
> -
> -static void wme_classop_walk(struct Qdisc *qd, struct qdisc_walker *arg)
> -{
> -	struct ieee80211_local *local =3D wdev_priv(qdisc_dev(qd)->ieee80211_pt=
r);
> -	struct ieee80211_hw *hw =3D &local->hw;
> -	int queue;
> -
> -	if (arg->stop)
> -		return;
> -
> -	for (queue =3D 0; queue < QD_NUM(hw); queue++) {
> -		if (arg->count < arg->skip) {
> -			arg->count++;
> -			continue;
> -		}
> -		/* we should return classids for our internal queues here
> -		 * as well as the external ones */
> -		if (arg->fn(qd, queue+1, arg) < 0) {
> -			arg->stop =3D 1;
> -			break;
> -		}
> -		arg->count++;
> -	}
> -}
> -
> -
> -static struct tcf_proto ** wme_classop_find_tcf(struct Qdisc *qd,
> -						unsigned long cl)
> -{
> -	struct ieee80211_sched_data *q =3D qdisc_priv(qd);
> -
> -	if (cl)
> -		return NULL;
> -
> -	return &q->filter_list;
> -}
> -
> -
> -/* this qdisc is classful (i.e. has classes, some of which may have leaf=
 qdiscs attached)
> - * - these are the operations on the classes */
> -static const struct Qdisc_class_ops class_ops =3D
> -{
> -	.graft =3D wme_classop_graft,
> -	.leaf =3D wme_classop_leaf,
> -
> -	.get =3D wme_classop_get,
> -	.put =3D wme_classop_put,
> -	.change =3D wme_classop_change,
> -	.delete =3D wme_classop_delete,
> -	.walk =3D wme_classop_walk,
> -
> -	.tcf_chain =3D wme_classop_find_tcf,
> -	.bind_tcf =3D wme_classop_bind,
> -	.unbind_tcf =3D wme_classop_put,
> -
> -	.dump =3D wme_classop_dump_class,
> -};
> -
> -
> -/* queueing discipline operations */
> -static struct Qdisc_ops wme_qdisc_ops __read_mostly =3D
> -{
> -	.next =3D NULL,
> -	.cl_ops =3D &class_ops,
> -	.id =3D "ieee80211",
> -	.priv_size =3D sizeof(struct ieee80211_sched_data),
> -
> -	.enqueue =3D wme_qdiscop_enqueue,
> -	.dequeue =3D wme_qdiscop_dequeue,
> -	.requeue =3D wme_qdiscop_requeue,
> -	.drop =3D NULL, /* drop not needed since we are always the root qdisc *=
/
> -
> -	.init =3D wme_qdiscop_init,
> -	.reset =3D wme_qdiscop_reset,
> -	.destroy =3D wme_qdiscop_destroy,
> -	.change =3D wme_qdiscop_tune,
> -
> -	.dump =3D wme_qdiscop_dump,
> -};
> -
> -
>  void ieee80211_install_qdisc(struct net_device *dev)
>  {
> -	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
> -	struct Qdisc *qdisc;
> -
> -	qdisc =3D qdisc_create_dflt(dev, txq,
> -				  &wme_qdisc_ops, TC_H_ROOT);
> -	if (!qdisc) {
> -		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
> -		return;
> -	}
> -
> -	/* same handle as would be allocated by qdisc_alloc_handle() */
> -	qdisc->handle =3D 0x80010000;
> -
> -	qdisc_lock_tree(dev);
> -	list_add_tail(&qdisc->list, &txq->qdisc_list);
> -	txq->qdisc_sleeping =3D qdisc;
> -	qdisc_unlock_tree(dev);
> +	dev->select_queue =3D ieee80211_select_queue;
>  }
> =20
>=20
>  int ieee80211_qdisc_installed(struct net_device *dev)
>  {
> -	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
> -
> -	return txq->qdisc_sleeping->ops =3D=3D &wme_qdisc_ops;
> -}
> -
> -
> -int ieee80211_wme_register(void)
> -{
> -	return register_qdisc(&wme_qdisc_ops);
> -}
> -
> -
> -void ieee80211_wme_unregister(void)
> -{
> -	unregister_qdisc(&wme_qdisc_ops);
> +	return dev->select_queue =3D=3D ieee80211_select_queue;
>  }
> =20
>  int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
>  			struct sta_info *sta, u16 tid)
>  {
> -	int i;
> -	struct netdev_queue *txq =3D netdev_get_tx_queue(local->mdev, 0);
> -	struct ieee80211_sched_data *q =3D
> -			qdisc_priv(txq->qdisc_sleeping);
>  	DECLARE_MAC_BUF(mac);
> +	int i;
> =20
>  	/* prepare the filter and save it for the SW queue
>  	 * matching the received HW queue */
> @@ -632,7 +182,7 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local=
 *local,
> =20
>  	/* try to get a Qdisc from the pool */
>  	for (i =3D local->hw.queues; i < QD_NUM(&local->hw); i++)
> -		if (!test_and_set_bit(i, q->qdisc_pool)) {
> +		if (!test_and_set_bit(i, local->queue_pool)) {
>  			ieee80211_stop_queue(local_to_hw(local), i);
>  			sta->tid_to_tx_q[tid] =3D i;
> =20
> @@ -643,9 +193,8 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local=
 *local,
>  #ifdef CONFIG_MAC80211_HT_DEBUG
>  			if (net_ratelimit())
>  				printk(KERN_DEBUG "allocated aggregation queue"
> -					" %d tid %d addr %s pool=3D0x%lX\n",
> -					i, tid, print_mac(mac, sta->addr),
> -					q->qdisc_pool[0]);
> +				       " %d tid %d addr %s\n",
> +				       i, tid, print_mac(mac, sta->addr));
>  #endif /* CONFIG_MAC80211_HT_DEBUG */
>  			return 0;
>  		}
> @@ -657,44 +206,12 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_loc=
al *local,
>   * the caller needs to hold netdev_get_tx_queue(local->mdev, X)->lock
>   */
>  void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
> -				   struct sta_info *sta, u16 tid,
> -				   u8 requeue)
> +				   struct sta_info *sta, u16 tid)
>  {
>  	struct ieee80211_hw *hw =3D &local->hw;
> -	struct netdev_queue *txq =3D netdev_get_tx_queue(local->mdev, 0);
> -	struct ieee80211_sched_data *q =3D
> -		qdisc_priv(txq->qdisc_sleeping);
>  	int agg_queue =3D sta->tid_to_tx_q[tid];
> =20
>  	/* return the qdisc to the pool */
> -	clear_bit(agg_queue, q->qdisc_pool);
> +	clear_bit(agg_queue, local->queue_pool);
>  	sta->tid_to_tx_q[tid] =3D QD_NUM(hw);
> -
> -	if (requeue)
> -		ieee80211_requeue(local, agg_queue);
> -	else
> -		q->queues[agg_queue]->ops->reset(q->queues[agg_queue]);
> -}
> -
> -void ieee80211_requeue(struct ieee80211_local *local, int queue)
> -{
> -	struct netdev_queue *txq =3D netdev_get_tx_queue(local->mdev, 0);
> -	struct Qdisc *root_qd =3D txq->qdisc_sleeping;
> -	struct ieee80211_sched_data *q =3D qdisc_priv(root_qd);
> -	struct Qdisc *qdisc =3D q->queues[queue];
> -	struct sk_buff *skb =3D NULL;
> -	u32 len;
> -
> -	if (!qdisc || !qdisc->dequeue)
> -		return;
> -
> -	printk(KERN_DEBUG "requeue: qlen =3D %d\n", qdisc->q.qlen);
> -	for (len =3D qdisc->q.qlen; len > 0; len--) {
> -		skb =3D qdisc->dequeue(qdisc);
> -		root_qd->q.qlen--;
> -		/* packet will be classified again and */
> -		/* skb->packet_data->queue will be overridden if needed */
> -		if (skb)
> -			wme_qdiscop_enqueue(skb, root_qd);
> -	}
>  }
> diff --git a/net/mac80211/wme.h b/net/mac80211/wme.h
> index bbdb533..c79be0e 100644
> --- a/net/mac80211/wme.h
> +++ b/net/mac80211/wme.h
> @@ -37,11 +37,7 @@ int ieee80211_qdisc_installed(struct net_device *dev);
>  int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
>  			       struct sta_info *sta, u16 tid);
>  void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
> -				   struct sta_info *sta, u16 tid,
> -				   u8 requeue);
> -void ieee80211_requeue(struct ieee80211_local *local, int queue);
> -int ieee80211_wme_register(void);
> -void ieee80211_wme_unregister(void);
> +				   struct sta_info *sta, u16 tid);
>  #else
>  static inline void ieee80211_install_qdisc(struct net_device *dev)
>  {
> @@ -56,18 +52,7 @@ static inline int ieee80211_ht_agg_queue_add(struct ie=
ee80211_local *local,
>  	return -EAGAIN;
>  }
>  static inline void ieee80211_ht_agg_queue_remove(struct ieee80211_local =
*local,
> -						 struct sta_info *sta, u16 tid,
> -						 u8 requeue)
> -{
> -}
> -static inline void ieee80211_requeue(struct ieee80211_local *local, int =
queue)
> -{
> -}
> -static inline int ieee80211_wme_register(void)
> -{
> -	return 0;
> -}
> -static inline void ieee80211_wme_unregister(void)
> +						 struct sta_info *sta, u16 tid)
>  {
>  }
>  #endif /* CONFIG_NET_SCHED */

--=-BB/tj6Po59uI8fV7vnDM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIbJhdAAoJEKVg1VMiehFY8FQP/02Qz5zYo1ryKstrfwl655D0
aRMljyq3u2bVjFPy2wNR29erqsZjHsMyqwSCjt89rVCQJMBy2sYA7lN5IwSknDpx
0oD6nKC4UxZtq+/YjXZ0ZA6Bqaz1G+FrVZO/1ZZx+hjE9UQ+CeP129CcILVphqyT
FIc1BtNzM5IBgqAjWdPVjln37LzVKavisVLk37gdHk82krJvYjnuX+3pmHr9yRUE
T90rV+j3Y4sakXXz+rDjFqpwQrbOZH97O4cBWf1fTLtqueIA0E2UjZdRsiJFP450
bBfA47t4BvG3SqlNf1MWQVgGGPlvf7r9Bo33i6DjXQm+tDVy11RzdBa51pphb/eP
xIFqm65p8iJtF6JdJ1rpVCSP+8Yl2Bki7fzH82iW80PQHpNz3uSGocd6W2nPkyrO
/Mg+Sw/VBbZpgXO2ymvW6X5c5ntsGObG6zFjy2EuoeKPoCG3i+N5ykt7a/XPKs0k
mmUKzRp3vF/haagb/GmI/v1ezY68BKwbICRuHbp32WFdoFnnaStPlylX6YMQniNd
3uRwD+LWzd3mC7T1UPYXnuaJsiAFv5sVHSX4lN0b0yTxYp4GTLlw3PAQAjlvMQ6u
Tk2u+RkOhskVJmJmO/mfFqw/RQCIa4NVUNZO+B+dzQ3AzKanMVUPLcJ05R2773fm
nKpyv9gRalHxmYnmyIqH
=QclO
-----END PGP SIGNATURE-----

--=-BB/tj6Po59uI8fV7vnDM--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
