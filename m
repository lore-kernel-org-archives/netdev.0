From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 11:37:18 +0200
Message-ID: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:57146 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbcD0Jjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 05:39:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the support of the 6WIND SHULTI switch. It is a software
switch doing L2 forwarding.

This first version implements the minimum needed to get the device working.
It also implements, via switchdev and rtnetlink, bridge forwarding offload,
including FDB static entries, FDB learning and FDB ageing.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/6wind/Kconfig                 |   20 +
 drivers/net/ethernet/6wind/Makefile                |    6 +
 drivers/net/ethernet/6wind/shulti/Kconfig          |   12 +
 drivers/net/ethernet/6wind/shulti/Makefile         |    6 +
 drivers/net/ethernet/6wind/shulti/shulti_core.c    | 1164 ++++++++++++++++++++
 drivers/net/ethernet/6wind/shulti/shulti_private.h |   68 ++
 drivers/net/ethernet/6wind/shulti/shulti_swdev.c   |  233 ++++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 include/linux/netdevice.h                          |    4 +
 include/uapi/linux/Kbuild                          |    1 +
 include/uapi/linux/shulti.h                        |   87 ++
 13 files changed, 1612 insertions(+)
 create mode 100644 drivers/net/ethernet/6wind/Kconfig
 create mode 100644 drivers/net/ethernet/6wind/Makefile
 create mode 100644 drivers/net/ethernet/6wind/shulti/Kconfig
 create mode 100644 drivers/net/ethernet/6wind/shulti/Makefile
 create mode 100644 drivers/net/ethernet/6wind/shulti/shulti_core.c
 create mode 100644 drivers/net/ethernet/6wind/shulti/shulti_private.h
 create mode 100644 drivers/net/ethernet/6wind/shulti/shulti_swdev.c
 create mode 100644 include/uapi/linux/shulti.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 37691abd894c..608ab3fe0eea 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -166,6 +166,15 @@ L:	linux-hams@vger.kernel.org
 S:	Maintained
 F:	drivers/net/hamradio/6pack.c
 
+6WIND NETWORK DRIVERS
+M: 	Nicolas Dichtel <nicolas.dichtel@6wind.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+W:	http://www.6wind.com/
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+F:	include/uapi/linux/shulti.h
+F:	drivers/net/ethernet/6wind/
+
 8169 10/100/1000 GIGABIT ETHERNET DRIVER
 M:	Realtek linux nic maintainers <nic_swsd@realtek.com>
 L:	netdev@vger.kernel.org
diff --git a/drivers/net/ethernet/6wind/Kconfig b/drivers/net/ethernet/6wind/Kconfig
new file mode 100644
index 000000000000..495e692a1547
--- /dev/null
+++ b/drivers/net/ethernet/6wind/Kconfig
@@ -0,0 +1,20 @@
+#
+# 6WIND drivers configuration
+#
+
+config NET_VENDOR_6WIND
+	bool "6WIND devices"
+	default y
+	---help---
+	  If you have a network device belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about 6WIND devices. If you say Y, you will be asked
+	  for your specific device in the following questions.
+
+if NET_VENDOR_6WIND
+
+source "drivers/net/ethernet/6wind/shulti/Kconfig"
+
+endif # NET_VENDOR_6WIND
diff --git a/drivers/net/ethernet/6wind/Makefile b/drivers/net/ethernet/6wind/Makefile
new file mode 100644
index 000000000000..7375a2c6e09e
--- /dev/null
+++ b/drivers/net/ethernet/6wind/Makefile
@@ -0,0 +1,6 @@
+#
+#
+# Makefile for the 6WIND device drivers.
+#
+
+obj-$(CONFIG_6WIND_SHULTI) += shulti/
diff --git a/drivers/net/ethernet/6wind/shulti/Kconfig b/drivers/net/ethernet/6wind/shulti/Kconfig
new file mode 100644
index 000000000000..c7daa8461e35
--- /dev/null
+++ b/drivers/net/ethernet/6wind/shulti/Kconfig
@@ -0,0 +1,12 @@
+#
+# 6WIND SHULTI driver configuration
+#
+
+config 6WIND_SHULTI
+	tristate "6WIND SHULTI support"
+	depends on NET_SWITCHDEV
+	---help---
+	  This driver supports 6WIND SHULTI switch device.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called shulti.
diff --git a/drivers/net/ethernet/6wind/shulti/Makefile b/drivers/net/ethernet/6wind/shulti/Makefile
new file mode 100644
index 000000000000..faf4ffe8aac5
--- /dev/null
+++ b/drivers/net/ethernet/6wind/shulti/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the 6WIND SHULTI driver.
+#
+
+obj-$(CONFIG_6WIND_SHULTI)	+= shulti.o
+shulti-objs			:= shulti_core.o shulti_swdev.o
diff --git a/drivers/net/ethernet/6wind/shulti/shulti_core.c b/drivers/net/ethernet/6wind/shulti/shulti_core.c
new file mode 100644
index 000000000000..f5de0b6a946e
--- /dev/null
+++ b/drivers/net/ethernet/6wind/shulti/shulti_core.c
@@ -0,0 +1,1164 @@
+/*
+ * Copyright (c) 2016 6WIND S.A.
+ * Copyright (c) 2016 Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+#include <linux/completion.h>
+#include <linux/rtnetlink.h>
+#include <linux/shulti.h>
+#include <net/genetlink.h>
+#include <net/netns/generic.h>
+#include <net/rtnetlink.h>
+#include <net/switchdev.h>
+
+#include "shulti_private.h"
+
+#define DRV_VERSION	"1.0"
+
+static unsigned int shulti_tx_queues;
+static unsigned int shulti_rx_queues;
+
+static int shulti_net_id __read_mostly;
+struct shulti_net *shulti_pernet(struct net *net)
+{
+	return net_generic(net, shulti_net_id);
+}
+
+struct shulti_priv *__shulti_lookup_port(struct shulti_swdev *swdev,
+					 u32 swdev_portid)
+{
+	struct shulti_priv *port = NULL;
+
+	list_for_each_entry_rcu(port, &swdev->port_list, list)
+		if (port->swdev_portid == swdev_portid)
+			return port;
+
+	return NULL;
+}
+
+/* genl functions */
+struct genl_family shulti_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct shulti_genl_hdr),
+	.name = SHULTI_NAME,
+	.version = 1,
+	.maxattr = SHULTI_A_MAX,
+	.netnsok = true,
+};
+
+static const struct genl_multicast_group shulti_mcgrp[] = {
+	{ .name = SHULTI_NAME, },
+};
+
+static const struct nla_policy shulti_genl_policy[SHULTI_A_MAX + 1] = {
+	[SHULTI_A_NL_PORTIDS]	= { .type = NLA_NESTED },
+	[SHULTI_A_SWDEV_PORTID]	= { .type = NLA_U32 },
+	[SHULTI_A_RX_QUEUES]	= { .type = NLA_U32 },
+	[SHULTI_A_ERRCODE]	= { .type = NLA_S32 },
+	[SHULTI_A_IFINDEX]	= { .type = NLA_S32 },
+	[SHULTI_A_LINK_STATUS]	= { .type = NLA_U8 },
+	[SHULTI_A_STATS]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[SHULTI_A_VLAN_VID]	= { .len = sizeof(struct shulti_vlan_vid) },
+	[SHULTI_A_DRVINFO]	= { .len = sizeof(struct ethtool_drvinfo) },
+	[SHULTI_A_SETTINGS]	= { .len = sizeof(struct ethtool_cmd) },
+	[SHULTI_A_RX_MODES]	= { .type = NLA_U32 },
+	[SHULTI_A_UC_ADDR]	= { .len = ETH_ALEN },
+	[SHULTI_A_MC_ADDR]	= { .len = ETH_ALEN },
+	[SHULTI_A_STP_STATE]	= { .type = NLA_U8 },
+	[SHULTI_A_BR_STATE_LEARNING] = { .type = NLA_U8 },
+	[SHULTI_A_BR_AGEING_TIME] = { .type = NLA_U32 },
+	[SHULTI_A_BR_FDB]	= { .len = sizeof(struct shulti_br_fdb) },
+};
+
+static int shulti_set_tx_queues(struct shulti_swdev *swdev, unsigned int num)
+{
+	/* rtnl get_num_tx_queues ops is global to the module hence this info
+	 * is global.
+	 */
+	if (shulti_tx_queues && num &&
+	    shulti_tx_queues != num)
+		return -EINVAL;
+
+	swdev->data_nl_portids_cnt = num;
+	shulti_tx_queues = num;
+	return 0;
+}
+
+static void shulti_destroy_port_rcu(struct rcu_head *head)
+{
+	struct shulti_priv *port = container_of(head, struct shulti_priv,
+						rcu);
+	struct net_device *dev = priv2netdev(port);
+
+	port->swdev_id = 0;
+	port->swdev_portid = 0;
+	port->genl_req.portid = 0;
+	INIT_LIST_HEAD_RCU(&port->list);
+	shulti_switchdev_fini(dev);
+	dev_put(dev);
+}
+
+static void __shulti_release_swdev_port(struct shulti_priv *port)
+{
+	list_del_rcu(&port->list);
+	call_rcu(&port->rcu, shulti_destroy_port_rcu);
+}
+
+static void __shulti_release_swdev(struct shulti_swdev *swdev)
+{
+	struct shulti_priv *port, *tmp;
+	LIST_HEAD(swdev_port_list);
+
+	ASSERT_RTNL();
+
+	/* Ensure that it's not already freed */
+	if (!swdev->data_nl_portids)
+		return;
+
+	list_for_each_entry_safe(port, tmp, &swdev->port_list, list) {
+		__shulti_release_swdev_port(port);
+		unregister_netdevice_queue(priv2netdev(port), &swdev_port_list);
+	}
+	unregister_netdevice_many(&swdev_port_list);
+
+	swdev->ctrl_nl_portid = 0;
+	swdev->swdev_id = 0;
+	shulti_set_tx_queues(swdev, 0);
+	shulti_rx_queues = 0;
+	kfree(swdev->data_nl_portids);
+	swdev->data_nl_portids = NULL;
+	module_put(THIS_MODULE);
+}
+
+/* genl commands */
+static int shulti_genl_bind(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_genl_hdr *hdr = info->userhdr;
+	int err = -EAGAIN;
+	size_t len;
+
+	if (!info->attrs[SHULTI_A_RX_QUEUES] ||
+	    !info->attrs[SHULTI_A_NL_PORTIDS])
+		return -EINVAL;
+
+	if (!try_module_get(THIS_MODULE))
+		return -EAGAIN;
+
+	if (!rtnl_trylock())
+		goto err_mod;
+
+	/* Only one instance is allowed for now. */
+	err = -EBUSY;
+	if (pernet->swdev.swdev_id)
+		goto err_lock;
+
+	/* rtnl get_num_rx_queues ops is global to the module hence this info
+	 * is global.
+	 */
+	err = -EINVAL;
+	if (shulti_rx_queues &&
+	    shulti_rx_queues != nla_get_u32(info->attrs[SHULTI_A_RX_QUEUES]))
+		goto err_lock;
+	shulti_rx_queues = nla_get_u32(info->attrs[SHULTI_A_RX_QUEUES]);
+
+	len = nla_len(info->attrs[SHULTI_A_NL_PORTIDS]);
+	pernet->swdev.data_nl_portids = kmalloc(len, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!pernet->swdev.data_nl_portids)
+		goto err_lock;
+	err = shulti_set_tx_queues(&pernet->swdev, len / sizeof(u32));
+	if (err < 0)
+		goto err_free;
+	memcpy(pernet->swdev.data_nl_portids,
+	       nla_data(info->attrs[SHULTI_A_NL_PORTIDS]), len);
+
+	pernet->swdev.swdev_id = hdr->swdev_id;
+	pernet->swdev.ctrl_nl_portid = info->snd_portid;
+	rtnl_unlock();
+	return 0;
+
+err_free:
+	kfree(pernet->swdev.data_nl_portids);
+	pernet->swdev.data_nl_portids = NULL;
+err_lock:
+	rtnl_unlock();
+err_mod:
+	module_put(THIS_MODULE);
+	return err;
+}
+
+static int shulti_genl_unbind(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_genl_hdr *hdr = info->userhdr;
+	int err = -EINVAL;
+
+	if (!rtnl_trylock())
+		return -EAGAIN;
+
+	if (!pernet->swdev.swdev_id ||
+	    pernet->swdev.swdev_id != hdr->swdev_id ||
+	    pernet->swdev.ctrl_nl_portid != info->snd_portid)
+		goto end;
+
+	__shulti_release_swdev(&pernet->swdev);
+	err = 0;
+end:
+	rtnl_unlock();
+	return err;
+}
+
+static int shulti_genl_port_info(struct sk_buff *skb, struct genl_info *info)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	int err = -EMSGSIZE, ifindex;
+	struct sk_buff *msg = NULL;
+	struct shulti_priv *port;
+	struct net_device *dev;
+	u32 swdev_portid;
+	size_t len;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID])
+		return -EINVAL;
+
+	if (shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rcu_read_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port) {
+		rcu_read_unlock();
+		return -ENXIO;
+	}
+	dev = priv2netdev(port);
+	ifindex = dev->ifindex;
+	rcu_read_unlock();
+
+	len = genlmsg_total_size(sizeof(struct shulti_genl_hdr))
+	      + nla_total_size(sizeof(uint32_t)) /* SHULTI_A_SWDEV_PORTID */
+	      + nla_total_size(sizeof(int));     /* SHULTI_A_IFINDEX */
+	msg = genlmsg_new(len, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	shulti_hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+				 &shulti_genl_family, 0, SHULTI_C_PORT_INFO);
+	if (!shulti_hdr)
+		goto err;
+	shulti_hdr->swdev_id = pernet->swdev.swdev_id;
+
+	if (nla_put_u32(msg, SHULTI_A_SWDEV_PORTID, swdev_portid))
+		goto err;
+	if (nla_put_s32(msg, SHULTI_A_IFINDEX, ifindex))
+		goto err;
+
+	genlmsg_end(msg, shulti_hdr);
+	return genlmsg_reply(msg, info);
+err:
+	nlmsg_free(msg);
+	return err;
+}
+
+static int shulti_genl_link_status(struct sk_buff *msg, struct genl_info *info)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_priv *port;
+	struct net_device *dev;
+	int err = -ENOENT;
+	u32 swdev_portid;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID] ||
+	    !info->attrs[SHULTI_A_LINK_STATUS])
+		return -EINVAL;
+
+	if (shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rcu_read_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port)
+		goto out;
+	dev = priv2netdev(port);
+
+	if (nla_get_u8(info->attrs[SHULTI_A_LINK_STATUS]))
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+out:
+	rcu_read_unlock();
+	return err;
+}
+
+static int shulti_genl_packet(struct sk_buff *msg, struct genl_info *info)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_priv *port;
+	struct net_device *dev;
+	struct sk_buff *skb;
+	u32 swdev_portid;
+	size_t len;
+	int err = -ENOENT;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID] ||
+	    !info->attrs[SHULTI_A_PACKET])
+		return -EINVAL;
+
+	if (shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rcu_read_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port)
+		goto out;
+	dev = priv2netdev(port);
+
+	err = -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto out;
+
+	err = -ENOMEM;
+	len = nla_len(info->attrs[SHULTI_A_PACKET]);
+	skb = netdev_alloc_skb_ip_align(dev, len);
+	if (!skb)
+		goto out;
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	skb_copy_to_linear_data(skb, nla_data(info->attrs[SHULTI_A_PACKET]),
+				len);
+	skb_put(skb, len);
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_rx(skb);
+	err = 0;
+out:
+	rcu_read_unlock();
+	return err;
+}
+
+static int shulti_genl_answer(struct sk_buff *msg, struct genl_info *info,
+			      int attr)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_priv *port;
+	u32 swdev_portid;
+	int err = -ENOENT;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID] ||
+	    (attr && !info->attrs[attr]))
+		return -EINVAL;
+
+	if (shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rcu_read_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port)
+		goto out_rcu_unlock;
+
+	spin_lock(&port->genl_req.lock);
+	err = -ESRCH;
+	/* Is someone waiting for an answer? */
+	if (!port->genl_req.wait_answer)
+		goto out_spin_unlock;
+
+	if (info->attrs[SHULTI_A_ERRCODE])
+		port->genl_req.errcode =
+			nla_get_s32(info->attrs[SHULTI_A_ERRCODE]);
+	else
+		port->genl_req.errcode = 0;
+	if (attr &&
+	    port->genl_req.answer &&
+	    nla_len(info->attrs[attr]) == port->genl_req.answer_len)
+		memcpy(port->genl_req.answer, nla_data(info->attrs[attr]),
+		       nla_len(info->attrs[attr]));
+	complete(&port->genl_req.compl);
+	err = 0;
+out_spin_unlock:
+	spin_unlock(&port->genl_req.lock);
+out_rcu_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int shulti_genl_get_error_code(struct sk_buff *msg,
+				      struct genl_info *info)
+{
+	return shulti_genl_answer(msg, info, 0);
+}
+
+static int shulti_genl_update_stats(struct sk_buff *msg, struct genl_info *info)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_priv *port;
+	u32 swdev_portid;
+	int err = -ENOENT;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID] ||
+	    !info->attrs[SHULTI_A_STATS] ||
+	    shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rcu_read_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port)
+		goto out;
+	memcpy(&port->stats, nla_data(info->attrs[SHULTI_A_STATS]),
+	       nla_len(info->attrs[SHULTI_A_STATS]));
+	err = 0;
+out:
+	rcu_read_unlock();
+	return err;
+}
+
+static int shulti_genl_drvinfo(struct sk_buff *msg, struct genl_info *info)
+{
+	return shulti_genl_answer(msg, info, SHULTI_A_DRVINFO);
+}
+
+static int shulti_genl_get_settings(struct sk_buff *msg,
+				    struct genl_info *info)
+{
+	return shulti_genl_answer(msg, info, SHULTI_A_SETTINGS);
+}
+
+static const struct genl_ops shulti_genl_ops[] = {
+	{
+		.cmd = SHULTI_C_BIND,
+		.doit = shulti_genl_bind,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_UNBIND,
+		.doit = shulti_genl_unbind,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_PORT_INFO,
+		.doit = shulti_genl_port_info,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_LINK_STATUS,
+		.doit = shulti_genl_link_status,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_PACKET,
+		.doit = shulti_genl_packet,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_UPDATE_STATS,
+		.doit = shulti_genl_update_stats,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_VLAN_RX_ADD_VID,
+		.doit = shulti_genl_get_error_code,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_VLAN_RX_DEL_VID,
+		.doit = shulti_genl_get_error_code,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_DRVINFO,
+		.doit = shulti_genl_drvinfo,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_GET_SETTINGS,
+		.doit = shulti_genl_get_settings,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_SET_SETTINGS,
+		.doit = shulti_genl_get_error_code,
+		.policy = shulti_genl_policy,
+	},
+	{
+		.cmd = SHULTI_C_SET_BR_FDB,
+		.doit = shulti_genl_set_br_fdb,
+		.policy = shulti_genl_policy,
+	},
+};
+
+static void shulti_destroy_swdev(struct work_struct *work)
+{
+	struct shulti_swdev *swdev =
+		container_of(work, struct shulti_swdev, destroy_work);
+
+	rtnl_lock();
+	__shulti_release_swdev(swdev);
+	rtnl_unlock();
+}
+
+static int shulti_rcv_nl_event(struct notifier_block *this,
+			       unsigned long event, void *ptr)
+{
+	struct netlink_notify *n = ptr;
+	struct net *net = n->net;
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct shulti_priv *port;
+	struct net_device *dev;
+
+	if (event == NETLINK_URELEASE &&
+	    n->protocol == NETLINK_GENERIC &&
+	    n->portid == pernet->swdev.ctrl_nl_portid) {
+		/* disable tx */
+		list_for_each_entry_rcu(port, &pernet->swdev.port_list, list) {
+			dev = priv2netdev(port);
+			netif_carrier_off(dev);
+			netif_tx_disable(dev);
+		}
+		/* disable rx */
+		pernet->swdev.swdev_id = 0;
+
+		/* schedule cleaning */
+		pernet->swdev.ctrl_nl_portid = 0;
+		schedule_work(&pernet->swdev.destroy_work);
+	}
+
+	return NOTIFY_DONE;
+}
+
+struct sk_buff *shulti_genl_build_req(struct net_device *dev, int cmd,
+				      size_t attrlen, gfp_t flags)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+	struct shulti_genl_hdr *shulti_hdr;
+	struct sk_buff *msg = NULL;
+	size_t size;
+
+	if (!priv->swdev_id)
+		goto err;
+
+	size = genlmsg_total_size(sizeof(struct shulti_genl_hdr))
+	       + nla_total_size(sizeof(uint32_t)) /* SHULTI_A_SWDEV_PORTID */
+	       + attrlen; /* attributes */
+
+	msg = genlmsg_new(size, flags);
+	if (!msg)
+		goto err;
+
+	shulti_hdr = genlmsg_put(msg, 0, 0, &shulti_genl_family, 0, cmd);
+	if (!shulti_hdr)
+		goto err;
+
+	shulti_hdr->swdev_id = priv->swdev_id;
+	if (nla_put_u32(msg, SHULTI_A_SWDEV_PORTID, priv->swdev_portid))
+		goto err;
+
+	return msg;
+err:
+	nlmsg_free(msg);
+	return NULL;
+}
+
+int shulti_genl_send_req(struct net_device *dev, struct sk_buff *msg,
+			 bool need_answer, void *answer, size_t answer_len)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+	struct shulti_genl_hdr *shulti_hdr;
+	int err = -EAGAIN;
+
+	shulti_hdr = genlmsg_data(nlmsg_data(nlmsg_hdr(msg)));
+	genlmsg_end(msg, shulti_hdr);
+
+	if (need_answer) {
+		spin_lock(&priv->genl_req.lock);
+		/* Parallel requests are not supported for now */
+		if (priv->genl_req.wait_answer)
+			goto out_locked;
+		priv->genl_req.wait_answer = true;
+		priv->genl_req.errcode = 0;
+		priv->genl_req.answer = answer;
+		priv->genl_req.answer_len = answer_len;
+		reinit_completion(&priv->genl_req.compl);
+		spin_unlock(&priv->genl_req.lock);
+	}
+
+	err = genlmsg_unicast(priv->swdev_net, msg, priv->genl_req.portid);
+	if (err < 0)
+		goto out_unlocked;
+	msg = NULL;
+
+	if (!need_answer)
+		goto out;
+
+	if (wait_for_completion_interruptible_timeout(&priv->genl_req.compl,
+						      msecs_to_jiffies(50))
+	    <= 0)
+		err = -ETIMEDOUT;
+
+out_unlocked:
+	spin_lock(&priv->genl_req.lock);
+	if (!err)
+		err = priv->genl_req.errcode;
+
+out_locked:
+	if (need_answer) {
+		priv->genl_req.wait_answer = false;
+		priv->genl_req.answer = NULL;
+	}
+	spin_unlock(&priv->genl_req.lock);
+	nlmsg_free(msg);
+out:
+	return err;
+}
+
+static struct notifier_block shulti_nl_notifier = {
+	.notifier_call  = shulti_rcv_nl_event,
+};
+
+/* ndo handlers */
+static int shulti_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+	struct shulti_net *pernet = shulti_pernet(priv->swdev_net);
+	struct shulti_genl_hdr *shulti_hdr;
+	struct sk_buff *msg = NULL;
+	unsigned int hlen, q;
+	struct nlattr *nla;
+	size_t size;
+
+	if (!pernet->swdev.swdev_id)
+		goto err;
+
+	size = genlmsg_total_size(sizeof(struct shulti_genl_hdr))
+	       + nla_total_size(sizeof(uint32_t)); /* SHULTI_A_SWDEV_PORTID */
+
+	hlen = skb_zerocopy_headlen(skb);
+	size += sizeof(struct nlattr) + hlen;
+
+	msg = genlmsg_new(size, GFP_ATOMIC);
+	if (!msg)
+		goto err;
+
+	shulti_hdr = genlmsg_put(msg, 0, 0, &shulti_genl_family, 0,
+				 SHULTI_C_PACKET);
+	if (!shulti_hdr)
+		goto err;
+
+	shulti_hdr->swdev_id = priv->swdev_id;
+	if (nla_put_u32(msg, SHULTI_A_SWDEV_PORTID, priv->swdev_portid))
+		goto err;
+
+	if (skb_tailroom(msg) < sizeof(struct nlattr) + hlen)
+		goto err;
+
+	nla = (struct nlattr *)skb_put(msg, sizeof(struct nlattr));
+	nla->nla_type = SHULTI_A_PACKET;
+	nla->nla_len = nla_attr_size(skb->len);
+
+	if (skb_zerocopy(msg, skb, skb->len, hlen))
+		goto err;
+
+	genlmsg_end(msg, shulti_hdr);
+	q = skb_get_queue_mapping(skb) % shulti_tx_queues;
+	if (genlmsg_unicast(priv->swdev_net, msg,
+			    pernet->swdev.data_nl_portids[q]) < 0)
+		goto err;
+
+	consume_skb(skb);
+	return NETDEV_TX_OK;
+
+err:
+	dev->stats.tx_dropped++;
+	nlmsg_free(msg);
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static struct rtnl_link_stats64 *
+shulti_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *tot)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	netdev_stats_to_stats64(tot, &dev->stats);
+	tot->rx_packets += priv->stats.rx_packets;
+	tot->tx_packets += priv->stats.tx_packets;
+	tot->rx_bytes += priv->stats.rx_bytes;
+	tot->tx_bytes += priv->stats.tx_bytes;
+	tot->rx_errors += priv->stats.rx_errors;
+	tot->tx_errors += priv->stats.tx_errors;
+	tot->multicast += priv->stats.multicast;
+	tot->rx_missed_errors += priv->stats.rx_missed_errors;
+
+	return tot;
+}
+
+static void shulti_set_rx_mode(struct net_device *dev)
+{
+	struct netdev_hw_addr *ha;
+	unsigned char *ethaddr;
+	struct sk_buff *msg;
+	struct nlattr *attr;
+	u32 rx_modes = 0;
+	size_t len;
+
+	len = nla_total_size(sizeof(u32)) +
+	      nla_total_size(netdev_uc_count(dev) * ETH_ALEN) +
+	      nla_total_size(netdev_mc_count(dev) * ETH_ALEN);
+
+	msg = shulti_genl_build_req(dev, SHULTI_C_SET_RX_MODE, len,
+				    GFP_ATOMIC);
+	if (!msg)
+		return;
+
+	rx_modes = dev->flags & (IFF_PROMISC | IFF_ALLMULTI);
+	if (nla_put_u32(msg, SHULTI_A_RX_MODES, rx_modes) < 0)
+		goto err;
+
+	attr = nla_reserve(msg, SHULTI_A_UC_ADDR,
+			   netdev_mc_count(dev) * ETH_ALEN);
+	if (!attr)
+		goto err;
+	ethaddr = (unsigned char *)nla_data(attr);
+	netdev_for_each_uc_addr(ha, dev) {
+		ether_addr_copy(ethaddr, ha->addr);
+		ethaddr += ETH_ALEN;
+	}
+
+	attr = nla_reserve(msg, SHULTI_A_MC_ADDR,
+			   netdev_mc_count(dev) * ETH_ALEN);
+	if (!attr)
+		goto err;
+	ethaddr = (unsigned char *)nla_data(attr);
+	netdev_for_each_mc_addr(ha, dev) {
+		ether_addr_copy(ethaddr, ha->addr);
+		ethaddr += ETH_ALEN;
+	}
+
+	shulti_genl_send_req(dev, msg, false, NULL, 0);
+	return;
+err:
+	nlmsg_free(msg);
+}
+
+static u16 shulti_pick_default_tx_queue(void)
+{
+	unsigned int cpu = smp_processor_id();
+
+	return (u16)(cpu % shulti_tx_queues);
+}
+
+static u16 shulti_select_queue(struct net_device *dev, struct sk_buff *skb,
+			       void *accel_priv,
+			       select_queue_fallback_t fallback)
+{
+	u16 queue_index;
+
+	if (skb_rx_queue_recorded(skb))
+		queue_index = skb_get_rx_queue(skb);
+	else
+		queue_index = shulti_pick_default_tx_queue();
+
+	while (unlikely(queue_index >= dev->real_num_tx_queues))
+		queue_index -= dev->real_num_tx_queues;
+
+	return queue_index;
+}
+
+static int shulti_vlan_set_rx_vid(struct net_device *dev, u8 cmd,
+				  __be16 proto, uint16_t vid)
+{
+	struct shulti_vlan_vid vlan_vid = {
+		.proto = proto,
+		.vid = vid,
+	};
+	size_t len = sizeof(vlan_vid);
+	struct sk_buff *msg;
+
+	msg = shulti_genl_build_req(dev, cmd, nla_total_size(len), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	if (nla_put(msg, SHULTI_A_VLAN_VID, len, &vlan_vid) < 0) {
+		nlmsg_free(msg);
+		return -EMSGSIZE;
+	}
+
+	return shulti_genl_send_req(dev, msg, true, NULL, 0);
+}
+
+static int shulti_vlan_rx_add_vid(struct net_device *dev, __be16 proto,
+				  uint16_t vid)
+{
+	return shulti_vlan_set_rx_vid(dev, SHULTI_C_VLAN_RX_ADD_VID,
+				      proto, vid);
+}
+
+static int shulti_vlan_rx_del_vid(struct net_device *dev, __be16 proto,
+				  uint16_t vid)
+{
+	return shulti_vlan_set_rx_vid(dev, SHULTI_C_VLAN_RX_DEL_VID,
+				      proto, vid);
+}
+
+static int shulti_get_phys_port_id(struct net_device *dev,
+				   struct netdev_phys_item_id *ppid)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	ppid->id_len = sizeof(priv->swdev_portid);
+	memcpy(ppid->id, &priv->swdev_portid, ppid->id_len);
+
+	return 0;
+}
+
+static int shulti_get_phys_port_name(struct net_device *dev,
+				     char *buf, size_t len)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	strncpy(buf, priv->phys_port_name, len);
+	return 0;
+}
+
+static const struct net_device_ops shulti_netdev_ops = {
+	.ndo_start_xmit		= shulti_xmit,
+	.ndo_get_stats64	= shulti_get_stats64,
+	.ndo_set_rx_mode	= shulti_set_rx_mode,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_select_queue	= shulti_select_queue,
+	.ndo_features_check	= passthru_features_check,
+	.ndo_vlan_rx_add_vid	= shulti_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= shulti_vlan_rx_del_vid,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+	.ndo_get_phys_port_id	= shulti_get_phys_port_id,
+	.ndo_get_phys_port_name	= shulti_get_phys_port_name,
+};
+
+static void shulti_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	struct sk_buff *msg;
+
+	msg = shulti_genl_build_req(dev, SHULTI_C_DRVINFO, 0, GFP_KERNEL);
+	if (!msg)
+		goto fallback;
+
+	if (shulti_genl_send_req(dev, msg, true, info, sizeof(*info)) < 0)
+		goto fallback;
+	return;
+
+fallback:
+	strlcpy(info->driver, SHULTI_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static int shulti_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct sk_buff *msg;
+
+	msg = shulti_genl_build_req(dev, SHULTI_C_GET_SETTINGS, 0,
+				    GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	return shulti_genl_send_req(dev, msg, true, cmd, sizeof(*cmd));
+}
+
+static int shulti_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	size_t len = sizeof(struct ethtool_cmd);
+	struct sk_buff *msg;
+
+	msg = shulti_genl_build_req(dev, SHULTI_C_SET_SETTINGS,
+				    nla_total_size(len), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	if (nla_put(msg, SHULTI_A_SETTINGS, len, cmd) < 0) {
+		nlmsg_free(msg);
+		return -EMSGSIZE;
+	}
+
+	return shulti_genl_send_req(dev, msg, true, NULL, 0);
+}
+
+static struct ethtool_ops shulti_ethtool_ops = {
+	.get_drvinfo      = shulti_get_drvinfo,
+	.get_settings     = shulti_get_settings,
+	.set_settings     = shulti_set_settings,
+};
+
+/* For udev */
+static struct device_type shulti_type = {
+	.name = "shulti",
+};
+
+static void shulti_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	SET_NETDEV_DEVTYPE(dev, &shulti_type);
+
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+
+	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	dev->features = dev->hw_features | NETIF_F_LLTX;
+	dev->vlan_features = dev->features;
+
+	dev->netdev_ops = &shulti_netdev_ops;
+	dev->ethtool_ops = &shulti_ethtool_ops;
+	dev->destructor = free_netdev;
+}
+
+/* rtnl stuff */
+static const struct nla_policy shulti_policy[IFLA_SHULTI_MAX + 1] = {
+	[IFLA_SHULTI_SWDEV_ID]		= { .type = NLA_U32 },
+	[IFLA_SHULTI_SWDEV_PORTID]	= { .type = NLA_U32 },
+	[IFLA_SHULTI_PHYS_PORT_NAME]	= { .type = NLA_STRING,
+					    .len = IFNAMSIZ },
+};
+
+static int shulti_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (!data[IFLA_SHULTI_SWDEV_ID] ||
+	    !data[IFLA_SHULTI_SWDEV_PORTID])
+		return -EINVAL;
+
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+
+	return 0;
+}
+
+static int shulti_newlink(struct net *src_net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[])
+{
+	struct shulti_net *pernet = shulti_pernet(src_net);
+	struct shulti_priv *priv = netdev_priv(dev);
+	u32 swdev_id, swdev_portid;
+	int err;
+
+	ASSERT_RTNL();
+
+	swdev_id = nla_get_u32(data[IFLA_SHULTI_SWDEV_ID]);
+	swdev_portid = nla_get_u32(data[IFLA_SHULTI_SWDEV_PORTID]);
+
+	if (pernet->swdev.swdev_id != swdev_id)
+		return -EINVAL;
+	if (__shulti_lookup_port(&pernet->swdev, swdev_portid))
+		return -EEXIST;
+	priv->swdev_id = swdev_id;
+	priv->swdev_portid = swdev_portid;
+	priv->swdev_net = src_net;
+	if (data[IFLA_SHULTI_PHYS_PORT_NAME])
+		strcpy(priv->phys_port_name,
+		       nla_data(data[IFLA_SHULTI_PHYS_PORT_NAME]));
+	else
+		memset(priv->phys_port_name, 0, sizeof(priv->phys_port_name));
+	list_add_rcu(&priv->list, &pernet->swdev.port_list);
+	dev_hold(dev);
+	priv->genl_req.portid = pernet->swdev.ctrl_nl_portid;
+	init_completion(&priv->genl_req.compl);
+	priv->genl_req.answer = NULL;
+	spin_lock_init(&priv->genl_req.lock);
+
+	if (!tb[IFLA_ADDRESS])
+		eth_hw_addr_random(dev);
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
+	else
+		snprintf(dev->name, IFNAMSIZ, SHULTI_NAME "%%d");
+
+	shulti_switchdev_init(dev);
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto err;
+
+	netif_carrier_off(dev);
+	return 0;
+
+err:
+	__shulti_release_swdev_port(priv);
+	return err;
+}
+
+static void shulti_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	ASSERT_RTNL();
+
+	__shulti_release_swdev_port(priv);
+	unregister_netdevice_queue(dev, head);
+}
+
+static int shulti_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	if (nla_put_u32(skb, IFLA_SHULTI_SWDEV_ID, priv->swdev_id) ||
+	    nla_put_u32(skb, IFLA_SHULTI_SWDEV_PORTID, priv->swdev_portid))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static unsigned int shulti_get_num_rx_queues(void)
+{
+	return shulti_rx_queues;
+}
+
+static unsigned int shulti_get_num_tx_queues(void)
+{
+	return shulti_tx_queues;
+}
+
+static struct rtnl_link_ops shulti_link_ops = {
+	.kind			= SHULTI_NAME,
+	.priv_size		= sizeof(struct shulti_priv),
+	.setup			= shulti_setup,
+	.maxtype		= IFLA_SHULTI_MAX,
+	.policy			= shulti_policy,
+	.validate		= shulti_validate,
+	.newlink		= shulti_newlink,
+	.dellink		= shulti_dellink,
+	.fill_info		= shulti_fill_info,
+	.get_num_tx_queues	= shulti_get_num_tx_queues,
+	.get_num_rx_queues	= shulti_get_num_rx_queues,
+};
+
+/* netns init/exit */
+static int __net_init shulti_net_init(struct net *net)
+{
+	struct shulti_net *pernet = shulti_pernet(net);
+
+	memset(&pernet->swdev, 0, sizeof(pernet->swdev));
+	INIT_LIST_HEAD(&pernet->swdev.port_list);
+	INIT_WORK(&pernet->swdev.destroy_work, shulti_destroy_swdev);
+	return 0;
+}
+
+static void __net_exit shulti_net_exit(struct net *net)
+{
+	struct shulti_net *pernet = shulti_pernet(net);
+
+	/* Nothing to do, if we hit this function, all sockets are already
+	 * closed and thus all associated netdevs are already unregistered.
+	 */
+	WARN_ON(pernet->swdev.ctrl_nl_portid);
+}
+
+static struct pernet_operations shulti_net_ops = {
+	.init = shulti_net_init,
+	.exit = shulti_net_exit,
+	.id   = &shulti_net_id,
+	.size = sizeof(struct shulti_net),
+};
+
+/* module init/exit */
+static int __init shulti_module_init(void)
+{
+	int err;
+
+	err = rtnl_link_register(&shulti_link_ops);
+	if (err < 0)
+		goto err;
+
+	err = genl_register_family_with_ops_groups(&shulti_genl_family,
+						   shulti_genl_ops,
+						   shulti_mcgrp);
+	if (err < 0)
+		goto err_rtnl_unreg;
+
+	err = netlink_register_notifier(&shulti_nl_notifier);
+	if (err < 0)
+		goto err_genl_unreg;
+
+	err = register_pernet_device(&shulti_net_ops);
+
+	return 0;
+
+err_genl_unreg:
+	genl_unregister_family(&shulti_genl_family);
+err_rtnl_unreg:
+	rtnl_link_unregister(&shulti_link_ops);
+err:
+	return err;
+}
+
+static void __exit shulti_module_exit(void)
+{
+	netlink_unregister_notifier(&shulti_nl_notifier);
+	genl_unregister_family(&shulti_genl_family);
+	rtnl_link_unregister(&shulti_link_ops);
+}
+
+module_init(shulti_module_init);
+module_exit(shulti_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Nicolas Dichtel <nicolas.dichtel@6wind.com>");
+MODULE_DESCRIPTION("6WIND SHULTI driver");
+MODULE_ALIAS_RTNL_LINK(SHULTI_NAME);
diff --git a/drivers/net/ethernet/6wind/shulti/shulti_private.h b/drivers/net/ethernet/6wind/shulti/shulti_private.h
new file mode 100644
index 000000000000..40c0458a2483
--- /dev/null
+++ b/drivers/net/ethernet/6wind/shulti/shulti_private.h
@@ -0,0 +1,68 @@
+/*
+ * Copyright (c) 2016 6WIND S.A.
+ * Copyright (c) 2016 Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ */
+
+#ifndef _SHULTI_PRIVATE_H_
+#define _SHULTI_PRIVATE_H_
+
+#include <linux/types.h>
+#include <linux/spinlock_types.h>
+#include <linux/netdevice.h>
+#include <linux/completion.h>
+#include <net/net_namespace.h>
+#include <net/genetlink.h>
+
+struct shulti_priv {
+	u32				swdev_id;
+	u32				swdev_portid;
+	char				phys_port_name[IFNAMSIZ];
+	struct net			*swdev_net;
+	struct list_head		list;
+	struct rcu_head			rcu;
+	struct rtnl_link_stats64	stats;
+	struct {
+		u32			portid;
+		struct completion	compl;
+		bool			wait_answer;
+		int			errcode;
+		void			*answer;
+		size_t			answer_len;
+		/* protect access to genl_req fields */
+		spinlock_t		lock;
+	} genl_req;
+	struct {
+		u32			br_flags;
+		u8			stp_state;
+	} bridge;
+};
+
+struct shulti_swdev {
+	u32			swdev_id;
+	u32			ctrl_nl_portid;
+	u32			*data_nl_portids;
+	u32			data_nl_portids_cnt;
+	struct list_head	port_list;
+	struct work_struct	destroy_work;
+};
+
+struct shulti_net {
+	struct shulti_swdev	swdev;
+};
+
+/* from shulti_core.c */
+struct shulti_net *shulti_pernet(struct net *net);
+struct shulti_priv *__shulti_lookup_port(struct shulti_swdev *swdev,
+					 u32 swdev_portid);
+struct sk_buff *shulti_genl_build_req(struct net_device *dev, int cmd,
+				      size_t attrlen, gfp_t flags);
+int shulti_genl_send_req(struct net_device *dev, struct sk_buff *msg,
+			 bool need_answer, void *answer, size_t answer_len);
+
+/* from shulti_swdev.c */
+void shulti_switchdev_init(struct net_device *dev);
+void shulti_switchdev_fini(struct net_device *dev);
+int shulti_genl_set_br_fdb(struct sk_buff *msg, struct genl_info *info);
+
+#endif /* _SHULTI_PRIVATE_H_ */
diff --git a/drivers/net/ethernet/6wind/shulti/shulti_swdev.c b/drivers/net/ethernet/6wind/shulti/shulti_swdev.c
new file mode 100644
index 000000000000..06dc26ad060f
--- /dev/null
+++ b/drivers/net/ethernet/6wind/shulti/shulti_swdev.c
@@ -0,0 +1,233 @@
+/*
+ * Copyright (c) 2016 6WIND S.A.
+ * Copyright (c) 2016 Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+#include <linux/if_bridge.h>
+#include <linux/shulti.h>
+#include <net/switchdev.h>
+
+#include "shulti_private.h"
+
+int shulti_genl_set_br_fdb(struct sk_buff *msg, struct genl_info *info)
+{
+	struct shulti_genl_hdr *shulti_hdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+	struct shulti_net *pernet = shulti_pernet(net);
+	struct switchdev_notifier_fdb_info swdev_fdb;
+	struct shulti_br_fdb *shulti_fdb;
+	struct shulti_priv *port;
+	u32 swdev_portid;
+	int err = -ENOENT;
+
+	if (!info->attrs[SHULTI_A_SWDEV_PORTID] ||
+	    !info->attrs[SHULTI_A_BR_FDB] ||
+	    shulti_hdr->swdev_id != pernet->swdev.swdev_id)
+		return -EINVAL;
+
+	swdev_portid = nla_get_u32(info->attrs[SHULTI_A_SWDEV_PORTID]);
+	rtnl_lock();
+	port = __shulti_lookup_port(&pernet->swdev, swdev_portid);
+	if (!port)
+		goto out_unlock;
+
+	shulti_fdb = nla_data(info->attrs[SHULTI_A_BR_FDB]);
+	swdev_fdb.addr = shulti_fdb->addr;
+	swdev_fdb.vid = shulti_fdb->vid;
+	if (shulti_fdb->add)
+		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
+					 priv2netdev(port), &swdev_fdb.info);
+	else
+		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
+					 priv2netdev(port), &swdev_fdb.info);
+out_unlock:
+	rtnl_unlock();
+	return err;
+}
+
+static int shulti_port_attr_get(struct net_device *dev,
+				struct switchdev_attr *attr)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		attr->u.ppid.id_len = sizeof(priv->swdev_id);
+		memcpy(&attr->u.ppid.id, &priv->swdev_id, attr->u.ppid.id_len);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		attr->u.brport_flags = priv->bridge.br_flags;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static void __shulti_destructor(void const *data)
+{
+	struct sk_buff *msg = (struct sk_buff *)data;
+
+	nlmsg_free(msg);
+}
+
+static int __shulti_port_attr_set(struct net_device *dev,
+				  struct switchdev_trans *trans,
+				  u8 cmd, int attrtype, size_t attrlen,
+				  void *attrdata, gfp_t flags)
+{
+	struct sk_buff *msg;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		struct switchdev_trans_item *elem;
+		size_t len;
+
+		elem = kzalloc(sizeof(*elem), flags);
+		if (!elem)
+			return -ENOMEM;
+
+		len = nla_total_size(attrlen);
+		msg = shulti_genl_build_req(dev, cmd, len, flags);
+		if (!msg) {
+			kfree(elem);
+			return -ENOMEM;
+		}
+		if (nla_put(msg, attrtype, attrlen, attrdata) < 0) {
+			nlmsg_free(msg);
+			kfree(elem);
+			return -EMSGSIZE;
+		}
+		switchdev_trans_item_enqueue(trans, msg, __shulti_destructor,
+					     elem);
+		return 0;
+	}
+
+	msg = switchdev_trans_item_dequeue(trans);
+	return shulti_genl_send_req(dev, msg, false, NULL, 0);
+}
+
+static int shulti_port_attr_stp_state_set(struct net_device *dev,
+					  struct switchdev_trans *trans,
+					  u8 state)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	if (!switchdev_trans_ph_prepare(trans))
+		priv->bridge.stp_state = state;
+
+	return __shulti_port_attr_set(dev, trans, SHULTI_C_SET_BRIDGE,
+				      SHULTI_A_STP_STATE, sizeof(state),
+				      &state, GFP_KERNEL);
+}
+
+static int shulti_port_attr_br_flags_set(struct net_device *dev,
+					 struct switchdev_trans *trans,
+					 unsigned long flags)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+	u8 learning = !!(flags & BR_LEARNING);
+
+	if (!((priv->bridge.br_flags ^ flags) & BR_LEARNING))
+		return 0;
+
+	if (!switchdev_trans_ph_prepare(trans))
+		priv->bridge.br_flags = flags;
+
+	return __shulti_port_attr_set(dev, trans, SHULTI_C_SET_BRIDGE,
+				      SHULTI_A_BR_STATE_LEARNING,
+				      sizeof(learning), &learning, GFP_KERNEL);
+}
+
+static int shulti_port_attr_br_ageing_time_set(struct net_device *dev,
+					       struct switchdev_trans *trans,
+					       u32 ageing_time)
+{
+	return __shulti_port_attr_set(dev, trans, SHULTI_C_SET_BRIDGE,
+				      SHULTI_A_BR_AGEING_TIME,
+				      sizeof(ageing_time), &ageing_time,
+				      GFP_KERNEL);
+}
+
+static int shulti_port_attr_set(struct net_device *dev,
+				const struct switchdev_attr *attr,
+				struct switchdev_trans *trans)
+{
+	int err = 0;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		err = shulti_port_attr_stp_state_set(dev, trans,
+						     attr->u.stp_state);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		err = shulti_port_attr_br_flags_set(dev, trans,
+						    attr->u.brport_flags);
+		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		err = shulti_port_attr_br_ageing_time_set(dev, trans,
+							  attr->u.ageing_time);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static const struct switchdev_ops shulti_switchdev_ops = {
+	.switchdev_port_attr_get        = shulti_port_attr_get,
+	.switchdev_port_attr_set        = shulti_port_attr_set,
+};
+
+void shulti_switchdev_init(struct net_device *dev)
+{
+	struct shulti_priv *priv = netdev_priv(dev);
+
+	dev->switchdev_ops = &shulti_switchdev_ops;
+	priv->bridge.br_flags = BR_LEARNING_SYNC;
+}
+
+void shulti_switchdev_fini(struct net_device *dev)
+{
+}
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 2ffd63463299..5a231b10134a 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -18,6 +18,7 @@ config SUNGEM_PHY
 	tristate
 
 source "drivers/net/ethernet/3com/Kconfig"
+source "drivers/net/ethernet/6wind/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/agere/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1d349e9aa9a6..c4800da261b0 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
+obj-$(CONFIG_NET_VENDOR_6WIND) += 6wind/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_GRETH) += aeroflex/
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18d8394f2e5d..fdec31c15490 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2012,6 +2012,10 @@ static inline void *netdev_priv(const struct net_device *dev)
 	return (char *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
 }
 
+#define priv2netdev(priv) \
+	((struct net_device *)((char *)(priv) - \
+			      ALIGN(sizeof(struct net_device), NETDEV_ALIGN)))
+
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
  */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 813ffb2e22c9..cba49d1d5684 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -363,6 +363,7 @@ header-y += rtc.h
 header-y += rtnetlink.h
 header-y += scc.h
 header-y += sched.h
+header-y += shulti.h
 header-y += scif_ioctl.h
 header-y += screen_info.h
 header-y += sctp.h
diff --git a/include/uapi/linux/shulti.h b/include/uapi/linux/shulti.h
new file mode 100644
index 000000000000..3877d7e2f760
--- /dev/null
+++ b/include/uapi/linux/shulti.h
@@ -0,0 +1,87 @@
+/*
+ * Copyright (c) 2016 6WIND S.A.
+ * Copyright (c) 2016 Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ */
+
+#ifndef _UAPI_SHULTI_H_
+#define _UAPI_SHULTI_H_
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+
+/* rtnl linkinfo attributes */
+enum {
+	IFLA_SHULTI_UNSPEC,
+	IFLA_SHULTI_SWDEV_ID,
+	IFLA_SHULTI_SWDEV_PORTID,
+	IFLA_SHULTI_PHYS_PORT_NAME,
+
+	__IFLA_SHULTI_MAX
+#define IFLA_SHULTI_MAX	(__IFLA_SHULTI_MAX - 1)
+};
+
+/* genl stuff */
+#define SHULTI_NAME  "shulti"
+
+struct shulti_genl_hdr {
+	__u32	swdev_id;
+};
+
+enum {
+	SHULTI_C_UNSPEC = 0,
+	SHULTI_C_BIND,
+	SHULTI_C_UNBIND,
+	SHULTI_C_PORT_INFO,
+	SHULTI_C_LINK_STATUS,
+	SHULTI_C_PACKET,
+	SHULTI_C_UPDATE_STATS,
+	SHULTI_C_VLAN_RX_ADD_VID,
+	SHULTI_C_VLAN_RX_DEL_VID,
+	SHULTI_C_DRVINFO,
+	SHULTI_C_GET_SETTINGS,
+	SHULTI_C_SET_SETTINGS,
+	SHULTI_C_SET_RX_MODE,
+	SHULTI_C_SET_BRIDGE,
+	SHULTI_C_SET_BR_FDB,
+
+	__SHULTI_C_MAX,
+#define SHULTI_C_MAX (__SHULTI_C_MAX - 1)
+};
+
+enum {
+	SHULTI_A_UNSPEC,
+	SHULTI_A_NL_PORTIDS,
+	SHULTI_A_SWDEV_PORTID,
+	SHULTI_A_RX_QUEUES,
+	SHULTI_A_ERRCODE,
+	SHULTI_A_IFINDEX,
+	SHULTI_A_LINK_STATUS,
+	SHULTI_A_PACKET,
+	SHULTI_A_STATS,
+	SHULTI_A_VLAN_VID,
+	SHULTI_A_DRVINFO,
+	SHULTI_A_SETTINGS,
+	SHULTI_A_RX_MODES,
+	SHULTI_A_UC_ADDR,
+	SHULTI_A_MC_ADDR,
+	SHULTI_A_STP_STATE,
+	SHULTI_A_BR_STATE_LEARNING,
+	SHULTI_A_BR_AGEING_TIME,
+	SHULTI_A_BR_FDB,
+
+	__SHULTI_A_MAX
+#define SHULTI_A_MAX	(__SHULTI_A_MAX - 1)
+};
+
+struct shulti_vlan_vid {
+	__be16 proto;
+	__u16 vid;
+};
+
+struct shulti_br_fdb {
+	__u8 add;
+	__u8 addr[ETH_ALEN];
+	__u16 vid;
+};
+#endif /* _UAPI_SHULTI_H_ */
-- 
2.4.2
