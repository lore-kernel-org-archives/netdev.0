From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC/HACK] net/compat/wext: allow sending different messages to
 compat tasks
Date: Sun, 21 Jun 2009 15:10:35 +0200
Message-ID: <1245589835.5003.2.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wireless extensions have the unfortunate problem that events
are multicast, and are not independent of pointer size. Thus,
currently 32-bit tasks on 64-bit platforms cannot properly
receive events and fail with all kinds of strange problems,
for instance wpa_supplicant never notices disassociations, due
to the way the 64-bit event looks to a 32-bit process the fact
that the address is all zeroes is lost, it thinks instead it
is 00:01:00:00:00:00 (actually I'm not entirely sure about the
position of the 1 but it's like that).

The same problem existed with the ioctls, until David Miller
fixed those some time ago in an heroic effort.

A different problem caused by this is that we cannot send the
ASSOCREQIE/ASSOCRESPIE events because sending them causes a
32-bit wpa_supplicant on a 64-bit system to overwrite its
internal information, which is worse than it not getting the
information at all -- so we currently resort to sending a
custom string event that it then parses. This, however, has a
severe size limitation we are frequently hitting with modern
access points; this limitation would be lifted if we were able
to send the specific events.

In order to fix these problems, I would like to suggest this
approach I've implemented. When sending an event, we send the
event twice, for 32 and 64 bit tasks. Then, when the event is
read from the socket, the netlink code makes sure to pass out
only the event that is compatible with the task.

To determine whether compat is needed or not, I have used the
MSG_CMSG_COMPAT flag. It may now need a new name, since it can
now be set for recv calls that don't have CMSGs.

To mark the event, I added a new field to the netlink skb cb,
which is only available under COMPAT_NETLINK_MULTICAST, which
is automatically selected for compat and wireless extensions
(a select cannot be used because select isn't transitive).

My patch preserves the socket semantics but if messages are
lost it is possible for a socket to only get the event that
will turn out to be incompatible, in which case a task may
block although select() or poll() returned that the fd is
readable. However, because the messages are sent from process
context, this is very unlikely.

I have not solved one small part of the problem, and I don't
think it is necessary to: if a 32-bit application uses read()
rather than any form of recvmsg() it will still get the wrong
(64-bit) event. However, neither do applications actually do
this, nor would it be a regression.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/linux/netlink.h  |    9 ++++
 include/linux/wireless.h |    8 ++++
 net/Kconfig              |    5 ++
 net/compat.c             |   10 +++--
 net/netlink/af_netlink.c |   23 ++++++++++++
 net/wireless/wext.c      |   89 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 140 insertions(+), 4 deletions(-)

--- wireless-testing.orig/net/wireless/wext.c	2009-06-19 16:27:57.000000000 +0200
+++ wireless-testing/net/wireless/wext.c	2009-06-21 13:51:31.000000000 +0200
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
@@ -1348,6 +1363,22 @@ void wireless_send_event(struct net_devi
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
@@ -1446,9 +1477,67 @@ void wireless_send_event(struct net_devi
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
 	nlmsg_end(skb, nlh);
+#ifndef CONFIG_COMPAT
+	/*
+	 * This is under #ifdef because when we send both, we should
+	 * make sure that both skbs exist. That's no guarantee that they
+	 * will also make it to all sockets, but it's very likely since
+	 * the actual sending is done from process context.
+	 */
+	skb_queue_tail(&dev_net(dev)->wext_nlevents, skb);
+	schedule_work(&wireless_nlevent_work);
+#else
+	hdr_len = compat_event_type_size[descr->header_type];
+	event_len = hdr_len + extra_len;
 
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
+
+	nlmsg_end(compskb, nlh);
+
+	NETLINK_CB(skb).compat = NL_COMPAT_MC_NOTCOMP;
+	NETLINK_CB(compskb).compat = NL_COMPAT_MC_COMPONLY;
 	skb_queue_tail(&dev_net(dev)->wext_nlevents, skb);
+	skb_queue_tail(&dev_net(dev)->wext_nlevents, compskb);
 	schedule_work(&wireless_nlevent_work);
+#endif
 }
 EXPORT_SYMBOL(wireless_send_event);
 
--- wireless-testing.orig/include/linux/netlink.h	2009-06-19 08:01:12.000000000 +0200
+++ wireless-testing/include/linux/netlink.h	2009-06-19 17:29:10.000000000 +0200
@@ -161,6 +161,12 @@ static inline struct nlmsghdr *nlmsg_hdr
 	return (struct nlmsghdr *)skb->data;
 }
 
+enum nl_compat_mc {
+	NL_COMPAT_MC_ALL = 0,
+	NL_COMPAT_MC_COMPONLY,
+	NL_COMPAT_MC_NOTCOMP,
+};
+
 struct netlink_skb_parms
 {
 	struct ucred		creds;		/* Skb credentials	*/
@@ -170,6 +176,9 @@ struct netlink_skb_parms
 	__u32			loginuid;	/* Login (audit) uid */
 	__u32			sessionid;	/* Session id (audit) */
 	__u32			sid;		/* SELinux security id */
+#ifdef CONFIG_COMPAT_NETLINK_MULTICAST
+	enum nl_compat_mc	compat;
+#endif
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
--- wireless-testing.orig/net/Kconfig	2009-05-18 12:02:05.000000000 +0200
+++ wireless-testing/net/Kconfig	2009-06-19 17:29:10.000000000 +0200
@@ -23,6 +23,11 @@ menuconfig NET
 
 if NET
 
+config COMPAT_NETLINK_MULTICAST
+	def_bool y
+	depends on COMPAT
+	depends on WIRELESS_EXT
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
--- wireless-testing.orig/net/netlink/af_netlink.c	2009-06-19 08:01:29.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-06-21 14:52:52.000000000 +0200
@@ -1358,16 +1358,39 @@ static int netlink_recvmsg(struct kiocb 
 	size_t copied;
 	struct sk_buff *skb;
 	int err;
+#ifdef CONFIG_COMPAT_NETLINK_MULTICAST
+	enum nl_compat_mc compat;
+#endif
 
 	if (flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
 	copied = 0;
 
+#ifdef CONFIG_COMPAT_NETLINK_MULTICAST
+ again:
+#endif
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (skb == NULL)
 		goto out;
 
+#ifdef CONFIG_COMPAT_NETLINK_MULTICAST
+	compat = NETLINK_CB(skb).compat;
+
+	if (unlikely(compat != NL_COMPAT_MC_ALL)) {
+		bool need_compat = !!(flags & MSG_CMSG_COMPAT);
+		if ((compat == NL_COMPAT_MC_NOTCOMP && need_compat) ||
+		    (compat == NL_COMPAT_MC_COMPONLY && !need_compat)) {
+			kfree_skb(skb);
+			/*
+			 * Compat messages should always be sent in pairs,
+			 * so if this one isn't it, the next one will be.
+			 */
+			goto again;
+		}
+	}
+#endif
+
 	msg->msg_namelen = 0;
 
 	copied = skb->len;
--- wireless-testing.orig/net/compat.c	2009-06-19 17:50:30.000000000 +0200
+++ wireless-testing/net/compat.c	2009-06-19 17:53:13.000000000 +0200
@@ -782,16 +782,18 @@ asmlinkage long compat_sys_socketcall(in
 		ret = sys_socketpair(a0, a1, a[2], compat_ptr(a[3]));
 		break;
 	case SYS_SEND:
-		ret = sys_send(a0, compat_ptr(a1), a[2], a[3]);
+		ret = sys_send(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT);
 		break;
 	case SYS_SENDTO:
-		ret = sys_sendto(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), a[5]);
+		ret = sys_sendto(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT,
+				 compat_ptr(a[4]), a[5]);
 		break;
 	case SYS_RECV:
-		ret = sys_recv(a0, compat_ptr(a1), a[2], a[3]);
+		ret = sys_recv(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT);
 		break;
 	case SYS_RECVFROM:
-		ret = sys_recvfrom(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), compat_ptr(a[5]));
+		ret = sys_recvfrom(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT,
+				   compat_ptr(a[4]), compat_ptr(a[5]));
 		break;
 	case SYS_SHUTDOWN:
 		ret = sys_shutdown(a0,a1);
--- wireless-testing.orig/include/linux/wireless.h	2009-06-21 12:06:56.000000000 +0200
+++ wireless-testing/include/linux/wireless.h	2009-06-21 12:15:24.000000000 +0200
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


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
