From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (2/3) vlan propogate carrier and hotplug state
Date: Tue, 3 Aug 2004 13:40:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803134014.7164280c@dell_ss3.pdx.osdl.net>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
	<410FD348.9040301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>,
        "David S. Miller"
 <davem@redhat.com>
In-Reply-To: <410FD348.9040301@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The bridge STP code now wants to handle device's getting connected/disconnected
and this includes vlan devices.  This patch makes the VLAN pseudo device state
mirror the state of the real device.  Only bothered with carrier and hotplug.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-08-03 13:35:48 -07:00
+++ b/net/8021q/vlan.c	2004-08-03 13:35:48 -07:00
@@ -69,6 +69,10 @@
 	.func = vlan_skb_recv, /* VLAN receive method */
 };
 
+/* Bits of netdev state that are propogated from real device to virtual */
+#define VLAN_LINK_STATE_MASK \
+	((1<<__LINK_STATE_PRESENT)|(1<<__LINK_STATE_NOCARRIER))
+
 /* End of global variables definitions. */
 
 /*
@@ -472,6 +476,8 @@
 	new_dev->flags = real_dev->flags;
 	new_dev->flags &= ~IFF_UP;
 
+	new_dev->state = real_dev->state & VLAN_LINK_STATE_MASK;
+
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
 	 */
@@ -598,9 +604,20 @@
 	 */
 
 	switch (event) {
-	case NETDEV_CHANGEADDR:
-	case NETDEV_GOING_DOWN:
-		/* Ignore for now */
+	case NETDEV_CHANGE:
+		/* Propogate real device state to vlan devices */
+		flgs = dev->state & VLAN_LINK_STATE_MASK;
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = grp->vlan_devices[i];
+			if (!vlandev)
+				continue;
+
+			if ((vlandev->state & VLAN_LINK_STATE_MASK) != flgs) {
+				vlandev->state = (vlandev->state &~ VLAN_LINK_STATE_MASK) 
+					| flgs;
+				netdev_state_change(vlandev);
+			}
+		}
 		break;
 
 	case NETDEV_DOWN:
