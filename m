From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 02/15] net: rcu-ify tcf_proto
Date: Sun, 24 Aug 2014 22:31:33 -0700 (PDT)
Message-ID: <20140824.223133.170922940598584254.davem@davemloft.net>
References: <20140825004659.2180.35028.stgit@nitbit.x32>
	<20140825004830.2180.70308.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbaHYFbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 01:31:36 -0400
In-Reply-To: <20140825004830.2180.70308.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 24 Aug 2014 17:48:31 -0700

> @@ -722,8 +724,9 @@ static void sfq_free(void *addr)
>  static void sfq_destroy(struct Qdisc *sch)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
> +	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
>  
> -	tcf_destroy_chain(&q->filter_list);
> +	tcf_destroy_chain(&fl);

This will cause tcf_destroy_chain() to set the local variable
'fl' to NULL rather than q->filter_list.

I don't see how this can be correct at all.

You need to make tcf_destroy_chain() take a pointer to an __rcu
pointer, and do the proper dereferencing and RCU assignments in
that chain destroy loop.

This might be why you're getting annotation warnings.
