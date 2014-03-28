From: David Decotigny <decot@googlers.com>
Subject: [PATCH v1] net-sysfs: expose number of link up/down transitions
Date: Thu, 27 Mar 2014 21:35:00 -0700
Message-ID: <cc4b88e880d31d8d71a5c8872a64c9d665cd097e.1395980768.git.decot@googlers.com>
References: <cover.1395980768.git.decot@googlers.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	David Decotigny <decot@googlers.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395980768.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested:
  grep . /sys/class/net/*/count_link_*
  + ip link set dev X down/up

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/linux/netdevice.h |  4 ++++
 net/core/net-sysfs.c      | 18 ++++++++++++++++++
 net/sched/sch_generic.c   |  2 ++
 3 files changed, 24 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b6d12c..cf52869 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1315,6 +1315,10 @@ struct net_device {
 					     * Do not use this in drivers.
 					     */
 
+	/* Stats to monitor link on/off, flapping */
+	atomic_t		count_link_up;
+	atomic_t		count_link_down;
+
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index daed9a6..a65ac54 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -253,6 +253,22 @@ static ssize_t operstate_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(operstate);
 
+static ssize_t count_link_up_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	return sprintf(buf, fmt_dec, atomic_read(&netdev->count_link_up));
+}
+
+static ssize_t count_link_down_show(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	return sprintf(buf, fmt_dec, atomic_read(&netdev->count_link_down));
+}
+static DEVICE_ATTR_RO(count_link_up);
+static DEVICE_ATTR_RO(count_link_down);
+
 /* read-write attributes */
 
 static int change_mtu(struct net_device *net, unsigned long new_mtu)
@@ -386,6 +402,8 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_duplex.attr,
 	&dev_attr_dormant.attr,
 	&dev_attr_operstate.attr,
+	&dev_attr_count_link_up.attr,
+	&dev_attr_count_link_down.attr,
 	&dev_attr_ifalias.attr,
 	&dev_attr_carrier.attr,
 	&dev_attr_mtu.attr,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e82e43b..2d06943 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -310,6 +310,7 @@ void netif_carrier_on(struct net_device *dev)
 	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
+		atomic_inc(&dev->count_link_up);
 		linkwatch_fire_event(dev);
 		if (netif_running(dev))
 			__netdev_watchdog_up(dev);
@@ -328,6 +329,7 @@ void netif_carrier_off(struct net_device *dev)
 	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
+		atomic_inc(&dev->count_link_down);
 		linkwatch_fire_event(dev);
 	}
 }
-- 
1.9.1.423.g4596e3a
