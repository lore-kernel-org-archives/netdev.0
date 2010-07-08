From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Thu,  8 Jul 2010 10:34:47 +0200
Message-ID: <1278578095-25324-2-git-send-email-karl@hiramoto.org>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcagg.dreamhost.com ([208.97.132.66]:57465 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754984Ab0GHIfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 04:35:05 -0400
In-Reply-To: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add notifier chain for changes in atm_dev.

Clients like br2684 will call register_atmdevice_notifier() to be notified of
changes. Drivers will call atm_dev_signal_change() to notify clients like
br2684 of the change.

On DSL and ATM devices it's usefull to have a know if you have a carrier
signal. netdevice LOWER_UP changes can be propagated to userspace via netlink
monitor.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 include/linux/atmdev.h |   20 ++++++++++++++++++++
 net/atm/common.c       |   30 ++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 817b237..649dd24 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -431,6 +431,15 @@ struct atm_dev *atm_dev_register(const char *type,const struct atmdev_ops *ops,
     int number,unsigned long *flags); /* number == -1: pick first available */
 struct atm_dev *atm_dev_lookup(int number);
 void atm_dev_deregister(struct atm_dev *dev);
+
+/*
+ * atm_dev_signal_change
+ *
+ * Propagate lower layer signal change in atm_dev->signal to netdevice.
+ * The event will be sent via a notifier call chain.
+ */
+void atm_dev_signal_change(struct atm_dev *dev, char signal);
+
 void vcc_insert_socket(struct sock *sk);
 
 
@@ -510,6 +519,17 @@ void register_atm_ioctl(struct atm_ioctl *);
  */
 void deregister_atm_ioctl(struct atm_ioctl *);
 
+
+
+/*
+ * register_atmdevice_notifier - register atm_dev notify events
+ *
+ * Clients like br2684 will register notify events
+ * Currently we notify of signal found/lost
+ */
+int register_atmdevice_notifier(struct notifier_block *nb);
+void unregister_atmdevice_notifier(struct notifier_block *nb);
+
 #endif /* __KERNEL__ */
 
 #endif
diff --git a/net/atm/common.c b/net/atm/common.c
index b43feb1..940404a 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -37,6 +37,8 @@ EXPORT_SYMBOL(vcc_hash);
 DEFINE_RWLOCK(vcc_sklist_lock);
 EXPORT_SYMBOL(vcc_sklist_lock);
 
+static ATOMIC_NOTIFIER_HEAD(atm_dev_notify_chain);
+
 static void __vcc_insert_socket(struct sock *sk)
 {
 	struct atm_vcc *vcc = atm_sk(sk);
@@ -212,6 +214,22 @@ void vcc_release_async(struct atm_vcc *vcc, int reply)
 }
 EXPORT_SYMBOL(vcc_release_async);
 
+void atm_dev_signal_change(struct atm_dev *dev, char signal)
+{
+	pr_debug("%s signal=%d dev=%p number=%d dev->signal=%d\n",
+		__func__, signal, dev, dev->number, dev->signal);
+
+	/* atm driver sending invalid signal */
+	WARN_ON(signal < ATM_PHY_SIG_LOST || signal > ATM_PHY_SIG_FOUND);
+
+	if (dev->signal == signal)
+		return; /* no change */
+
+	dev->signal = signal;
+
+	atomic_notifier_call_chain(&atm_dev_notify_chain, signal, dev);
+}
+EXPORT_SYMBOL(atm_dev_signal_change);
 
 void atm_dev_release_vccs(struct atm_dev *dev)
 {
@@ -781,6 +799,18 @@ int vcc_getsockopt(struct socket *sock, int level, int optname,
 	return vcc->dev->ops->getsockopt(vcc, level, optname, optval, len);
 }
 
+int register_atmdevice_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&atm_dev_notify_chain, nb);
+}
+EXPORT_SYMBOL_GPL(register_atmdevice_notifier);
+
+void unregister_atmdevice_notifier(struct notifier_block *nb)
+{
+	atomic_notifier_chain_unregister(&atm_dev_notify_chain, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_atmdevice_notifier);
+
 static int __init atm_init(void)
 {
 	int error;
-- 
1.7.1

