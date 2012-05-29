From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Wed, 30 May 2012 00:30:35 +0200
Message-ID: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
