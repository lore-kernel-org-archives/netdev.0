From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH] atmtcp: add sysfs attr for changing atm carrier signal state.
Date: Sun,  3 Oct 2010 21:51:25 +0200
Message-ID: <1286135485-27355-1-git-send-email-karl@hiramoto.org>
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net,
	Karl Hiramoto <karl@hiramoto.org>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:55016 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab0JCTw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 15:52:28 -0400
Received: from homiemail-a16.g.dreamhost.com (caiajhbdcaib.dreamhost.com [208.97.132.81])
	by hapkido.dreamhost.com (Postfix) with ESMTP id C000E17A620
	for <netdev@vger.kernel.org>; Sun,  3 Oct 2010 12:52:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used for device testing carrier signal changes in other parts of
the atm stack.

Carrier lost set by:
echo -n 0 > /sys/class/atm/atmtcp0/carrier

Carrier detected:
echo -n 1 > /sys/class/atm/atmtcp0/carrier

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/atm/atmtcp.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index b910181..7540e33 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -210,6 +210,18 @@ static int atmtcp_v_send(struct atm_vcc *vcc,struct sk_buff *skb)
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOLINK;
 	}
+
+	if (vcc->dev->signal == ATM_PHY_SIG_LOST) {
+		pr_warning(DEV_LABEL ": Dropping TX pkt, upper layer not handling carrier signal lost\n");
+		if (vcc->pop)
+			vcc->pop(vcc, skb);
+		else
+			dev_kfree_skb(skb);
+
+		atomic_inc(&vcc->stats->tx_err);
+		return -ENOLINK;
+	}
+
 	size = skb->len+sizeof(struct atmtcp_hdr);
 	new_skb = atm_alloc_charge(out_vcc,size,GFP_ATOMIC);
 	if (!new_skb) {
@@ -304,6 +316,12 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
 		atomic_inc(&vcc->stats->tx_err);
 		goto done;
 	}
+
+	if (out_vcc->dev->signal == ATM_PHY_SIG_LOST) {
+		pr_debug(DEV_LABEL ": Dropping RX pkt while no carrier signal\n");
+		result = -ENOLINK;
+		goto done;
+	}
 	skb_pull(skb,sizeof(struct atmtcp_hdr));
 	new_skb = atm_alloc_charge(out_vcc,skb->len,GFP_KERNEL);
 	if (!new_skb) {
@@ -356,6 +374,43 @@ static struct atm_dev atmtcp_control_dev = {
 	.lock		= __SPIN_LOCK_UNLOCKED(atmtcp_control_dev.lock)
 };
 
+static ssize_t __set_signal(struct device *dev,
+		struct device_attribute *attr,
+		const char *buf, size_t len)
+{
+	struct atm_dev *atm_dev = container_of(dev, struct atm_dev, class_dev);
+	int signal;
+
+	if (sscanf(buf, "%d", &signal) == 1) {
+
+		if (signal < ATM_PHY_SIG_LOST || signal > ATM_PHY_SIG_FOUND)
+			signal = ATM_PHY_SIG_UNKNOWN;
+
+		atm_dev_signal_change(atm_dev, signal);
+		return 1;
+	}
+	return -EINVAL;
+}
+
+static ssize_t __show_signal(struct device *dev,
+	struct device_attribute *attr, char *buf)
+{
+	struct atm_dev *atm_dev = container_of(dev, struct atm_dev, class_dev);
+	return sprintf(buf, "%d\n", atm_dev->signal);
+}
+
+static DEVICE_ATTR(signal, 0644, __show_signal, __set_signal);
+
+static struct attribute *atmtcp_attrs[] = {
+	&dev_attr_signal.attr,
+	NULL
+};
+
+static struct attribute_group atmtcp_group_attrs = {
+	.name = NULL, /* We want them in dev's root folder */
+	.attrs = atmtcp_attrs
+};
+
 
 static int atmtcp_create(int itf,int persist,struct atm_dev **result)
 {
@@ -376,6 +431,10 @@ static int atmtcp_create(int itf,int persist,struct atm_dev **result)
 	dev->dev_data = dev_data;
 	PRIV(dev)->vcc = NULL;
 	PRIV(dev)->persist = persist;
+
+	if (sysfs_create_group(&dev->class_dev.kobj, &atmtcp_group_attrs))
+		dev_err(&dev->class_dev, "Could not register sysfs attrs for atmtcp\n");
+
 	if (result) *result = dev;
 	return 0;
 }
-- 
1.7.2.2

