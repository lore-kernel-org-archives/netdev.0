From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/11] bonding: rebuild the lock use for
 bond monitor
Date: Sat, 14 Dec 2013 02:01:49 -0500 (EST)
Message-ID: <20131214.020149.2022684556057698333.davem@davemloft.net>
References: <52A7F148.6000302@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab3LNHBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 02:01:51 -0500
In-Reply-To: <52A7F148.6000302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 11 Dec 2013 12:59:52 +0800

> Now the bond slave list is not protected by bond lock, only by RTNL,
> but the monitor still use the bond lock to protect the slave list,
> it is useless, according to the Veaceslav's opinion, there were
> three way to fix the protect problem:
> 
> 1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
>    in bond->lock, but it is unsafe to call call_netdevice_notifiers()
>    in write lock.
> 2. remove unused bond->lock for monitor function, only use the exist
>    rtnl lock(), it will take performance loss in fast path.
> 3. use RCU to protect the slave list, of course, performance is better,
>    but in slow path, it is ignored.
> 
> obviously the solution 1 is not fit here, I will consider the 2 and 3
> solution. My principle is simple, if in fast path, RCU is better,
> otherwise in slow path, both is well, but according to the Jay Vosburgh's
> opinion, the monitor will loss performace if use RTNL to protect the all
> slave list, so remove the bond lock and replace with RCU.
> 
> The second problem is the curr_slave_lock for bond, it is too old and
> unwanted in many place, because the curr_active_slave would only be
> changed in 3 place:
> 
> 1. enslave slave.
> 2. release slave.
> 3. change active slave.
> 
> all above were already holding bond lock, RTNL and curr_slave_lock
> together, it is tedious and no need to add so mach lock, when change
> the curr_active_slave, you have to hold the RTNL and curr_slave_lock
> together, and when you read the curr_active_slave, RTNL or curr_slave_lock,
> any one of them is no problem.
> 
> for the stability, I did not change the logic for the monitor,
> all change is clear and simple, I have test the patch set for lockdep,
> it work well and stability.

Series applied, thanks.
