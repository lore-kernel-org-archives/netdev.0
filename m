From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 2.6.11-rc4-netdev1] bonding: don't drop non-VLAN traffic
Date: Thu, 31 Mar 2005 12:23:43 -0800
Message-ID: <200503312023.j2VKNhir031974@death.nxdomain.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Posted this a few weeks ago, don't see it in netdev-2.6 yet.
Did this get lost somewhere, or is it still pending?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

To: netdev@oss.sgi.com
Cc: Olaf Kirch <okir@suse.de>
Subject: [PATCH REPOST 2.6.11-rc4-netdev1] bonding: don't drop non-VLAN traffic
Date: Thu, 03 Mar 2005 15:33:11 -0800
From: Jay Vosburgh <fubar@us.ibm.com>


	Change the bonding driver to not drop non-VLAN traffic when a
VLAN is configured above it.  Originally fixed by Olaf Kirch
<okir@suse.de>; I changed his patch slightly to update comments.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

--- linux-2.6.11-rc4-netdev1-virgin/drivers/net/bonding/bond_main.c	2005-02-15 11:31:40.000000000 -0800
+++ linux-2.6.11-rc4-netdev1/drivers/net/bonding/bond_main.c	2005-02-15 16:09:10.000000000 -0800
@@ -793,29 +793,20 @@
  * @skb: hw accel VLAN tagged skb to transmit
  * @slave_dev: slave that is supposed to xmit this skbuff
  * 
- * When the bond gets an skb to tarnsmit that is
+ * When the bond gets an skb to transmit that is
  * already hardware accelerated VLAN tagged, and it
  * needs to relay this skb to a slave that is not
  * hw accel capable, the skb needs to be "unaccelerated",
  * i.e. strip the hwaccel tag and re-insert it as part
  * of the payload.
- * 
- * Assumption - once a VLAN device is created over the bond device, all
- * packets are going to be hardware accelerated VLAN tagged since the IP
- * binding is done over the VLAN device
  */
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev)
 {
 	unsigned short vlan_id;
-	int res;
 
 	if (!list_empty(&bond->vlan_list) &&
-	    !(slave_dev->features & NETIF_F_HW_VLAN_TX)) {
-		res = vlan_get_tag(skb, &vlan_id);
-		if (res) {
-			return -EINVAL;
-		}
-
+	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
+	    vlan_get_tag(skb, &vlan_id) == 0) {
 		skb->dev = slave_dev;
 		skb = vlan_put_tag(skb, vlan_id);
 		if (!skb) {
