From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [1/4] bonding: don't call slave_xxx_netpoll under spinlocks
Date: Mon, 22 Jul 2013 08:40:34 +0800
Message-ID: <51EC7F82.7060109@huawei.com>
References: <51EA3B03.7010302@huawei.com> <20130720103800.GB9149@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:21156 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab3GVAlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 20:41:11 -0400
In-Reply-To: <20130720103800.GB9149@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/20 18:38, Veaceslav Falico wrote:
> On Sat, Jul 20, 2013 at 03:23:47PM +0800, dingtianhong wrote:
>> the slave_xxx_netpoll may sleep, so it should't be called under spinlocks.
> 
> I don't really see how it may sleep, it was specifically changed to not
> sleep actually. However, see below...
>

I think the synchronize_rcu_bh() in slave disable_netpoll will sched and speed,so spinlock
should not used here.

>>
>> the slave point of the bonding will not be changed outside rtnl lock,
>> so rtnl lock is enough here.
> 
> Yep, as far as I see there's really no need to take the lock, both the
> slave list and the netpoll part are always protected by rtnl lock, unless
> I'm missing something, and indeed .ndo_netpoll_setup() is always called
> under rtnl.
> 
> BTW, bond_netpoll_cleanup() has the same problem - maybe you could check if
> we can remove the bond->lock from there also and update the patch?
> 

yes, this patch has remove bond_netpoll_cleanup(), and change _bond_netpoll_cleanup() to bond_netpoll_cleanup(), rtnl lock is enough here.

>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>
>> ---
>> drivers/net/bonding/bond_main.c | 15 +++------------
>> 1 file changed, 3 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 07f257d4..5eb75ef 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1249,8 +1249,9 @@ static void bond_poll_controller(struct net_device *bond_dev)
>> {
>> }
>>
>> -static void __bond_netpoll_cleanup(struct bonding *bond)
>> +static void bond_netpoll_cleanup(struct net_device *bond_dev)
>> {
>> +    struct bonding *bond = netdev_priv(bond_dev);
>>     struct slave *slave;
>>     int i;
>>
>> @@ -1258,14 +1259,6 @@ static void __bond_netpoll_cleanup(struct bonding *bond)
>>         if (IS_UP(slave->dev))
>>             slave_disable_netpoll(slave);
>> }
>> -static void bond_netpoll_cleanup(struct net_device *bond_dev)
>> -{
>> -    struct bonding *bond = netdev_priv(bond_dev);
>> -
>> -    read_lock(&bond->lock);
>> -    __bond_netpoll_cleanup(bond);
>> -    read_unlock(&bond->lock);
>> -}
>>
>> static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, gfp_t gfp)
>> {
>> @@ -1273,15 +1266,13 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
>>     struct slave *slave;
>>     int i, err = 0;
>>
>> -    read_lock(&bond->lock);
>>     bond_for_each_slave(bond, slave, i) {
>>         err = slave_enable_netpoll(slave);
>>         if (err) {
>> -            __bond_netpoll_cleanup(bond);
>> +            bond_netpoll_cleanup(dev);
>>             break;
>>         }
>>     }
>> -    read_unlock(&bond->lock);
>>     return err;
>> }
>>
> 
> .
> 
