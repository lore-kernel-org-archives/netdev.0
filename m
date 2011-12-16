From: igorm@etf.rs
Subject: [PATCH 07/10 net-next] net:ipv4:devinet: Add support for alloc/free of per device stats and (un)register of per device proc files
Date: Fri, 16 Dec 2011 16:26:00 +0100
Message-ID: <1324049163-11207-8-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35838 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760025Ab1LPP00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:26 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Added function snmp_alloc_dev and snmp_free_dev for
allocing/freeing per device statistics.

snmp_alloc_dev is only called when in_device is created. If it failes,
in_device can't be created.
snmp_free_dev is only called when in_device is destroyed.

Added calls for snmp_(un)register_dev functions.

snmp_unregister_dev is called when in_device is destroyed and when it changes name.
snmp_register_dev is called when in_device is created. If it failes in_device
can be created. snmp_register_dev is also called when in_device change name.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/devinet.c |   75 +++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 66 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 65f01dc..c18564f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -211,6 +211,38 @@ static inline void inet_free_ifa(struct in_ifaddr *ifa)
 	call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 }
 
+static int snmp_alloc_dev(struct in_device *idev)
+{
+	if (snmp_mib_init((void __percpu **)idev->stats.ip,
+			sizeof(struct ipstats_mib),
+			__alignof__(struct ipstats_mib)) < 0)
+		goto err_ip;
+	idev->stats.icmpdev = kzalloc(sizeof(struct icmp_mib_dev),
+						GFP_KERNEL);
+	if (!idev->stats.icmpdev)
+		goto err_icmp;
+	idev->stats.icmpmsgdev = kzalloc(sizeof(struct icmpmsg_mib_dev),
+						GFP_KERNEL);
+	if (!idev->stats.icmpmsgdev)
+		goto err_icmpmsg;
+
+	return 0;
+
+err_icmpmsg:
+	kfree(idev->stats.icmpdev);
+err_icmp:
+	snmp_mib_free((void __percpu **)idev->stats.ip);
+err_ip:
+	return -ENOMEM;
+}
+
+static void snmp_free_dev(struct in_device *idev)
+{
+	kfree(idev->stats.icmpmsgdev);
+	kfree(idev->stats.icmpdev);
+	snmp_mib_free((void __percpu **)idev->stats.ip);
+}
+
 void in_dev_finish_destroy(struct in_device *idev)
 {
 	struct net_device *dev = idev->dev;
@@ -224,8 +256,10 @@ void in_dev_finish_destroy(struct in_device *idev)
 	dev_put(dev);
 	if (!idev->dead)
 		pr_err("Freeing alive in_device %p\n", idev);
-	else
+	else {
+		snmp_free_dev(idev);
 		kfree(idev);
+	}
 }
 EXPORT_SYMBOL(in_dev_finish_destroy);
 
@@ -249,6 +283,22 @@ static struct in_device *inetdev_init(struct net_device *dev)
 		dev_disable_lro(dev);
 	/* Reference in_dev->dev */
 	dev_hold(dev);
+
+	if (snmp_alloc_dev(in_dev) < 0) {
+		printk(KERN_CRIT
+			"%s(): cannot allocate memory for statistics; dev=%s.\n",
+			__func__, dev->name);
+		neigh_parms_release(&arp_tbl, in_dev->arp_parms);
+		dev_put(dev);
+		kfree(in_dev);
+		return NULL;
+	}
+
+	if (snmp_register_dev(in_dev) < 0)
+		printk(KERN_WARNING
+			"%s(): cannot create /proc/net/dev_snmp/%s\n",
+			__func__, dev->name);
+
 	/* Account for reference dev->ip_ptr (below) */
 	in_dev_hold(in_dev);
 
@@ -292,6 +342,7 @@ static void inetdev_destroy(struct in_device *in_dev)
 	}
 
 	RCU_INIT_POINTER(dev->ip_ptr, NULL);
+	snmp_unregister_dev(in_dev);
 
 	devinet_sysctl_unregister(in_dev);
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
@@ -1222,14 +1273,20 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_UNREGISTER:
 		inetdev_destroy(in_dev);
 		break;
-	case NETDEV_CHANGENAME:
-		/* Do not notify about label change, this event is
-		 * not interesting to applications using netlink.
-		 */
-		inetdev_changename(dev, in_dev);
-
-		devinet_sysctl_unregister(in_dev);
-		devinet_sysctl_register(in_dev);
+	case NETDEV_CHANGENAME: {
+			int err;
+			/* Do not notify about label change, this event is
+			 * not interesting to applications using netlink.
+			 */
+			inetdev_changename(dev, in_dev);
+
+			snmp_unregister_dev(in_dev);
+			devinet_sysctl_unregister(in_dev);
+			devinet_sysctl_register(in_dev);
+			err = snmp_register_dev(in_dev);
+			if (err)
+				return notifier_from_errno(err);
+		}
 		break;
 	}
 out:
-- 
1.7.5.4
