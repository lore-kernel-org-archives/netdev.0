From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 19/31] net: sysfs interface support for moving devices between network namespaces.
Date: Thu, 25 Jan 2007 12:00:21 -0700
Message-ID: <11697516371558-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35778 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030199AbXAYTBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:20 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

I haven't a clue if this interface will meet with widespread approval but
at this point it is simple, and very useful.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/net-sysfs.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1be6f94..f8a5c6b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -188,6 +188,40 @@ static ssize_t store_mtu(struct class_device *cd, const char *buf, size_t len)
 	return netdev_store(cd, buf, len, change_mtu);
 }
 
+static ssize_t show_new_ns_pid(struct class_device *cd, char *buf)
+{
+	return -EPERM;
+}
+static int change_new_ns_pid(struct net_device *dev, unsigned long new_ns_pid)
+{
+	struct task_struct *tsk;
+	int err;
+	net_t net;
+	/* Look up the network namespace */
+	err = -ESRCH;
+	rcu_read_lock();
+	tsk = find_task_by_pid(new_ns_pid);
+	if (tsk) {
+		task_lock(tsk);
+		if (tsk->nsproxy) {
+			err = 0;
+			net = get_net(tsk->nsproxy->net_ns);
+		}
+		task_unlock(tsk);
+	}
+	rcu_read_unlock();
+	/* If I found a network namespace move the device */
+	if (!err) {
+		err = dev_change_net_namespace(dev, net, NULL);
+		put_net(net);
+	}
+	return err;
+}
+static ssize_t store_new_ns_pid(struct class_device *cd, const char *buf, size_t len)
+{
+	return netdev_store(cd, buf, len, change_new_ns_pid);
+}
+
 NETDEVICE_SHOW(flags, fmt_hex);
 
 static int change_flags(struct net_device *dev, unsigned long new_flags)
@@ -243,6 +277,7 @@ static struct class_device_attribute net_class_attributes[] = {
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
 	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
+	__ATTR(new_ns_pid, S_IWUSR, show_new_ns_pid, store_new_ns_pid),
 	{}
 };
 
-- 
1.4.4.1.g278f

