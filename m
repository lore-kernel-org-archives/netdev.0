From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH 1/6] atm: add hooks to propagate signal changes to netdevice
Date: Fri,  2 Jul 2010 19:47:05 +0200
Message-ID: <1278092830-10473-2-git-send-email-karl@hiramoto.org>
References: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:39858 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758661Ab0GBRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:26 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdcaib.dreamhost.com [208.97.132.81])
	by hapkido.dreamhost.com (Postfix) with ESMTP id A06FB179548
	for <netdev@vger.kernel.org>; Fri,  2 Jul 2010 10:48:26 -0700 (PDT)
In-Reply-To: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On DSL and ATM devices it's usefull to have a know if you have a carrier signal.
netdevice LOWER_UP changes can be propagated to userspace via netlink monitor.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 include/linux/atmdev.h |    5 +++++
 net/atm/common.c       |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 817b237..c6958ec 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -311,6 +311,7 @@ struct atm_vcc {
 	void (*pop)(struct atm_vcc *vcc,struct sk_buff *skb); /* optional */
 	int (*push_oam)(struct atm_vcc *vcc,void *cell);
 	int (*send)(struct atm_vcc *vcc,struct sk_buff *skb);
+	void (*signal_change)(struct atm_vcc *vcc); /* optional. to propagate LOWER_UP */
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
@@ -431,6 +432,10 @@ struct atm_dev *atm_dev_register(const char *type,const struct atmdev_ops *ops,
     int number,unsigned long *flags); /* number == -1: pick first available */
 struct atm_dev *atm_dev_lookup(int number);
 void atm_dev_deregister(struct atm_dev *dev);
+/**
+* Propagate lower layer signal change in atm_dev->signal to netdevice.
+*/
+void atm_dev_signal_change(struct atm_dev *dev, char signal);
 void vcc_insert_socket(struct sock *sk);
 
 
diff --git a/net/atm/common.c b/net/atm/common.c
index b43feb1..ccf09f2 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -212,6 +212,39 @@ void vcc_release_async(struct atm_vcc *vcc, int reply)
 }
 EXPORT_SYMBOL(vcc_release_async);
 
+void atm_dev_signal_change(struct atm_dev *dev, char signal)
+{
+	int i;
+	pr_debug("%s signal=%d dev=%p number=%d dev->signal=%d\n",
+		__func__, signal, dev, dev->number, dev->signal);
+
+	if (dev->signal == signal)
+		return; /* no change */
+
+	dev->signal = signal;
+
+	read_lock_irq(&vcc_sklist_lock);
+	for (i = 0; i < VCC_HTABLE_SIZE; i++) {
+		struct hlist_head *head = &vcc_hash[i];
+		struct hlist_node *node, *tmp;
+		struct sock *s;
+		struct atm_vcc *vcc;
+		sk_for_each_safe(s, node, tmp, head) {
+			vcc = atm_sk(s);
+			pr_debug("%s signal=%d vcc=%p dev=%p vcc->dev=%p %d.%d itf=%d meta=%d\n",
+				__func__, signal, vcc, dev, vcc->dev,
+				vcc->vpi, vcc->vci, vcc->itf, test_bit(ATM_VF_META, &vcc->flags));
+			/* if there is a signal change callback and dev matches,
+				or if this is a meta dev (clip atm_dev is arpd) */
+			if (vcc->signal_change && (vcc->dev == dev
+				|| test_bit(ATM_VF_META, &vcc->flags))) {
+				vcc->signal_change(vcc);
+			}
+		}
+	}
+	read_unlock_irq(&vcc_sklist_lock);
+}
+EXPORT_SYMBOL(atm_dev_signal_change);
 
 void atm_dev_release_vccs(struct atm_dev *dev)
 {
-- 
1.7.1

