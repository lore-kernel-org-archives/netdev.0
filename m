From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [PATCH] vmxnet3: Fix inconsistent LRO state after initialization
Date: Mon, 16 May 2011 18:28:15 +0200
Message-ID: <201105161828.15237.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:49714 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab1EPRDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:03:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During initialization of vmxnet3, the state of LRO
gets out of sync with netdev->features.

This leads to very poor TCP performance in a IP forwarding
setup and is hitting many VMware users.

Simplified call sequence:
1. vmxnet3_declare_features() initializes "adapter->lro" to true.

2. The kernel automatically disables LRO if IP forwarding is enabled,
so vmxnet3_set_flags() gets called. This also updates netdev->features.

3. Now vmxnet3_setup_driver_shared() is called. "adapter->lro" is still
set to true and LRO gets enabled again, even though
netdev->features shows it's disabled.

Fix it by updating "adapter->lro", too.


The private vmxnet3 adapter flags are scheduled for removal
in net-next, see commit a0d2730c9571aeba793cb5d3009094ee1d8fda35
"net: vmxnet3: convert to hw_features".

Patch applies to 2.6.37 / 2.6.38 and 2.6.39-rc6.

Please CC: comments.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>

diff -u -r -p linux-2.6.37.i686/drivers/net/vmxnet3/vmxnet3_ethtool.c linux-2.6.37.lro/drivers/net/vmxnet3/vmxnet3_ethtool.c
--- linux-2.6.37.i686/drivers/net/vmxnet3/vmxnet3_ethtool.c	2011-05-16 17:43:26.652081801 +0200
+++ linux-2.6.37.lro/drivers/net/vmxnet3/vmxnet3_ethtool.c	2011-05-16 17:47:52.784081802 +0200
@@ -287,6 +287,9 @@ vmxnet3_set_flags(struct net_device *net
 		/* toggle the LRO feature*/
 		netdev->features ^= NETIF_F_LRO;
 
+		/* Update private LRO flag */
+		adapter->lro = lro_requested;
+
 		/* update harware LRO capability accordingly */
 		if (lro_requested)
 			adapter->shared->devRead.misc.uptFeatures |=
