From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Mon, 18 Jul 2011 09:13:02 +0200
Message-ID: <20110718071300.GA2244@minipsycho>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion>
 <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho>
 <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab1GRHNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 03:13:12 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 17, 2011 at 11:06:57PM CEST, mirqus@gmail.com wrote:
>W dniu 17 lipca 2011 21:44 u=C5=BCytkownik Jiri Pirko <jpirko@redhat.c=
om> napisa=C5=82:
>> Sun, Jul 17, 2011 at 10:36:04AM CEST, mirqus@gmail.com wrote:
>>>W dniu 17 lipca 2011 09:30 u=C5=BCytkownik Jiri Pirko <jpirko@redhat=
=2Ecom> napisa=C5=82:
>>>> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>>>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>>>>> Some devices are not able to enable/disable rx/tw vlan accel sep=
arately.
>>>>>> they depend on ndo_vlan_rx_register to know if to enable of disa=
ble
>>>>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>>>>> this must be resolved.
>>>>>>
>>>>>> One solution might be to enable accel on device start every time=
, even
>>>>>> if there are no vlan up on. But this would change behaviour and =
might
>>>>>> lead to possible regression (on older devices).
>>>>>[...]
>>>>>
>>>>>Please describe the possible regression. As I see it, there won't =
be
>>>>>any user visible change of behaviour - network code takes care of
>>>>>reinserting VLAN tag when necessary. If you think that disabling t=
ag
>>>>>stripping is beneficial for cases where no VLANs are configured, i=
t's
>>>>>better to do that in netdev_fix_features() for devices which adver=
tise
>>>>>NETIF_F_HW_VLAN_RX in hw_features.
>>>>
>>>> Well I just wanted to preserve current behaviour which is that in =
many
>>>> drivers vlan accel is enabled only if some vid is registered upon =
the
>>>> device and it's disabled again when no vid is registered. I can se=
e
>>>> no way to do this with current code after removing ndo_vlan_rx_reg=
ister.
>>>>
>>>> I expect unexpected
>>>
>>>:-D
>>>
>>>> ... problems on old cards when vlan accel would be
>>>> enabled all the time, but maybe I'm wrong...
>>>
>>>Device has no way of knowing how the system uses VLAN tags, stripped
>>>or not. Any problems would be driver problems and since you're makin=
g
>>>it all use generic code, bugs will hit all drivers simultaneously or
>>>(preferably) won't happen at all.
>>>
>>>> One idea is for device which do not support sepatate rx/tx vlan ac=
cel
>>>> enabling/disabling they can probably use ndo_fix_features force to
>>>> enable/disable rx/tx pair together. That would resolve the situati=
on as
>>>> well giving user possibility to turn off vlan accel in case of any=
 issues.
>>>
>>>That is exactly the idea behind ndo_fix_features.
>
>> In netdev_fix_features add check if either one of NETIF_F_HW_VLAN_TX=
 or
>> NETIF_F_HW_VLAN_RX is set and in that case set the other one. Of cou=
rse
>> this would be done only for devices what do not support separate rx/=
tx
>> vlan on/off. But how to distinguish? NETIF_F_HW_VLAN_BOTH feature fl=
ag?
>
>Not in netdev_fix_features(). This case you describe should be handled
>in driver-specific

Well since the code would be the same in many drivers I was thinking
about putting it in general code...

Anyway, would you please look at following example patch and tell me if
it looks good to you?

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 0f481b9..ca70e16 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -555,7 +555,6 @@ struct atl1c_smb {
 struct atl1c_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
-	struct vlan_group   *vlgrp;
 	struct napi_struct  napi;
 	struct atl1c_hw        hw;
 	struct atl1c_hw_stats  hw_stats;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 1269ba5..ad49ad0 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -411,29 +411,30 @@ static void atl1c_set_multi(struct net_device *ne=
tdev)
 	}
 }
=20
-static void atl1c_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+static void __atl1c_vlan_mode(u32 features, u32 *mac_ctrl_data)
+{
+	/* NETIF_F_HW_VLAN_RX is always in same state as NETIF_F_HW_VLAN_TX *=
/
+	if (features & NETIF_F_HW_VLAN_TX) {
+		/* enable VLAN tag insert/strip */
+		*mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
+	} else {
+		/* disable VLAN tag insert/strip */
+		*mac_ctrl_data &=3D ~MAC_CTRL_RMV_VLAN;
+	}
+}
+
+static void atl1c_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct atl1c_adapter *adapter =3D netdev_priv(netdev);
 	struct pci_dev *pdev =3D adapter->pdev;
 	u32 mac_ctrl_data =3D 0;
=20
 	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_vlan_rx_register\n");
+		dev_dbg(&pdev->dev, "atl1c_vlan_mode\n");
=20
 	atl1c_irq_disable(adapter);
-
-	adapter->vlgrp =3D grp;
 	AT_READ_REG(&adapter->hw, REG_MAC_CTRL, &mac_ctrl_data);
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
-	} else {
-		/* disable VLAN tag insert/strip */
-		mac_ctrl_data &=3D ~MAC_CTRL_RMV_VLAN;
-	}
-
+	__atl1c_vlan_mode(features, &mac_ctrl_data);
 	AT_WRITE_REG(&adapter->hw, REG_MAC_CTRL, mac_ctrl_data);
 	atl1c_irq_enable(adapter);
 }
@@ -443,9 +444,10 @@ static void atl1c_restore_vlan(struct atl1c_adapte=
r *adapter)
 	struct pci_dev *pdev =3D adapter->pdev;
=20
 	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_restore_vlan !");
-	atl1c_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+		dev_dbg(&pdev->dev, "atl1c_restore_vlan\n");
+	atl1c_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
+
 /*
  * atl1c_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -483,12 +485,38 @@ static void atl1c_set_rxbufsize(struct atl1c_adap=
ter *adapter,
=20
 static u32 atl1c_fix_features(struct net_device *netdev, u32 features)
 {
+	u32 changed =3D netdev->features ^ features;
+
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure these are always set in pair.
+	 */
+	if ((changed & NETIF_F_HW_VLAN_TX && features & NETIF_F_HW_VLAN_TX) |=
|
+	    (changed & NETIF_F_HW_VLAN_RX && features & NETIF_F_HW_VLAN_RX))
+		features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	else
+		features &=3D ~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+
 	if (netdev->mtu > MAX_TSO_FRAME_SIZE)
 		features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
=20
 	return features;
 }
=20
+static int atl1c_set_features(struct net_device *netdev, u32 features)
+{
+	u32 changed =3D netdev->features ^ features;
+
+	/*
+	 * Test for NETIF_F_HW_VLAN_TX as it's paired with NETIF_F_HW_VLAN_RX
+	 * by atl1c_fix_features.
+	 */
+	if (changed & NETIF_F_HW_VLAN_TX)
+		atl1c_vlan_mode(netdev, features);
+
+	return 0;
+}
+
 /*
  * atl1c_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -1433,8 +1461,7 @@ static void atl1c_setup_mac_ctrl(struct atl1c_ada=
pter *adapter)
 	mac_ctrl_data |=3D ((hw->preamble_len & MAC_CTRL_PRMLEN_MASK) <<
 			MAC_CTRL_PRMLEN_SHIFT);
=20
-	if (adapter->vlgrp)
-		mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
+	__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
=20
 	mac_ctrl_data |=3D MAC_CTRL_BC_EN;
 	if (netdev->flags & IFF_PROMISC)
@@ -1878,14 +1905,14 @@ rrs_checked:
 		skb_put(skb, length - ETH_FCS_LEN);
 		skb->protocol =3D eth_type_trans(skb, netdev);
 		atl1c_rx_checksum(adapter, skb, rrs);
-		if (unlikely(adapter->vlgrp) && rrs->word3 & RRS_VLAN_INS) {
+		if (rrs->word3 & RRS_VLAN_INS) {
 			u16 vlan;
=20
 			AT_TAG_TO_VLAN(rrs->vlan_tag, vlan);
 			vlan =3D le16_to_cpu(vlan);
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vlan);
-		} else
-			netif_receive_skb(skb);
+			__vlan_hwaccel_put_tag(skb, vlan);
+		}
+		netif_receive_skb(skb);
=20
 		(*work_done)++;
 		count++;
@@ -2507,8 +2534,7 @@ static int atl1c_suspend(struct device *dev)
 		/* clear phy interrupt */
 		atl1c_read_phy_reg(hw, MII_ISR, &mii_intr_status_data);
 		/* Config MAC Ctrl register */
-		if (adapter->vlgrp)
-			mac_ctrl_data |=3D MAC_CTRL_RMV_VLAN;
+		__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
=20
 		/* magic packet maybe Broadcast&multicast&Unicast frame */
 		if (wufc & AT_WUFC_MAG)
@@ -2581,14 +2607,14 @@ static const struct net_device_ops atl1c_netdev=
_ops =3D {
 	.ndo_stop		=3D atl1c_close,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_start_xmit		=3D atl1c_xmit_frame,
-	.ndo_set_mac_address 	=3D atl1c_set_mac_addr,
+	.ndo_set_mac_address	=3D atl1c_set_mac_addr,
 	.ndo_set_multicast_list =3D atl1c_set_multi,
 	.ndo_change_mtu		=3D atl1c_change_mtu,
 	.ndo_fix_features	=3D atl1c_fix_features,
+	.ndo_set_features	=3D atl1c_set_features,
 	.ndo_do_ioctl		=3D atl1c_ioctl,
 	.ndo_tx_timeout		=3D atl1c_tx_timeout,
 	.ndo_get_stats		=3D atl1c_get_stats,
-	.ndo_vlan_rx_register	=3D atl1c_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D atl1c_netpoll,
 #endif
@@ -2608,10 +2634,10 @@ static int atl1c_init_netdev(struct net_device =
*netdev, struct pci_dev *pdev)
 	netdev->hw_features =3D	NETIF_F_SG	   |
 				NETIF_F_HW_CSUM	   |
 				NETIF_F_HW_VLAN_TX |
+				NETIF_F_HW_VLAN_RX |
 				NETIF_F_TSO	   |
 				NETIF_F_TSO6;
-	netdev->features =3D	netdev->hw_features |
-				NETIF_F_HW_VLAN_RX;
+	netdev->features =3D	netdev->hw_features;
 	return 0;
 }
=20
--=20
1.7.6

