From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/7] [NEIGH]: Move netlink neighbour bits to linux/neighbour.h
Date: Mon, 07 Aug 2006 00:00:04 +0200
Message-ID: <20060807171050.534616070@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4302 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932142AbWHGRMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:25 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neigh_header
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moves netlink neighbour bits to linux/neighbour.h. Also
moves bits to be exported to userspace from net/neighbour.h
to linux/neighbour.h and removes __KERNEL__ guards, userspace
is not supposed to be using it.

rtnetlink_rcv_msg() is not longer required to parse attributes
for the neighbour layer, remove dependency on obsolete and
buggy rta_buf.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/linux/neighbour.h
===================================================================
--- /dev/null
+++ net-2.6.19.git/include/linux/neighbour.h
@@ -0,0 +1,65 @@
+#ifndef __LINUX_NEIGHBOUR_H
+#define __LINUX_NEIGHBOUR_H
+
+#include <linux/netlink.h>
+
+struct ndmsg
+{
+	__u8		ndm_family;
+	__u8		ndm_pad1;
+	__u16		ndm_pad2;
+	__s32		ndm_ifindex;
+	__u16		ndm_state;
+	__u8		ndm_flags;
+	__u8		ndm_type;
+};
+
+enum
+{
+	NDA_UNSPEC,
+	NDA_DST,
+	NDA_LLADDR,
+	NDA_CACHEINFO,
+	NDA_PROBES,
+	__NDA_MAX
+};
+
+#define NDA_MAX (__NDA_MAX - 1)
+
+/*
+ *	Neighbor Cache Entry Flags
+ */
+
+#define NTF_PROXY	0x08	/* == ATF_PUBL */
+#define NTF_ROUTER	0x80
+
+/*
+ *	Neighbor Cache Entry States.
+ */
+
+#define NUD_INCOMPLETE	0x01
+#define NUD_REACHABLE	0x02
+#define NUD_STALE	0x04
+#define NUD_DELAY	0x08
+#define NUD_PROBE	0x10
+#define NUD_FAILED	0x20
+
+/* Dummy states */
+#define NUD_NOARP	0x40
+#define NUD_PERMANENT	0x80
+#define NUD_NONE	0x00
+
+/* NUD_NOARP & NUD_PERMANENT are pseudostates, they never change
+   and make no address resolution or NUD.
+   NUD_PERMANENT is also cannot be deleted by garbage collectors.
+ */
+
+struct nda_cacheinfo
+{
+	__u32		ndm_confirmed;
+	__u32		ndm_used;
+	__u32		ndm_updated;
+	__u32		ndm_refcnt;
+};
+
+#endif
Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -386,69 +386,6 @@ struct rta_session
 
 
 
-/**************************************************************
- *		Neighbour discovery.
- ****/
-
-struct ndmsg
-{
-	unsigned char	ndm_family;
-	unsigned char	ndm_pad1;
-	unsigned short	ndm_pad2;
-	int		ndm_ifindex;	/* Link index			*/
-	__u16		ndm_state;
-	__u8		ndm_flags;
-	__u8		ndm_type;
-};
-
-enum
-{
-	NDA_UNSPEC,
-	NDA_DST,
-	NDA_LLADDR,
-	NDA_CACHEINFO,
-	NDA_PROBES,
-	__NDA_MAX
-};
-
-#define NDA_MAX (__NDA_MAX - 1)
-
-#define NDA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
-#define NDA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
-
-/*
- *	Neighbor Cache Entry Flags
- */
-
-#define NTF_PROXY	0x08	/* == ATF_PUBL */
-#define NTF_ROUTER	0x80
-
-/*
- *	Neighbor Cache Entry States.
- */
-
-#define NUD_INCOMPLETE	0x01
-#define NUD_REACHABLE	0x02
-#define NUD_STALE	0x04
-#define NUD_DELAY	0x08
-#define NUD_PROBE	0x10
-#define NUD_FAILED	0x20
-
-/* Dummy states */
-#define NUD_NOARP	0x40
-#define NUD_PERMANENT	0x80
-#define NUD_NONE	0x00
-
-
-struct nda_cacheinfo
-{
-	__u32		ndm_confirmed;
-	__u32		ndm_used;
-	__u32		ndm_updated;
-	__u32		ndm_refcnt;
-};
-
-
 /*****************************************************************
  *		Neighbour tables specific messages.
  *
Index: net-2.6.19.git/include/net/neighbour.h
===================================================================
--- net-2.6.19.git.orig/include/net/neighbour.h
+++ net-2.6.19.git/include/net/neighbour.h
@@ -1,6 +1,8 @@
 #ifndef _NET_NEIGHBOUR_H
 #define _NET_NEIGHBOUR_H
 
+#include <linux/neighbour.h>
+
 /*
  *	Generic neighbour manipulation
  *
@@ -14,40 +16,6 @@
  *		- Add neighbour cache statistics like rtstat
  */
 
-/* The following flags & states are exported to user space,
-   so that they should be moved to include/linux/ directory.
- */
-
-/*
- *	Neighbor Cache Entry Flags
- */
-
-#define NTF_PROXY	0x08	/* == ATF_PUBL */
-#define NTF_ROUTER	0x80
-
-/*
- *	Neighbor Cache Entry States.
- */
-
-#define NUD_INCOMPLETE	0x01
-#define NUD_REACHABLE	0x02
-#define NUD_STALE	0x04
-#define NUD_DELAY	0x08
-#define NUD_PROBE	0x10
-#define NUD_FAILED	0x20
-
-/* Dummy states */
-#define NUD_NOARP	0x40
-#define NUD_PERMANENT	0x80
-#define NUD_NONE	0x00
-
-/* NUD_NOARP & NUD_PERMANENT are pseudostates, they never change
-   and make no address resolution or NUD.
-   NUD_PERMANENT is also cannot be deleted by garbage collectors.
- */
-
-#ifdef __KERNEL__
-
 #include <asm/atomic.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
@@ -374,6 +342,3 @@ struct neighbour_cb {
 #define NEIGH_CB(skb)	((struct neighbour_cb *)(skb)->cb)
 
 #endif
-#endif
-
-
Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -104,7 +104,6 @@ static const int rtm_min[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
 	[RTM_FAM(RTM_NEWADDR)]      = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
 	[RTM_FAM(RTM_NEWROUTE)]     = NLMSG_LENGTH(sizeof(struct rtmsg)),
-	[RTM_FAM(RTM_NEWNEIGH)]     = NLMSG_LENGTH(sizeof(struct ndmsg)),
 	[RTM_FAM(RTM_NEWRULE)]      = NLMSG_LENGTH(sizeof(struct fib_rule_hdr)),
 	[RTM_FAM(RTM_NEWQDISC)]     = NLMSG_LENGTH(sizeof(struct tcmsg)),
 	[RTM_FAM(RTM_NEWTCLASS)]    = NLMSG_LENGTH(sizeof(struct tcmsg)),
@@ -121,7 +120,6 @@ static const int rta_max[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWLINK)]      = IFLA_MAX,
 	[RTM_FAM(RTM_NEWADDR)]      = IFA_MAX,
 	[RTM_FAM(RTM_NEWROUTE)]     = RTA_MAX,
-	[RTM_FAM(RTM_NEWNEIGH)]     = NDA_MAX,
 	[RTM_FAM(RTM_NEWRULE)]      = FRA_MAX,
 	[RTM_FAM(RTM_NEWQDISC)]     = TCA_MAX,
 	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,

