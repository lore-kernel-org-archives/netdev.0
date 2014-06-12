From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: how to extend bond device features to support  tunneling offloads
Date: Thu, 12 Jun 2014 16:43:35 +0300
Message-ID: <5399AE87.1040308@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:37773 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933410AbaFLNrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 09:47:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So we realized that when bonding is used, the TX path of the IP stack 
above becomes blind to whether the
underlying NIC supports tunneling offloads :(

In a slightly different context, this is addressed for veth in commit 
82d8189 "veth: extend features to support tunneling"  -- now, doing 
quick test with the below RFC patch, I have VXLAN traffic over bonding 
to go through HW LSO where w.o the patch it doesn't.

Do people think bonding needs to recompute the tunneling related 
features (e.g @ hw_features andhw_enc_features) each time the active 
slave changes or we can blindly (...) do it when the bond device is 
being setup in a similar manner to how Eric's patch goes?

Or.


diff --git a/drivers/net/bonding/bond_main.c 
b/drivers/net/bonding/bond_main.c
index d3a6789..3ef6504 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3891,6 +3891,11 @@ static void bond_destructor(struct net_device 
*bond_dev)
         free_netdev(bond_dev);
  }

+
+#define BOND_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO 
|    \
+                      NETIF_F_HW_CSUM | NETIF_F_RXCSUM | 
NETIF_F_HIGHDMA | \
+                      NETIF_F_GSO_UDP_TUNNEL)
+
  void bond_setup(struct net_device *bond_dev)
  {
         struct bonding *bond = netdev_priv(bond_dev);
@@ -3945,6 +3950,8 @@ void bond_setup(struct net_device *bond_dev)
NETIF_F_HW_VLAN_CTAG_FILTER;

         bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
+       bond_dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+       bond_dev->hw_enc_features  = BOND_FEATURES;
         bond_dev->features |= bond_dev->hw_features;
  }
