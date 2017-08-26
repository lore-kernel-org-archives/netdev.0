From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3 v9] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Fri, 25 Aug 2017 20:06:23 -0700 (PDT)
Message-ID: <20170825.200623.1467784779129980276.davem@davemloft.net>
References: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
        <1503635966-14076-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@ACULAB.COM, marcel@holtmann.org, andrew@lunn.ch
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHZDG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:06:26 -0400
In-Reply-To: <1503635966-14076-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 24 Aug 2017 22:39:26 -0600

> +static void rmnet_force_unassociate_device(struct net_device *dev)
> +{
> +	struct net_device *real_dev = dev;
> +	struct rmnet_walk_data d;
> +	LIST_HEAD(list);
> +
> +	if (!rmnet_is_real_dev_registered(real_dev))
> +		return;
> +
> +	ASSERT_RTNL();
> +
> +	d.real_dev = real_dev;
> +	d.head = &list;
> +
> +	rcu_read_lock();
> +	netdev_walk_all_lower_dev_rcu(real_dev, rmnet_dev_walk_unreg, &d);
> +	synchronize_net();
> +
> +	unregister_netdevice_many(&list);
> +	rcu_read_unlock();
> +
> +	rmnet_unregister_real_device(real_dev);
> +}

In these code paths where you are the writer, you have to rely upon
the RTNL mutex (or some other mutual exclusion mechanism) to protect
the update operation.  RCU locking itself does not provide this.

So you should use something like rcu_dereference_rtnl() or similar.

So this would be rmnet_force_unassociate_device() and rmnet_dellink()

RCU is subtle and the writer paths have the be handled differently
from the reader paths.  Please take some time to study how RCU should
be applied properly in these situations rather than just slapping a
patch together overnight.

Thank you.
