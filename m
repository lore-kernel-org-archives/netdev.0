From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] iproute2: fix addrlabel interface names handling
Date: Fri,  7 May 2010 23:31:02 +0200
Message-ID: <1273267862-22443-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:47330 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535Ab0EGVck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 17:32:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip addrlabel outputs if%d names due to missing init call:
$ ip addrlabel s
prefix a::42/128 dev if4 label 1000

Also, ip did not accept "if%d" interfaces on input.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 ip/ipaddrlabel.c |    2 ++
 lib/ll_map.c     |    6 +++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index cf438d6..95e813d 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -252,6 +252,8 @@ static int ipaddrlabel_flush(int argc, char **argv)
 
 int do_ipaddrlabel(int argc, char **argv)
 {
+	ll_init_map(&rth);
+
 	if (argc < 1) {
 		return ipaddrlabel_list(0, NULL);
 	} else if (matches(argv[0], "list") == 0 ||
diff --git a/lib/ll_map.c b/lib/ll_map.c
index 5addf4a..b8b49aa 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -161,6 +161,7 @@ unsigned ll_name_to_index(const char *name)
 	static int icache;
 	struct idxmap *im;
 	int i;
+	unsigned idx;
 
 	if (name == NULL)
 		return 0;
@@ -176,7 +177,10 @@ unsigned ll_name_to_index(const char *name)
 		}
 	}
 
-	return if_nametoindex(name);
+	idx = if_nametoindex(name);
+	if (idx == 0)
+		sscanf(name, "if%u", &idx);
+	return idx;
 }
 
 int ll_init_map(struct rtnl_handle *rth)
-- 
1.6.4.4

