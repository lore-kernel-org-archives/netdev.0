From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next] vlan: avoid a synchronize_net when parent device goes down
Date: Thu,  5 Mar 2015 15:37:01 -0800
Message-ID: <1425598621-18083-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:49950 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751291AbbCEXms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 18:42:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a parent device is brought down, all of the vlan devices
on top of it are brought down in vlan_device_event which ultimately
leads to a call to synchronize_net in dev_deactivate_many. If many
vlan devices are configured on top of one device, these calls can
take a significant time. This patch works around this issue by
setting the dismantle flag in vlandev. It is a bit hacky and
overloads the meaning of dismantle but can bring a big improvement
on busy systems where synchronize_net can take longer than usual.

The call stack leading to the synchronize_net is,

[<ffffffff812f8747>] synchronize_net+0x25/0x2e
[<ffffffff8130f94a>] dev_deactivate_many+0x186/0x222
[<ffffffff812fb7a8>] __dev_close_many+0x83/0xca
[<ffffffff812fb820>] __dev_close+0x31/0x42
[<ffffffff812f9220>] __dev_change_flags+0xa8/0x12b
[<ffffffff812fc42c>] dev_change_flags+0x1c/0x51
[<ffffffffa00ab6be>] vlan_device_event+0x39a/0x4cc [8021q]
[<ffffffff813d982b>] notifier_call_chain+0x32/0x5e
[<ffffffff8104642c>] raw_notifier_call_chain+0xf/0x11
[<ffffffff812fb720>] call_netdevice_notifiers+0x45/0x4a
[<ffffffff812fb8e3>] dev_close_many+0xb2/0xfd

Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 net/8021q/vlan.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 64c6bed..6846ca2 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -355,6 +355,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct net_device *vlandev;
 	struct vlan_dev_priv *vlan;
 	bool last = false;
+	bool old_dismantle, no_sync = true;
 	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev)) {
@@ -423,11 +424,24 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!(flgs & IFF_UP))
 				continue;
 
+			/* Set vlandev->dismantle to avoid synchronize_net
+			 * getting called for every vlan device in
+			 * dev_deactivate_many. A synchronize_net is needed
+			 * at the end of the loop if at least one vlandev
+			 * and the parent device didn't have dismantle set
+			 */
+			old_dismantle = vlandev->dismantle;
+			no_sync = no_sync && old_dismantle;
+			vlandev->dismantle = true;
+
 			vlan = vlan_dev_priv(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 				dev_change_flags(vlandev, flgs & ~IFF_UP);
 			netif_stacked_transfer_operstate(dev, vlandev);
+			vlandev->dismantle = old_dismantle;
 		}
+		if (!dev->dismantle && !no_sync)
+			synchronize_net();
 		break;
 
 	case NETDEV_UP:
-- 
1.8.1.4
