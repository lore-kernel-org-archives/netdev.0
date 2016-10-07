From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: [iproute2] bridge: Fix garbled json output seen if a vlan filter is specified
Date: Fri,  7 Oct 2016 09:40:18 -0700
Message-ID: <1475858418-1618-1-git-send-email-anuradhak@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, anuradhak@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35614 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941212AbcJGQkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 12:40:39 -0400
Received: by mail-pa0-f51.google.com with SMTP id qn10so20921239pac.2
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 09:40:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: anuradhak <anuradhak@cumulusnetworks.com>

json objects were started but not completed if the fdb vlan did not
match the specified filter vlan.

Sample output:
$ bridge -j fdb show vlan 111
[{
        "mac": "44:38:39:00:69:88",
        "dev": "br0",
        "vlan": 111,
        "master": "br0",
        "state": "permanent"
    }
]
$ bridge -j fdb show vlan 100
[]
$

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
---
 bridge/fdb.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index c6e0379..90f4b15 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -100,11 +100,6 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter_index && filter_index != r->ndm_ifindex)
 		return 0;
 
-	if (jw_global) {
-		jsonw_pretty(jw_global, 1);
-		jsonw_start_object(jw_global);
-	}
-
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
@@ -114,6 +109,11 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter_vlan && filter_vlan != vid)
 		return 0;
 
+	if (jw_global) {
+		jsonw_pretty(jw_global, 1);
+		jsonw_start_object(jw_global);
+	}
+
 	if (n->nlmsg_type == RTM_DELNEIGH) {
 		if (jw_global)
 			jsonw_string_field(jw_global, "opCode", "deleted");
-- 
2.1.4
