From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH iproute2 1/2] Modify neighbour proxy show
Date: Thu, 26 Jan 2012 18:50:04 +0400
Message-ID: <1327589405-10930-2-git-send-email-antonz@parallels.com>
References: <1327589405-10930-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devel@openvz.org>, Tony Zelenoff <antonz@parallels.com>,
	<kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>
To: <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:45106 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab2AZOuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 09:50:12 -0500
In-Reply-To: <1327589405-10930-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New "ip neigh show proxy" command now can show proxies which
were added with "ip neigh add proxy" command. Kernel code to
support this feature sent a bit earlier to netdev.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 ip/ipneigh.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index c8f745e..313cc63 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -209,6 +209,7 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter.index && filter.index != r->ndm_ifindex)
 		return 0;
 	if (!(filter.state&r->ndm_state) &&
+	    !(r->ndm_flags & NTF_PROXY) &&
 	    (r->ndm_state || !(filter.state&0x100)) &&
              (r->ndm_family != AF_DECnet))
 		return 0;
@@ -267,6 +268,9 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->ndm_flags & NTF_ROUTER) {
 		fprintf(fp, " router");
 	}
+	if (r->ndm_flags & NTF_PROXY) {
+		fprintf(fp, " proxy");
+	}
 	if (tb[NDA_CACHEINFO] && show_stats) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
 		int hz = get_user_hz();
@@ -314,6 +318,7 @@ int do_show_or_flush(int argc, char **argv, int flush)
 {
 	char *filter_dev = NULL;
 	int state_given = 0;
+	struct ndmsg ndm = { 0 };
 
 	ipneigh_reset_filter();
 
@@ -354,7 +359,9 @@ int do_show_or_flush(int argc, char **argv, int flush)
 			if (state == 0)
 				state = 0x100;
 			filter.state |= state;
-		} else {
+		} else if (strcmp(*argv, "proxy") == 0)
+			ndm.ndm_flags = NTF_PROXY;
+		else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
@@ -418,7 +425,9 @@ int do_show_or_flush(int argc, char **argv, int flush)
 		return 1;
 	}
 
-	if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNEIGH) < 0) {
+	ndm.ndm_family = filter.family;
+
+	if (rtnl_dump_request(&rth, RTM_GETNEIGH, &ndm, sizeof(struct ndmsg)) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
 	}
-- 
1.7.1
