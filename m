From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 2/2] bonding: support QinQ for bond arp interval
Date: Mon, 17 Mar 2014 10:46:04 -0700
Message-ID: <21958.1395078364@death.nxdomain>
References: <1395057975-19084-1-git-send-email-dingtianhong@huawei.com> <1395057975-19084-3-git-send-email-dingtianhong@huawei.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, kaber@trash.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36033 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbaCQRqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 13:46:12 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 17 Mar 2014 11:46:10 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id F1C1B1FF0044
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 11:46:07 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2HFhI0D4981118
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 16:43:18 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2HHk7Lm006942
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 11:46:07 -0600
In-reply-to: <1395057975-19084-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The bond send arp request to indicate that the slave is active, and if the bond dev
>is a vlan dev, it will set the vlan tag in skb to notice the vlan group, but the
>bond could only send a skb with 802.1q proto, not support for QinQ.
>
>So add outer tag for lower vlan tag and inner tag for upper vlan tag to support QinQ,
>The new skb will be consist of two vlan tag just like this:
>
>dst mac | src mac | outer vlan tag | inner vlan tag | data | .....
>
>If We don't need QinQ, the inner vlan tag could be set to 0 and use outer vlan tag
> as a normal vlan group.
>
>Using "ip link" to configure the bond for QinQ and add test log:
>
>ip link add link bond0  bond0.20 type vlan proto 802.1ad id 20
>ip link add link bond0.20  bond0.20.200 type vlan proto 802.1q id 200

	Is this nesting backwards?  The way I read it (and the way I
recall that VLANs nest), "bond0.20" is the "regular" VLAN, i.e., if we
just have bond0.20 it would be a standard 802.1q (ethertype 0x8100)
VLAN.  Adding the second VLAN, .200 in this example, would be the second
(outer) tag, and would be the 802.1ad (ethertype 0x88a8) tag.

	In other words, adding a VLAN to an already existing VLAN makes
the newly added VLAN the "outer" and the already existing VLAN the
"inner."  Am I confused?

>ifconfig bond0.20 11.11.20.36/24
>ifconfig bond0.20.200 11.11.200.36/24
>
>echo +11.11.200.37 > /sys/class/net/bond0/bonding/arp_ip_target
>
>90:e2:ba:07:4a:5c (oui Unknown) > Broadcast, ethertype 802.1Q-QinQ (0x88a8),length 50: vlan 20, p 0,ethertype 802.1Q, vlan 200, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 11.11.200.37 tell 11.11.200.36, length 28
>
>90:e2:ba:06:f9:86 (oui Unknown) > 90:e2:ba:07:4a:5c (oui Unknown), ethertype 802.1Q-QinQ (0x88a8), length 50: vlan 20, p 0, ethertype 802.1Q, vlan 200, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Reply 11.11.200.37 is-at 90:e2:ba:06:f9:86 (oui Unknown), length 28
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 61 ++++++++++++++++++++++++++++++-----------
> drivers/net/bonding/bonding.h   |  5 ++++
> 2 files changed, 50 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 324389b..068f983 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2124,12 +2124,15 @@ static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
>  * switches in VLAN mode (especially if ports are configured as
>  * "native" to a VLAN) might not pass non-tagged frames.
>  */
>-static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_ip, __be32 src_ip, unsigned short vlan_id)
>+static void bond_arp_send(struct net_device *slave_dev, int arp_op,
>+			  __be32 dest_ip, __be32 src_ip,
>+			  struct bond_vlan_tag *inner,
>+			  struct bond_vlan_tag *outer)
> {
> 	struct sk_buff *skb;
>
>-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 vid %d\n",
>-		 arp_op, slave_dev->name, &dest_ip, &src_ip, vlan_id);
>+	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
>+		 arp_op, slave_dev->name, &dest_ip, &src_ip);
>
> 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
> 			 NULL, slave_dev->dev_addr, NULL);
>@@ -2138,10 +2141,22 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
> 		pr_err("ARP packet allocation failed\n");
> 		return;
> 	}
>-	if (vlan_id) {
>-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
>+	if (outer->vlan_id) {
>+		if (inner->vlan_id) {
>+			pr_debug("inner tag: proto %X vid %X\n",
>+				 ntohs(inner->vlan_proto), inner->vlan_id);
>+			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
>+			if (!skb) {
>+				pr_err("failed to insert inner VLAN tag\n");

	This should be rate limited and not a straight pr_err; it's
going to spam the log if the system is out of free memory (the only
reason __vlan_put_tag can fail at the moment).  The existing code works
the same way, but it's wrong, too.

>+				return;
>+			}
>+		}
>+
>+		pr_debug("outer reg: proto %X vid %X\n",
>+			 ntohs(outer->vlan_proto), outer->vlan_id);
>+		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
> 		if (!skb) {
>-			pr_err("failed to insert VLAN tag\n");
>+			pr_err("failed to insert outer VLAN tag\n");

	Same comment here.

> 			return;
> 		}
> 	}
>@@ -2154,11 +2169,16 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 	struct net_device *upper, *vlan_upper;
> 	struct list_head *iter, *vlan_iter;
> 	struct rtable *rt;
>+	struct bond_vlan_tag inner, outer;
> 	__be32 *targets = bond->params.arp_targets, addr;
>-	int i, vlan_id;
>+	int i;
>
> 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
> 		pr_debug("basa: target %pI4\n", &targets[i]);
>+		inner.vlan_proto = 0;
>+		inner.vlan_id = 0;
>+		outer.vlan_proto = 0;
>+		outer.vlan_id = 0;
>
> 		/* Find out through which dev should the packet go */
> 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
>@@ -2170,12 +2190,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 			if (bond->params.arp_validate && net_ratelimit())
> 				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
> 					bond->dev->name, &targets[i]);
>-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, 0);
>+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
> 			continue;
> 		}
>
>-		vlan_id = 0;
>-
> 		/* bond device itself */
> 		if (rt->dst.dev == bond->dev)
> 			goto found;

	Also, in the code a few lines after the above, there's a "TODO:
QinQ?"  comment.  If you're adding QinQ support, we should probably
remove the TODO reminder.

	-J

>@@ -2192,10 +2210,25 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 						  vlan_iter) {
> 			if (!is_vlan_dev(vlan_upper))
> 				continue;
>+
>+			if (vlan_upper == rt->dst.dev) {
>+				outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
>+				outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
>+				rcu_read_unlock();
>+				goto found;
>+			}
> 			netdev_for_each_all_upper_dev_rcu(vlan_upper, upper,
> 							  iter) {
> 				if (upper == rt->dst.dev) {
>-					vlan_id = vlan_dev_vlan_id(vlan_upper);
>+					/* If the upper dev is a vlan dev too,
>+					 *  set the vlan tag to inner tag.
>+					 */
>+					if (is_vlan_dev(upper)) {
>+						inner.vlan_proto = vlan_dev_vlan_proto(upper);
>+						inner.vlan_id = vlan_dev_vlan_id(upper);
>+					}
>+					outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
>+					outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
> 					rcu_read_unlock();
> 					goto found;
> 				}
>@@ -2208,10 +2241,6 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 		 */
> 		netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
> 			if (upper == rt->dst.dev) {
>-				/* if it's a vlan - get its VID */
>-				if (is_vlan_dev(upper))
>-					vlan_id = vlan_dev_vlan_id(upper);
>-
> 				rcu_read_unlock();
> 				goto found;
> 			}
>@@ -2230,7 +2259,7 @@ found:
> 		addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
> 		ip_rt_put(rt);
> 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>-			      addr, vlan_id);
>+			      addr, &inner, &outer);
> 	}
> }
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 0896f1d..b8bdd0a 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -266,6 +266,11 @@ struct bonding {
> #define bond_slave_get_rtnl(dev) \
> 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
>
>+struct bond_vlan_tag {
>+	__be16		vlan_proto;
>+	unsigned short	vlan_id;
>+};
>+
> /**
>  * Returns NULL if the net_device does not belong to any of the bond's slaves
>  *
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
