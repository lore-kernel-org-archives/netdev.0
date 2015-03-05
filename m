From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1] bonding: implement bond_poll_controller()
Date: Wed, 04 Mar 2015 20:01:15 -0800
Message-ID: <1425528075.5130.238.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425522400-3671-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:41059 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbbCEEBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:01:18 -0500
Received: by igal13 with SMTP id l13so42868890iga.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 20:01:17 -0800 (PST)
In-Reply-To: <1425522400-3671-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 18:26 -0800, Mahesh Bandewar wrote:

...

> +	rcu_read_lock();
> +	bond_for_each_slave_rcu(bond, slave, iter) {
> +		ops = slave->dev->netdev_ops;
> +		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
> +			continue;
> +
> +		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +			struct aggregator *agg =
> +			    SLAVE_AD_INFO(slave)->port.aggregator;
> +
> +			if (agg &&
> +			    agg->aggregator_identifier != ad_info.aggregator_id)
> +				continue;
> +		}
> +
> +		ni = rcu_dereference_bh(slave->dev->npinfo);

rcu_read_lock();
X = rcu_dereference_bh(Y);
rcu_read_unlock();

Is a mismatch of RCU API.

It should be either :

rcu_read_lock();
X = rcu_dereference(Y);
rcu_read_unlock();

or

rcu_read_lock_bh();
X = rcu_dereference_bh(Y);
rcu_read_unlock_bh();



> +		if (down_trylock(&ni->dev_lock))
> +			continue;
> +		ops->ndo_poll_controller(slave->dev);
> +		up(&ni->dev_lock);
> +	}
> +	rcu_read_unlock();
>  }
>  
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
