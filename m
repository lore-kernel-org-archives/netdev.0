From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: sched: allocate a handle to default
 qdiscs
Date: Fri, 21 Aug 2015 09:14:58 -0700
Message-ID: <1440173698.6610.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440172688-2163-1-git-send-email-phil@nwl.cc>
	 <1440172688-2163-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, brouer@redhat.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36449 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbbHUQPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 12:15:01 -0400
Received: by pawq9 with SMTP id q9so55694428paw.3
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 09:15:00 -0700 (PDT)
In-Reply-To: <1440172688-2163-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-21 at 17:58 +0200, Phil Sutter wrote:
> Since tc_get_qdisc() does not allow to remove a qdisc with zero handle,
> a handle needs to be allocated to default qdiscs (currently pfifo_fast
> or mq) in order to allow removing them.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  include/net/sch_generic.h | 1 +
>  net/sched/sch_api.c       | 3 ++-
>  net/sched/sch_generic.c   | 5 +++++
>  3 files changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 4495193..2bfc898 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -391,6 +391,7 @@ void dev_deactivate(struct net_device *dev);
>  void dev_deactivate_many(struct list_head *head);
>  struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
>  			      struct Qdisc *qdisc);
> +u32 qdisc_alloc_handle(struct net_device *dev);
>  void qdisc_reset(struct Qdisc *qdisc);
>  void qdisc_destroy(struct Qdisc *qdisc);
>  void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index f06aa01..224374c 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -723,7 +723,7 @@ EXPORT_SYMBOL(qdisc_class_hash_remove);
>  /* Allocate an unique handle from space managed by kernel
>   * Possible range is [8000-FFFF]:0000 (0x8000 values)
>   */
> -static u32 qdisc_alloc_handle(struct net_device *dev)
> +u32 qdisc_alloc_handle(struct net_device *dev)
>  {
>  	int i = 0x8000;
>  	static u32 autohandle = TC_H_MAKE(0x80000000U, 0);
> @@ -739,6 +739,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL(qdisc_alloc_handle);
>  
>  void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
>  {
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 1fb65f9..ab614ee 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -634,6 +634,11 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>  	if (IS_ERR(sch))
>  		goto errout;
>  	sch->parent = parentid;
> +#ifdef CONFIG_NET_SCHED
> +	sch->handle = qdisc_alloc_handle(dev_queue->dev);
> +	if (!sch->handle)
> +		goto errout;
> +#endif
>  
>  	if (!ops->init || ops->init(sch, NULL) == 0)
>  		return sch;

This might break HTB setups with more than 32768 classes ?

The pfifo qdisc that gets attached had no handle.

qdisc_alloc_handle() has a limited range.
