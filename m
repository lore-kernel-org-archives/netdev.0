From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and show table id
Date: Mon, 21 Sep 2015 11:19:48 -0700
Message-ID: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32938 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932312AbbIUSTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:19:55 -0400
Received: by pacex6 with SMTP id ex6so123260207pac.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 11:19:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently 'ip route get' does not show the table the lookup result comes
from and prior to kernel commit c36ba6603a11 the response from the kernel
was hardcoded to the main table. From the discussion this appears to be
a leftover from the route cache where the cached entry lost the table id
and so the result was hardcoded to main table.

c36ba6603a11 added the RTM_F_LOOKUP_TABLE flag to maintain that behavior
but to allow new tools to ask for the actual table id for the lookup.
This patch adds that flag to ip route get request and if the result is
not the main table shows the table id.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c              | 6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8f49e6289003..bae43d5d8fb6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -421,9 +421,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_OIF] && filter.oifmask != -1)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
+	if (table && (table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
+		fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
-		if ((table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
-			fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 		if ((r->rtm_protocol != RTPROT_BOOT || show_details > 0) && filter.protocolmask != -1)
 			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
 		if ((r->rtm_scope != RT_SCOPE_UNIVERSE || show_details > 0) && filter.scopemask != -1)
@@ -1638,6 +1638,8 @@ static int iproute_get(int argc, char **argv)
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 
+	req.r.rtm_flags |= RTM_F_LOOKUP_TABLE;
+
 	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 		exit(2);
 
-- 
1.9.1
