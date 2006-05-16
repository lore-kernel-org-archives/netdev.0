From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Mon, 15 May 2006 22:16:37 -0700 (PDT)
Message-ID: <20060515.221637.90861876.davem@davemloft.net>
References: <20060504.161148.44973535.davem@davemloft.net>
	<200605051248.42662.kelly@au.ibm.com>
	<200605161102.29472.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30153
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751303AbWEPFRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 01:17:06 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200605161102.29472.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Tue, 16 May 2006 11:02:29 +1000

> +/* handles default chan buffers that nobody else wants */
> +static int default_netchannel_thread(void *unused)
> +{
> +	wait_queue_t wait;
> +	struct netchannel_buftrailer *bp;
> +	struct sk_buff *skbp;
> +
> +	wait.private = current;
> +	wait.func = default_wake_function;;
> +	INIT_LIST_HEAD(&wait.task_list);
> +
> +	add_wait_queue(&default_netchannel_wq, &wait);
> +	set_current_state(TASK_UNINTERRUPTIBLE);
> +	while (!kthread_should_stop()) {
> +		bp = __netchannel_dequeue(&default_netchannel);
> +		skbp = skb_netchan_graft(bp, GFP_ATOMIC);
> +		netif_receive_skb(skbp);
> +	}
> +	remove_wait_queue(&default_netchannel_wq, &wait);
> +	__set_current_state(TASK_RUNNING);
> +	return 0;
> +}
> +

When does this thread ever go to sleep?  Seems like it will loop
forever and not block when the default_netchannel queue is empty.
:-)

> +	unsigned long dlen = np->netchan_buf_len - np->netchan_buf_offset;

Probably deserves a "netchan_buf_len(bp)" inline in linux/netchannel.h

> diff -urp davem_orig/net/ipv4/inet_hashtables.c kelly/net/ipv4/inet_hashtables.c
> --- davem_orig/net/ipv4/inet_hashtables.c	2006-04-27 00:08:33.000000000 +1000
> +++ kelly/net/ipv4/inet_hashtables.c	2006-05-05 12:45:44.000000000 +1000

The hash table bits look good, just as they did last time :-)
So I'll put this part into my vj-2.6 tree now, thanks.

