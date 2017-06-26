From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] separate SIOCGIFCONF from the rest of dev_ioctl()
Date: Mon, 26 Jun 2017 18:40:33 +0100
Message-ID: <20170626174033.GA10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43720 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdFZRkk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 13:40:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[
This is just an RFC - I'm not asking to apply it at the moment.  Are there
any objections in principle to that change?
]

	Only two of dev_ioctl() callers may pass SIOCGIFCONF to it.
Separating that codepath from the rest of dev_ioctl() allows both
to simplify dev_ioctl() itself (all other cases work with struct ifreq *)
*and* seriously simplify the compat side of that beast: all it takes
is passing to inet_gifconf() an extra argument - the size of individual
records (sizeof(struct ifreq) or sizeof(struct compat_ifreq)).  With
dev_ifconf() called directly from sock_do_ioctl()/compat_dev_ifconf()
that's easy to arrange.

As the result, compat side of SIOCGIFCONF doesn't need any
allocations, copy_in_user() back and forth, etc.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2efb56..84428fd0c999 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2729,7 +2729,8 @@ static inline bool dev_validate_header(const struct net_device *dev,
 	return false;
 }
 
-typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
+typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr,
+			   int len, int size);
 int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
 static inline int unregister_gifconf(unsigned int family)
 {
@@ -3278,6 +3279,7 @@ void netdev_rx_handler_unregister(struct net_device *dev);
 
 bool dev_valid_name(const char *name);
 int dev_ioctl(struct net *net, unsigned int cmd, void __user *);
+int dev_ifconf(struct net *net, struct ifconf *, int);
 int dev_ethtool(struct net *net, struct ifreq *);
 unsigned int dev_get_flags(const struct net_device *);
 int __dev_change_flags(struct net_device *, unsigned int flags);
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index b94b1d293506..b98d1860b29a 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -64,9 +64,8 @@ EXPORT_SYMBOL(register_gifconf);
  *	Thus we will need a 'compatibility mode'.
  */
 
-static int dev_ifconf(struct net *net, char __user *arg)
+int dev_ifconf(struct net *net, struct ifconf *ifc, int size)
 {
-	struct ifconf ifc;
 	struct net_device *dev;
 	char __user *pos;
 	int len;
@@ -77,11 +76,8 @@ static int dev_ifconf(struct net *net, char __user *arg)
 	 *	Fetch the caller's info block.
 	 */
 
-	if (copy_from_user(&ifc, arg, sizeof(struct ifconf)))
-		return -EFAULT;
-
-	pos = ifc.ifc_buf;
-	len = ifc.ifc_len;
+	pos = ifc->ifc_buf;
+	len = ifc->ifc_len;
 
 	/*
 	 *	Loop over the interfaces, and write an info block for each.
@@ -93,10 +89,10 @@ static int dev_ifconf(struct net *net, char __user *arg)
 			if (gifconf_list[i]) {
 				int done;
 				if (!pos)
-					done = gifconf_list[i](dev, NULL, 0);
+					done = gifconf_list[i](dev, NULL, 0, size);
 				else
 					done = gifconf_list[i](dev, pos + total,
-							       len - total);
+							       len - total, size);
 				if (done < 0)
 					return -EFAULT;
 				total += done;
@@ -107,12 +103,12 @@ static int dev_ifconf(struct net *net, char __user *arg)
 	/*
 	 *	All done.  Write the updated control block back to the caller.
 	 */
-	ifc.ifc_len = total;
+	ifc->ifc_len = total;
 
 	/*
 	 * 	Both BSD and Solaris return 0 here, so we do too.
 	 */
-	return copy_to_user(arg, &ifc, sizeof(struct ifconf)) ? -EFAULT : 0;
+	return 0;
 }
 
 /*
@@ -396,17 +392,6 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	int ret;
 	char *colon;
 
-	/* One special case: SIOCGIFCONF takes ifconf argument
-	   and requires shared lock, because it sleeps writing
-	   to user space.
-	 */
-
-	if (cmd == SIOCGIFCONF) {
-		rtnl_lock();
-		ret = dev_ifconf(net, (char __user *) arg);
-		rtnl_unlock();
-		return ret;
-	}
 	if (cmd == SIOCGIFNAME)
 		return dev_ifname(net, (struct ifreq __user *)arg);
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index df14815a3b8c..8f4621591556 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1160,22 +1160,25 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	goto out;
 }
 
-static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
+static int inet_gifconf(struct net_device *dev, char __user *buf, int len, int size)
 {
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 	struct in_ifaddr *ifa;
 	struct ifreq ifr;
 	int done = 0;
 
+	if (WARN_ON(size > sizeof(struct ifreq)))
+		goto out;
+
 	if (!in_dev)
 		goto out;
 
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
 		if (!buf) {
-			done += sizeof(ifr);
+			done += size;
 			continue;
 		}
-		if (len < (int) sizeof(ifr))
+		if (len < size)
 			break;
 		memset(&ifr, 0, sizeof(struct ifreq));
 		strcpy(ifr.ifr_name, ifa->ifa_label);
@@ -1184,13 +1187,12 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
 		(*(struct sockaddr_in *)&ifr.ifr_addr).sin_addr.s_addr =
 								ifa->ifa_local;
 
-		if (copy_to_user(buf, &ifr, sizeof(struct ifreq))) {
+		if (copy_to_user(buf + done, &ifr, size)) {
 			done = -EFAULT;
 			break;
 		}
-		buf  += sizeof(struct ifreq);
-		len  -= sizeof(struct ifreq);
-		done += sizeof(struct ifreq);
+		len  -= size;
+		done += size;
 	}
 out:
 	return done;
diff --git a/net/socket.c b/net/socket.c
index c2564eb25c6b..46d026a95ad9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -909,10 +909,22 @@ static long sock_do_ioctl(struct net *net, struct socket *sock,
 	 * If this ioctl is unknown try to hand it down
 	 * to the NIC driver.
 	 */
-	if (err == -ENOIOCTLCMD)
-		err = dev_ioctl(net, cmd, argp);
+	if (err != -ENOIOCTLCMD)
+		return err;
 
-	return err;
+	if (cmd == SIOCGIFCONF) {
+		struct ifconf ifc;
+		if (copy_from_user(&ifc, argp, sizeof(struct ifconf)))
+			return -EFAULT;
+		rtnl_lock();
+		err = dev_ifconf(net, &ifc, sizeof(struct ifreq));
+		rtnl_unlock();
+		if (!err && copy_to_user(argp, &ifc, sizeof(struct ifconf)))
+			err = -EFAULT;
+		return err;
+	}
+
+	return dev_ioctl(net, cmd, argp);
 }
 
 /*
@@ -2659,70 +2671,25 @@ static int dev_ifname32(struct net *net, struct compat_ifreq __user *uifr32)
 	return 0;
 }
 
-static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
+static int compat_dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 {
 	struct compat_ifconf ifc32;
 	struct ifconf ifc;
-	struct ifconf __user *uifc;
-	struct compat_ifreq __user *ifr32;
-	struct ifreq __user *ifr;
-	unsigned int i, j;
 	int err;
 
 	if (copy_from_user(&ifc32, uifc32, sizeof(struct compat_ifconf)))
 		return -EFAULT;
 
-	memset(&ifc, 0, sizeof(ifc));
-	if (ifc32.ifcbuf == 0) {
-		ifc32.ifc_len = 0;
-		ifc.ifc_len = 0;
-		ifc.ifc_req = NULL;
-		uifc = compat_alloc_user_space(sizeof(struct ifconf));
-	} else {
-		size_t len = ((ifc32.ifc_len / sizeof(struct compat_ifreq)) + 1) *
-			sizeof(struct ifreq);
-		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
-		ifc.ifc_len = len;
-		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
-		ifr32 = compat_ptr(ifc32.ifcbuf);
-		for (i = 0; i < ifc32.ifc_len; i += sizeof(struct compat_ifreq)) {
-			if (copy_in_user(ifr, ifr32, sizeof(struct compat_ifreq)))
-				return -EFAULT;
-			ifr++;
-			ifr32++;
-		}
-	}
-	if (copy_to_user(uifc, &ifc, sizeof(struct ifconf)))
-		return -EFAULT;
+	ifc.ifc_len = ifc32.ifc_len;
+	ifc.ifc_req = compat_ptr(ifc32.ifcbuf);
 
-	err = dev_ioctl(net, SIOCGIFCONF, uifc);
+	rtnl_lock();
+	err = dev_ifconf(net, &ifc, sizeof(struct compat_ifreq));
+	rtnl_unlock();
 	if (err)
 		return err;
 
-	if (copy_from_user(&ifc, uifc, sizeof(struct ifconf)))
-		return -EFAULT;
-
-	ifr = ifc.ifc_req;
-	ifr32 = compat_ptr(ifc32.ifcbuf);
-	for (i = 0, j = 0;
-	     i + sizeof(struct compat_ifreq) <= ifc32.ifc_len && j < ifc.ifc_len;
-	     i += sizeof(struct compat_ifreq), j += sizeof(struct ifreq)) {
-		if (copy_in_user(ifr32, ifr, sizeof(struct compat_ifreq)))
-			return -EFAULT;
-		ifr32++;
-		ifr++;
-	}
-
-	if (ifc32.ifcbuf == 0) {
-		/* Translate from 64-bit structure multiple to
-		 * a 32-bit one.
-		 */
-		i = ifc.ifc_len;
-		i = ((i / sizeof(struct ifreq)) * sizeof(struct compat_ifreq));
-		ifc32.ifc_len = i;
-	} else {
-		ifc32.ifc_len = i;
-	}
+	ifc32.ifc_len = ifc.ifc_len;
 	if (copy_to_user(uifc32, &ifc32, sizeof(struct compat_ifconf)))
 		return -EFAULT;
 
@@ -3119,7 +3086,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCGIFNAME:
 		return dev_ifname32(net, argp);
 	case SIOCGIFCONF:
-		return dev_ifconf(net, argp);
+		return compat_dev_ifconf(net, argp);
 	case SIOCETHTOOL:
 		return ethtool_ioctl(net, argp);
 	case SIOCWANDEV:
