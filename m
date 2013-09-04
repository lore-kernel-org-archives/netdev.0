From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Wed, 4 Sep 2013 12:18:24 +0200
Message-ID: <20130904101823.GO1992@redhat.com>
References: <522700D1.5060805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762286Ab3IDKTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 06:19:54 -0400
Content-Disposition: inline
In-Reply-To: <522700D1.5060805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 05:43:45PM +0800, Ding Tianhong wrote:
...snip...
>+/**
>+ * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an empty list
>+ * Caller must hold rcu_read_lock
>+ */
>+#define bond_first_slave_rcu(bond) \
>+	list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>+#define bond_last_slave_rcu(bond) \
>+	(list_empty(&(bond)->slave_list) ? NULL : \
>+						bond_to_slave_rcu((bond)->slave_list.prev))

Here, bond_last_slave_rcu() is racy. The list can be non-empty when
list_empty() is verified, however afterwards it might become empty, when
you call bond_to_slave_rcu(), and thus you'll get
bond_to_slave(bond->slave_list) in the result, which is not a slave.

Take a look at list_first_or_null_rcu() for a reference. The main idea is
that it first gets the ->next pointer, with RCU protection, and then
verifies if it's the list head or not, and if not - it gets the container
already. This way the ->next pointer won't get away.

These kind of bugs are really rare, but are *EXTREMELY* hard to debug.

>+
> #define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
> #define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
>
>@@ -93,6 +106,15 @@
> 	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
> 					  bond_to_slave((pos)->list.prev))
>
>+/* Since bond_first/last_slave_rcu can return NULL, these can return NULL too */
>+#define bond_next_slave_rcu(bond, pos) \
>+	(bond_is_last_slave(bond, pos) ? bond_first_slave_rcu(bond) : \
>+					 bond_to_slave_rcu((pos)->list.next))
>+
>+#define bond_prev_slave_rcu(bond, pos) \
>+	(bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
>+					  bond_to_slave_rcu((pos)->list.prev))
>+

These two are also racy. bond_is_last/first_slave() is not rcu-ified, and
thus you can't rely on it without proper locking. Same ideas apply as per
bond_first_slave_rcu().
