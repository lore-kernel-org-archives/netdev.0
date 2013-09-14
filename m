From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [RFC PATCH 2/4] net: Add lower dev list helpers
Date: Sat, 14 Sep 2013 14:27:56 +0200
Message-ID: <20130914122756.GA18327@redhat.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <20130911184647.26914.40440.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com, john.ronciak@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab3INM3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Sep 2013 08:29:48 -0400
Content-Disposition: inline
In-Reply-To: <20130911184647.26914.40440.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 11:46:49AM -0700, John Fastabend wrote:
>This patch adds helpers to traverse the lower dev lists, these
>helpers match the upper dev list implementation.
>
>VSI implementers may use these to track a list of connected netdevs.
>This is easier then having drivers do their own accounting.

Just as a note (as I have quite no idea how ixgbe works) - you are aware
that the upper/lower lists currently include *all* upper/lower devices, and
not only the first-connected ones?

I've seen that you usually verify it, however not always, just a heads-up -
sorry if misread.

I'm also currently trying to get the new patchset included - which would
split the first-tier connected devices from all the 'other' (as in - lower
of a lower and upper of an upper) devices, so that way, I think, it would
be easier/faster for you to use it. It also has a ->private field, easily
accessible, which you could have used instead of/in conjunction with/for
struct ixgbe_vsi_adapter.

[PATCH v2 net-next 00/27] bonding: use neighbours instead of own lists

Here's the patchset.

Hope that helps.

>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
> include/linux/netdevice.h |    8 ++++++++
> net/core/dev.c            |   25 +++++++++++++++++++++++++
> 2 files changed, 33 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 041b42a..4d24b38 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2813,6 +2813,8 @@ extern int		bpf_jit_enable;
> extern bool netdev_has_upper_dev(struct net_device *dev,
> 				 struct net_device *upper_dev);
> extern bool netdev_has_any_upper_dev(struct net_device *dev);
>+extern struct net_device *netdev_lower_get_next_dev_rcu(struct net_device *dev,
>+							struct list_head **iter);
> extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
> 							struct list_head **iter);
>
>@@ -2823,6 +2825,12 @@ extern struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
> 	     upper; \
> 	     upper = netdev_upper_get_next_dev_rcu(dev, &(iter)))
>
>+#define netdev_for_each_lower_dev_rcu(dev, lower, iter) \
>+	for (iter = &(dev)->lower_dev_list, \
>+	     lower = netdev_lower_get_next_dev_rcu(dev, &(iter)); \
>+	     lower; \
>+	     lower = netdev_lower_get_next_dev_rcu(dev, &(iter)))
>+
> extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
> extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
> extern int netdev_upper_dev_link(struct net_device *dev,
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 5c713f2..65ed610 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4468,6 +4468,31 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
> }
> EXPORT_SYMBOL(netdev_master_upper_dev_get);
>
>+/* netdev_lower_get_next_dev_rcu - Get the next dev from lower list
>+ * @dev: device
>+ * @iter: list_head ** of the current position
>+ *
>+ * Gets the next device from the dev's lower list, starting from iter
>+ * position. The caller must hold RTNL/RCU read lock.
>+ */
>+struct net_device *netdev_lower_get_next_dev_rcu(struct net_device *dev,
>+						 struct list_head **iter)
>+{
>+	struct netdev_adjacent *lower;
>+
>+	WARN_ON_ONCE(!rcu_read_lock_held());
>+
>+	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
>+
>+	if (&lower->list == &dev->lower_dev_list)
>+		return NULL;
>+
>+	*iter = &lower->list;
>+
>+	return lower->dev;
>+}
>+EXPORT_SYMBOL(netdev_lower_get_next_dev_rcu);
>+
> /* netdev_upper_get_next_dev_rcu - Get the next dev from upper list
>  * @dev: device
>  * @iter: list_head ** of the current position
>
