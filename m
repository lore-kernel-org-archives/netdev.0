From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v4 iproute2 4/6] ip route: Change type mask to bitmask
Date: Wed, 29 Jun 2016 11:27:00 -0700
Message-ID: <1467224822-16773-5-git-send-email-dsa@cumulusnetworks.com>
References: <1467224822-16773-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35629 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbcF2S1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:27:11 -0400
Received: by mail-pf0-f177.google.com with SMTP id c2so20608373pfa.2
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:27:11 -0700 (PDT)
In-Reply-To: <1467224822-16773-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow option to select multiple route types to show or exlude
specific route types.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8224d7ffa94b..aae693d17be8 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -113,7 +113,7 @@ static struct
 	int flushe;
 	int protocol, protocolmask;
 	int scope, scopemask;
-	int type, typemask;
+	__u64 typemask;
 	int tos, tosmask;
 	int iif, iifmask;
 	int oif, oifmask;
@@ -178,7 +178,8 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 		return 0;
 	if ((filter.scope^r->rtm_scope)&filter.scopemask)
 		return 0;
-	if ((filter.type^r->rtm_type)&filter.typemask)
+
+	if (filter.typemask && !(filter.typemask & (1 << r->rtm_type)))
 		return 0;
 	if ((filter.tos^r->rtm_tos)&filter.tosmask)
 		return 0;
@@ -365,7 +366,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (n->nlmsg_type == RTM_DELROUTE)
 		fprintf(fp, "Deleted ");
-	if ((r->rtm_type != RTN_UNICAST || show_details > 0) && !filter.type)
+	if ((r->rtm_type != RTN_UNICAST || show_details > 0) &&
+	    (!filter.typemask || (filter.typemask & (1 << r->rtm_type))))
 		fprintf(fp, "%s ", rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
 
 	if (tb[RTA_DST]) {
@@ -1433,10 +1435,9 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 			int type;
 
 			NEXT_ARG();
-			filter.typemask = -1;
 			if (rtnl_rtntype_a2n(&type, *argv))
 				invarg("node type value is invalid\n", *argv);
-			filter.type = type;
+			filter.typemask = (1<<type);
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
-- 
2.1.4
