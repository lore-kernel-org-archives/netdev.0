From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 3/3] net/compat/wext: send different messages to compat
 tasks
Date: Wed, 24 Jun 2009 13:34:50 +0200
Message-ID: <20090624113731.935845071@sipsolutions.net>
References: <20090624113447.441667549@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=005-wext-event-compat.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wireless extensions have the unfortunate problem that events
are multicast netlink messages, and are not independent of
pointer size. Thus, currently 32-bit tasks on 64-bit platforms
cannot properly receive events and fail with all kinds of
strange problems, for instance wpa_supplicant never notices
disassociations, due to the way the 64-bit event looks (to a
32-bit process), the fact that the address is all zeroes is
lost, it thinks instead it is 00:00:00:00:01:00.

The same problem existed with the ioctls, until David Miller
fixed those some time ago in an heroic effort.

A different problem caused by this is that we cannot send the
ASSOCREQIE/ASSOCRESPIE events because sending them causes a
32-bit wpa_supplicant on a 64-bit system to overwrite its
internal information, which is worse than it not getting the
information at all -- so we currently resort to sending a
custom string event that it then parses. This, however, has a
severe size limitation we are frequently hitting with modern
access points; this limitation would can be lifted after this
patch by sending the correct binary, not custom, event.

A similar problem apparently happens for some other netlink
users on x86_64 with 32-bit tasks due to the alignment for
64-bit quantities.

In order to fix these problems, I have implemented a way to
send compat messages to tasks. When sending an event, we send
the non-compat event data together with a compat event data in
skb_shinfo(main_skb)->frag_list. Then, when the event is read
from the socket, the netlink code makes sure to pass out only
the skb that is compatible with the task. This approach was
suggested by David Miller, my original approach required
always sending two skbs but that had various small problems.

To determine whether compat is needed or not, I have used the
MSG_CMSG_COMPAT flag, and adjusted the call path for recv and
recvfrom to include it, even if those calls do not have a cmsg
parameter.

I have not solved one small part of the problem, and I don't
think it is necessary to: if a 32-bit application uses read()
rather than any form of recvmsg() it will still get the wrong
(64-bit) event. However, neither do applications actually do
this, nor would it be a regression.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
v2: * after some discussion with davem, use frag_list as noted,
      and note that there are more possible uses for this
    * add another Kconfig symbol for code that can use select
      for the feature
    * add help, in Kconfig, describing the feature

 arch/mips/kernel/scall64-n32.S |    2 -
 arch/mips/kernel/scall64-o32.S |    4 +-
 arch/sparc/kernel/sys32.S      |    2 -
 include/linux/wireless.h       |    8 ++++
 net/Kconfig                    |   20 ++++++++++
 net/compat.c                   |   17 +++++++-
 net/netlink/af_netlink.c       |   21 +++++++++++
 net/wireless/wext.c            |   78 +++++++++++++++++++++++++++++++++++++++++
 8 files changed, 146 insertions(+), 6 deletions(-)

--- wireless-testing.orig/net/wireless/wext.c	2009-06-24 13:31:59.000000000 +0200
+++ wireless-testing/net/wireless/wext.c	2009-06-24 13:32:02.000000000 +0200
@@ -417,6 +417,21 @@ static const int event_type_size[] = {
 	IW_EV_QUAL_LEN,			/* IW_HEADER_TYPE_QUAL */
 };
 
+#ifdef CONFIG_COMPAT
+static const int compat_event_type_size[] = {
+	IW_EV_COMPAT_LCP_LEN,		/* IW_HEADER_TYPE_NULL */
+	0,
+	IW_EV_COMPAT_CHAR_LEN,		/* IW_HEADER_TYPE_CHAR */
+	0,
+	IW_EV_COMPAT_UINT_LEN,		/* IW_HEADER_TYPE_UINT */
+	IW_EV_COMPAT_FREQ_LEN,		/* IW_HEADER_TYPE_FREQ */
+	IW_EV_COMPAT_ADDR_LEN,		/* IW_HEADER_TYPE_ADDR */
+	0,
+	IW_EV_COMPAT_POINT_LEN,		/* Without variable payload */
+	IW_EV_COMPAT_PARAM_LEN,		/* IW_HEADER_TYPE_PARAM */
+	IW_EV_COMPAT_QUAL_LEN,		/* IW_HEADER_TYPE_QUAL */
+};
+#endif
 
 /************************ COMMON SUBROUTINES ************************/
 /*
@@ -1341,6 +1356,22 @@ void wireless_send_event(struct net_devi
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
 	struct nlattr *nla;
+#ifdef CONFIG_COMPAT
+	struct __compat_iw_event *compat_event;
+	struct compat_iw_point compat_wrqu;
+	struct sk_buff *compskb;
+#endif
+
+	/*
+	 * Nothing in the kernel sends scan events with data, be safe.
+	 * This is necessary because we cannot fix up scan event data
+	 * for compat, due to being contained in 'extra', but normally
+	 * applications are required to retrieve the scan data anyway
+	 * and no data is included in the event, this codifies that
+	 * practice.
+	 */
+	if (WARN_ON(cmd == SIOCGIWSCAN && extra))
+		extra = NULL;
 
 	/* Get the description of the Event */
 	if (cmd <= SIOCIWLAST) {
@@ -1439,7 +1470,54 @@ void wireless_send_event(struct net_devi
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
 	nlmsg_end(skb, nlh);
+#ifdef CONFIG_COMPAT
+	hdr_len = compat_event_type_size[descr->header_type];
+	event_len = hdr_len + extra_len;
+
+	compskb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (!compskb) {
+		kfree_skb(skb);
+		return;
+	}
+
+	/* Send via the RtNetlink event channel */
+	nlh = rtnetlink_ifinfo_prep(dev, compskb);
+	if (WARN_ON(!nlh)) {
+		kfree_skb(skb);
+		kfree_skb(compskb);
+		return;
+	}
+
+	/* Add the wireless events in the netlink packet */
+	nla = nla_reserve(compskb, IFLA_WIRELESS, event_len);
+	if (!nla) {
+		kfree_skb(skb);
+		kfree_skb(compskb);
+		return;
+	}
+	compat_event = nla_data(nla);
+
+	compat_event->len = event_len;
+	compat_event->cmd = cmd;
+	if (descr->header_type == IW_HEADER_TYPE_POINT) {
+		compat_wrqu.length = wrqu->data.length;
+		compat_wrqu.flags = wrqu->data.flags;
+		memcpy(&compat_event->pointer,
+			((char *) &compat_wrqu) + IW_EV_COMPAT_POINT_OFF,
+			hdr_len - IW_EV_COMPAT_LCP_LEN);
+		if (extra_len)
+			memcpy(((char *) compat_event) + hdr_len,
+				extra, extra_len);
+	} else {
+		/* extra_len must be zero, so no if (extra) needed */
+		memcpy(&compat_event->pointer, wrqu,
+			hdr_len - IW_EV_COMPAT_LCP_LEN);
+	}
 
+	nlmsg_end(compskb, nlh);
+
+	skb_shinfo(skb)->frag_list = compskb;
+#endif
 	skb_queue_tail(&dev_net(dev)->wext_nlevents, skb);
 	schedule_work(&wireless_nlevent_work);
 }
--- wireless-testing.orig/net/Kconfig	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/net/Kconfig	2009-06-24 13:32:02.000000000 +0200
@@ -23,6 +23,26 @@ menuconfig NET
 
 if NET
 
+config WANT_COMPAT_NETLINK_MESSAGES
+	bool
+	help
+	  This option can be selected by other options that need compat
+	  netlink messages.
+
+config COMPAT_NETLINK_MESSAGES
+	def_bool y
+	depends on COMPAT
+	depends on WIRELESS_EXT || WANT_COMPAT_NETLINK_MESSAGES
+	help
+	  This option makes it possible to send different netlink messages
+	  to tasks depending on whether the task is a compat task or not. To
+	  achieve this, you need to set skb_shinfo(skb)->frag_list to the
+	  compat skb before sending the skb, the netlink code will sort out
+	  which message to actually pass to the task.
+
+	  Newly written code should NEVER need this option but do
+	  compat-independent messages instead!
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
--- wireless-testing.orig/net/netlink/af_netlink.c	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-06-24 13:32:02.000000000 +0200
@@ -1368,6 +1368,27 @@ static int netlink_recvmsg(struct kiocb 
 	if (skb == NULL)
 		goto out;
 
+#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
+	if (unlikely(skb_shinfo(skb)->frag_list)) {
+		bool need_compat = !!(flags & MSG_CMSG_COMPAT);
+
+		/*
+		 * If this skb has a frag_list, then here that means that
+		 * we will have to use the frag_list skb for compat tasks
+		 * and the regular skb for non-compat tasks.
+		 */
+		if (need_compat) {
+			struct sk_buff *compskb = skb_shinfo(skb)->frag_list;
+			skb_shinfo(skb)->frag_list = NULL;
+			kfree_skb(skb);
+			skb = compskb;
+		} else {
+			kfree_skb(skb_shinfo(skb)->frag_list);
+			skb_shinfo(skb)->frag_list = NULL;
+		}
+	}
+#endif
+
 	msg->msg_namelen = 0;
 
 	copied = skb->len;
--- wireless-testing.orig/net/compat.c	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/net/compat.c	2009-06-24 13:32:02.000000000 +0200
@@ -743,6 +743,18 @@ asmlinkage long compat_sys_recvmsg(int f
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_recv(int fd, void __user *buf, size_t len, unsigned flags)
+{
+	return sys_recv(fd, buf, len, flags | MSG_CMSG_COMPAT);
+}
+
+asmlinkage long compat_sys_recvfrom(int fd, void __user *buf, size_t len,
+				    unsigned flags, struct sockaddr __user *addr,
+				    int __user *addrlen)
+{
+	return sys_recvfrom(fd, buf, len, flags | MSG_CMSG_COMPAT, addr, addrlen);
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
@@ -788,10 +800,11 @@ asmlinkage long compat_sys_socketcall(in
 		ret = sys_sendto(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), a[5]);
 		break;
 	case SYS_RECV:
-		ret = sys_recv(a0, compat_ptr(a1), a[2], a[3]);
+		ret = compat_sys_recv(a0, compat_ptr(a1), a[2], a[3]);
 		break;
 	case SYS_RECVFROM:
-		ret = sys_recvfrom(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), compat_ptr(a[5]));
+		ret = compat_sys_recvfrom(a0, compat_ptr(a1), a[2], a[3],
+					  compat_ptr(a[4]), compat_ptr(a[5]));
 		break;
 	case SYS_SHUTDOWN:
 		ret = sys_shutdown(a0,a1);
--- wireless-testing.orig/include/linux/wireless.h	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/include/linux/wireless.h	2009-06-24 13:32:02.000000000 +0200
@@ -1132,6 +1132,14 @@ struct __compat_iw_event {
 };
 #define IW_EV_COMPAT_LCP_LEN offsetof(struct __compat_iw_event, pointer)
 #define IW_EV_COMPAT_POINT_OFF offsetof(struct compat_iw_point, length)
+
+/* Size of the various events for compat */
+#define IW_EV_COMPAT_CHAR_LEN	(IW_EV_COMPAT_LCP_LEN + IFNAMSIZ)
+#define IW_EV_COMPAT_UINT_LEN	(IW_EV_COMPAT_LCP_LEN + sizeof(__u32))
+#define IW_EV_COMPAT_FREQ_LEN	(IW_EV_COMPAT_LCP_LEN + sizeof(struct iw_freq))
+#define IW_EV_COMPAT_PARAM_LEN	(IW_EV_COMPAT_LCP_LEN + sizeof(struct iw_param))
+#define IW_EV_COMPAT_ADDR_LEN	(IW_EV_COMPAT_LCP_LEN + sizeof(struct sockaddr))
+#define IW_EV_COMPAT_QUAL_LEN	(IW_EV_COMPAT_LCP_LEN + sizeof(struct iw_quality))
 #define IW_EV_COMPAT_POINT_LEN	\
 	(IW_EV_COMPAT_LCP_LEN + sizeof(struct compat_iw_point) - \
 	 IW_EV_COMPAT_POINT_OFF)
--- wireless-testing.orig/arch/sparc/kernel/sys32.S	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/arch/sparc/kernel/sys32.S	2009-06-24 13:32:02.000000000 +0200
@@ -121,7 +121,7 @@ SIGN2(sys32_syslog, sys_syslog, %o0, %o2
 SIGN1(sys32_umask, sys_umask, %o0)
 SIGN3(sys32_tgkill, sys_tgkill, %o0, %o1, %o2)
 SIGN1(sys32_sendto, sys_sendto, %o0)
-SIGN1(sys32_recvfrom, sys_recvfrom, %o0)
+SIGN1(sys32_recvfrom, compat_sys_recvfrom, %o0)
 SIGN3(sys32_socket, sys_socket, %o0, %o1, %o2)
 SIGN2(sys32_connect, sys_connect, %o0, %o2)
 SIGN2(sys32_bind, sys_bind, %o0, %o2)
--- wireless-testing.orig/arch/mips/kernel/scall64-n32.S	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/arch/mips/kernel/scall64-n32.S	2009-06-24 13:32:02.000000000 +0200
@@ -164,7 +164,7 @@ EXPORT(sysn32_call_table)
 	PTR	sys_connect
 	PTR	sys_accept
 	PTR	sys_sendto
-	PTR	sys_recvfrom
+	PTR	compat_sys_recvfrom
 	PTR	compat_sys_sendmsg		/* 6045 */
 	PTR	compat_sys_recvmsg
 	PTR	sys_shutdown
--- wireless-testing.orig/arch/mips/kernel/scall64-o32.S	2009-06-24 13:30:31.000000000 +0200
+++ wireless-testing/arch/mips/kernel/scall64-o32.S	2009-06-24 13:32:02.000000000 +0200
@@ -378,8 +378,8 @@ sys_call_table:
 	PTR	sys_getsockname
 	PTR	sys_getsockopt
 	PTR	sys_listen
-	PTR	sys_recv			/* 4175 */
-	PTR	sys_recvfrom
+	PTR	compat_sys_recv			/* 4175 */
+	PTR	compat_sys_recvfrom
 	PTR	compat_sys_recvmsg
 	PTR	sys_send
 	PTR	compat_sys_sendmsg

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
