From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: set real_num_tx_queues to zreo avoid to
 trigger BUG_ON
Date: Fri, 19 Feb 2016 23:36:43 -0500 (EST)
Message-ID: <20160219.233643.95383657086552033.davem@davemloft.net>
References: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, peter.huangpeng@huawei.com
To: arei.gonglei@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gonglei <arei.gonglei@huawei.com>
Date: Sat, 20 Feb 2016 09:27:26 +0800

> It's possible for a race condition to exist between xennet_open() and
> talk_to_netback(). After invoking netfront_probe() then other
> threads or processes invoke xennet_open (such as NetworkManager)
> immediately may trigger BUG_ON(). Besides, we also should reset
> real_num_tx_queues in xennet_destroy_queues().

One should really never invoke register_netdev() until the device is
%100 fully initialized.

This means you cannot call register_netdev() until it is completely
legal to invoke your ->open() method.

And I think that is what the real problem is here.

If you follow the correct rules for ordering wrt. register_netdev()
there are no "races".  Because ->open() must be legally invokable
from the exact moment you call register_netdev().

I'm not applying this, as it really sounds like the fundamental issue
is the order in which the xen-netfront private data is initialized
or setup before being registered.
