From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Fri, 8 Aug 2014 03:26:33 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1408080259370.14535@ws.cisco>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>  <1406634039-15030-3-git-send-email-_govind@gmx.com>  <20140730.175306.483788306179792581.davem@davemloft.net>  <1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
 <20140802072607.6eec3334@haswell.linuxnetplumber.net> <1406991970.30258.47.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, _govind@gmx.com,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53579 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbaHGV44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2014 17:56:56 -0400
In-Reply-To: <1406991970.30258.47.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2 Aug 2014, Ben Hutchings wrote:

> On Sat, 2014-08-02 at 07:26 -0700, Stephen Hemminger wrote:
> [...]
>> Looks like you just reinvented netlink :-)
>
> Badly? ;-)
>
>> I wish ethtool would die.
>> It has fixed size static structures and has no notification mechanism.
>>
>> If we could just get all the ethtool features into netlink, under IF_LINK
>> then most of this could go away.
>
> It doesn't go away, it just stops growing.
>
> I know we've talked about this before and I agree in principle.  *But*
> neither you nor anyone else proposed how to get there from here.
>

If netlink is the way to go, I think we should stop adding new features to
ethtool and add new features only through netlink.

Some thing like this.

* Create new genetlink for ethtool.
* define doit function for set/get driver parameters.
* For setting ethtool parameters, user program sends nlmsg with only variable
   that needs to be set. If some attr is not know to driver, it return error.
* For getting ethtool parameters user program sends nlmsg with get parameters
   type, driver sends nlmsg back with only relevant value. Other are assumed 0
   by user program
* This should provide backward and forward compatibility, and also should
   allow us to add new variables.

What do you guys think?

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
  drivers/net/ethernet/cisco/enic/enic.h         |   1 +
  drivers/net/ethernet/cisco/enic/enic_ethtool.c |  33 ++++++++
  drivers/net/ethernet/cisco/enic/enic_main.c    |   1 +
  include/linux/netdevice.h                      |   2 +
  include/uapi/linux/etnetlink.h                 |  29 +++++++
  net/core/Makefile                              |   2 +-
  net/core/etnetlink.c                           | 109 +++++++++++++++++++++++++
  7 files changed, 176 insertions(+), 1 deletion(-)
  create mode 100644 include/uapi/linux/etnetlink.h
  create mode 100644 net/core/etnetlink.c

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 5ba5ad0..1e3c709 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -246,5 +246,6 @@ int enic_sriov_enabled(struct enic *enic);
  int enic_is_valid_vf(struct enic *enic, int vf);
  int enic_is_dynamic(struct enic *enic);
  void enic_set_ethtool_ops(struct net_device *netdev);
+void enic_set_etnl_ops(struct net_device *netdev);

  #endif /* _ENIC_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 523c9ce..90662f2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -18,6 +18,8 @@

  #include <linux/netdevice.h>
  #include <linux/ethtool.h>
+#include <net/genetlink.h>
+#include <linux/skbuff.h>

  #include "enic_res.h"
  #include "enic.h"
@@ -393,7 +395,38 @@ static const struct ethtool_ops enic_ethtool_ops = {
  	.get_rxnfc = enic_get_rxnfc,
  };

+int enic_buffparam_set(struct net_device *dev, struct sk_buff *skb,
+		       struct genl_info *info)
+{
+	struct enic *enic = netdev_priv(dev);
+
+	if (info->attrs[ETNL_RX_COPYBREAK]) {
+		enic->rx_copybreak = nla_get_u32(info->attrs[ETNL_RX_COPYBREAK]);
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+int enic_buffparam_get(struct net_device *dev, struct sk_buff *skb,
+			struct genl_info *info)
+{
+	struct enic *enic = netdev_priv(dev);
+
+	return nla_put_u32(skb, ETNL_RX_COPYBREAK, enic->rx_copybreak);
+}
+
+static const struct etnl_ops enic_etnl_ops = {
+	.buffparam_set = enic_buffparam_set,
+	.buffparam_get = enic_buffparam_get,
+};
+
  void enic_set_ethtool_ops(struct net_device *netdev)
  {
  	netdev->ethtool_ops = &enic_ethtool_ops;
  }
+
+void enic_set_etnl_ops(struct net_device *netdev)
+{
+	netdev->etnl_ops = &enic_etnl_ops;
+}
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b7e69fd..aa22277 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2540,6 +2540,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)

  	netdev->watchdog_timeo = 2 * HZ;
  	enic_set_ethtool_ops(netdev);
+	enic_set_etnl_ops(netdev);

  	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
  	if (ENIC_SETTING(enic, LOOP)) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3837739..cfc06bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -50,6 +50,7 @@
  #include <linux/netdev_features.h>
  #include <linux/neighbour.h>
  #include <uapi/linux/netdevice.h>
+#include <uapi/linux/etnetlink.h>

  struct netpoll_info;
  struct device;
@@ -1496,6 +1497,7 @@ struct net_device {
  #endif
  	const struct net_device_ops *netdev_ops;
  	const struct ethtool_ops *ethtool_ops;
+	const struct etnl_ops *etnl_ops;
  	const struct forwarding_accel_ops *fwd_ops;

  	const struct header_ops *header_ops;
diff --git a/include/uapi/linux/etnetlink.h b/include/uapi/linux/etnetlink.h
new file mode 100644
index 0000000..653b341
--- /dev/null
+++ b/include/uapi/linux/etnetlink.h
@@ -0,0 +1,29 @@
+#ifndef __NET_CORE_ETNETLINK_H
+#define __NET_CORE_ETNETLINK_H
+
+#include <linux/skbuff.h>
+#include <net/genetlink.h>
+#define ETNL_NAME "etnetlink"
+
+struct etnl_ops {
+	int (*buffparam_set)(struct net_device *netdev, struct sk_buff *skb,
+			     struct genl_info *info);
+	int (*buffparam_get)(struct net_device *netdev, struct sk_buff *skb,
+			     struct genl_info *info);
+};
+
+enum etnl_attr {
+	ETNL_BUFFPARAM_SET = 0,
+	ETNL_BUFFPARAM_GET = 1,
+};
+
+enum etnl_buffparam_enum {
+	ETNL_INVALID = 0,
+	ETNL_IF_INDEX = 1,
+	ETNL_RX_COPYBREAK = 2,
+	ETNL_BUFFPARAM_MAX,
+};
+
+#define ETNL_ATTR_MAX ETNL_BUFFPARAM_MAX + 1
+
+#endif /* __NET_CORE_ETNETLINK_H */
diff --git a/net/core/Makefile b/net/core/Makefile
index 71093d9..49bb55c 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o

  obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
  			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o tso.o
+			sock_diag.o dev_ioctl.o tso.o etnetlink.o

  obj-$(CONFIG_XFRM) += flow.o
  obj-y += net-sysfs.o
diff --git a/net/core/etnetlink.c b/net/core/etnetlink.c
new file mode 100644
index 0000000..2550a9d
--- /dev/null
+++ b/net/core/etnetlink.c
@@ -0,0 +1,109 @@
+#include <linux/if.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/notifier.h>
+#include <linux/device.h>
+#include <linux/etherdevice.h>
+#include <linux/sched.h>
+#include <net/genetlink.h>
+
+#include <uapi/linux/etnetlink.h>
+
+static struct genl_family etnl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = ETNL_NAME,
+	.version = 1,
+	.maxattr = ETNL_ATTR_MAX,
+	.netnsok = true,
+};
+
+int etnl_buffparam_set(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net_device *netdev = NULL;
+	u32 if_index;
+	int ret = -EOPNOTSUPP;
+
+	if (!info->attrs[ETNL_IF_INDEX]) {
+		return -EINVAL;
+	} else {
+		if_index = nla_get_u32(info->attrs[ETNL_IF_INDEX]);
+		netdev = dev_get_by_index(net, if_index);
+		if (!netdev)
+			return -EINVAL;
+	}
+	if (netdev->etnl_ops && netdev->etnl_ops->buffparam_set) {
+		ret = netdev->etnl_ops->buffparam_set(netdev, skb, info);
+	}
+	dev_put(netdev);
+	return ret;
+}
+
+int etnl_buffparam_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *skb_reply;
+	struct net *net = genl_info_net(info);
+	struct net_device *netdev = NULL;
+	void *reply;
+	int if_index, ret;
+
+	if (!info->attrs[ETNL_IF_INDEX]) {
+		return -EINVAL;
+	} else {
+		if_index = nla_get_u32(info->attrs[ETNL_IF_INDEX]);
+		netdev = dev_get_by_index(net, if_index);
+		if (!netdev)
+			return -EINVAL;
+	}
+	skb_reply = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb_reply)
+		return -ENOMEM;
+	reply = genlmsg_put_reply(skb_reply, info, &etnl_family, 0,
+				  info->genlhdr->cmd);
+	if (!reply)
+		goto nla_put_failure;
+
+	if (netdev->etnl_ops && netdev->etnl_ops->buffparam_get)
+		if (netdev->etnl_ops->buffparam_get(netdev, skb_reply, info))
+			goto nla_put_failure;
+
+	genlmsg_end(skb_reply, reply);
+	return genlmsg_reply(skb_reply, info);
+
+nla_put_failure:
+	ret = -EMSGSIZE;
+	nlmsg_free(skb_reply);
+	return ret;
+}
+
+static const struct nla_policy etnl_buffparam_policy[ETNL_ATTR_MAX] = {
+	[ETNL_IF_INDEX]		= { .type = NLA_U32 },
+	[ETNL_RX_COPYBREAK]	= { .type = NLA_U32 },
+};
+
+static const struct genl_ops etnl_ops[] = {
+	{
+		.cmd = ETNL_BUFFPARAM_SET,
+		.doit = etnl_buffparam_set,
+		.policy = etnl_buffparam_policy,
+	},
+	{
+		.cmd = ETNL_BUFFPARAM_GET,
+		.doit = etnl_buffparam_get,
+		.policy = etnl_buffparam_policy,
+	},
+};
+
+static int __init etnl_init(void)
+{
+	return genl_register_family_with_ops(&etnl_family, etnl_ops);
+}
+//subsys_initcall(etnl_init);
+late_initcall(etnl_init);
+
+static void __exit etnl_exit(void)
+{
+}
+module_exit(etnl_exit);
-- 
2.0.4
