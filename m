From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v3 2/9] atm/br2684: register notifier event for carrier signal changes.
Date: Wed,  7 Jul 2010 10:50:29 +0200
Message-ID: <1278492636-11094-3-git-send-email-karl@hiramoto.org>
References: <1278492636-11094-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcaid.dreamhost.com ([208.97.132.83]:48958 "EHLO
	homiemail-a30.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751539Ab0GGIuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 04:50:51 -0400
In-Reply-To: <1278492636-11094-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a signal change event occurs call netif_carrier_on/off.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 net/atm/br2684.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 6719af6..01a628d 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -139,6 +139,42 @@ static struct net_device *br2684_find_dev(const struct br2684_if_spec *s)
 	return NULL;
 }
 
+static int atm_dev_event(struct notifier_block *this, unsigned long event,
+		 void *arg)
+{
+	struct atm_dev *atm_dev = arg;
+	struct list_head *lh;
+	struct net_device *net_dev;
+	struct br2684_vcc *brvcc;
+	struct atm_vcc *atm_vcc;
+
+	pr_debug("event=%ld dev=%p\n", event, atm_dev);
+
+	read_lock_irq(&devs_lock);
+	list_for_each(lh, &br2684_devs) {
+		net_dev = list_entry_brdev(lh);
+
+		list_for_each_entry(brvcc, &BRPRIV(net_dev)->brvccs, brvccs) {
+			atm_vcc = brvcc->atmvcc;
+			if (atm_vcc && brvcc->atmvcc->dev == atm_dev) {
+
+				if (atm_vcc->dev->signal == ATM_PHY_SIG_LOST)
+					netif_carrier_off(net_dev);
+				else
+					netif_carrier_on(net_dev);
+
+			}
+		}
+	}
+	read_unlock_irq(&devs_lock);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block atm_dev_notifier = {
+	.notifier_call = atm_dev_event,
+};
+
 /* chained vcc->pop function.  Check if we should wake the netif_queue */
 static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 {
@@ -362,6 +398,12 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			unregister_netdev(net_dev);
 			free_netdev(net_dev);
 		}
+		read_lock_irq(&devs_lock);
+		if (list_empty(&br2684_devs)) {
+			/* last br2684 device */
+			unregister_atmdevice_notifier(&atm_dev_notifier);
+		}
+		read_unlock_irq(&devs_lock);
 		return;
 	}
 
@@ -530,6 +572,13 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 
 		br2684_push(atmvcc, skb);
 	}
+
+	/* initialize netdev carrier state */
+	if (atmvcc->dev->signal == ATM_PHY_SIG_LOST)
+		netif_carrier_off(net_dev);
+	else
+		netif_carrier_on(net_dev);
+
 	__module_get(THIS_MODULE);
 	return 0;
 
@@ -620,9 +669,16 @@ static int br2684_create(void __user *arg)
 	}
 
 	write_lock_irq(&devs_lock);
+
 	brdev->payload = payload;
-	brdev->number = list_empty(&br2684_devs) ? 1 :
-	    BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
+
+	if (list_empty(&br2684_devs)) {
+		/* 1st br2684 device */
+		register_atmdevice_notifier(&atm_dev_notifier);
+		brdev->number = 1;
+	} else
+		brdev->number = BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
+
 	list_add_tail(&brdev->br2684_devs, &br2684_devs);
 	write_unlock_irq(&devs_lock);
 	return 0;
@@ -758,6 +814,7 @@ static int __init br2684_init(void)
 		return -ENOMEM;
 #endif
 	register_atm_ioctl(&br2684_ioctl_ops);
+
 	return 0;
 }
 
@@ -772,6 +829,11 @@ static void __exit br2684_exit(void)
 	remove_proc_entry("br2684", atm_proc_root);
 #endif
 
+
+	/* if not already empty */
+	if (!list_empty(&br2684_devs))
+		unregister_atmdevice_notifier(&atm_dev_notifier);
+
 	while (!list_empty(&br2684_devs)) {
 		net_dev = list_entry_brdev(br2684_devs.next);
 		brdev = BRPRIV(net_dev);
-- 
1.7.1

