From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Thu, 23 Apr 2009 14:04:50 -0700
Message-ID: <13724.1240520690@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:38651 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015AbZDWVEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 17:04:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NKsDE3014796
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 16:54:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NL4jpI168760
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 17:04:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NL4ikg014068
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 17:04:45 -0400
In-reply-to: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Added VLAN maintainer to cc, patch enclosed ]

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>I hope that you can help clarify what's the correct/supported method
>to work with vlans and bonds, with 2.6.29 I see that one can either
>
>	- vlan a bond (bond0.4001 over bond0 over eth0/1.4001)
>	- bond vlans (e.g bond0 over eth0/1.4001)
>
>I played a bit with bonding vlans (2.6.29 active-backup mode) and it
>doesn't seem to work - specifically, I noted that bonding doesn't issue
>fail-over after I changed the current slave link status to down ("ifconfig
>eth0.4001 down"). I suspect that the carrier based link monitoring scheme
>is broken wrt to vlan devices - e.g I found that at least from sysfs
>perspective the vlan device carrier isn't available:
>
>$ cat /sys/class/net/eth0.4001/carrier
>cat: /sys/class/net/eth0.4001/carrier: Invalid argument

	Ok, I just got a minute to fool with this, and it appears to
sort of work for me on a relatively recent cut of net-2.6 (approximately
2.6.30-rc1).  I didn't try 2.6.29 exactly, but the only issues I had
with the version I used are as described below.

	I suspect the "carrier: Invalid argument" response you describe
above is a result of the show_carrier function in net-sysfs.c, which
returns EINVAL if the device is not netif_running.  If the device (vlan
or not) is running, the carrier is returned.

	Anyway, configuring a bond over two VLAN devices (bond0 ->
eth{0,1}.600 -> eth0{0,1}), it configures and comes up fine.

	If I pull the cable for eth0 or eth1, the vlan device's carrier
state updates correctly, and bonding fails over.

	However, if I set eth0.VLAN or eth0 itself administratively
down, no failover takes place.  This is apparently because the VLAN
device doesn't adjust its carrier state for UP or DOWN events from the
underlying real device or for open/close of the VLAN device itself.  It
does update the carrier state for CHANGE events (from linkwatch, for
example).

	So, here's a patch with a description.  This resolves the
bonding problem for me; it might have other undesirable side effects,
though.  It's debatable whether it's really necessary, but it does make
the VLAN device behave more like a real network device in this case:

[PATCH] vlan: update vlan carrier state for admin up/down

	Currently, the VLAN event handler does not adjust the VLAN
device's carrier state when the real device or the VLAN device is set
administratively up or down.

	The following patch adds a transfer of operating state from the
real device to the VLAN device when the real device is administratively
set up or down, and sets the carrier state up or down during init, open
and close of the VLAN device.

	This permits observers above the VLAN device that care about the
carrier state (bonding's link monitor, for example) to receive updates
for administrative changes by more closely mimicing the behavior of real
devices.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2b7390e..d1e1054 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -492,6 +492,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 				continue;
 
 			dev_change_flags(vlandev, flgs & ~IFF_UP);
+			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
 
@@ -507,6 +508,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 				continue;
 
 			dev_change_flags(vlandev, flgs | IFF_UP);
+			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1b34135..2ce6658 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -462,6 +462,7 @@ static int vlan_dev_open(struct net_device *dev)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_join(dev);
 
+	netif_carrier_on(dev);
 	return 0;
 
 clear_allmulti:
@@ -471,6 +472,7 @@ del_unicast:
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
 out:
+	netif_carrier_off(dev);
 	return err;
 }
 
@@ -492,6 +494,7 @@ static int vlan_dev_stop(struct net_device *dev)
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
 
+	netif_carrier_off(dev);
 	return 0;
 }
 
@@ -612,6 +615,8 @@ static int vlan_dev_init(struct net_device *dev)
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 	int subclass = 0;
 
+	netif_carrier_off(dev);
+
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
 	dev->iflink = real_dev->ifindex;
