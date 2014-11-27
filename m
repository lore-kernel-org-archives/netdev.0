From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 08/21] net-sysfs: expose physical switch id for particular device
Date: Thu, 27 Nov 2014 11:40:13 +0100
Message-ID: <1417084826-9875-9-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:61913 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbaK0Kkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:39 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so6088469wgh.32
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:38 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Reviewed-by: Thomas Graf <tgraf@suug.ch>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
v3->v4:
-added entry to Documentation/ABI/testing/sysfs-class-net as suggested
 by Florian
v2->v3:
-changed "sw" string to "switch" to avoid confusion
v1->v2:
-no change
---
 Documentation/ABI/testing/sysfs-class-net |  8 ++++++++
 net/core/net-sysfs.c                      | 24 ++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index e1b2e78..beb8ec4 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -216,3 +216,11 @@ Contact:	netdev@vger.kernel.org
 Description:
 		Indicates the interface protocol type as a decimal value. See
 		include/uapi/linux/if_arp.h for all possible values.
+
+What:		/sys/class/net/<iface>/phys_switch_id
+Date:		November 2014
+KernelVersion:	3.19
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the unique physical switch identifier of a switch this
+		port belongs to, as a string.
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 26c46f4..9993412 100644
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
@@ -416,6 +417,28 @@ static ssize_t phys_port_id_show(struct device *dev,
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
+		ret = netdev_switch_parent_id_get(netdev, &ppid);
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
@@ -441,6 +464,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_tx_queue_len.attr,
 	&dev_attr_gro_flush_timeout.attr,
 	&dev_attr_phys_port_id.attr,
+	&dev_attr_phys_switch_id.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
1.9.3
