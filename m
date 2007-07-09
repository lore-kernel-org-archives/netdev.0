From: Patrick McHardy <kaber@trash.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
 to -mm tree
Date: Mon, 09 Jul 2007 15:52:40 +0200
Message-ID: <46923DA8.9010208@trash.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>	 <20070705142135.GG4759@ff.dom.local>	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>	 <20070706064523.GA2144@ff.dom.local>	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>	 <468E4FD9.4060702@trash.net>	 <1183733732.6389.26.camel@ranko-fc2.spidernet.net>	 <1183794918.30237.69.camel@localhost.localdomain>	 <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63241 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbXGINw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 09:52:56 -0400
In-Reply-To: <1183984861.18656.21.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranko Zivojnovic wrote:
> On Sat, 2007-07-07 at 17:10 +0200, Patrick McHardy wrote:
> 
>>On Sat, 7 Jul 2007, Ranko Zivojnovic wrote:
>>
>>>Maybe the appropriate way to fix this would to call gen_kill_estimator,
>>>with the appropriate lock order, before the call to qdisc_destroy, so
>>>when dev->queue_lock is taken for qdisc_destroy - the structure is
>>>already off the list.
>>
>>Probably easier to just kill est_lock and use rcu lists.
>>I'm currently travelling, I'll look into it tomorrow.
> 
> 
> Patrick, I've taken liberty to try and implement this myself. Attached
> is the whole new gen_estimator-fix-locking-and-timer-related-bugs.patch
> that is RCU lists based. Please be kind to review.


Thanks for taking care of this, I'm a bit behind.
See below for comments ..


> --- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
> +++ b/net/core/gen_estimator.c	2007-07-09 14:27:12.053336875 +0300
> @@ -79,7 +79,7 @@
>  
>  struct gen_estimator
>  {
> -	struct gen_estimator	*next;
> +	struct list_head	list;
>  	struct gnet_stats_basic	*bstats;
>  	struct gnet_stats_rate_est	*rate_est;
>  	spinlock_t		*stats_lock;
> @@ -89,26 +89,27 @@
>  	u32			last_packets;
>  	u32			avpps;
>  	u32			avbps;
> +	struct rcu_head		e_rcu;


You could also use synchronize_rcu(), estimator destruction is
not particulary performance critical.

>  static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
>  
>  /* Estimator array lock */
> -static DEFINE_RWLOCK(est_lock);
> +static DEFINE_SPINLOCK(est_lock);


The lock isn't needed anymore since we can rely on the rtnl
for creation/destruction.

>  /**
> @@ -152,6 +153,7 @@
>  {
>  	struct gen_estimator *est;
>  	struct gnet_estimator *parm = RTA_DATA(opt);
> +	int idx;
>  
>  	if (RTA_PAYLOAD(opt) < sizeof(*parm))
>  		return -EINVAL;
> @@ -163,7 +165,8 @@
>  	if (est == NULL)
>  		return -ENOBUFS;
>  
> -	est->interval = parm->interval + 2;
> +	INIT_LIST_HEAD(&est->list);


Initializing the members' list_head isn't necessary.

