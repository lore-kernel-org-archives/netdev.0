From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 3/3] batman-adv: Avoid endless loop in bat-on-bat netdevice check
Date: Tue, 16 Feb 2016 23:01:28 +0800
Message-ID: <1455634888-29400-4-git-send-email-a@unstable.cc>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:1133 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932716AbcBPPEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:04:08 -0500
In-Reply-To: <1455634888-29400-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

batman-adv checks in different situation if a new device is already on top
of a different batman-adv device. This is done by getting the iflink of a
device and all its parent. It assumes that this iflink is always a parent
device in an acyclic graph. But this assumption is broken by devices like
veth which are actually a pair of two devices linked to each other. The
recursive check would therefore get veth0 when calling dev_get_iflink on
veth1. And it gets veth0 when calling dev_get_iflink with veth1.

Creating a veth pair and loading batman-adv freezes parts of the system

    ip link add veth0 type veth peer name veth1
    modprobe batman-adv

An RCU stall will be detected on the system which cannot be fixed.

    INFO: rcu_sched self-detected stall on CPU
            1: (5264 ticks this GP) idle=3e9/140000000000001/0
    softirq=144683/144686 fqs=5249
             (t=5250 jiffies g=46 c=45 q=43)
    Task dump for CPU 1:
    insmod          R  running task        0   247    245 0x00000008
     ffffffff8151f140 ffffffff8107888e ffff88000fd141c0 ffffffff8151f140
     0000000000000000 ffffffff81552df0 ffffffff8107b420 0000000000000001
     ffff88000e3fa700 ffffffff81540b00 ffffffff8107d667 0000000000000001
    Call Trace:
     <IRQ>  [<ffffffff8107888e>] ? rcu_dump_cpu_stacks+0x7e/0xd0
     [<ffffffff8107b420>] ? rcu_check_callbacks+0x3f0/0x6b0
     [<ffffffff8107d667>] ? hrtimer_run_queues+0x47/0x180
     [<ffffffff8107cf9d>] ? update_process_times+0x2d/0x50
     [<ffffffff810873fb>] ? tick_handle_periodic+0x1b/0x60
     [<ffffffff810290ae>] ? smp_trace_apic_timer_interrupt+0x5e/0x90
     [<ffffffff813bbae2>] ? apic_timer_interrupt+0x82/0x90
     <EOI>  [<ffffffff812c3fd7>] ? __dev_get_by_index+0x37/0x40
     [<ffffffffa0031f3e>] ? batadv_hard_if_event+0xee/0x3a0 [batman_adv]
     [<ffffffff812c5801>] ? register_netdevice_notifier+0x81/0x1a0
    [...]

This can be avoided by checking if two devices are each others parent and
stopping the check in this situation.

Fixes: b7eddd0b3950 ("batman-adv: prevent using any virtual device created on batman-adv as hard-interface")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven@narfation.org: rewritten description, extracted fix]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/hard-interface.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 01acccc4d218..57f7107169f5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -76,6 +76,28 @@ out:
 }
 
 /**
+ * batadv_mutual_parents - check if two devices are each others parent
+ * @dev1: 1st net_device
+ * @dev2: 2nd net_device
+ *
+ * veth devices come in pairs and each is the parent of the other!
+ *
+ * Return: true if the devices are each others parent, otherwise false
+ */
+static bool batadv_mutual_parents(const struct net_device *dev1,
+				  const struct net_device *dev2)
+{
+	int dev1_parent_iflink = dev_get_iflink(dev1);
+	int dev2_parent_iflink = dev_get_iflink(dev2);
+
+	if (!dev1_parent_iflink || !dev2_parent_iflink)
+		return false;
+
+	return (dev1_parent_iflink == dev2->ifindex) &&
+	       (dev2_parent_iflink == dev1->ifindex);
+}
+
+/**
  * batadv_is_on_batman_iface - check if a device is a batman iface descendant
  * @net_dev: the device to check
  *
@@ -108,6 +130,9 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 	if (WARN(!parent_dev, "Cannot find parent device"))
 		return false;
 
+	if (batadv_mutual_parents(net_dev, parent_dev))
+		return false;
+
 	ret = batadv_is_on_batman_iface(parent_dev);
 
 	return ret;
-- 
2.7.1
