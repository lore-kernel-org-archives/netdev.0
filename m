From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 2/2] net: add sysfs attribute to control napi threaded mode
Date: Tue, 10 May 2016 16:11:54 +0200
Message-ID: <335b4fc3f774284a934d7fe272388d7385ff2e27.1462886866.git.pabeni@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1462886866.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this patch addis a new sysfs attribute to the network
device class. Said attribute is a bitmask that allows controlling
the threaded mode for all the napi instances of the given
network device.

The threaded mode can be switched only if related network device
is down.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/net-sysfs.c | 102 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2b3f76f..60bc768 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -489,6 +489,107 @@ static ssize_t phys_switch_id_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(phys_switch_id);
 
+unsigned long *__alloc_thread_bitmap(struct net_device *netdev, int *bits)
+{
+	struct napi_struct *n;
+
+	*bits = 0;
+	list_for_each_entry(n, &netdev->napi_list, dev_list)
+		(*bits)++;
+
+	return kmalloc_array(BITS_TO_LONGS(*bits), sizeof(unsigned long),
+			     GFP_ATOMIC | __GFP_ZERO);
+}
+
+static ssize_t threaded_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct napi_struct *n;
+	unsigned long *bmap;
+	size_t count = 0;
+	int i, bits;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (!dev_isalive(netdev))
+		goto unlock;
+
+	bmap = __alloc_thread_bitmap(netdev, &bits);
+	if (!bmap) {
+		count = -ENOMEM;
+		goto unlock;
+	}
+
+	i = 0;
+	list_for_each_entry(n, &netdev->napi_list, dev_list) {
+		if (test_bit(NAPI_STATE_THREADED, &n->state))
+			set_bit(i, bmap);
+		i++;
+	}
+
+	count = bitmap_print_to_pagebuf(true, buf, bmap, bits);
+	kfree(bmap);
+
+unlock:
+	rtnl_unlock();
+
+	return count;
+}
+
+static ssize_t threaded_store(struct device *dev,
+			      struct device_attribute *attr,
+			      const char *buf, size_t len)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct napi_struct *n;
+	unsigned long *bmap;
+	int i, bits;
+	size_t ret;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (!dev_isalive(netdev)) {
+		ret = len;
+		goto unlock;
+	}
+
+	if (netdev->flags & IFF_UP) {
+		ret = -EBUSY;
+		goto unlock;
+	}
+
+	bmap = __alloc_thread_bitmap(netdev, &bits);
+	if (!bmap) {
+		ret = -ENOMEM;
+		goto unlock;
+	}
+
+	ret = bitmap_parselist(buf, bmap, bits);
+	if (ret)
+		goto free_unlock;
+
+	i = 0;
+	list_for_each_entry(n, &netdev->napi_list, dev_list) {
+		napi_set_threaded(n, test_bit(i, bmap));
+		i++;
+	}
+	ret = len;
+
+free_unlock:
+	kfree(bmap);
+
+unlock:
+	rtnl_unlock();
+	return ret;
+}
+static DEVICE_ATTR_RW(threaded);
+
 static struct attribute *net_class_attrs[] = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
@@ -517,6 +618,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_phys_port_name.attr,
 	&dev_attr_phys_switch_id.attr,
 	&dev_attr_proto_down.attr,
+	&dev_attr_threaded.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
1.8.3.1
