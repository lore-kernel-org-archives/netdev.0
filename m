From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 8/8] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Mon, 25 Jun 2012 20:28:20 +0200
Message-ID: <1340648900-6547-9-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46036 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab2FYS3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:29:10 -0400
Received: by yenl2 with SMTP id l2so3092256yen.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:29:10 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current flow, when you take down a physical device that has
VLANs configured on it, the NETDEV_GOING_DOWN notification will be
sent too late, i.e., no data can be sent to the wire anymore.

static int __dev_close_many(struct list_head *head)
{
...
	list_for_each_entry(dev, head, unreg_list) {
		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
...
	}
...
	list_for_each_entry(dev, head, unreg_list) {
		if (ops->ndo_stop)
			ops->ndo_stop(dev);
	}
...
}

static int dev_close_many(struct list_head *head)
{
	...
	__dev_close_many(head);

	list_for_each_entry(dev, head, unreg_list) {
		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
		call_netdevice_notifiers(NETDEV_DOWN, dev);
	}
}

In a setup like this: eth0 with VLANs 2, 3 the flow would be:

eth0 - NETDEV_GOING_DOWN
ndo_stop is called on the device
eth0.2 - NETDEV_GOING_DOWN
eth0.2 - NETDEV_DOWN
eth0.3 - NETDEV_GOING_DOWN
eth0.3 - NETDEV_DOWN
eth0 - NETDEV_DOWN

If instead NETDEV_GOING_DOWN is processed, the flow would be:
eth0.2 - NETDEV_GOING_DOWN
eth0.2 - NETDEV_DOWN
eth0.3 - NETDEV_GOING_DOWN
eth0.3 - NETDEV_DOWN
eth0 - NETDEV_GOING_DOWN
eth0 - NETDEV_DOWN
ndo_stop is called on the device

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/8021q/vlan.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6089f0c..fd87ecc 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -402,6 +402,12 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 		break;
 
+	case NETDEV_GOING_DOWN: /* NETDEV_DOWN */
+	/* If the parent device is going down it will call ndo_stop after
+	 * it sends out NETDEV_GOING_DOWN but before sending out NETDEV_DOWN,
+	 * The effect of which is, that no data can be sent anymore
+	 * by the time the VLAN device sends out its NETDEV_GOING_DOWN.
+	 */
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_N_VID; i++) {
-- 
1.7.10
