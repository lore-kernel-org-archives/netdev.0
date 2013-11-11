From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 5/10] bonding: create bond_first_slave_rcu()
Date: Mon, 11 Nov 2013 13:59:17 +0100
Message-ID: <20131111125917.GX19702@redhat.com>
References: <5280CF59.5090202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753728Ab3KKNBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 08:01:39 -0500
Content-Disposition: inline
In-Reply-To: <5280CF59.5090202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 08:36:41PM +0800, Ding Tianhong wrote:
>The bond_first_slave_rcu() will be used to instead of bond_first_slave()
>in rcu_read_lock().
>
>So move the struct netdev_adjacent to the netdevice.h and make the
>bond_first_slave_rcu() could use the struct.

The whole point in netdev_adjacent functions was to hide it from the users
who wanted to use it directly. See

http://www.spinics.net/lists/netdev/msg248026.html

for reference. Please try to avoid that.

>
>Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bonding.h |  9 +++++++++
> include/linux/netdevice.h     | 16 ++++++++++++++++
> net/core/dev.c                | 16 ----------------
> 3 files changed, 25 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 77a07a1..5d37606 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -91,6 +91,15 @@
> 		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
> 		NULL)
>
>+/* Caller must have rcu_read_lock */
>+#define bond_first_slave_rcu(bond) \
>+	({struct list_head *__ptr = (bond_slave_list(bond)); \
>+	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
>+	 likely(__ptr != __next) ? \
>+	 list_entry_rcu(__next, struct netdev_adjacent, list)->private : \
>+		NULL; \
>+	 })
>+
> #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
> #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 15fa01c..7ca0fc8 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2839,6 +2839,22 @@ extern int		netdev_tstamp_prequeue;
> extern int		weight_p;
> extern int		bpf_jit_enable;
>
>+struct netdev_adjacent {
>+	struct net_device *dev;
>+
>+	/* upper master flag, there can only be one master device per list */
>+	bool master;
>+
>+	/* counter for the number of times this device was added to us */
>+	u16 ref_nr;
>+
>+	/* private field for the users */
>+	void *private;
>+
>+	struct list_head list;
>+	struct rcu_head rcu;
>+};
>+
> bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
> bool netdev_has_any_upper_dev(struct net_device *dev);
> struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 8ffc52e..bcc5001 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4377,22 +4377,6 @@ softnet_break:
> 	goto out;
> }
>
>-struct netdev_adjacent {
>-	struct net_device *dev;
>-
>-	/* upper master flag, there can only be one master device per list */
>-	bool master;
>-
>-	/* counter for the number of times this device was added to us */
>-	u16 ref_nr;
>-
>-	/* private field for the users */
>-	void *private;
>-
>-	struct list_head list;
>-	struct rcu_head rcu;
>-};
>-
> static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
> 						     struct net_device *adj_dev,
> 						     struct list_head *adj_list)
>-- 
>1.8.2.1
>
>
>
