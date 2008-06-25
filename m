From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/4] tun: TUNSETFEATURES to set gso features.
Date: Thu, 26 Jun 2008 00:29:39 +1000
Message-ID: <200806260029.40267.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39667 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYFYOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:30:46 -0400
In-Reply-To: <200806260028.07883.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool is useful for setting (some) device fields, but it's
root-only.  Finer feature control is available through a tun-specific
ioctl.

(Includes Mark McLoughlin <markmc@redhat.com>'s fix to hold rtnl sem).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |   43 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_tun.h |    7 +++++++
 2 files changed, 50 insertions(+)

diff -r e08e6c5130ff drivers/net/tun.c
--- a/drivers/net/tun.c	Thu Jun 26 00:17:07 2008 +1000
+++ b/drivers/net/tun.c	Thu Jun 26 00:21:11 2008 +1000
@@ -596,6 +596,46 @@ static int tun_set_iff(struct net *net, 
 	return err;
 }
 
+/* This is like a cut-down ethtool ops, except done via tun fd so no
+ * privs required. */
+static int set_offload(struct net_device *dev, unsigned long arg)
+{
+	unsigned int old_features, features;
+
+	old_features = dev->features;
+	/* Unset features, set them as we chew on the arg. */
+	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST
+				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6));
+
+	if (arg & TUN_F_CSUM) {
+		features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		arg &= ~TUN_F_CSUM;
+
+		if (arg & (TUN_F_TSO4|TUN_F_TSO6)) {
+			if (arg & TUN_F_TSO_ECN) {
+				features |= NETIF_F_TSO_ECN;
+				arg &= ~TUN_F_TSO_ECN;
+			}
+			if (arg & TUN_F_TSO4)
+				features |= NETIF_F_TSO;
+			if (arg & TUN_F_TSO6)
+				features |= NETIF_F_TSO6;
+			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
+		}
+	}
+
+	/* This gives the user a way to test for new features in future by
+	 * trying to set them. */
+	if (arg)
+		return -EINVAL;
+
+	dev->features = features;
+	if (old_features != dev->features)
+		netdev_features_change(dev);
+
+	return 0;
+}
+
 static int tun_chr_ioctl(struct inode *inode, struct file *file,
 			 unsigned int cmd, unsigned long arg)
 {
@@ -699,6 +739,15 @@ static int tun_chr_ioctl(struct inode *i
 		tun->debug = arg;
 		break;
 #endif
+
+	case TUNSETOFFLOAD:
+	{
+		int ret;
+		rtnl_lock();
+		ret = set_offload(tun->dev, arg);
+		rtnl_unlock();
+		return ret;
+	}
 
 	case SIOCGIFFLAGS:
 		ifr.ifr_flags = tun->if_flags;
diff -r e08e6c5130ff include/linux/if_tun.h
--- a/include/linux/if_tun.h	Thu Jun 26 00:17:07 2008 +1000
+++ b/include/linux/if_tun.h	Thu Jun 26 00:21:11 2008 +1000
@@ -43,12 +43,19 @@
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
 #define TUNGETFEATURES _IOR('T', 207, unsigned int)
+#define TUNSETOFFLOAD _IOW('T', 208, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
 #define IFF_TAP		0x0002
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
+
+/* Features for GSO (TUNSETOFFLOAD). */
+#define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
+#define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */
+#define TUN_F_TSO6	0x04	/* I can handle TSO for IPv6 packets */
+#define TUN_F_TSO_ECN	0x08	/* I can handle TSO with ECN bits. */
 
 struct tun_pi {
 	unsigned short flags;
