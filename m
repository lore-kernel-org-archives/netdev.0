From: Brian Braunstein <brian@bristyle.com>
Subject: [PATCH] net: tun/tap: fixed hw address handling
Date: Sun, 25 Mar 2007 01:29:29 -0700
Message-ID: <460632E9.5030508@bristyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vtun@office.satix.net, akpm@osdl.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933224AbXCYIan@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Brian Braunstein <linuxkernel@bristyle.com>

Fixed tun/tap driver's handling of hw addresses. The hw address is stored in
both the net_device.dev_addr and tun.dev_addr fields.  These fields were not
kept synchronized, and in fact weren't even initialized to the same value.
Now during both init and when performing SIOCSIFHWADDR on the tun device
these values are both updated.  However, if SIOCSIFHWADDR is performed on the
net device directly (for instance, setting the hw address using ifconfig),
the tun device does not get updated.  Perhaps the tun.dev_addr field should
be removed completely at some point, as it is redundant and
net_device.dev_addr can be used anywhere it is used. 

Signed-off-by: Brian Braunstein <linuxkernel@bristyle.com>

---

Kernel Version: 2.6.20.4

--- linux-2.6.20.4-ORIG/drivers/net/tun.c	2007-03-23 12:52:51.000000000 -0700
+++ linux-2.6.20.4/drivers/net/tun.c	2007-03-25 00:44:20.000000000 -0700
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
