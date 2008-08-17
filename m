From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 13:01:55 +0300
Message-ID: <200808171301.56002.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808171235.46413.denys@visp.net.lb> <20080817095220.GB2907@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51772 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYHQKDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 06:03:05 -0400
In-Reply-To: <20080817095220.GB2907@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, now things finally organized.
fixing patch #1 was missing.

Rebooting system to this kernel. But strange thing, without fixing patch #1 it 
didn't crash for whole night, and 1-3 hours now (with same options as 
before).

Let's test now complete set of patches. I will keep around 2 hours on most 
loaded pppoe NAS, then distribute to 2-3 servers more if it doesn't crash.

On Sunday 17 August 2008, Jarek Poplawski wrote:
> On Sun, Aug 17, 2008 at 12:35:46PM +0300, Denys Fedoryshchenko wrote:
> > I have applied now
> > 01-fix-pkt_sched: Fix unloc~ in tc_ctl_tfilter()
> > 02-lockdep.patch (it is adding in sch_api.c lockdep_set_class)
> > "take 3" patch
>
> + fixing patch #1 (resend just before)
> + fixing patch #2 (resend below)
>
> Jarek P.
>
> --- (resend fixing patch #2)
>
>  include/linux/netdevice.h |    1 +
>  include/net/sch_generic.h |    5 ++++-
>  net/core/dev.c            |    1 +
>  3 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 488c56e..7041c2c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -445,6 +445,7 @@ struct netdev_queue {
>  	struct net_device	*dev;
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
> +	spinlock_t		qdisc_lock;
>  	spinlock_t		_xmit_lock;
>  	int			xmit_lock_owner;
>  	struct Qdisc		*qdisc_sleeping;
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a7abfda..f84e96c 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -185,7 +185,10 @@ static inline struct qdisc_skb_cb *qdisc_skb_cb(struct
> sk_buff *skb)
>
>  static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
>  {
> -	return &qdisc->q.lock;
> +	if (unlikely(qdisc->flags & TCQ_F_BUILTIN))
> +		return &qdisc->q.lock;
> +
> +	return &qdisc->dev_queue->qdisc_lock;
>  }
>
>  static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 600bb23..9ec20e0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3859,6 +3859,7 @@ static void __netdev_init_queue_locks_one(struct
> net_device *dev, void *_unused)
>  {
>  	spin_lock_init(&dev_queue->_xmit_lock);
> +	spin_lock_init(&dev_queue->qdisc_lock);
>  	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
>  	dev_queue->xmit_lock_owner = -1;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


