From: sfeldma@gmail.com
Subject: [PATCH iproute2] route: label externally offloaded routes
Date: Sat,  7 Mar 2015 22:15:35 -0800
Message-ID: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36853 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbCHGOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 01:14:31 -0500
Received: by padfa1 with SMTP id fa1so57514768pad.3
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 22:14:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

On ip route print dump, label externally offloaded routes with "external".
Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
net-next.  For example:

$ ip route
default via 192.168.0.2 dev eth0
11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
12.0.0.2  proto zebra  metric 30 external
        nexthop via 11.0.0.1  dev swp1 weight 1
        nexthop via 11.0.0.9  dev swp2 weight 1
12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/rtnetlink.h |    1 +
 ip/iproute.c              |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3eb7810..c74773c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -332,6 +332,7 @@ struct rtnexthop {
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
+#define RTNH_F_EXTERNAL		8	/* Route installed externally   */
 
 /* Macros to handle hexthops */
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 76d8e36..fdb0a98 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -426,6 +426,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "onlink ");
 	if (r->rtm_flags & RTNH_F_PERVASIVE)
 		fprintf(fp, "pervasive ");
+	if (r->rtm_flags & RTNH_F_EXTERNAL)
+		fprintf(fp, "external ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
 	if (tb[RTA_MARK]) {
-- 
1.7.10.4
