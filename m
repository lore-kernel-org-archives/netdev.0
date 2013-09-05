From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Thu, 5 Sep 2013 10:06:03 +0800
Message-ID: <5227E70B.5040407@huawei.com>
References: <522700D1.5060805@huawei.com> <20130904101823.GO1992@redhat.com> <20130904.122512.1633906087065495330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <vfalico@redhat.com>, <fubar@us.ibm.com>, <andy@greyhouse.net>,
	<nikolay@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20525 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab3IECGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 22:06:25 -0400
In-Reply-To: <20130904.122512.1633906087065495330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/9/5 0:25, David Miller wrote:
> From: Veaceslav Falico <vfalico@redhat.com>
> Date: Wed, 4 Sep 2013 12:18:24 +0200
> 
>> On Wed, Sep 04, 2013 at 05:43:45PM +0800, Ding Tianhong wrote:
>> ...snip...
>>> +/**
>>> + * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an
>>> empty list
>>> + * Caller must hold rcu_read_lock
>>> + */
>>> +#define bond_first_slave_rcu(bond) \
>>> +	list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>>> +#define bond_last_slave_rcu(bond) \
>>> +	(list_empty(&(bond)->slave_list) ? NULL : \
>>> + bond_to_slave_rcu((bond)->slave_list.prev))
>>
>> Here, bond_last_slave_rcu() is racy. The list can be non-empty when
>> list_empty() is verified, however afterwards it might become empty,
>> when
>> you call bond_to_slave_rcu(), and thus you'll get
>> bond_to_slave(bond->slave_list) in the result, which is not a slave.
>>
>> Take a look at list_first_or_null_rcu() for a reference. The main idea
>> is
>> that it first gets the ->next pointer, with RCU protection, and then
>> verifies if it's the list head or not, and if not - it gets the
>> container
>> already. This way the ->next pointer won't get away.
>>
>> These kind of bugs are really rare, but are *EXTREMELY* hard to debug.
> 
> I agree with this analysis.
> 
> Ding, "rcu_read_lock()" doesn't "lock" anything.  It's just a memory
> barrier.
> 
> All the list can still change on you asynchronously to your accesses.
> 
> That's why list_first_or_null_rcu() is so carefully arranged.
> Therefore, you must make similar accomodations.
> 
> 
> 

yes, after a long time thinking, I found the problem and know how to do next, repair and resend it later.

> .
> 
