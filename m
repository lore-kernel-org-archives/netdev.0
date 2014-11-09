From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/10] net-sysfs: expose physical switch id for particular device
Date: Sun,  9 Nov 2014 11:51:14 +0100
Message-ID: <1415530280-9190-5-git-send-email-jiri@resnulli.us>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53850 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbaKIKv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 05:51:28 -0500
Received: by mail-wg0-f44.google.com with SMTP id x12so6791707wgg.3
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 02:51:26 -0800 (PST)
In-Reply-To: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/net-sysfs.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 55dc4da..8e6603c 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -12,6 +12,7 @@
 #include <linux/capability.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <net/switchdev.h>
 #include <linux/if_arp.h>
 #include <linux/slab.h>
 #include <linux/nsproxy.h>
@@ -399,6 +400,28 @@ static ssize_t phys_port_id_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(phys_port_id);
 
+static ssize_t phys_switch_id_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (dev_isalive(netdev)) {
+		struct netdev_phys_item_id ppid;
+
+		ret = netdev_sw_parent_id_get(netdev, &ppid);
+		if (!ret)
+			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
+	}
+	rtnl_unlock();
+
+	return ret;
+}
+static DEVICE_ATTR_RO(phys_switch_id);
+
 static struct attribute *net_class_attrs[] = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
@@ -423,6 +446,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_flags.attr,
 	&dev_attr_tx_queue_len.attr,
 	&dev_attr_phys_port_id.attr,
+	&dev_attr_phys_switch_id.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
1.9.3
