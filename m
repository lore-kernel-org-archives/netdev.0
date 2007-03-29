From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [PATCH] net: tun/tap: fixed hw address handling
Date: Thu, 29 Mar 2007 14:07:11 -0400
Message-ID: <460C004F.8050702@redhat.com>
References: <460632E9.5030508@bristyle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070605000000030108090104"
Cc: Max Krasnyansky <maxk@qualcomm.com>, vtun@office.satix.net,
	akpm@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Brian Braunstein <brian@bristyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030603AbXC2SJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 14:09:43 -0400
In-Reply-To: <460632E9.5030508@bristyle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070605000000030108090104
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Brian Braunstein wrote:
> 
> From: Brian Braunstein <linuxkernel@bristyle.com>
> 
> Fixed tun/tap driver's handling of hw addresses.

Okay, the attached patch applies. Can someone comment on whether
it makes sense? (pasted inline for comments)

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

--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -196,7 +196,10 @@ static void tun_net_init(struct net_devi
                dev->set_multicast_list = tun_net_mclist;

                ether_setup(dev);
-               random_ether_addr(dev->dev_addr);
+
+               /* random address already created for us by tun_set_iff, use it */
+               memcpy(dev->dev_addr, tun->dev_addr, min(sizeof(tun->dev_addr), sizeof(dev->dev_addr)) );
+
                dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
                break;
        }
@@ -636,6 +639,7 @@ static int tun_chr_ioctl(struct inode *i
                return 0;

        case SIOCGIFHWADDR:
+               /* Note: the actual net device's address may be different */
                memcpy(ifr.ifr_hwaddr.sa_data, tun->dev_addr,
                                min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
                if (copy_to_user( argp, &ifr, sizeof ifr))
@@ -643,16 +647,22 @@ static int tun_chr_ioctl(struct inode *i
                return 0;

        case SIOCSIFHWADDR:
-               /** Set the character device's hardware address. This is used when
-                * filtering packets being sent from the network device to the character
-                * device. */
-               memcpy(tun->dev_addr, ifr.ifr_hwaddr.sa_data,
-                               min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
-               DBG(KERN_DEBUG "%s: set hardware address: %x:%x:%x:%x:%x:%x\n",
-                               tun->dev->name,
-                               tun->dev_addr[0], tun->dev_addr[1], tun->dev_addr[2],
-                               tun->dev_addr[3], tun->dev_addr[4], tun->dev_addr[5]);
-               return 0;
+               /* try to set the actual net device's hw address */
+               int ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
+
+               if (ret == 0) {
+                       /** Set the character device's hardware address. This is used when
+                        * filtering packets being sent from the network device to the character
+                        * device. */
+                       memcpy(tun->dev_addr, ifr.ifr_hwaddr.sa_data,
+                                       min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
+                       DBG(KERN_DEBUG "%s: set hardware address: %x:%x:%x:%x:%x:%x\n",
+                                       tun->dev->name,
+                                       tun->dev_addr[0], tun->dev_addr[1], tun->dev_addr[2],
+                                       tun->dev_addr[3], tun->dev_addr[4], tun->dev_addr[5]);
+               }
+
+               return  ret;

        case SIOCADDMULTI:
                /** Add the specified group to the character device's multicast filter



--------------070605000000030108090104
Content-Type: text/plain;
 name="linux-2.6-20.5t-tuntap_fix_set_hw_address.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-20.5t-tuntap_fix_set_hw_address.patch"

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

--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -196,7 +196,10 @@ static void tun_net_init(struct net_devi
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
@@ -636,6 +639,7 @@ static int tun_chr_ioctl(struct inode *i
 		return 0;
 
 	case SIOCGIFHWADDR:
+		/* Note: the actual net device's address may be different */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev_addr,
 				min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
 		if (copy_to_user( argp, &ifr, sizeof ifr))
@@ -643,16 +647,22 @@ static int tun_chr_ioctl(struct inode *i
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
 
 	case SIOCADDMULTI:
 		/** Add the specified group to the character device's multicast filter

--------------070605000000030108090104--
