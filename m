From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] net: netdevice mtu assumptions documentation
Date: Fri, 6 Jul 2007 11:31:17 -0700
Message-ID: <20070706113117.68184d0e@freepuppy.rosehill.hemminger.net>
References: <20070706112623.478aedcf@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33873 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756234AbXGFScB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 14:32:01 -0400
In-Reply-To: <20070706112623.478aedcf@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document the expectations about device MTU handling.
The documentation about oversize packet handling is probably too
loose.

IMHO devices should drop oversize packets for robustness,
but many devices allow it now. For example, if you set mtu to 1200
bytes, most ether devices will allow a 1500 byte frame in.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/Documentation/networking/netdevices.txt	2007-07-06 10:16:41.000000000 -0700
+++ b/Documentation/networking/netdevices.txt	2007-07-06 10:17:22.000000000 -0700
@@ -20,6 +20,31 @@ private data which gets freed when the n
 separately allocated data is attached to the network device
 (dev->priv) then it is up to the module exit handler to free that.
 
+MTU
+===
+Each network device has a Maximum Transfer Unit. The MTU does not
+include any link layer protocol overhead. Upper layer protocols must
+not pass a socket buffer (skb) to a device to transmit with more data
+than the mtu. The MTU does not include link layer header overhead, so
+for example on Ethernet if the standard MTU is 1500 bytes used, the
+actual skb will contain up to 1514 bytes because of the Ethernet
+header. Devices should allow for the 4 byte VLAN header as well.
+
+Segmentation Offload (GSO, TSO) is an exception to this rule.  The
+upper layer protocol may pass a large socket buffer to the device
+transmit routine, and the device will break that up into separate
+packets based on the current MTU.
+
+MTU is symmetrical and applies both to receive and transmit. A device
+must be able to receive at least the maximum size packet allowed by
+the MTU. A network device may use the MTU as mechanism to size receive
+buffers, but the device should allow packets with VLAN header. With
+standard Ethernet mtu of 1500 bytes, the device should allow up to
+1518 byte packets (1500 + 14 header + 4 tag).  The device may either:
+drop, truncate, or pass up oversize packets, but dropping oversize
+packets is preferred.
+
+
 struct net_device synchronization rules
 =======================================
 dev->open:
@@ -46,7 +71,7 @@ dev->hard_start_xmit:
 	When the driver sets NETIF_F_LLTX in dev->features this will be
 	called without holding netif_tx_lock. In this case the driver
 	has to lock by itself when needed. It is recommended to use a try lock
-	for this and return NETDEV_TX_LOCKED when the spin lock fails.
+	for this and return NETDEV_TX_LOCKED when the spin lock fails.
 	The locking there should also properly protect against 
 	set_multicast_list.
 
