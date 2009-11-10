From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/compat: fix dev_ifsioc emulation corner cases
Date: Tue, 10 Nov 2009 15:18:20 +0100
Message-ID: <200911101518.21061.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756310AbZKJOSa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handling for SIOCSHWTSTAMP is broken on architectures
with a split user/kernel address space like s390,
because it passes a real user pointer while using
set_fs(KERNEL_DS).
A similar problem might arise the next time somebody
adds code to dev_ifsioc.

Split up dev_ifsioc into three separate functions for
SIOCSHWTSTAMP, SIOC*IFMAP and all other numbers so
we can get rid of set_fs in all potentially affected
cases.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Patrick Ohly <patrick.ohly@intel.com>
Cc: David S. Miller <davem@davemloft.net>
---
 net/socket.c |  119 +++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 73 insertions(+), 46 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 17c98a5..1f2f6d2 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2564,38 +2564,15 @@ static int siocdevprivate_ioctl(struct net *net, unsigned int cmd,
 static int dev_ifsioc(struct net *net, struct socket *sock,
 			 unsigned int cmd, struct compat_ifreq __user *uifr32)
 {
-	struct ifreq ifr;
-	struct compat_ifmap __user *uifmap32;
-	mm_segment_t old_fs;
+	struct ifreq __user *uifr;
 	int err;
-	
-	uifmap32 = &uifr32->ifr_ifru.ifru_map;
-	switch (cmd) {
-	case SIOCSIFMAP:
-		err = copy_from_user(&ifr, uifr32, sizeof(ifr.ifr_name));
-		err |= __get_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
-		err |= __get_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
-		err |= __get_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
-		err |= __get_user(ifr.ifr_map.irq, &uifmap32->irq);
-		err |= __get_user(ifr.ifr_map.dma, &uifmap32->dma);
-		err |= __get_user(ifr.ifr_map.port, &uifmap32->port);
-		if (err)
-			return -EFAULT;
-		break;
-	case SIOCSHWTSTAMP:
-		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
-			return -EFAULT;
-		ifr.ifr_data = compat_ptr(uifr32->ifr_ifru.ifru_data);
-		break;
-	default:
-		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
-			return -EFAULT;
-		break;
-	}
-	old_fs = get_fs();
-	set_fs (KERNEL_DS);
-	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&ifr);
-	set_fs (old_fs);
+
+	uifr = compat_alloc_user_space(sizeof(*uifr));
+	if (copy_in_user(uifr, uifr32, sizeof(*uifr32)))
+		return -EFAULT;
+
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long)uifr);
+
 	if (!err) {
 		switch (cmd) {
 		case SIOCGIFFLAGS:
@@ -2612,18 +2589,7 @@ static int dev_ifsioc(struct net *net, struct socket *sock,
 		case SIOCGIFTXQLEN:
 		case SIOCGMIIPHY:
 		case SIOCGMIIREG:
-			if (copy_to_user(uifr32, &ifr, sizeof(*uifr32)))
-				return -EFAULT;
-			break;
-		case SIOCGIFMAP:
-			err = copy_to_user(uifr32, &ifr, sizeof(ifr.ifr_name));
-			err |= __put_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
-			err |= __put_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
-			err |= __put_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
-			err |= __put_user(ifr.ifr_map.irq, &uifmap32->irq);
-			err |= __put_user(ifr.ifr_map.dma, &uifmap32->dma);
-			err |= __put_user(ifr.ifr_map.port, &uifmap32->port);
-			if (err)
+			if (copy_in_user(uifr32, uifr, sizeof(*uifr32)))
 				err = -EFAULT;
 			break;
 		}
@@ -2631,6 +2597,65 @@ static int dev_ifsioc(struct net *net, struct socket *sock,
 	return err;
 }
 
+static int compat_sioc_ifmap(struct net *net, unsigned int cmd,
+			struct compat_ifreq __user *uifr32)
+{
+	struct ifreq ifr;
+	struct compat_ifmap __user *uifmap32;
+	mm_segment_t old_fs;
+	int err;
+
+	uifmap32 = &uifr32->ifr_ifru.ifru_map;
+	err = copy_from_user(&ifr, uifr32, sizeof(ifr.ifr_name));
+	err |= __get_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
+	err |= __get_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
+	err |= __get_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
+	err |= __get_user(ifr.ifr_map.irq, &uifmap32->irq);
+	err |= __get_user(ifr.ifr_map.dma, &uifmap32->dma);
+	err |= __get_user(ifr.ifr_map.port, &uifmap32->port);
+	if (err)
+		return -EFAULT;
+
+	old_fs = get_fs();
+	set_fs (KERNEL_DS);
+	err = dev_ioctl(net, cmd, (void __user *)&ifr);
+	set_fs (old_fs);
+
+	if (cmd == SIOCGIFMAP && !err) {
+		err = copy_to_user(uifr32, &ifr, sizeof(ifr.ifr_name));
+		err |= __put_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
+		err |= __put_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
+		err |= __put_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
+		err |= __put_user(ifr.ifr_map.irq, &uifmap32->irq);
+		err |= __put_user(ifr.ifr_map.dma, &uifmap32->dma);
+		err |= __put_user(ifr.ifr_map.port, &uifmap32->port);
+		if (err)
+			err = -EFAULT;
+	}
+	return err;
+}
+
+static int compat_siocshwtstamp(struct net *net, struct compat_ifreq __user *uifr32)
+{
+	void __user *uptr;
+	compat_uptr_t uptr32;
+	struct ifreq __user *uifr;
+
+	uifr = compat_alloc_user_space(sizeof (*uifr));
+	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
+		return -EFAULT;
+
+	if (get_user(uptr32, &uifr32->ifr_data))
+		return -EFAULT;
+
+	uptr = compat_ptr(uptr32);
+
+	if (put_user(uptr, &uifr->ifr_data))
+		return -EFAULT;
+
+	return dev_ioctl(net, SIOCSHWTSTAMP, uifr);
+}
+
 struct rtentry32 {
         u32   		rt_pad1;
         struct sockaddr rt_dst;         /* target address               */
@@ -2923,6 +2948,9 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 		return ethtool_ioctl(net, argp);
 	case SIOCWANDEV:
 		return compat_siocwandev(net, argp);
+	case SIOCGIFMAP:
+	case SIOCSIFMAP:
+		return compat_sioc_ifmap(net, cmd, argp);
 	case SIOCBONDENSLAVE:
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
@@ -2937,6 +2965,8 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 		return do_siocgstamp(net, sock, cmd, argp);
 	case SIOCGSTAMPNS:
 		return do_siocgstampns(net, sock, cmd, argp);
+	case SIOCSHWTSTAMP:
+		return compat_siocshwtstamp(net, argp);
 
 	case FIOSETOWN:
 	case SIOCSPGRP:
@@ -2963,12 +2993,9 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCADDMULTI:
 	case SIOCDELMULTI:
 	case SIOCGIFINDEX:
-	case SIOCGIFMAP:
-	case SIOCSIFMAP:
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCSIFHWBROADCAST:
-	case SIOCSHWTSTAMP:
 	case SIOCDIFADDR:
 	case SIOCGIFBRDADDR:
 	case SIOCSIFBRDADDR:
-- 
1.6.3.3
