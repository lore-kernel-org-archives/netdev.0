From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 0/10] bonding: rebuild the lock use for bond
 monitor
Date: Fri, 08 Nov 2013 17:32:14 +0100
Message-ID: <527D120E.3080706@redhat.com>
References: <527C4768.3010909@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756797Ab3KHQg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 11:36:56 -0500
In-Reply-To: <527C4768.3010909@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2013 03:07 AM, Ding Tianhong wrote:
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
> 
> v2. accept the Jay Vosburgh's opinion, remove the RTNL and replace with RCU,
>     also add some rcu function for bond use, so the patch set reach 10.
> 
> Best Regards
> Ding Tianhong
> 

Hi,
I've left my comments from a quick overview of the patches, my opinion on the
patchset is that it wasn't tested thoroughly enough (or at all). There're
multiple places that use a weaker compiler barrier instead of directly using
rcu_dereference() or rcu_access_pointer(), also there're multiple places which
can directly use macros already present in the RCU API.

Cheers,
 Nik
