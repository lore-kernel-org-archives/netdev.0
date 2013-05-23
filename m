From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after netdev_rx_handler_unregister
Date: Thu, 23 May 2013 09:41:30 +0800
Message-ID: <519D73CA.8090200@huawei.com>
References: <519C8504.1080906@huawei.com> <1369223145.3301.308.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:33152 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756946Ab3EWBmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:42:09 -0400
In-Reply-To: <1369223145.3301.308.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/22 19:45, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 16:42 +0800, dingtianhong wrote:
>> commit 00cfec3748 (net: add a synchronize_net() ...) add a synchronize_net()
>> in netdev_rx_handler_unregister() to guarantee the rx_handler  is NULL when
>> rx_handler_data is a non NULL in rcu_read_lock().
>>
>> so the caller should not use netdev_rx_handler_unregister in atomic as it may
>> schedule and sleep, the commit fcd99434f fix the bug in bond release, but the
>> problem is no action to guarantee the rx_handler_data is NULL when bond release,
>> so add synchronize_net() and fix it.
>>
>> This patch adds more comments to netdev_rx_handler_unregister().
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 2 ++
>>  net/core/dev.c                  | 3 +++
>>  2 files changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index d0aade0..592a603 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2007,6 +2007,8 @@ static int __bond_release_one(struct net_device *bond_dev,
>>  	 * for this slave anymore.
>>  	 */
>>  	netdev_rx_handler_unregister(slave_dev);
>> +	synchronize_net();
>> +
>>  	write_lock_bh(&bond->lock);
>>  
> 
> Patch is not needed.
> 
> This was discussed on netdev, please read the archives.
> 
> Its even documented in netdev_rx_handler_unregister(), could you please
> read again commit [1]
> 
> What about you describe the problems you really noticed ?
> 
> [1] commit
> 00cfec37484761a44a3b6f4675a54caa618210ae
> ("net: add a synchronize_net() in netdev_rx_handler_unregister()")
> 
> 

I totally understand the commit [1] and know the problem that you met at that time,
but its not a net core problem, its drivers problem, the function synchronize_net()
need to follow netdev_rx_handler_unregister() even though netdev_rx_handler_unregister()
has its own synchronize_net(), the commit [2] fcd99434f fix drivers problem follow your
opinion, but miss synchronize_net(),so add it.


> 
> .
> 
