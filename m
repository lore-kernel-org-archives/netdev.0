From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6]: Fix RTNLGRP_IPV6_IFINFO netlink notifications
Date: Fri, 09 Jun 2006 11:23:57 +0900 (JST)
Message-ID: <20060609.112357.10012542.yoshfuji@linux-ipv6.org>
References: <4488AB2E.3030301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:10513 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751352AbWFICXR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 22:23:17 -0400
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <4488AB2E.3030301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <4488AB2E.3030301@trash.net> (at Fri, 09 Jun 2006 00:56:46 +0200), Patrick McHardy <kaber@trash.net> says:

Okay, thanks.
I think it is better to eliminate these magic numbers.

How about this?

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 445006e..b5267c6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2860,6 +2860,11 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
+/* Maximum length of ifa_cacheinfo attributes */
+#define INET6_IFADDR_RTA_SPACE \
+		RTA_SPACE(16) /* IFA_ADDRESS */ + \
+		RTA_SPACE(sizeof(struct ifa_cacheinfo)) /* CACHEINFO */
+
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -3092,7 +3097,7 @@ static int inet6_dump_ifacaddr(struct sk
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
@@ -3142,6 +3147,16 @@ static void inline ipv6_store_devconf(st
 #endif
 }
 
+/* Maximum length of ifinfomsg attributes */
+#define INET6_IFINFO_RTA_SPACE \
+		RTA_SPACE(IFNAMSIZ) /* IFNAME */ + \
+		RTA_SPACE(MAX_ADDR_LEN) /* ADDRESS */ +	\
+		RTA_SPACE(sizeof(u32)) /* MTU */ + \
+		RTA_SPACE(0) /* PROTINFO */ + \
+		RTA_SPACE(sizeof(u32)) /* FLAGS */ + \
+		RTA_SPACE(sizeof(struct ifla_cacheinfo)) /* CACHEINFO */ + \
+		RTA_SPACE(sizeof(__s32[DEVCONF_MAX])) /* CONF */
+
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -3235,8 +3250,7 @@ static int inet6_dump_ifinfo(struct sk_b
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
-	/* 128 bytes ?? */
-	int size = NLMSG_SPACE(sizeof(struct ifinfomsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct ifinfomsg) + INET6_IFINFO_RTA_SPACE);
 	
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
@@ -3252,6 +3266,11 @@ void inet6_ifinfo_notify(int event, stru
 	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_IFINFO, GFP_ATOMIC);
 }
 
+/* Maximum length of prefix_cacheinfo attributes */
+#define INET6_PREFIX_RTA_SPACE \
+		RTA_SPACE(sizeof(((struct prefix_info *)NULL)->prefix)) /* ADDRESS */ + \
+		RTA_SPACE(sizeof(struct prefix_cacheinfo)) /* CACHEINFO */
+
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
 			struct prefix_info *pinfo, u32 pid, u32 seq, 
 			int event, unsigned int flags)
@@ -3296,7 +3315,7 @@ static void inet6_prefix_notify(int even
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct prefixmsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
