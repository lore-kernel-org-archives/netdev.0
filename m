From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] VLAN over bonding
Date: Tue, 15 Feb 2005 15:50:52 -0800
Message-ID: <200502152350.j1FNoq6f030802@death.nxdomain.ibm.com>
References: <okir@suse.de>
Cc: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
To: Olaf Kirch <okir@suse.de>
In-Reply-To: Message from Olaf Kirch <okir@suse.de>
   of "Mon, 14 Feb 2005 12:29:05 +0100." <20050214112905.GF23861@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch <okir@suse.de> wrote:
>It seems when you create a VLAN configuration on top of a bonding
>device, any normal (non-VLAN) traffic stops completely. The reason
>is that bond_dev_queue_xmit() drops all outgoing frames that have
>no VLAN tag.
>
>The attached patch tries to fix this - is this the right way to do this,
>or does that break other areas of VLAN-over-bonding?

	Logically this looks good.  I tried it out on a non-VLAN aware
e100, and it seems to the do right thing.  I tweaked the patch to update
the comments to reflect the new reality (and fix a typo while I was
there).

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
