From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: fdb: add state filter support
Date: Thu, 12 Jan 2017 17:47:39 +0100
Message-ID: <1484239659-16565-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        purna@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37517 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdALQrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:47:46 -0500
Received: by mail-wm0-f42.google.com with SMTP id c206so29307870wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:47:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new argument to the bridge fdb show command that allows
to filter by entry state.
Also update the man page to include all available show arguments.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 bridge/fdb.c      | 32 ++++++++++++++++++++++++++++++--
 man/man8/bridge.8 | 10 +++++++++-
 2 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index a91521776e99..a71a78f23b20 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -29,7 +29,7 @@
 #include "rt_names.h"
 #include "utils.h"
 
-static unsigned int filter_index, filter_vlan;
+static unsigned int filter_index, filter_vlan, filter_state;
 
 json_writer_t *jw_global;
 
@@ -39,7 +39,7 @@ static void usage(void)
 			"              [ self ] [ master ] [ use ] [ router ]\n"
 			"              [ local | static | dynamic ] [ dst IPADDR ] [ vlan VID ]\n"
 			"              [ port PORT] [ vni VNI ] [ via DEV ]\n");
-	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] [ vlan VID ] ]\n");
+	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] [ vlan VID ] [ state STATE ] ]\n");
 	exit(-1);
 }
 
@@ -63,6 +63,24 @@ static const char *state_n2a(unsigned int s)
 	return buf;
 }
 
+static int state_a2n(unsigned int *s, const char *arg)
+{
+	if (matches(arg, "permanent") == 0)
+		*s = NUD_PERMANENT;
+	else if (matches(arg, "static") == 0 || matches(arg, "temp") == 0)
+		*s = NUD_NOARP;
+	else if (matches(arg, "stale") == 0)
+		*s = NUD_STALE;
+	else if (matches(arg, "reachable") == 0 || matches(arg, "dynamic") == 0)
+		*s = NUD_REACHABLE;
+	else if (strcmp(arg, "all") == 0)
+		*s = ~0;
+	else if (get_unsigned(s, arg, 0))
+		return -1;
+
+	return 0;
+}
+
 static void start_json_fdb_flags_array(bool *fdb_flags)
 {
 	if (*fdb_flags)
@@ -100,6 +118,9 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter_index && filter_index != r->ndm_ifindex)
 		return 0;
 
+	if (filter_state && !(r->ndm_state & filter_state))
+		return 0;
+
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
@@ -310,6 +331,13 @@ static int fdb_show(int argc, char **argv)
 			if (filter_vlan)
 				duparg("vlan", *argv);
 			filter_vlan = atoi(*argv);
+		} else if (strcmp(*argv, "state") == 0) {
+			unsigned int state;
+
+			NEXT_ARG();
+			if (state_a2n(&state, *argv))
+				invarg("invalid state", *argv);
+			filter_state |= state;
 		} else {
 			if (matches(*argv, "help") == 0)
 				usage();
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 6617e188a384..9c5f855df72e 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -70,7 +70,15 @@ bridge \- show / manipulate bridge addresses and devices
 .ti -8
 .BR "bridge fdb" " [ " show " ] [ "
 .B dev
-.IR DEV " ]"
+.IR DEV " ] [ "
+.B br
+.IR BRDEV " ] [ "
+.B brport
+.IR DEV " ] [ "
+.B vlan
+.IR VID " ] [ "
+.B state
+.IR STATE " ]"
 
 .ti -8
 .BR "bridge mdb" " { " add " | " del " } "
-- 
2.1.4
