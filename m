From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] VLAN over bonding
Date: Mon, 14 Feb 2005 12:29:05 +0100
Message-ID: <20050214112905.GF23861@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

It seems when you create a VLAN configuration on top of a bonding
device, any normal (non-VLAN) traffic stops completely. The reason
is that bond_dev_queue_xmit() drops all outgoing frames that have
no VLAN tag.

The attached patch tries to fix this - is this the right way to do this,
or does that break other areas of VLAN-over-bonding?

Thanks
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=vlan-bonding-normal-frames

Index: linux-2.6.10/drivers/net/bonding/bond_main.c
===================================================================
--- linux-2.6.10.orig/drivers/net/bonding/bond_main.c
+++ linux-2.6.10/drivers/net/bonding/bond_main.c
@@ -807,15 +807,10 @@ struct vlan_entry *bond_next_vlan(struct
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

--XsQoSWH+UP9D9v3l--
