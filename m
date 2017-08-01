From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] iplink: Notify user if EEXIST error might be spurious
Date: Tue,  1 Aug 2017 19:27:47 +0200
Message-ID: <20170801172747.2817-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34975 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751860AbdHAR17 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 13:27:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in the days when RTM_NEWLINK wasn't yet implemented, people had to
rely upon kernel modules to create (virtual) interfaces for them. The
number of those was usually defined via module parameter, and a sane
default value was chosen. Now that iproute2 allows users to instantiate
new interfaces at will, this is no longer required - though for
backwards compatibility reasons, we're stuck with both methods which
collide at the point when one tries to create an interface with a
standard name for a type which exists in a kernel module: The kernel
will load the module, which instantiates the interface and the following
RTM_NEWLINK request will fail since the interface exists already. For
instance:

| # lsmod | grep dummy
| # ip link show | grep dummy0
| # ip link add dummy0 type dummy
| RTNETLINK answers: File exists
| # ip link show | grep -c dummy0
| 1

There is no race-free solution in userspace for this dilemma as far as I
can tell, so try to detect whether a user might have run into this and
notify that the given error message might be irrelevant.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 35 ++++++++++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 5aff2fde38dae..f94fa96668d21 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -867,6 +867,33 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	return ret - argc;
 }
 
+static bool link_name_is_standard(const char *type, const char *name)
+{
+	const struct {
+		const char *type;
+		const char *name;
+	} standard_links[] = {
+		{ "dummy", "dummy0" },
+		{ "ifb", "ifb0" },
+		{ "ifb", "ifb1" },
+		{ "bond", "bond0" },
+		{ "ipip", "tunl0" },
+		{ "gre", "gre0" },
+		{ "gretap", "gretap0" },
+		{ "vti", "ip_vti0" },
+		{ "sit", "sit0" },
+	};
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(standard_links); i++) {
+		if (strcmp(type, standard_links[i].type) ||
+		    strcmp(name, standard_links[i].name))
+			continue;
+		return true;
+	}
+	return false;
+}
+
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	int len;
@@ -1007,8 +1034,14 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0) {
+		if (errno == EEXIST &&
+		    flags & NLM_F_CREATE &&
+		    link_name_is_standard(type, name))
+			fprintf(stderr,
+				"Note: Kernel might have created interface upon module load.\n");
 		return -2;
+	}
 
 	return 0;
 }
-- 
2.13.1
