From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] prefix: Convert RTM_NEWPREFIX notifications to use the new netlink api
Date: Tue, 14 Nov 2006 15:27:43 +0100
Message-ID: <20061114142743.GS8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43198 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965864AbWKNO1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 09:27:22 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RTM_GETPREFIX is completely unused and is thus removed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/ipv6/addrconf.c
===================================================================
--- net-2.6.20.orig/net/ipv6/addrconf.c	2006-11-14 12:51:56.000000000 +0100
+++ net-2.6.20/net/ipv6/addrconf.c	2006-11-14 12:52:04.000000000 +0100
@@ -3518,16 +3518,18 @@
 }
 
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
-			struct prefix_info *pinfo, u32 pid, u32 seq, 
-			int event, unsigned int flags)
+			     struct prefix_info *pinfo, u32 pid, u32 seq,
+			     int event, unsigned int flags)
 {
-	struct prefixmsg	*pmsg;
-	struct nlmsghdr 	*nlh;
-	unsigned char		*b = skb->tail;
+	struct prefixmsg *pmsg;
+	struct nlmsghdr *nlh;
 	struct prefix_cacheinfo	ci;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*pmsg), flags);
-	pmsg = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*pmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	pmsg = nlmsg_data(nlh);
 	pmsg->prefix_family = AF_INET6;
 	pmsg->prefix_pad1 = 0;
 	pmsg->prefix_pad2 = 0;
@@ -3535,26 +3537,22 @@
 	pmsg->prefix_len = pinfo->prefix_len;
 	pmsg->prefix_type = pinfo->type;
 	pmsg->prefix_pad3 = 0;
-	
 	pmsg->prefix_flags = 0;
 	if (pinfo->onlink)
 		pmsg->prefix_flags |= IF_PREFIX_ONLINK;
 	if (pinfo->autoconf)
 		pmsg->prefix_flags |= IF_PREFIX_AUTOCONF;
 
-	RTA_PUT(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix);
+	NLA_PUT(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix);
 
 	ci.preferred_time = ntohl(pinfo->prefered);
 	ci.valid_time = ntohl(pinfo->valid);
-	RTA_PUT(skb, PREFIX_CACHEINFO, sizeof(ci), &ci);
+	NLA_PUT(skb, PREFIX_CACHEINFO, sizeof(ci), &ci);
 
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev, 
Index: net-2.6.20/net/core/rtnetlink.c
===================================================================
--- net-2.6.20.orig/net/core/rtnetlink.c	2006-11-14 11:52:24.000000000 +0100
+++ net-2.6.20/net/core/rtnetlink.c	2006-11-14 12:52:04.000000000 +0100
@@ -108,7 +108,6 @@
 	[RTM_FAM(RTM_NEWTCLASS)]    = NLMSG_LENGTH(sizeof(struct tcmsg)),
 	[RTM_FAM(RTM_NEWTFILTER)]   = NLMSG_LENGTH(sizeof(struct tcmsg)),
 	[RTM_FAM(RTM_NEWACTION)]    = NLMSG_LENGTH(sizeof(struct tcamsg)),
-	[RTM_FAM(RTM_NEWPREFIX)]    = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETMULTICAST)] = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 };
Index: net-2.6.20/include/linux/rtnetlink.h
===================================================================
--- net-2.6.20.orig/include/linux/rtnetlink.h	2006-11-14 11:52:24.000000000 +0100
+++ net-2.6.20/include/linux/rtnetlink.h	2006-11-14 12:52:04.000000000 +0100
@@ -81,8 +81,6 @@
 
 	RTM_NEWPREFIX	= 52,
 #define RTM_NEWPREFIX	RTM_NEWPREFIX
-	RTM_GETPREFIX	= 54,
-#define RTM_GETPREFIX	RTM_GETPREFIX
 
 	RTM_GETMULTICAST = 58,
 #define RTM_GETMULTICAST RTM_GETMULTICAST
Index: net-2.6.20/security/selinux/nlmsgtab.c
===================================================================
--- net-2.6.20.orig/security/selinux/nlmsgtab.c	2006-11-14 11:52:24.000000000 +0100
+++ net-2.6.20/security/selinux/nlmsgtab.c	2006-11-14 12:52:04.000000000 +0100
@@ -60,7 +60,6 @@
 	{ RTM_DELACTION,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETACTION,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_NEWPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
-	{ RTM_GETPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETMULTICAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETANYCAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETNEIGHTBL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
