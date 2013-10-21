From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 21 Oct 2013 15:31:34 +0200
Message-ID: <20131021133134.GF692@redhat.com>
References: <5264ECBC.2090208@huawei.com>
 <20131021091336.GB692@redhat.com>
 <5264F397.50608@huawei.com>
 <20131021093549.GC692@redhat.com>
 <52651ECB.1080901@huawei.com>
 <20131021124144.GD692@redhat.com>
 <20131021132136.GE692@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274Ab3JUNft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 09:35:49 -0400
Content-Disposition: inline
In-Reply-To: <20131021132136.GE692@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 03:21:36PM +0200, Veaceslav Falico wrote:
>On Mon, Oct 21, 2013 at 02:41:44PM +0200, Veaceslav Falico wrote:
>>On Mon, Oct 21, 2013 at 08:32:11PM +0800, Ding Tianhong wrote:
>>>On 2013/10/21 17:35, Veaceslav Falico wrote:
>>>>On Mon, Oct 21, 2013 at 05:27:51PM +0800, Ding Tianhong wrote:
>>>>>On 2013/10/21 17:13, Veaceslav Falico wrote:
>>>>>>On Mon, Oct 21, 2013 at 04:58:36PM +0800, Ding Tianhong wrote:
>>>>>>>Hi:
>>>>>>>
>>>>>>>The Patch Set will remove the invalid lock for bond work queue and replace it
>>>>>>>with rtnl lock, as read lock for bond could not protect slave list any more.
>>>>>>
>>>>>>rtnl lock is a lot more expensive than bond lock, and not only for bond,
>>>>>>but for all the networking stack.
>>>>>>
>>>>>>Why is the bond->lock invalid? It correctly protects slaves from being
>>>>>>modified concurrently.
>>>>>>
>>>>>>I don't see the point in this patchset.
>>>>>>
>>>>>
>>>>>yes, rtnl lock is a big lock, but I think bond->lock could not protect
>>>>>bond_for_each_slave any more, am I miss something?
>>>>
>>>>Why can't it protect bond_for_each_slave()?
>>>>
>>>
>>>bond_master_upper_dev_link() and bond_upper_dev_unlink() was only in rtnl lock,
>>>bond_for_each_slave may changed while loop in bond read lock, but it sees that
>>>nothing serious will happen yet.
>>>Maybe I miss something.
>>
>>Even if it is unsafe to use bond_for_each_slave() while holding bond->lock
>>- it means that we must protect the list by locking the
>>bond_upper_dev_(un)link() via bond->lock, but not by removing bond->lock
>>from everywhere where it is now. And I'm not that sure if it's safe or not.
>
>I've quickly looked over the code - yes, theoretically we could race
>between bond_for_each_slave() that is not rtnl-protected and
>bond_upper_dev_(un)link().

For this race, btw, it's enough to apply the following patch, and we're
good (we don't care if we add a slave whilst bond_for_each_slave()) -
untested patch:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d90734f..b3923e1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1737,10 +1737,10 @@ static int __bond_release_one(struct net_device *bond_dev,
  		unblock_netpoll_tx();
  		return -EINVAL;
  	}
+	bond_upper_dev_unlink(bond_dev, slave_dev);
  
  	write_unlock_bh(&bond->lock);
  
-	bond_upper_dev_unlink(bond_dev, slave_dev);
  	/* unregister rx_handler early so bond_handle_frame wouldn't be called
  	 * for this slave anymore.
  	 */
