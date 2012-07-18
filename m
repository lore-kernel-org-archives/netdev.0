From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 6/9] net/eipoib: Add sysfs support
Date: Wed, 18 Jul 2012 13:59:59 +0300
Message-ID: <1342609202-32427-7-git-send-email-ogerlitz@mellanox.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:47854 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753729Ab2GRLAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 07:00:37 -0400
In-Reply-To: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

The management interface for the driver uses sysfs entries. Via these sysfs
entries the driver gets details on new VIF's to manage. The driver can
enslave new VIF (IPoIB cloned interface) or detaches from it.

Here are few sysfs commands that are used in order to manage the driver,
according to few scenarios:

1. create new clone of IPoIB interface:

	$ echo .Y > /sys/class/net/ibX/create_child

create new clone ibX.Y with the same pkey as ibX, for example:

	$ echo .1 > /sys/class/net/ib0/create_child

will create new interface ib0.1

2. notify parent interface on new VIF to enslave:

	$ echo +ibX.Y > /sys/class/net/ethZ/eth/slaves

where ethZ is the driver interface, for example:

	$ echo +ib0.1 > /sys/class/net/eth4/eth/slaves

will enslave ib0.1 to eth4

3. notify parent interface interface on VIF details (mac and vlan)

	$ echo +ibX.Y <MAC address> > /sys/class/net/ethZ/eth/vifs

for example:

	$ echo +ib0.1 00:02:c9:43:3b:f1 > /sys/class/net/eth4/eth/vifs

4. notify parent to release VIF:

	$ echo -ibX.Y > /sys/class/net/ethZ/eth/slaves

where ethZ is the driver interface, for example:

        $ echo -ib0.1 > /sys/class/net/eth4/eth/slaves

will release ib0.1 from eth4

5. see the list of ipoib interfaces enslaved under eipoib interface,

	$ cat /sys/class/net/ethX/eth/vifs

for example:

	$ cat /sys/class/net/eth4/eth/vifs

	SLAVE=ib0.1      MAC=9a:c2:1f:d7:3b:63 VLAN=N/A
	SLAVE=ib0.2      MAC=52:54:00:60:55:88 VLAN=N/A
	SLAVE=ib0.3      MAC=52:54:00:60:55:89 VLAN=N/A

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/eipoib/eth_ipoib_sysfs.c |  640 ++++++++++++++++++++++++++++++++++
 1 files changed, 640 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/eipoib/eth_ipoib_sysfs.c

diff --git a/drivers/net/eipoib/eth_ipoib_sysfs.c b/drivers/net/eipoib/eth_ipoib_sysfs.c
new file mode 100644
index 0000000..c3fc121
--- /dev/null
+++ b/drivers/net/eipoib/eth_ipoib_sysfs.c
@@ -0,0 +1,640 @@
+/*
+ * Copyright (c) 2012 Mellanox Technologies. All rights reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * openfabric.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/in.h>
+#include <linux/sysfs.h>
+#include <linux/ctype.h>
+#include <linux/inet.h>
+#include <linux/rtnetlink.h>
+#include <linux/etherdevice.h>
+#include <net/net_namespace.h>
+
+#include "eth_ipoib.h"
+
+#define to_dev(obj)	container_of(obj, struct device, kobj)
+#define to_parent(cd)	((struct parent *)(netdev_priv(to_net_dev(cd))))
+#define MOD_NA_STRING		"N/A"
+
+#define _sprintf(p, buf, format, arg...)				\
+((PAGE_SIZE - (int)(p - buf)) <= 0 ? 0 :				\
+	scnprintf(p, PAGE_SIZE - (int)(p - buf), format, ## arg))\
+
+#define _end_of_line(_p, _buf)					\
+do { if (_p - _buf) /* eat the leftover space */			\
+		buf[_p - _buf - 1] = '\n';				\
+} while (0)
+
+/* helper functions */
+static int get_emac(u8 *mac, char *s)
+{
+	if (sscanf(s, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		   mac + 0, mac + 1, mac + 2, mac + 3, mac + 4,
+		   mac + 5) != 6)
+		return -1;
+
+	return 0;
+}
+
+static int get_imac(u8 *mac, char *s)
+{
+	if (sscanf(s, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:"
+		   "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:%hhx:"
+		   "%hhx:%hhx:%hhx:%hhx",
+		   mac + 0, mac + 1, mac + 2, mac + 3, mac + 4,
+		   mac + 5, mac + 6, mac + 7, mac + 8, mac + 9,
+		   mac + 10, mac + 11, mac + 12, mac + 13,
+		   mac + 14, mac + 15, mac + 16, mac + 17,
+		   mac + 18, mac + 19) != 20)
+		return -1;
+
+	return 0;
+}
+
+/* show/store functions per module (CLASS_ATTR) */
+static ssize_t show_parents(struct class *cls, struct class_attribute *attr,
+			    char *buf)
+{
+	char *p = buf;
+	struct parent *parent;
+
+	rtnl_lock(); /* because of parent_dev_list */
+
+	list_for_each_entry(parent, &parent_dev_list, parent_list) {
+		p += _sprintf(p, buf, "%s over IB port: %s\n",
+			      parent->dev->name,
+			      parent->ipoib_main_interface);
+	}
+	_end_of_line(p, buf);
+
+	rtnl_unlock();
+	return (ssize_t)(p - buf);
+}
+
+/* show/store functions per parent (DEVICE_ATTR) */
+static ssize_t parent_show_neighs(struct device *d,
+				  struct device_attribute *attr, char *buf)
+{
+	struct slave *slave;
+	struct neigh *neigh;
+	struct parent *parent = to_parent(d);
+	char *p = buf;
+
+	read_lock_bh(&parent->lock);
+	parent_for_each_slave(parent, slave) {
+		list_for_each_entry(neigh, &slave->neigh_list, list) {
+			p += _sprintf(p, buf, "SLAVE=%-10s EMAC=%pM IMAC=%pM:%pM:%pM:%.2x:%.2x\n",
+				      slave->dev->name,
+				      neigh->emac,
+				      neigh->imac, neigh->imac + 6, neigh->imac + 12,
+				      neigh->imac[18], neigh->imac[19]);
+		}
+	}
+
+	read_unlock_bh(&parent->lock);
+
+	_end_of_line(p, buf);
+
+	return (ssize_t)(p - buf);
+}
+
+struct neigh *parent_get_neigh_cmd(char op,
+				   char *ifname, u8 *remac, u8 *rimac)
+{
+	struct neigh *neigh_cmd;
+
+	neigh_cmd = kzalloc(sizeof *neigh_cmd, GFP_ATOMIC);
+	if (!neigh_cmd) {
+		pr_err("%s cannot allocate neigh struct\n", ifname);
+		goto out;
+	}
+
+	/*
+	 * populate emac field so it can be used easily
+	 * in neigh_cmd_find_by_mac()
+	 */
+	memcpy(neigh_cmd->emac, remac, ETH_ALEN);
+	memcpy(neigh_cmd->imac, rimac, INFINIBAND_ALEN);
+
+	/* prepare the command as a string */
+	sprintf(neigh_cmd->cmd, "%c%s %pM %pM:%pM:%pM:%.2x:%.2x",
+		op, ifname, remac, rimac, rimac + 6, rimac + 12, rimac[18], rimac[19]);
+out:
+	return neigh_cmd;
+}
+
+/* write_lock_bh(&parent->lock) must be held */
+ssize_t __parent_store_neighs(struct device *d,
+			      struct device_attribute *attr,
+			      const char *buffer, size_t count)
+{
+	char command[IFNAMSIZ + 1] = { 0, };
+	char emac_str[ETH_ALEN * 3] = { 0, };
+	u8 emac[ETH_ALEN];
+	char imac_str[INFINIBAND_ALEN * 3] = { 0, };
+	u8 imac[INFINIBAND_ALEN];
+	char *ifname;
+	int found = 0, ret = count;
+	struct slave *slave = NULL, *slave_tmp;
+	struct neigh *neigh;
+	struct parent *parent = to_parent(d);
+
+	sscanf(buffer, "%s %s %s", command, emac_str, imac_str);
+
+	/* check ifname */
+	ifname = command + 1;
+	if ((strlen(command) <= 1) || !dev_valid_name(ifname) ||
+	    (command[0] != '+' && command[0] != '-'))
+		goto err_no_cmd;
+
+	/* check if ifname exist */
+	parent_for_each_slave(parent, slave_tmp) {
+		if (!strcmp(slave_tmp->dev->name, ifname)) {
+			found = 1;
+			slave = slave_tmp;
+		}
+	}
+
+	if (!found) {
+		pr_err("%s could not find slave\n", ifname);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (get_emac(emac, emac_str)) {
+		pr_err("%s bad emac %s\n", ifname, emac_str);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (get_imac(imac, imac_str)) {
+		pr_err("%s bad imac %s\n", ifname, imac_str);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* process command */
+	if (command[0] == '+') {
+		found = 0;
+		list_for_each_entry(neigh, &slave->neigh_list, list) {
+			if (!memcmp(neigh->emac, emac, ETH_ALEN))
+				found = 1;
+		}
+
+		if (found) {
+			pr_err("%s: cannot update neigh, slave already has "
+			       "this neigh mac %pM\n",
+			       slave->dev->name, emac);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		neigh = kzalloc(sizeof *neigh, GFP_ATOMIC);
+		if (!neigh) {
+			pr_err("%s cannot allocate neigh struct\n",
+			       slave->dev->name);
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		/* ready to go */
+		pr_info("%s: slave %s neigh mac is set to %pM\n",
+			ifname, parent->dev->name, emac);
+		memcpy(neigh->emac, emac, ETH_ALEN);
+		memcpy(neigh->imac, imac, INFINIBAND_ALEN);
+
+		list_add_tail(&neigh->list, &slave->neigh_list);
+
+		goto out;
+	}
+
+	if (command[0] == '-') {
+		found = 0;
+		list_for_each_entry(neigh, &slave->neigh_list, list) {
+			if (!memcmp(neigh->emac, emac, ETH_ALEN))
+				found = 1;
+		}
+
+		if (!found) {
+			pr_err("%s cannot delete neigh mac %pM\n",
+			       ifname, emac);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		list_del(&neigh->list);
+		kfree(neigh);
+
+		goto out;
+	}
+
+err_no_cmd:
+	pr_err("%s USAGE: (-|+)ifname emac imac\n", DRV_NAME);
+	ret = -EPERM;
+
+out:
+	return ret;
+}
+
+static ssize_t parent_store_neighs(struct device *d,
+				   struct device_attribute *attr,
+				   const char *buffer, size_t count)
+{
+	struct parent *parent = to_parent(d);
+	ssize_t rc;
+
+	write_lock_bh(&parent->lock);
+	rc = __parent_store_neighs(d, attr, buffer, count);
+	write_unlock_bh(&parent->lock);
+
+	return rc;
+}
+
+static DEVICE_ATTR(neighs, S_IRUGO | S_IWUSR, parent_show_neighs,
+		   parent_store_neighs);
+
+static ssize_t parent_show_vifs(struct device *d,
+				struct device_attribute *attr, char *buf)
+{
+	struct slave *slave;
+	struct parent *parent = to_parent(d);
+	char *p = buf;
+
+	read_lock_bh(&parent->lock);
+	parent_for_each_slave(parent, slave) {
+		if (is_zero_ether_addr(slave->emac)) {
+			p += _sprintf(p, buf, "SLAVE=%-10s MAC=%-17s "
+				      "VLAN=%s\n", slave->dev->name,
+				      MOD_NA_STRING, MOD_NA_STRING);
+		} else if (slave->vlan == VLAN_N_VID) {
+			p += _sprintf(p, buf, "SLAVE=%-10s MAC=%pM VLAN=%s\n",
+				      slave->dev->name,
+				      slave->emac,
+				      MOD_NA_STRING);
+		} else {
+			p += _sprintf(p, buf, "SLAVE=%-10s MAC=%pM VLAN=%d\n",
+				      slave->dev->name,
+				      slave->emac,
+				      slave->vlan);
+		}
+	}
+	read_unlock_bh(&parent->lock);
+
+	_end_of_line(p, buf);
+
+	return (ssize_t)(p - buf);
+}
+
+static ssize_t parent_store_vifs(struct device *d,
+				 struct device_attribute *attr,
+				 const char *buffer, size_t count)
+{
+	char command[IFNAMSIZ + 1] = { 0, };
+	char mac_str[ETH_ALEN * 3] = { 0, };
+	char *ifname;
+	u8 mac[ETH_ALEN];
+	int found = 0, ret = count;
+	struct slave *slave = NULL, *slave_tmp;
+	struct parent *parent = to_parent(d);
+
+	sscanf(buffer, "%s %s", command, mac_str);
+
+	write_lock_bh(&parent->lock);
+
+	/* check ifname */
+	ifname = command + 1;
+	if ((strlen(command) <= 1) || !dev_valid_name(ifname) ||
+	    (command[0] != '+' && command[0] != '-'))
+		goto err_no_cmd;
+
+	/* check if ifname exist */
+	parent_for_each_slave(parent, slave_tmp) {
+		if (!strcmp(slave_tmp->dev->name, ifname)) {
+			found = 1;
+			slave = slave_tmp;
+		}
+	}
+
+	if (!found) {
+		pr_err("%s could not find slave\n", ifname);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* process command */
+	if (command[0] == '+') {
+		if (get_emac(mac, mac_str) || !is_valid_ether_addr(mac)) {
+			pr_err("%s invalid mac input\n", ifname);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		if (!is_zero_ether_addr(slave->emac)) {
+			pr_err("%s slave %s mac already set to %pM\n",
+			       ifname, slave->dev->name, slave->emac);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		/* check another slave has this mac/vlan */
+		found = 0;
+		parent_for_each_slave(parent, slave_tmp) {
+			if (!memcmp(slave_tmp->emac, mac, ETH_ALEN) &&
+			    slave_tmp->vlan == slave->vlan) {
+				pr_err("cannot update %s, slave %s already has"
+				       " vlan 0x%x mac %pM\n",
+				       parent->dev->name, slave->dev->name,
+				       slave_tmp->vlan,
+				       mac);
+				ret = -EINVAL;
+				goto out;
+			}
+		}
+
+		/* ready to go */
+		pr_info("slave %s mac is set to %pM\n",
+			ifname, mac);
+
+		memcpy(slave->emac, mac, ETH_ALEN);
+		goto out;
+	}
+
+	if (command[0] == '-') {
+		if (is_zero_ether_addr(slave->emac)) {
+			pr_err("%s slave mac already unset %pM\n",
+			       ifname, slave->emac);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		pr_info("slave %s mac is unset (was %pM)\n",
+			ifname, slave->emac);
+
+		goto out;
+	}
+
+err_no_cmd:
+	pr_err("%s USAGE: (-|+)ifname [mac]\n", DRV_NAME);
+	ret = -EPERM;
+
+out:
+	write_unlock_bh(&parent->lock);
+
+	return ret;
+}
+
+static DEVICE_ATTR(vifs, S_IRUGO | S_IWUSR, parent_show_vifs,
+		   parent_store_vifs);
+
+static ssize_t parent_show_slaves(struct device *d,
+				  struct device_attribute *attr, char *buf)
+{
+	struct slave *slave;
+	struct parent *parent = to_parent(d);
+	char *p = buf;
+
+	read_lock_bh(&parent->lock);
+	parent_for_each_slave(parent, slave)
+		p += _sprintf(p, buf, "%s\n", slave->dev->name);
+	read_unlock_bh(&parent->lock);
+
+	_end_of_line(p, buf);
+
+	return (ssize_t)(p - buf);
+}
+
+static ssize_t parent_store_slaves(struct device *d,
+				   struct device_attribute *attr,
+				   const char *buffer, size_t count)
+{
+	char command[IFNAMSIZ + 1] = { 0, };
+	char *ifname;
+	int res, ret = count;
+	struct slave *slave;
+	struct net_device *dev = NULL;
+	struct parent *parent = to_parent(d);
+
+	/* Quick sanity check -- is the parent interface up? */
+	if (!(parent->dev->flags & IFF_UP)) {
+		pr_warn("%s: doing slave updates when "
+			"interface is down.\n", dev->name);
+	}
+
+	if (!rtnl_trylock()) /* because __dev_get_by_name */
+		return restart_syscall();
+
+	sscanf(buffer, "%16s", command);
+
+	ifname = command + 1;
+	if ((strlen(command) <= 1) || !dev_valid_name(ifname))
+		goto err_no_cmd;
+
+	if (command[0] == '+') {
+		/* Got a slave name in ifname. Is it already in the list? */
+		dev = __dev_get_by_name(&init_net, ifname);
+		if (!dev) {
+			pr_warn("%s: Interface %s does not exist!\n",
+				parent->dev->name, ifname);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		read_lock_bh(&parent->lock);
+		parent_for_each_slave(parent, slave) {
+			if (slave->dev == dev) {
+				pr_err("%s ERR- Interface %s is already enslaved!\n",
+				       parent->dev->name, dev->name);
+				ret = -EPERM;
+			}
+		}
+		read_unlock_bh(&parent->lock);
+
+		if (ret < 0)
+			goto out;
+
+		pr_info("%s: adding slave %s\n",
+			parent->dev->name, ifname);
+
+		res = parent_enslave(parent->dev, dev);
+		if (res)
+			ret = res;
+
+		goto out;
+	}
+
+	if (command[0] == '-') {
+		dev = NULL;
+		parent_for_each_slave(parent, slave)
+			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
+				dev = slave->dev;
+				break;
+			}
+
+		if (dev) {
+			pr_info("%s: removing slave %s\n",
+				parent->dev->name, dev->name);
+			res = parent_release_slave(parent->dev, dev);
+			if (res) {
+				ret = res;
+				goto out;
+			}
+		} else {
+			pr_warn("%s: unable to remove non-existent "
+				"slave for parent %s.\n",
+				ifname, parent->dev->name);
+			ret = -ENODEV;
+		}
+		goto out;
+	}
+
+err_no_cmd:
+	pr_err("%s USAGE: (-|+)ifname\n", DRV_NAME);
+	ret = -EPERM;
+
+out:
+	rtnl_unlock();
+	return ret;
+}
+
+static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, parent_show_slaves,
+		   parent_store_slaves);
+
+/* sysfs create/destroy functions */
+static struct attribute *per_parent_attrs[] = {
+	&dev_attr_slaves.attr, /* DEVICE_ATTR(slaves..) */
+	&dev_attr_vifs.attr,
+	&dev_attr_neighs.attr,
+	NULL,
+};
+
+/* name spcase  support */
+static const void *eipoib_namespace(struct class *cls,
+				    const struct class_attribute *attr)
+{
+	const struct eipoib_net *eipoib_n =
+		container_of(attr,
+			     struct eipoib_net, class_attr_eipoib_interfaces);
+	return eipoib_n->net;
+}
+
+static struct attribute_group parent_group = {
+	/* per parent sysfs files under: /sys/class/net/<IF>/eth/.. */
+	.name = "eth",
+	.attrs = per_parent_attrs
+};
+
+int create_slave_symlinks(struct net_device *master,
+			  struct net_device *slave)
+{
+	char linkname[IFNAMSIZ+7];
+	int ret = 0;
+
+	ret = sysfs_create_link(&(slave->dev.kobj), &(master->dev.kobj),
+				"eth_parent");
+	if (ret)
+		return ret;
+
+	sprintf(linkname, "slave_%s", slave->name);
+	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
+				linkname);
+	return ret;
+
+}
+
+void destroy_slave_symlinks(struct net_device *master,
+			    struct net_device *slave)
+{
+	char linkname[IFNAMSIZ+7];
+
+	sysfs_remove_link(&(slave->dev.kobj), "eth_parent");
+	sprintf(linkname, "slave_%s", slave->name);
+	sysfs_remove_link(&(master->dev.kobj), linkname);
+}
+
+static struct class_attribute class_attr_eth_ipoib_interfaces = {
+	.attr = {
+		.name = "eth_ipoib_interfaces",
+		.mode = S_IWUSR | S_IRUGO,
+	},
+	.show = show_parents,
+	.namespace = eipoib_namespace,
+};
+
+/* per module sysfs file under: /sys/class/net/eth_ipoib_interfaces */
+int mod_create_sysfs(struct eipoib_net *eipoib_n)
+{
+	int rc;
+	/* defined in CLASS_ATTR(eth_ipoib_interfaces..) */
+	eipoib_n->class_attr_eipoib_interfaces =
+		class_attr_eth_ipoib_interfaces;
+
+	sysfs_attr_init(&eipoib_n->class_attr_eipoib_interfaces.attr);
+
+	rc = netdev_class_create_file(&eipoib_n->class_attr_eipoib_interfaces);
+	if (rc)
+		pr_err("%s failed to create sysfs (rc %d)\n",
+		       eipoib_n->class_attr_eipoib_interfaces.attr.name, rc);
+
+	return rc;
+}
+
+void mod_destroy_sysfs(struct eipoib_net *eipoib_n)
+{
+	netdev_class_remove_file(&eipoib_n->class_attr_eipoib_interfaces);
+}
+
+int parent_create_sysfs_entry(struct parent *parent)
+{
+	struct net_device *dev = parent->dev;
+	int rc;
+
+	rc = sysfs_create_group(&(dev->dev.kobj), &parent_group);
+	if (rc)
+		pr_info("failed to create sysfs group\n");
+
+	return rc;
+}
+
+void parent_destroy_sysfs_entry(struct parent *parent)
+{
+	struct net_device *dev = parent->dev;
+
+	sysfs_remove_group(&(dev->dev.kobj), &parent_group);
+}
-- 
1.7.1
