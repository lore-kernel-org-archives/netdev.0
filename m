From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6]: Fix RTNLGRP_IPV6_IFINFO netlink notifications
Date: Wed, 14 Jun 2006 01:39:03 +0900 (JST)
Message-ID: <20060614.013903.51529969.yoshfuji@linux-ipv6.org>
References: <4488AB2E.3030301@trash.net>
	<20060609.112357.10012542.yoshfuji@linux-ipv6.org>
	<448EE1CA.7020603@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:24836 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932164AbWFMQiX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 12:38:23 -0400
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <448EE1CA.7020603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <448EE1CA.7020603@trash.net> (at Tue, 13 Jun 2006 18:03:22 +0200), Patrick McHardy <kaber@trash.net> says:

> Yes, thats better. I also thing we shouldn't return -EINVAL but
> -ENOSPC or something like that, -EINVAL usually indicated that
> the user sent an invalid message, which isn't the case here.
> Maybe a WARN_ON would also be appropriate, since this condition
> always means there is a bug.

Yes, but that's another issue.
Of course, you can cook up patch for it.


> > How about this?
> > 
> > +/* Maximum length of ifinfomsg attributes */
> > +#define INET6_IFINFO_RTA_SPACE \
> > +		RTA_SPACE(IFNAMSIZ) /* IFNAME */ + \
:
> This doesn't seem to account for IFLA_LINK. Other than that it looks
> fine too me.

[IPV6]: Sum real space for RTAs.

This patch fixes RTNLGRP_IPV6_IFINFO netlink notifications.
Issue pointed out by Patrick McHardy <kaber@trash.net>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 445006e..c2c26fa 100644
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
@@ -3142,6 +3147,17 @@ #endif
 #endif
 }
 
+/* Maximum length of ifinfomsg attributes */
+#define INET6_IFINFO_RTA_SPACE \
+		RTA_SPACE(IFNAMSIZ) /* IFNAME */ + \
+		RTA_SPACE(MAX_ADDR_LEN) /* ADDRESS */ +	\
+		RTA_SPACE(sizeof(u32)) /* MTU */ + \
+		RTA_SPACE(sizeof(int)) /* LINK */ + \
+		RTA_SPACE(0) /* PROTINFO */ + \
+		RTA_SPACE(sizeof(u32)) /* FLAGS */ + \
+		RTA_SPACE(sizeof(struct ifla_cacheinfo)) /* CACHEINFO */ + \
+		RTA_SPACE(sizeof(__s32[DEVCONF_MAX])) /* CONF */
+
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -3235,8 +3251,7 @@ static int inet6_dump_ifinfo(struct sk_b
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
-	/* 128 bytes ?? */
-	int size = NLMSG_SPACE(sizeof(struct ifinfomsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct ifinfomsg) + INET6_IFINFO_RTA_SPACE);
 	
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
@@ -3252,6 +3267,11 @@ void inet6_ifinfo_notify(int event, stru
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
@@ -3296,7 +3316,7 @@ static void inet6_prefix_notify(int even
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct prefixmsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
