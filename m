From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: avoid a synchronize_net when parent
 device goes down
Date: Sun, 08 Mar 2015 22:21:34 -0400 (EDT)
Message-ID: <20150308.222134.544504915277666481.davem@davemloft.net>
References: <1425598621-18083-1-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: noureddine@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbCICVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 22:21:39 -0400
In-Reply-To: <1425598621-18083-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@arista.com>
Date: Thu,  5 Mar 2015 15:37:01 -0800

> When a parent device is brought down, all of the vlan devices
> on top of it are brought down in vlan_device_event which ultimately
> leads to a call to synchronize_net in dev_deactivate_many. If many
> vlan devices are configured on top of one device, these calls can
> take a significant time. This patch works around this issue by
> setting the dismantle flag in vlandev. It is a bit hacky and
> overloads the meaning of dismantle but can bring a big improvement
> on busy systems where synchronize_net can take longer than usual.
> 
> The call stack leading to the synchronize_net is,
> 
> [<ffffffff812f8747>] synchronize_net+0x25/0x2e
> [<ffffffff8130f94a>] dev_deactivate_many+0x186/0x222
> [<ffffffff812fb7a8>] __dev_close_many+0x83/0xca
> [<ffffffff812fb820>] __dev_close+0x31/0x42
> [<ffffffff812f9220>] __dev_change_flags+0xa8/0x12b
> [<ffffffff812fc42c>] dev_change_flags+0x1c/0x51
> [<ffffffffa00ab6be>] vlan_device_event+0x39a/0x4cc [8021q]
> [<ffffffff813d982b>] notifier_call_chain+0x32/0x5e
> [<ffffffff8104642c>] raw_notifier_call_chain+0xf/0x11
> [<ffffffff812fb720>] call_netdevice_notifiers+0x45/0x4a
> [<ffffffff812fb8e3>] dev_close_many+0xb2/0xfd
> 
> Signed-off-by: Salam Noureddine <noureddine@arista.com>

Please let's implement this properly.  VLAN is not the only case
that would benefit from something like this.

Something like:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4541378..df0753f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2185,6 +2185,7 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name);
 int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
+int dev_close_many(struct list_head *head, bool unlink);
 void dev_disable_lro(struct net_device *dev);
 int dev_loopback_xmit(struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 64c6bed..98a30a5 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -413,7 +413,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			vlan_transfer_features(dev, vlandev);
 		break;
 
-	case NETDEV_DOWN:
+	case NETDEV_DOWN: {
+		struct net_device *tmp;
+		LIST_HEAD(close_list);
+
 		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
 			vlan_vid_del(dev, htons(ETH_P_8021Q), 0);
 
@@ -425,11 +428,18 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 			vlan = vlan_dev_priv(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
-				dev_change_flags(vlandev, flgs & ~IFF_UP);
+				list_add(&vlandev->close_list, &close_list);
+		}
+
+		dev_close_many(&close_list, false);
+
+		list_for_each_entry_safe(vlandev, tmp, &close_list, close_list) {
 			netif_stacked_transfer_operstate(dev, vlandev);
+			list_del_init(&vlandev->close_list);
 		}
+		list_del(&close_list);
 		break;
-
+	}
 	case NETDEV_UP:
 		/* Put all VLANs for this dev in the up state too.  */
 		vlan_group_for_each_dev(grp, i, vlandev) {
diff --git a/net/core/dev.c b/net/core/dev.c
index 962ee9d..d190c32 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1385,7 +1385,7 @@ static int __dev_close(struct net_device *dev)
 	return retval;
 }
 
-static int dev_close_many(struct list_head *head)
+int dev_close_many(struct list_head *head, bool unlink)
 {
 	struct net_device *dev, *tmp;
 
@@ -1399,11 +1399,13 @@ static int dev_close_many(struct list_head *head)
 	list_for_each_entry_safe(dev, tmp, head, close_list) {
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
-		list_del_init(&dev->close_list);
+		if (unlink)
+			list_del_init(&dev->close_list);
 	}
 
 	return 0;
 }
+EXPORT_SYMBOL(dev_close_many);
 
 /**
  *	dev_close - shutdown an interface.
@@ -1420,7 +1422,7 @@ int dev_close(struct net_device *dev)
 		LIST_HEAD(single);
 
 		list_add(&dev->close_list, &single);
-		dev_close_many(&single);
+		dev_close_many(&single, true);
 		list_del(&single);
 	}
 	return 0;
@@ -5968,7 +5970,7 @@ static void rollback_registered_many(struct list_head *head)
 	/* If device is running, close it first. */
 	list_for_each_entry(dev, head, unreg_list)
 		list_add_tail(&dev->close_list, &close_head);
-	dev_close_many(&close_head);
+	dev_close_many(&close_head, true);
 
 	list_for_each_entry(dev, head, unreg_list) {
 		/* And unlink it from device chain. */
