From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 06/12] net: sched: support qdisc_reset on NOLOCK qdisc
Date: Thu, 31 Dec 2015 18:30:04 -0800
Message-ID: <20160101023003.GA17287@ast-mbp.thefacebook.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
 <20151230175313.26257.46445.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net,
	john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36548 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbcAACaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 21:30:07 -0500
Received: by mail-pa0-f42.google.com with SMTP id yy13so66328330pab.3
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2015 18:30:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151230175313.26257.46445.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 09:53:13AM -0800, John Fastabend wrote:
> The qdisc_reset operation depends on the qdisc lock at the moment
> to halt any additions to gso_skb and statistics while the list is
> free'd and the stats zeroed.
> 
> Without the qdisc lock we can not guarantee another cpu is not in
> the process of adding a skb to one of the "cells". Here are the
> two cases we have to handle.
> 
>  case 1: qdisc_graft operation. In this case a "new" qdisc is attached
> 	 and the 'qdisc_destroy' operation is called on the old qdisc.
> 	 The destroy operation will wait a rcu grace period and call
> 	 qdisc_rcu_free(). At which point gso_cpu_skb is free'd along
> 	 with all stats so no need to zero stats and gso_cpu_skb from
> 	 the reset operation itself.
> 
> 	 Because we can not continue to call qdisc_reset before waiting
> 	 an rcu grace period so that the qdisc is detached from all
> 	 cpus simply do not call qdisc_reset() at all and let the
> 	 qdisc_destroy operation clean up the qdisc. Note, a refcnt
> 	 greater than 1 would cause the destroy operation to be
> 	 aborted however if this ever happened the reference to the
> 	 qdisc would be lost and we would have a memory leak.
> 
>  case 2: dev_deactivate sequence. This can come from a user bringing
> 	 the interface down which causes the gso_skb list to be flushed
> 	 and the qlen zero'd. At the moment this is protected by the
> 	 qdisc lock so while we clear the qlen/gso_skb fields we are
> 	 guaranteed no new skbs are added. For the lockless case
> 	 though this is not true. To resolve this move the qdisc_reset
> 	 call after the new qdisc is assigned and a grace period is
> 	 exercised to ensure no new skbs can be enqueued. Further
> 	 the RTNL lock is held so we can not get another call to
> 	 activate the qdisc while the skb lists are being free'd.
> 
> 	 Finally, fix qdisc_reset to handle the per cpu stats and
> 	 skb lists.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
...
> -	/* Prune old scheduler */
> -	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
> -		qdisc_reset(oqdisc);
> -
...
> -		sync_needed |= !dev->dismantle;
> +		sync_needed = true;

I think killing above <=1 check and forcing synchronize_net() will
make qdisc destruction more reliable than it's right now.
Your commit log sounds too pessimistic :)

btw, sync_needed variable can be removed as well.

All other patches look good. Great stuff overall!
