From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/6] bonding: simplify and use RCU
 protection for 3ad xmit path
Date: Wed, 04 Sep 2013 12:25:12 -0400 (EDT)
Message-ID: <20130904.122512.1633906087065495330.davem@davemloft.net>
References: <522700D1.5060805@huawei.com>
	<20130904101823.GO1992@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757086Ab3IDQZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 12:25:16 -0400
In-Reply-To: <20130904101823.GO1992@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed, 4 Sep 2013 12:18:24 +0200

> On Wed, Sep 04, 2013 at 05:43:45PM +0800, Ding Tianhong wrote:
> ...snip...
>>+/**
>>+ * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an
>>empty list
>>+ * Caller must hold rcu_read_lock
>>+ */
>>+#define bond_first_slave_rcu(bond) \
>>+	list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>>+#define bond_last_slave_rcu(bond) \
>>+	(list_empty(&(bond)->slave_list) ? NULL : \
>>+ bond_to_slave_rcu((bond)->slave_list.prev))
> 
> Here, bond_last_slave_rcu() is racy. The list can be non-empty when
> list_empty() is verified, however afterwards it might become empty,
> when
> you call bond_to_slave_rcu(), and thus you'll get
> bond_to_slave(bond->slave_list) in the result, which is not a slave.
> 
> Take a look at list_first_or_null_rcu() for a reference. The main idea
> is
> that it first gets the ->next pointer, with RCU protection, and then
> verifies if it's the list head or not, and if not - it gets the
> container
> already. This way the ->next pointer won't get away.
> 
> These kind of bugs are really rare, but are *EXTREMELY* hard to debug.

I agree with this analysis.

Ding, "rcu_read_lock()" doesn't "lock" anything.  It's just a memory
barrier.

All the list can still change on you asynchronously to your accesses.

That's why list_first_or_null_rcu() is so carefully arranged.
Therefore, you must make similar accomodations.
