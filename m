From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: oops / kernel panic in bonding.
Date: Tue, 22 Mar 2011 11:16:48 +0100
Message-ID: <20110322101648.GB3210@psychotron.brq.redhat.com>
References: <4D8660EC.6080102@gmail.com>
 <4D866F59.5070703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2974 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876Ab1CVKQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 06:16:53 -0400
Content-Disposition: inline
In-Reply-To: <4D866F59.5070703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 20, 2011 at 10:19:21PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 20/03/2011 21:17, Nicolas de Peslo=FCan a =E9crit :
>>Hi Jiri,
>>
>>I suspect we have a race condition somewhere in the new
>>bond_handle_frame function:
>>
>>The following commands produce one of the following errors:
>>
>>modprobe bonding max_bonds=3D0
>>echo +bond0>/sys/class/net/bonding_masters
>>echo +bond1>/sys/class/net/bonding_masters
>>echo +eth1>/sys/class/net/bond1/bonding/slaves
>>
>>This is mostly reproducible, under VirtualBox.
>>
>>All tests done with 08351fc6a75731226e1112fc7254542bd3a2912e at the t=
op
>>commit (current net-next-2.6).
>
>I suspect netdev_rx_handler_register is called too early in bond_ensla=
ve.
>
>I think it should be the last thing we do in bond_enslave, if we
>don't want to face the risk to have bond_handle_frame being called
>before everything is properly setup.
>
>	Nicolas.

Nicolas, would you please give the following patch a drive?

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 1a6e9eb..c339eb1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1482,21 +1482,16 @@ static rx_handler_result_t bond_handle_frame(st=
ruct sk_buff **pskb)
 {
 	struct sk_buff *skb =3D *pskb;
 	struct slave *slave;
-	struct net_device *bond_dev;
 	struct bonding *bond;
=20
-	slave =3D bond_slave_get_rcu(skb->dev);
-	bond_dev =3D ACCESS_ONCE(slave->dev->master);
-	if (unlikely(!bond_dev))
-		return RX_HANDLER_PASS;
-
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
 		return RX_HANDLER_CONSUMED;
=20
 	*pskb =3D skb;
=20
-	bond =3D netdev_priv(bond_dev);
+	slave =3D bond_slave_get_rcu(skb->dev);
+	bond =3D slave->bond;
=20
 	if (bond->params.arp_interval)
 		slave->dev->last_rx =3D jiffies;
@@ -1505,10 +1500,10 @@ static rx_handler_result_t bond_handle_frame(st=
ruct sk_buff **pskb)
 		return RX_HANDLER_EXACT;
 	}
=20
-	skb->dev =3D bond_dev;
+	skb->dev =3D bond->dev;
=20
 	if (bond->params.mode =3D=3D BOND_MODE_ALB &&
-	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
+	    bond->dev->priv_flags & IFF_BRIDGE_PORT &&
 	    skb->pkt_type =3D=3D PACKET_HOST) {
=20
 		if (unlikely(skb_cow_head(skb,
@@ -1516,7 +1511,7 @@ static rx_handler_result_t bond_handle_frame(stru=
ct sk_buff **pskb)
 			kfree_skb(skb);
 			return RX_HANDLER_CONSUMED;
 		}
-		memcpy(eth_hdr(skb)->h_dest, bond_dev->dev_addr, ETH_ALEN);
+		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
 	}
=20
 	return RX_HANDLER_ANOTHER;
@@ -1698,20 +1693,15 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
 		pr_debug("Error %d calling netdev_set_bond_master\n", res);
 		goto err_restore_mac;
 	}
-	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
-					 new_slave);
-	if (res) {
-		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
-		goto err_unset_master;
-	}
=20
 	/* open the slave since the application closed it */
 	res =3D dev_open(slave_dev);
 	if (res) {
 		pr_debug("Opening slave %s failed\n", slave_dev->name);
-		goto err_unreg_rxhandler;
+		goto err_unset_master;
 	}
=20
+	new_slave->bond =3D bond;
 	new_slave->dev =3D slave_dev;
 	slave_dev->priv_flags |=3D IFF_BONDING;
=20
@@ -1907,6 +1897,13 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
 	if (res)
 		goto err_close;
=20
+	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
+					 new_slave);
+	if (res) {
+		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
+		goto err_dest_symlinks;
+	}
+
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
 		bond_is_active_slave(new_slave) ? "n active" : " backup",
@@ -1916,13 +1913,12 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
 	return 0;
=20
 /* Undo stages on error */
+err_dest_symlinks:
+	bond_destroy_slave_symlinks(bond_dev, slave_dev);
+
 err_close:
 	dev_close(slave_dev);
=20
-err_unreg_rxhandler:
-	netdev_rx_handler_unregister(slave_dev);
-	synchronize_net();
-
 err_unset_master:
 	netdev_set_bond_master(slave_dev, NULL);
=20
@@ -1988,6 +1984,12 @@ int bond_release(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
 		return -EINVAL;
 	}
=20
+	/* unregister rx_handler early so bond_handle_frame wouldn't be calle=
d
+	 * for this slave anymore.
+	 */
+	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
+
 	if (!bond->params.fail_over_mac) {
 		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond->slave_cnt > 1)
@@ -2104,8 +2106,6 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 		netif_addr_unlock_bh(bond_dev);
 	}
=20
-	netdev_rx_handler_unregister(slave_dev);
-	synchronize_net();
 	netdev_set_bond_master(slave_dev, NULL);
=20
 	slave_disable_netpoll(slave);
@@ -2171,13 +2171,20 @@ static int bond_release_all(struct net_device *=
bond_dev)
 	bond_change_active_slave(bond, NULL);
=20
 	while ((slave =3D bond->first_slave) !=3D NULL) {
+		slave_dev =3D slave->dev;
+
+		/* unregister rx_handler early so bond_handle_frame wouldn't
+		 * be called for this slave anymore.
+		 */
+		netdev_rx_handler_unregister(slave_dev);
+		synchronize_net();
+
 		/* Inform AD package of unbinding of slave
 		 * before slave is detached from the list.
 		 */
 		if (bond->params.mode =3D=3D BOND_MODE_8023AD)
 			bond_3ad_unbind_slave(slave);
=20
-		slave_dev =3D slave->dev;
 		bond_detach_slave(bond, slave);
=20
 		/* now that the slave is detached, unlock and perform
@@ -2217,8 +2224,6 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 			netif_addr_unlock_bh(bond_dev);
 		}
=20
-		netdev_rx_handler_unregister(slave_dev);
-		synchronize_net();
 		netdev_set_bond_master(slave_dev, NULL);
=20
 		slave_disable_netpoll(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 6b26962..90736cb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -187,6 +187,7 @@ struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct slave *next;
 	struct slave *prev;
+	struct bonding *bond; /* our master */
 	int    delay;
 	unsigned long jiffies;
 	unsigned long last_arp_rx;

