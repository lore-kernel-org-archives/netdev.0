From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net 1/3] net: allow netdev_all_upper_get_next_dev_rcu with rtnl
 lock held
Date: Tue, 19 Nov 2013 09:18:42 -0800
Message-ID: <528B9D72.1090004@gmail.com>
References: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com> <1384875654-7795-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Veaceslav Falico <vfalico@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:63925 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3KSRS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 12:18:58 -0500
Received: by mail-ob0-f175.google.com with SMTP id uz6so859945obc.34
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 09:18:58 -0800 (PST)
In-Reply-To: <1384875654-7795-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2013 07:40 AM, Jeff Kirsher wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
>
> It is useful to be able to walk all upper devices when bringing
> a device online where the RTNL lock is held. In this case it
> is safe to walk the all_adj_list because the RTNL lock is used
> to protect the write side as well.
>
> Here we rearrange the netdev_all_upper_get_next_dev_rcu into three
> routines:
>
> 	netdev_all_upper_get_next_dev_rcu()
> 	netdev_all_upper_get_next_dev_rtnl()
> 	netdev_all_upper_get_next_dev()
>
> One for RCU callers, one for RTNL callers and a final routine
> to implement the work. Both the _rcu and _rtnl variants are
> exposed. Where the net/ethernet/intel/ixgbe driver is a consumer
> of the _rtnl variant. netdev_all_upper_get_next_dev() is static.
>
> CC: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

[...]

NAK, lockdep_rtnl_is_held() is wrapped in CONFIG_PROVE_LOCKING,

	#ifdef CONFIG_PROVE_LOCKING
	extern int lockdep_rtnl_is_held(void);
	#endif /* #ifdef CONFIG_PROVE_LOCKING */

[...]

> +struct net_device *netdev_all_upper_get_next_dev_rtnl(struct net_device *dev,
> +						      struct list_head **iter)
> +{
> +	WARN_ON_ONCE(!lockdep_rtnl_is_held());

so this can cause a build error without CONFIG_PROVE_LOCKING. I can
either wrap this in a CONFIG_PROVE_LOCKING or do something like this,

  	extern int rtnl_is_locked(void);
  	#ifdef CONFIG_PROVE_LOCKING
  	extern int lockdep_rtnl_is_held(void);
	+#else
	+static inline int lockdep_rtnl_is_held(void)
	+{
	+       return 0;
	+}
	 #endif /* #ifdef CONFIG_PROVE_LOCKING */

The lazy way to do this is to wrap the call  site in rcu_read_{un}lock
but I would prefer not to do that.

> +	return netdev_all_upper_get_next_dev(dev, iter);
> +}

Sorry for the noise I'll spin a new version.

John

-- 
John Fastabend         Intel Corporation
