From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 05/07: reintroduce dev->qdisc for use by sch_api
Date: Sun, 6 Sep 2009 20:57:58 +0200
Message-ID: <20090906185757.GA8833@ami.dom.local>
References: <20090904164117.27300.78712.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51950 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758100AbZIFS6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2009 14:58:32 -0400
Received: by fxm17 with SMTP id 17so1618019fxm.37
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2009 11:58:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090904164117.27300.78712.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 09/04/2009 06:41 PM:

> commit 57a016350a3d85dc351ab90ce91e4dc49ce2183a
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Sep 4 16:12:45 2009 +0200
> 
>     net_sched: reintroduce dev->qdisc for use by sch_api
>     
>     Currently the multiqueue integration with the qdisc API suffers from
>     a few problems:
>     
>     - with multiple queues, all root qdiscs use the same handle. This means
>       they can't be exposed to userspace in a backwards compatible fashion.
>     
>     - all API operations always refer to queue number 0. Newly created
>       qdiscs are automatically shared between all queues, its not possible
>       to address individual queues or restore multiqueue behaviour once a
>       shared qdisc has been attached.
>     
>     - Dumps only contain the root qdisc of queue 0, in case of non-shared
>       qdiscs this means the statistics are incomplete.
>     
>     This patch reintroduces dev->qdisc, which points to the (single) root qdisc
>     from userspace's point of view. Currently it either points to the first
>     (non-shared) default qdisc, or a qdisc shared between all queues. The
>     following patches will introduce a classful dummy qdisc, which will be used
>     as root qdisc and contain the per-queue qdiscs as children.
...
> @@ -1323,7 +1317,6 @@ done:
>  static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>  {
>  	struct net *net = sock_net(skb->sk);
> -	struct netdev_queue *dev_queue;
>  	struct tcmsg *tcm = NLMSG_DATA(n);
>  	struct nlattr *tca[TCA_MAX + 1];
>  	struct net_device *dev;
> @@ -1361,7 +1354,6 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>  
>  	/* Step 1. Determine qdisc handle X:0 */
>  
> -	dev_queue = netdev_get_tx_queue(dev, 0);
>  	if (pid != TC_H_ROOT) {
>  		u32 qid1 = TC_H_MAJ(pid);
>  
> @@ -1372,7 +1364,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>  		} else if (qid1) {
>  			qid = qid1;
>  		} else if (qid == 0)
> -			qid = dev_queue->qdisc_sleeping->handle;
> +			qid = dev->qdisc->handle;
>  
>  		/* Now qid is genuine qdisc handle consistent
>  		   both with parent and child.
> @@ -1383,7 +1375,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>  			pid = TC_H_MAKE(qid, pid);
>  	} else {
>  		if (qid == 0)
> -			qid = dev_queue->qdisc_sleeping->handle;
> +			qid = dev->qdisc->handle;

Probably I miss something, but in mq root case it seems to never do
anything we need. If so, it could be the example of possible issues
elsewhere.

I thought this mq virtual root qdisc could be done more transparently
and invisible for the current code, but it seems, in your
implementation some pointers like this, or parent ids (especially
TC_H_ROOT) might be different, and even if it works OK, needs a lot of
verification. So, my question is, if it's really necessary.

Jarek P.
>  	}
>  
>  	/* OK. Locate qdisc */
