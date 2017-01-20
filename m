From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2] ipmroute: add support for RTNH_F_UNRESOLVED
Date: Fri, 20 Jan 2017 15:15:21 +0100
Message-ID: <1484921721-24378-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1484921062-23379-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38252 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdATOXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 09:23:46 -0500
Received: by mail-wm0-f49.google.com with SMTP id r144so45718100wme.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 06:23:45 -0800 (PST)
In-Reply-To: <1484921062-23379-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new field that is printed in the end of the line which
denotes the real entry state. Before this patch an entry's IIF could
disappear and it would look like an unresolved one (iif = unresolved):
(3.0.16.1, 225.11.16.1)          Iif: unresolved
with no way to really distinguish it from an unresolved entry.
After the patch if the dumped entry has RTNH_F_UNRESOLVED set we get:
(3.0.16.1, 225.11.16.1)          Iif: unresolved  State: unresolved
for unresolved entries and:
(0.0.0.0, 225.11.11.11)          Iif: eth4       Oifs: eth3  State: resolved
for resolved entries after the OIF list. Note that "State:" has ':' in
it so it cannot be mistaken for an interface name.

And for the example above, we'd get:
(0.0.0.0, 225.11.11.11)          Iif: unresolved     State: resolved

Also when dumping all routes via ip route show table all, it will show
up as:
multicast 225.11.16.1/32 from 3.0.16.1/32 table default proto 17 unresolved

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: sent latest version, with dumping the state in one line

 ip/ipmroute.c | 2 ++
 ip/iproute.c  | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 512afcd2086e..593ce3a1bd95 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -159,6 +159,8 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			nh = RTNH_NEXT(nh);
 		}
 	}
+	fprintf(fp, " State: %s",
+		r->rtm_flags & RTNH_F_UNRESOLVED ? "unresolved" : "resolved");
 	if (show_stats && tb[RTA_MFC_STATS]) {
 		struct rta_mfc_stats *mfcs = RTA_DATA(tb[RTA_MFC_STATS]);
 
diff --git a/ip/iproute.c b/ip/iproute.c
index e433de8be189..c19578337f71 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -448,6 +448,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "notify ");
 	if (r->rtm_flags & RTNH_F_LINKDOWN)
 		fprintf(fp, "linkdown ");
+	if (r->rtm_flags & RTNH_F_UNRESOLVED)
+		fprintf(fp, "unresolved ");
 	if (tb[RTA_MARK]) {
 		unsigned int mark = *(unsigned int *)RTA_DATA(tb[RTA_MARK]);
 
-- 
2.1.4
