From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Wed, 17 Jun 2009 18:12:29 -0700
Message-ID: <m18wjqqr9e.fsf@fess.ebiederm.org>
References: <1245263058.31588.38.camel@johannes.local>
	<m1y6rqwpur.fsf@fess.ebiederm.org>
	<1245276899.31588.57.camel@johannes.local>
	<m1r5xitpdh.fsf@fess.ebiederm.org>
	<1245282099.31588.69.camel@johannes.local>
	<m17hzato0r.fsf@fess.ebiederm.org>
	<1245283327.31588.74.camel@johannes.local>
	<m1my86qt73.fsf@fess.ebiederm.org>
	<1245285541.31588.79.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59917 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbZFRBMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:12:31 -0400
In-Reply-To: <1245285541.31588.79.camel@johannes.local> (Johannes Berg's message of "Thu\, 18 Jun 2009 02\:39\:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2009-06-17 at 17:30 -0700, Eric W. Biederman wrote:
>
>> >> This of course gives you a network namespace that can be found by for_each_net rcu
>> >> while the per net exit functions are running.  I think that opens up to races
>> >> that I don't want to think about.
>> >
>> > Indeed. Can we move the rcu_barrier() up? Or we could insert a
>> > synchronize_rcu() (which is sufficient for rcu_read_lock) before the
>> > exit functions are run?
>> 
>> I don't think we can move the barrier.   But adding an extra synchronize_rcu
>> should be fine.  We are talking about the slowest of the slow paths here.
>> It is so slow it even gets it's own kernel thread.
>
> Ok :) New patch below.
>
> Yes, you're right, we can't move it, it might still be used from exit
> for net_assign_generic or so.

Except for the changelog which is wrong about not needing any rcu
primitives I can't spot any bugs.

> johannes
>
> Subject: net: make namespace iteration possible under RCU
>
> We already call rcu_barrier(), so all we need to take
> care of is using proper RCU list add/del primitives.
>
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
>  include/net/net_namespace.h |    3 +++
>  net/core/net_namespace.c    |   10 +++++++---
>  2 files changed, 10 insertions(+), 3 deletions(-)
>
> --- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 01:36:26.000000000 +0200
> +++ wireless-testing/include/net/net_namespace.h	2009-06-18 02:17:14.000000000 +0200
> @@ -211,6 +211,9 @@ static inline struct net *read_pnet(stru
>  #define for_each_net(VAR)				\
>  	list_for_each_entry(VAR, &net_namespace_list, list)
>  
> +#define for_each_net_rcu(VAR)				\
> +	list_for_each_entry_rcu(VAR, &net_namespace_list, list)
> +
>  #ifdef CONFIG_NET_NS
>  #define __net_init
>  #define __net_exit
> --- wireless-testing.orig/net/core/net_namespace.c	2009-06-18 01:36:39.000000000 +0200
> +++ wireless-testing/net/core/net_namespace.c	2009-06-18 02:03:06.000000000 +0200
> @@ -6,6 +6,7 @@
>  #include <linux/delay.h>
>  #include <linux/sched.h>
>  #include <linux/idr.h>
> +#include <linux/rculist.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  
> @@ -134,7 +135,7 @@ struct net *copy_net_ns(unsigned long fl
>  	err = setup_net(new_net);
>  	if (!err) {
>  		rtnl_lock();
> -		list_add_tail(&new_net->list, &net_namespace_list);
> +		list_add_tail_rcu(&new_net->list, &net_namespace_list);
>  		rtnl_unlock();
>  	}
>  	mutex_unlock(&net_mutex);
> @@ -163,9 +164,12 @@ static void cleanup_net(struct work_stru
>  
>  	/* Don't let anyone else find us. */
>  	rtnl_lock();
> -	list_del(&net->list);
> +	list_del_rcu(&net->list);
>  	rtnl_unlock();
>  
> +	/* if somebody is rcu-iterating the list, wait */
> +	synchronize_rcu();
> +
>  	/* Run all of the network namespace exit methods */
>  	list_for_each_entry_reverse(ops, &pernet_list, list) {
>  		if (ops->exit)
> @@ -227,7 +231,7 @@ static int __init net_ns_init(void)
>  	err = setup_net(&init_net);
>  
>  	rtnl_lock();
> -	list_add_tail(&init_net.list, &net_namespace_list);
> +	list_add_tail_rcu(&init_net.list, &net_namespace_list);
>  	rtnl_unlock();
>  
>  	mutex_unlock(&net_mutex);
