From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 3/6] lib/inet_proto: Review inet_proto_{a2n,n2a}()
Date: Thu, 24 Aug 2017 11:51:47 +0200
Message-ID: <20170824095150.5469-4-phil@nwl.cc>
References: <20170824095150.5469-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60417 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbdHXJw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:52:28 -0400
In-Reply-To: <20170824095150.5469-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original intent was to make sure strings written by those functions
are NUL-terminated at all times, though it was suggested to get rid of
the 15 char protocol name limit as well which this patch accomplishes.

In addition to that, simplify inet_proto_a2n() a bit: Use the error
checking in get_u8() to find out whether passed 'buf' contains a valid
decimal number instead of checking the first character's value manually.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/inet_proto.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/lib/inet_proto.c b/lib/inet_proto.c
index ceda082b12a2e..53c029039b6d5 100644
--- a/lib/inet_proto.c
+++ b/lib/inet_proto.c
@@ -25,7 +25,7 @@
 
 const char *inet_proto_n2a(int proto, char *buf, int len)
 {
-	static char ncache[16];
+	static char *ncache;
 	static int icache = -1;
 	struct protoent *pe;
 
@@ -34,9 +34,12 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
 
 	pe = getprotobynumber(proto);
 	if (pe) {
+		if (icache != -1)
+			free(ncache);
 		icache = proto;
-		strncpy(ncache, pe->p_name, 16);
-		strncpy(buf, pe->p_name, len);
+		ncache = strdup(pe->p_name);
+		strncpy(buf, pe->p_name, len - 1);
+		buf[len - 1] = '\0';
 		return buf;
 	}
 	snprintf(buf, len, "ipproto-%d", proto);
@@ -45,24 +48,23 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
 
 int inet_proto_a2n(const char *buf)
 {
-	static char ncache[16];
+	static char *ncache;
 	static int icache = -1;
 	struct protoent *pe;
+	__u8 ret;
 
-	if (icache>=0 && strcmp(ncache, buf) == 0)
+	if (icache != -1 && strcmp(ncache, buf) == 0)
 		return icache;
 
-	if (buf[0] >= '0' && buf[0] <= '9') {
-		__u8 ret;
-		if (get_u8(&ret, buf, 10))
-			return -1;
+	if (!get_u8(&ret, buf, 10))
 		return ret;
-	}
 
 	pe = getprotobyname(buf);
 	if (pe) {
+		if (icache != -1)
+			free(ncache);
 		icache = pe->p_proto;
-		strncpy(ncache, pe->p_name, 16);
+		ncache = strdup(pe->p_name);
 		return pe->p_proto;
 	}
 	return -1;
-- 
2.13.1
