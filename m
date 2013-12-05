From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/16] net/compat: Merge multiple implementations
 of ifreq::ifr_data conversion
Date: Thu, 5 Dec 2013 23:43:41 +0000
Message-ID: <1386287021.1516.126.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34730 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3LEXno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:43:44 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/socket.c | 49 ++++++-------------------------------------------
 1 file changed, 6 insertions(+), 43 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index fbb6ec13b1f4..7a766ab83ca5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2964,11 +2964,8 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 			 struct compat_ifreq __user *ifr32)
 {
 	struct ifreq kifr;
-	struct ifreq __user *uifr;
 	mm_segment_t old_fs;
 	int err;
-	u32 data;
-	void __user *datap;
 
 	switch (cmd) {
 	case SIOCBONDENSLAVE:
@@ -2985,26 +2982,13 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 		set_fs(old_fs);
 
 		return err;
-	case SIOCBONDSLAVEINFOQUERY:
-	case SIOCBONDINFOQUERY:
-		uifr = compat_alloc_user_space(sizeof(*uifr));
-		if (copy_in_user(&uifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
-			return -EFAULT;
-
-		if (get_user(data, &ifr32->ifr_ifru.ifru_data))
-			return -EFAULT;
-
-		datap = compat_ptr(data);
-		if (put_user(datap, &uifr->ifr_ifru.ifru_data))
-			return -EFAULT;
-
-		return dev_ioctl(net, cmd, uifr);
 	default:
 		return -ENOIOCTLCMD;
 	}
 }
 
-static int siocdevprivate_ioctl(struct net *net, unsigned int cmd,
+/* Handle ioctls that use ifreq::ifr_data and just need struct ifreq converted */
+static int compat_ifr_data_ioctl(struct net *net, unsigned int cmd,
 				 struct compat_ifreq __user *u_ifreq32)
 {
 	struct ifreq __user *u_ifreq64;
@@ -3104,27 +3088,6 @@ static int compat_sioc_ifmap(struct net *net, unsigned int cmd,
 	return err;
 }
 
-static int compat_siocshwtstamp(struct net *net, struct compat_ifreq __user *uifr32)
-{
-	void __user *uptr;
-	compat_uptr_t uptr32;
-	struct ifreq __user *uifr;
-
-	uifr = compat_alloc_user_space(sizeof(*uifr));
-	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
-		return -EFAULT;
-
-	if (get_user(uptr32, &uifr32->ifr_data))
-		return -EFAULT;
-
-	uptr = compat_ptr(uptr32);
-
-	if (put_user(uptr, &uifr->ifr_data))
-		return -EFAULT;
-
-	return dev_ioctl(net, SIOCSHWTSTAMP, uifr);
-}
-
 struct rtentry32 {
 	u32		rt_pad1;
 	struct sockaddr rt_dst;         /* target address               */
@@ -3236,7 +3199,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	struct net *net = sock_net(sk);
 
 	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15))
-		return siocdevprivate_ioctl(net, cmd, argp);
+		return compat_ifr_data_ioctl(net, cmd, argp);
 
 	switch (cmd) {
 	case SIOCSIFBR:
@@ -3256,8 +3219,6 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCBONDENSLAVE:
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
-	case SIOCBONDSLAVEINFOQUERY:
-	case SIOCBONDINFOQUERY:
 	case SIOCBONDCHANGEACTIVE:
 		return bond_ioctl(net, cmd, argp);
 	case SIOCADDRT:
@@ -3267,8 +3228,10 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 		return do_siocgstamp(net, sock, cmd, argp);
 	case SIOCGSTAMPNS:
 		return do_siocgstampns(net, sock, cmd, argp);
+	case SIOCBONDSLAVEINFOQUERY:
+	case SIOCBONDINFOQUERY:
 	case SIOCSHWTSTAMP:
-		return compat_siocshwtstamp(net, argp);
+		return compat_ifr_data_ioctl(net, cmd, argp);
 
 	case FIOSETOWN:
 	case SIOCSPGRP:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
