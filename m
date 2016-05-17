From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: close another race condition in
 tcf_mirred_release()
Date: Tue, 17 May 2016 08:08:02 -0400
Message-ID: <573B09A2.3040206@mojatatu.com>
References: <1463436678-20254-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33994 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897AbcEQMIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 08:08:05 -0400
Received: by mail-io0-f194.google.com with SMTP id d62so2984655iof.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 05:08:04 -0700 (PDT)
In-Reply-To: <1463436678-20254-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-16 06:11 PM, Cong Wang wrote:
> We saw the following extra refcount release on veth device:
>
>    kernel: [7957821.463992] unregister_netdevice: waiting for mesos50284 to become free. Usage count = -1
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
>          spin_lock_bh(&mirred_list_lock);
>          list_for_each_entry(m, &mirred_list, tcfm_list) {
>                  if (rcu_access_pointer(m->tcfm_dev) == dev) {
>                          dev_put(dev);
>                          /* Note : no rcu grace period necessary, as
>                           * net_device are already rcu protected.
>                           */
>                          RCU_INIT_POINTER(m->tcfm_dev, NULL);
>                  }
>          }
>          spin_unlock_bh(&mirred_list_lock);
>
> CPU0:
> tcf_mirred_release():
>          spin_lock_bh(&mirred_list_lock);
>          list_del(&m->tcfm_list);
>          spin_unlock_bh(&mirred_list_lock);
>          if (dev)               // <======== Stil refers to the old m->tcfm_dev
>                  dev_put(dev);  // <======== dev_put() is called on it again
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

LGTM.
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
