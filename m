From: akpm@linux-foundation.org
Subject: [patch 05/15] net: tun/tap: fixed hw address handling
Date: Thu, 26 Apr 2007 00:27:24 -0700
Message-ID: <200704260727.l3Q7RP9D023955@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linuxkernel@bristyle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34570 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933414AbXDZH2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Braunstein <linuxkernel@bristyle.com>

Fixed tun/tap driver's handling of hw addresses.  The hw address is stored
in both the net_device.dev_addr and tun.dev_addr fields.  These fields were
not kept synchronized, and in fact weren't even initialized to the same
value.  Now during both init and when performing SIOCSIFHWADDR on the tun
device these values are both updated.  However, if SIOCSIFHWADDR is
performed on the net device directly (for instance, setting the hw address
using ifconfig), the tun device does not get updated.  Perhaps the
tun.dev_addr field should be removed completely at some point, as it is
redundant and net_device.dev_addr can be used anywhere it is used.

Signed-off-by: Brian Braunstein <linuxkernel@bristyle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tun.c |   38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff -puN drivers/net/tun.c~net-tun-tap-fixed-hw-address-handling drivers/net/tun.c
--- a/drivers/net/tun.c~net-tun-tap-fixed-hw-address-handling
+++ a/drivers/net/tun.c
@@ -18,6 +18,10 @@
 /*
  *  Changes:
  *
+ *  Brian Braunstein <linuxkernel@bristyle.com> 2007/03/23
+ *    Fixed hw address handling.  Now net_device.dev_addr is kept consistent
+ *    with tun.dev_addr when the address is set by this module.
+ *
  *  Mike Kershaw <dragorn@kismetwireless.net> 2005/08/14
  *    Add TUNSETLINK ioctl to set the link encapsulation
  *
@@ -196,7 +200,10 @@ static void tun_net_init(struct net_devi
 		dev->set_multicast_list = tun_net_mclist;
 
 		ether_setup(dev);
-		random_ether_addr(dev->dev_addr);
+
+		/* random address already created for us by tun_set_iff, use it */
+		memcpy(dev->dev_addr, tun->dev_addr, min(sizeof(tun->dev_addr), sizeof(dev->dev_addr)) );
+
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
@@ -636,6 +643,7 @@ static int tun_chr_ioctl(struct inode *i
 		return 0;
 
 	case SIOCGIFHWADDR:
+		/* Note: the actual net device's address may be different */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev_addr,
 				min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
 		if (copy_to_user( argp, &ifr, sizeof ifr))
@@ -643,16 +651,24 @@ static int tun_chr_ioctl(struct inode *i
 		return 0;
 
 	case SIOCSIFHWADDR:
-		/** Set the character device's hardware address. This is used when
-		 * filtering packets being sent from the network device to the character
-		 * device. */
-		memcpy(tun->dev_addr, ifr.ifr_hwaddr.sa_data,
-				min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
-		DBG(KERN_DEBUG "%s: set hardware address: %x:%x:%x:%x:%x:%x\n",
-				tun->dev->name,
-				tun->dev_addr[0], tun->dev_addr[1], tun->dev_addr[2],
-				tun->dev_addr[3], tun->dev_addr[4], tun->dev_addr[5]);
-		return 0;
+	{
+		/* try to set the actual net device's hw address */
+		int ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
+
+		if (ret == 0) {
+			/** Set the character device's hardware address. This is used when
+			 * filtering packets being sent from the network device to the character
+			 * device. */
+			memcpy(tun->dev_addr, ifr.ifr_hwaddr.sa_data,
+					min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
+			DBG(KERN_DEBUG "%s: set hardware address: %x:%x:%x:%x:%x:%x\n",
+					tun->dev->name,
+					tun->dev_addr[0], tun->dev_addr[1], tun->dev_addr[2],
+					tun->dev_addr[3], tun->dev_addr[4], tun->dev_addr[5]);
+		}
+
+		return  ret;
+	}
 
 	case SIOCADDMULTI:
 		/** Add the specified group to the character device's multicast filter
_
