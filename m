From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 5/6] bonding: restructure and add rcu for
 bond_for_each_slave_next()
Date: Wed, 4 Sep 2013 12:35:40 +0200
Message-ID: <20130904103540.GP1992@redhat.com>
References: <522700EF.3000702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755014Ab3IDKhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 06:37:03 -0400
Content-Disposition: inline
In-Reply-To: <522700EF.3000702@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 05:44:15PM +0800, Ding Tianhong wrote:
...snip...
>+/* Check whether the slave is the only one in bond */
>+#define bond_is_only_slave(bond, pos) \
>+	(((pos)->list.prev == &(bond)->slave_list) && \
>+				    ((pos)->list.next == &(bond)->slave_list))

Could be done without pos at all -

!list_empty(&(bond)->slave_list) && \
&(bond)->slave_list.next == &(bond)->slave_list.prev

If we have only one slave and pos is NOT our slave then... well.. we have
big troubles.

>+
> /**
>  * bond_for_each_slave_from - iterate the slaves list from a starting point
>  * @bond:	the bond holding this list.
>  * @pos:	current slave.
>- * @cnt:	counter for max number of moves
>  * @start:	starting point.
>  *
>  * Caller must hold bond->lock
>  */
>-#define bond_for_each_slave_from(bond, pos, cnt, start) \
>-	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
>-	     cnt++, pos = bond_next_slave(bond, pos))
>+#define bond_for_each_slave_from(bond, pos, start) \
>+	for (pos = start; pos && (bond_is_only_slave(bond, start) ? \
>+	    &pos->list != &bond->slave_list : \
>+	    &pos->list != &start->list); bond_is_only_slave(bond, start) ? \
>+	    (pos = list_entry(pos->list.next, typeof(*pos), list)) : \
>+	    (pos = bond_next_slave(bond, pos)))

Did you check that?

pos = slave1 (bond has more than one slave);
pos && &pos->list != &slave1->list - false.

We won't ever enter this loop if we have >1 slaves.

I don't understand this at all.

>+
>+/**
>+ * bond_for_each_slave_from_rcu - iterate the slaves list from a starting point
>+ * @bond:	the bond holding this list.
>+ * @pos:	current slave.
>+ * @start:	starting point.
>+ *
>+ * Caller must hold rcu_read_lock
>+ */
>+#define bond_for_each_slave_from_rcu(bond, pos, start) \
>+	for (pos = start; pos && (bond_is_only_slave(bond, start) ? \
>+	    &pos->list != &bond->slave_list : \
>+	    &pos->list != &start->list); bond_is_only_slave(bond, start) ? \
>+	    (pos = list_entry_rcu(pos->list.next, typeof(*pos), list)) : \
>+	    (pos = bond_next_slave_rcu(bond, pos)))

Ditto as bond_for_each_slave_from() and, also, see my comment about RCU
from patch 1.

>
> /**
>  * bond_for_each_slave - iterate over all slaves
>-- 
>1.8.2.1
>
>
>
