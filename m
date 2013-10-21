From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 21 Oct 2013 14:41:44 +0200
Message-ID: <20131021124144.GD692@redhat.com>
References: <5264ECBC.2090208@huawei.com>
 <20131021091336.GB692@redhat.com>
 <5264F397.50608@huawei.com>
 <20131021093549.GC692@redhat.com>
 <52651ECB.1080901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239Ab3JUMqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 08:46:01 -0400
Content-Disposition: inline
In-Reply-To: <52651ECB.1080901@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 08:32:11PM +0800, Ding Tianhong wrote:
>On 2013/10/21 17:35, Veaceslav Falico wrote:
>> On Mon, Oct 21, 2013 at 05:27:51PM +0800, Ding Tianhong wrote:
>>> On 2013/10/21 17:13, Veaceslav Falico wrote:
>>>> On Mon, Oct 21, 2013 at 04:58:36PM +0800, Ding Tianhong wrote:
>>>>> Hi:
>>>>>
>>>>> The Patch Set will remove the invalid lock for bond work queue and replace it
>>>>> with rtnl lock, as read lock for bond could not protect slave list any more.
>>>>
>>>> rtnl lock is a lot more expensive than bond lock, and not only for bond,
>>>> but for all the networking stack.
>>>>
>>>> Why is the bond->lock invalid? It correctly protects slaves from being
>>>> modified concurrently.
>>>>
>>>> I don't see the point in this patchset.
>>>>
>>>
>>> yes, rtnl lock is a big lock, but I think bond->lock could not protect
>>> bond_for_each_slave any more, am I miss something?
>>
>> Why can't it protect bond_for_each_slave()?
>>
>
>bond_master_upper_dev_link() and bond_upper_dev_unlink() was only in rtnl lock,
>bond_for_each_slave may changed while loop in bond read lock, but it sees that
>nothing serious will happen yet.
>Maybe I miss something.

Even if it is unsafe to use bond_for_each_slave() while holding bond->lock
- it means that we must protect the list by locking the
bond_upper_dev_(un)link() via bond->lock, but not by removing bond->lock
from everywhere where it is now. And I'm not that sure if it's safe or not.

>
>Ding
>
>
>>>
>>> Ding
>>>
>>>>>
>>>>> Ding Tianhong (5):
>>>>>  bonding: remove bond read lock for bond_mii_monitor()
>>>>>  bonding: remove bond read lock for bond_alb_monitor()
>>>>>  bonding: remove bond read lock for bond_loadbalance_arp_mon()
>>>>>  bonding: remove bond read lock for bond_activebackup_arp_mon()
>>>>>  bonding: remove bond read lock for bond_3ad_state_machine_handler()
>>>>>
>>>>> drivers/net/bonding/bond_3ad.c  |   9 ++--
>>>>> drivers/net/bonding/bond_alb.c  |  20 ++------
>>>>> drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
>>>>> 3 files changed, 40 insertions(+), 89 deletions(-)
>>>>>
>>>>> --
>>>>> 1.8.2.1
>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>> .
>>
>
>
