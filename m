From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: close another race condition in
 tcf_mirred_release()
Date: Tue, 17 May 2016 14:22:47 -0400 (EDT)
Message-ID: <20160517.142247.1572671234268001610.davem@davemloft.net>
References: <1463436678-20254-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbcEQSWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:22:53 -0400
In-Reply-To: <1463436678-20254-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 16 May 2016 15:11:18 -0700

> We saw the following extra refcount release on veth device:
> 
>   kernel: [7957821.463992] unregister_netdevice: waiting for mesos50284 to become free. Usage count = -1
> 
> Since we heavily use mirred action to redirect packets to veth, I think
> this is caused by the following race condition:
> 
> CPU0:
> tcf_mirred_release(): (in RCU callback)
> 	struct net_device *dev = rcu_dereference_protected(m->tcfm_dev, 1);
> 
> CPU1:
> mirred_device_event():
>         spin_lock_bh(&mirred_list_lock);
>         list_for_each_entry(m, &mirred_list, tcfm_list) {
>                 if (rcu_access_pointer(m->tcfm_dev) == dev) {
>                         dev_put(dev);
>                         /* Note : no rcu grace period necessary, as
>                          * net_device are already rcu protected.
>                          */
>                         RCU_INIT_POINTER(m->tcfm_dev, NULL);
>                 }
>         }
>         spin_unlock_bh(&mirred_list_lock);
> 
> CPU0:
> tcf_mirred_release():
>         spin_lock_bh(&mirred_list_lock);
>         list_del(&m->tcfm_list);
>         spin_unlock_bh(&mirred_list_lock);
>         if (dev)               // <======== Stil refers to the old m->tcfm_dev
>                 dev_put(dev);  // <======== dev_put() is called on it again
> 
> The action init code path is good because it is impossible to modify
> an action that is being removed.
> 
> So, fix this by moving everything under the spinlock.
> 
> Fixes: 2ee22a90c7af ("net_sched: act_mirred: remove spinlock in fast path")
> Fixes: 6bd00b850635 ("act_mirred: fix a race condition on mirred_list")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
