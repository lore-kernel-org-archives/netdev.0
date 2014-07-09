From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 9 Jul 2014 12:24:41 +0200
Message-ID: <20140709102441.GB1227@redhat.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbaGIK1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 06:27:45 -0400
Content-Disposition: inline
In-Reply-To: <1404868198-24839-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
>In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
>group are selected based on the hash distribution. This does not
>exclude dead links which are part of the bond. Also if there is a
>temporary link event which brings down the interface, packets
>hashed on that interface would be dropped too.
>
>This patch fixes these issues and distributes flows across the
>UP links only. Also the array construction of links which are
>capable of sending packets happen in the control path leaving
>only link-selection duing the data-path.
>
>One possible side effect of this is - at a link event; all
>flows will be shuffled to get good distribution. But impact of
>this should be minimum with the assumption that a member or
>members of the bond group are not available is a very temporary
>situation.

Good one, it indeed will speed up things/fix it.

Some comments:

I didn't see how you handle the case when a slave is removed (i.e.
released) from bonding.

>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
...snip...
>+static int bond_tlb_update_slave_arr(struct bonding *bond)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct slave *tx_slave;
>+	struct list_head *iter;
>+	struct tlb_up_slave *new_arr, *old_arr;
>+
>+	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>+			  GFP_KERNEL);
>+	if (!new_arr)
>+		return -ENOMEM;
>+
>+	bond_for_each_slave(bond, tx_slave, iter) {
>+		if (bond_slave_can_tx(tx_slave))
>+			new_arr->arr[new_arr->count++] = tx_slave;
>+	}
>+
>+	spin_lock(&bond_info->slave_arr_lock);

I don't think you can re-enter bond_alb_handle_link_change(), as it's
protected either by rtnl or write-lock curr_active_slave.

>+	old_arr = bond_info->slave_arr;
>+	rcu_assign_pointer(bond_info->slave_arr, new_arr);
>+	spin_unlock(&bond_info->slave_arr_lock);
>+	if (old_arr)
>+		kfree_rcu(old_arr, rcu);
>+
>+	return 0;
>+}
...snip...
