From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] ip monitor: Dont print timestamp or banner-label for cloned routes
Date: Thu,  4 Sep 2014 21:52:18 +0300
Message-ID: <1409856738-1938-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:50443 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaIDTAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:00:18 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so10671754wes.36
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 12:00:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is ugly fix but solves the case when timestamp
or banner-label is printed before the cloned route will be skipped
by iproute filter which filters out all cached routes by default.
In such case timestamp will be printed twice:

    Timestamp: Thu Sep  4 19:46:59 2014 457933 usec
    Timestamp: Thu Sep  4 19:47:07 2014 977970 usec
    10.3.5.1 dev wlp3s0 lladdr XX:XX:XX:XX:XX:XX STALE

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 70f2a7a..2bd3fed 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -41,9 +41,6 @@ static int accept_msg(const struct sockaddr_nl *who,
 {
 	FILE *fp = (FILE*)arg;
 
-	if (timestamp)
-		print_timestamp(fp);
-
 	if (n->nlmsg_type == RTM_NEWROUTE || n->nlmsg_type == RTM_DELROUTE) {
 		struct rtmsg *r = NLMSG_DATA(n);
 		int len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
@@ -53,6 +50,12 @@ static int accept_msg(const struct sockaddr_nl *who,
 			return -1;
 		}
 
+		if (r->rtm_flags&RTM_F_CLONED)
+			return 0;
+
+		if (timestamp)
+			print_timestamp(fp);
+
 		if (r->rtm_family == RTNL_FAMILY_IPMR ||
 		    r->rtm_family == RTNL_FAMILY_IP6MR) {
 			if (prefix_banner)
@@ -66,6 +69,10 @@ static int accept_msg(const struct sockaddr_nl *who,
 			return 0;
 		}
 	}
+
+	if (timestamp)
+		print_timestamp(fp);
+
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
 		if (prefix_banner)
-- 
2.1.0
