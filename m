From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/12]: wext: Dispatch and handle compat ioctls entirely in
 net/wireless/wext.c
Date: Tue, 17 Jun 2008 00:54:29 -0700 (PDT)
Message-ID: <20080617.005429.225194068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno@sm.sony.co.jp, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757390AbYFQHy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:54:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


wext: Dispatch and handle compat ioctls entirely in net/wireless/wext.c

Next we can kill the hacks in fs/compat_ioctl.c and also
dispatch compat ioctls down into the driver and 80211 protocol
helper layers in order to handle iw_point objects embedded in
stream replies which need to be translated.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 fs/compat_ioctl.c        |    6 ---
 include/linux/wireless.h |   13 ++++++
 include/net/wext.h       |    7 +++
 net/socket.c             |   10 ++++
 net/wireless/wext.c      |  104 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 134 insertions(+), 6 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 97dba0d..8ab850b 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1757,12 +1757,6 @@ static int do_i2c_smbus_ioctl(unsigned int fd, unsigned int cmd, unsigned long a
 	return sys_ioctl(fd, cmd, (unsigned long)tdata);
 }
 
-struct compat_iw_point {
-	compat_caddr_t pointer;
-	__u16 length;
-	__u16 flags;
-};
-
 static int do_wireless_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	struct iwreq __user *iwr;
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 4a95a0e..79d8468 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -677,6 +677,19 @@ struct	iw_point
   __u16		flags;		/* Optional params */
 };
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+
+#include <linux/compat.h>
+
+struct compat_iw_point {
+	compat_caddr_t pointer;
+	__u16 length;
+	__u16 flags;
+};
+#endif
+#endif
+
 /*
  *	A frequency
  *	For numbers lower than 10^9, we encode the number in 'm' and
diff --git a/include/net/wext.h b/include/net/wext.h
index 80b31d8..6d76a39 100644
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -12,6 +12,8 @@ extern int wext_proc_init(struct net *net);
 extern void wext_proc_exit(struct net *net);
 extern int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 			     void __user *arg);
+extern int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
+				    unsigned long arg);
 #else
 static inline int wext_proc_init(struct net *net)
 {
@@ -26,6 +28,11 @@ static inline int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned
 {
 	return -EINVAL;
 }
+static inline int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
+					   unsigned long arg)
+{
+	return -EINVAL;
+}
 #endif
 
 #endif /* __NET_WEXT_H */
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..81fe825 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -90,6 +90,7 @@
 #include <asm/unistd.h>
 
 #include <net/compat.h>
+#include <net/wext.h>
 
 #include <net/sock.h>
 #include <linux/netfilter.h>
@@ -2210,10 +2211,19 @@ static long compat_sock_ioctl(struct file *file, unsigned cmd,
 {
 	struct socket *sock = file->private_data;
 	int ret = -ENOIOCTLCMD;
+	struct sock *sk;
+	struct net *net;
+
+	sk = sock->sk;
+	net = sock_net(sk);
 
 	if (sock->ops->compat_ioctl)
 		ret = sock->ops->compat_ioctl(sock, cmd, arg);
 
+	if (ret == -ENOIOCTLCMD &&
+	    (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST))
+		ret = compat_wext_handle_ioctl(net, cmd, arg);
+
 	return ret;
 }
 #endif
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 09022cb..1a4636a 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1112,6 +1112,110 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 	return ret;
 }
 
+#ifdef CONFIG_COMPAT
+static int compat_standard_call(struct net_device	*dev,
+				struct iwreq		*iwr,
+				unsigned int		cmd,
+				iw_handler		handler)
+{
+	const struct iw_ioctl_description *descr;
+	struct compat_iw_point *iwp_compat;
+	struct iw_request_info info;
+	struct iw_point iwp;
+	int err;
+
+	descr = standard_ioctl + (cmd - SIOCIWFIRST);
+
+	if (descr->header_type != IW_HEADER_TYPE_POINT)
+		return ioctl_standard_call(dev, iwr, cmd, handler);
+
+	iwp_compat = (struct compat_iw_point *) &iwr->u.data;
+	iwp.pointer = compat_ptr(iwp_compat->pointer);
+	iwp.length = iwp_compat->length;
+	iwp.flags = iwp_compat->flags;
+
+	info.cmd = cmd;
+	info.flags = 0;
+
+	err = ioctl_standard_iw_point(&iwp, cmd, descr, handler, dev, &info);
+
+	iwp_compat->pointer = ptr_to_compat(iwp.pointer);
+	iwp_compat->length = iwp.length;
+	iwp_compat->flags = iwp.flags;
+
+	return err;
+}
+
+static int compat_private_call(struct net_device *dev, struct iwreq *iwr,
+			       unsigned int cmd, iw_handler handler)
+{
+	const struct iw_priv_args *descr;
+	struct iw_request_info info;
+	int ret, extra_size;
+
+	extra_size = get_priv_descr_and_size(dev, cmd, &descr);
+
+	/* Prepare the call */
+	info.cmd = cmd;
+	info.flags = 0;
+
+	/* Check if we have a pointer to user space data or not. */
+	if (extra_size == 0) {
+		/* No extra arguments. Trivial to handle */
+		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
+	} else {
+		struct compat_iw_point *iwp_compat;
+		struct iw_point iwp;
+
+		iwp_compat = (struct compat_iw_point *) &iwr->u.data;
+		iwp.pointer = compat_ptr(iwp_compat->pointer);
+		iwp.length = iwp_compat->length;
+		iwp.flags = iwp_compat->flags;
+
+		ret = ioctl_private_iw_point(&iwp, cmd, descr,
+					     handler, dev, &info, extra_size);
+
+		iwp_compat->pointer = ptr_to_compat(iwp.pointer);
+		iwp_compat->length = iwp.length;
+		iwp_compat->flags = iwp.flags;
+	}
+
+	/* Call commit handler if needed and defined */
+	if (ret == -EIWCOMMIT)
+		ret = call_commit_handler(dev);
+
+	return ret;
+}
+
+int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
+			     unsigned long arg)
+{
+	void __user *argp = (void __user *)arg;
+	struct iwreq iwr;
+	char *colon;
+	int ret;
+
+	if (copy_from_user(&iwr, argp, sizeof(struct iwreq)))
+		return -EFAULT;
+
+	iwr.ifr_name[IFNAMSIZ-1] = 0;
+	colon = strchr(iwr.ifr_name, ':');
+	if (colon)
+		*colon = 0;
+
+	ret = wext_ioctl_dispatch(net, (struct ifreq *) &iwr, cmd,
+				  compat_standard_call,
+				  compat_private_call);
+
+	if (ret >= 0 &&
+	    IW_IS_GET(cmd) &&
+	    copy_to_user(argp, &iwr, sizeof(struct iwreq)))
+		return -EFAULT;
+
+	return ret;
+}
+#endif
+
 /************************* EVENT PROCESSING *************************/
 /*
  * Process events generated by the wireless layer or the driver.
-- 
1.5.5.1.308.g1fbb5

