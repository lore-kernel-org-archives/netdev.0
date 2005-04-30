From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [RTNETLINK] Fix & cleanup rtm_min/rtm_max
Date: Sat, 30 Apr 2005 21:52:02 +0200
Message-ID: <20050430195202.GD577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Converts rtm_min and rtm_max arrays to use c99 designated
initializers for easier insertion of new message families.
RTM_GETMULTICAST and RTM_GETANYCAST did not have the minimal
message size specified which means that the netlink message
was parsed for routing attributes starting from the header.
Adds the proper minimal message sizes for these messages
(netlink header + common rtnetlink header) to fix this issue.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.12-rc3.orig/include/linux/rtnetlink.h	2005-04-30 20:30:02.000000000 +0200
+++ linux-2.6.12-rc3/include/linux/rtnetlink.h	2005-04-30 20:31:01.000000000 +0200
@@ -93,6 +93,8 @@
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
 
+#define RTM_FAM(cmd)	(((cmd) - RTM_BASE) >> 2)
+
 /* 
    Generic structure for encapsulation of optional route information.
    It is reminiscent of sockaddr, but with sa_family replaced
--- linux-2.6.12-rc3.orig/net/core/rtnetlink.c	2005-04-30 20:22:24.000000000 +0200
+++ linux-2.6.12-rc3/net/core/rtnetlink.c	2005-04-30 20:31:01.000000000 +0200
@@ -89,28 +89,31 @@
 
 static const int rtm_min[(RTM_MAX+1-RTM_BASE)/4] =
 {
-	NLMSG_LENGTH(sizeof(struct ifinfomsg)),
-	NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
-	NLMSG_LENGTH(sizeof(struct rtmsg)),
-	NLMSG_LENGTH(sizeof(struct ndmsg)),
-	NLMSG_LENGTH(sizeof(struct rtmsg)),
-	NLMSG_LENGTH(sizeof(struct tcmsg)),
-	NLMSG_LENGTH(sizeof(struct tcmsg)),
-	NLMSG_LENGTH(sizeof(struct tcmsg)),
-	NLMSG_LENGTH(sizeof(struct tcamsg))
+	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+	[RTM_FAM(RTM_NEWADDR)]      = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
+	[RTM_FAM(RTM_NEWROUTE)]     = NLMSG_LENGTH(sizeof(struct rtmsg)),
+	[RTM_FAM(RTM_NEWNEIGH)]     = NLMSG_LENGTH(sizeof(struct ndmsg)),
+	[RTM_FAM(RTM_NEWRULE)]      = NLMSG_LENGTH(sizeof(struct rtmsg)),
+	[RTM_FAM(RTM_NEWQDISC)]     = NLMSG_LENGTH(sizeof(struct tcmsg)),
+	[RTM_FAM(RTM_NEWTCLASS)]    = NLMSG_LENGTH(sizeof(struct tcmsg)),
+	[RTM_FAM(RTM_NEWTFILTER)]   = NLMSG_LENGTH(sizeof(struct tcmsg)),
+	[RTM_FAM(RTM_NEWACTION)]    = NLMSG_LENGTH(sizeof(struct tcamsg)),
+	[RTM_FAM(RTM_NEWPREFIX)]    = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+	[RTM_FAM(RTM_GETMULTICAST)] = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 };
 
 static const int rta_max[(RTM_MAX+1-RTM_BASE)/4] =
 {
-	IFLA_MAX,
-	IFA_MAX,
-	RTA_MAX,
-	NDA_MAX,
-	RTA_MAX,
-	TCA_MAX,
-	TCA_MAX,
-	TCA_MAX,
-	TCAA_MAX
+	[RTM_FAM(RTM_NEWLINK)]      = IFLA_MAX,
+	[RTM_FAM(RTM_NEWADDR)]      = IFA_MAX,
+	[RTM_FAM(RTM_NEWROUTE)]     = RTA_MAX,
+	[RTM_FAM(RTM_NEWNEIGH)]     = NDA_MAX,
+	[RTM_FAM(RTM_NEWRULE)]      = RTA_MAX,
+	[RTM_FAM(RTM_NEWQDISC)]     = TCA_MAX,
+	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,
+	[RTM_FAM(RTM_NEWTFILTER)]   = TCA_MAX,
+	[RTM_FAM(RTM_NEWACTION)]    = TCAA_MAX,
 };
 
 void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
