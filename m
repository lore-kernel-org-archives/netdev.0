From: sfeldma@gmail.com
Subject: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Sun, 15 Mar 2015 12:31:34 -0700
Message-ID: <1426447894-41398-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, tarbal@gmail.com, linville@tuxdriver.com
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36110 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbCOTae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:30:34 -0400
Received: by padcy3 with SMTP id cy3so42573612pad.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:30:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v2:

No clear outcome on polling for choices of "external", "offload", "hw", or
"hardware".  Andy's concern about "external" being confusing for users is
valid.  So, I'm making executive decision to use "external_offload" for label,
as suggested by Jiri.

v1:

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
Acked-by: Jiri Pirko <jiri@resnulli.us>
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
index b32025f..ffdf4f2 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -412,6 +412,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "onlink ");
 	if (r->rtm_flags & RTNH_F_PERVASIVE)
 		fprintf(fp, "pervasive ");
+	if (r->rtm_flags & RTNH_F_EXTERNAL)
+		fprintf(fp, "external_offload ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
 	if (tb[RTA_MARK]) {
-- 
1.7.10.4
