From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/5] ss: reduce max indentation level in init_service_resolver()
Date: Sat, 28 Nov 2015 01:00:02 +0100
Message-ID: <1448668805-28074-3-git-send-email-phil@nwl.cc>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60093 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbK1AAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:50 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exit early or continue on error instead of putting conditional into
conditional to make reading the code a bit easier.

Also, the call to memcpy() can be skipped by initialising prog with the
desired prefix.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 53 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 30 insertions(+), 23 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a9ae85ec564e9..4988d34e18c78 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -870,31 +870,38 @@ static void init_service_resolver(void)
 {
 	char buf[128];
 	FILE *fp = popen("/usr/sbin/rpcinfo -p 2>/dev/null", "r");
-	if (fp) {
-		fgets(buf, sizeof(buf), fp);
-		while (fgets(buf, sizeof(buf), fp) != NULL) {
-			unsigned int progn, port;
-			char proto[128], prog[128];
-			if (sscanf(buf, "%u %*d %s %u %s", &progn, proto,
-				   &port, prog+4) == 4) {
-				struct scache *c = malloc(sizeof(*c));
-				if (c) {
-					c->port = port;
-					memcpy(prog, "rpc.", 4);
-					c->name = strdup(prog);
-					if (strcmp(proto, TCP_PROTO) == 0)
-						c->proto = TCP_PROTO;
-					else if (strcmp(proto, UDP_PROTO) == 0)
-						c->proto = UDP_PROTO;
-					else
-						c->proto = NULL;
-					c->next = rlist;
-					rlist = c;
-				}
-			}
-		}
+
+	if (!fp)
+		return;
+
+	if (!fgets(buf, sizeof(buf), fp)) {
 		pclose(fp);
+		return;
+	}
+	while (fgets(buf, sizeof(buf), fp) != NULL) {
+		unsigned int progn, port;
+		char proto[128], prog[128] = "rpc.";
+		struct scache *c;
+
+		if (sscanf(buf, "%u %*d %s %u %s",
+		           &progn, proto, &port, prog+4) != 4)
+			continue;
+
+		if (!(c = malloc(sizeof(*c))))
+			continue;
+
+		c->port = port;
+		c->name = strdup(prog);
+		if (strcmp(proto, TCP_PROTO) == 0)
+			c->proto = TCP_PROTO;
+		else if (strcmp(proto, UDP_PROTO) == 0)
+			c->proto = UDP_PROTO;
+		else
+			c->proto = NULL;
+		c->next = rlist;
+		rlist = c;
 	}
+	pclose(fp);
 }
 
 static int ip_local_port_min, ip_local_port_max;
-- 
2.5.0
