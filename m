From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/8] iproute2: Add support for printing AF_PACKET addresses
Date: Fri, 13 Mar 2015 13:54:31 -0500
Message-ID: <87r3ssramw.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47212 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756819AbbCMS6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:58:13 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 lib/utils.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index a97eae9d5148..65d1632ddbc1 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -25,11 +25,12 @@
 #include <asm/types.h>
 #include <linux/pkt_sched.h>
 #include <linux/param.h>
+#include <linux/if_arp.h>
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
 
-
+#include "rt_names.h"
 #include "utils.h"
 #include "namespace.h"
 
@@ -397,6 +398,18 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 		return 0;
 	}
 
+	if (family == AF_PACKET) {
+		int len;
+		len = ll_addr_a2n((char *)&addr->data, sizeof(addr->data), name);
+		if (len < 0)
+			return -1;
+
+		addr->family = AF_PACKET;
+		addr->bytelen = len;
+		addr->bitlen = len * 8;
+		return 0;
+	}
+
 	if (strchr(name, ':')) {
 		addr->family = AF_INET6;
 		if (family != AF_UNSPEC && family != AF_INET6)
@@ -485,10 +498,6 @@ done:
 
 int get_addr(inet_prefix *dst, const char *arg, int family)
 {
-	if (family == AF_PACKET) {
-		fprintf(stderr, "Error: \"%s\" may be inet address, but it is not allowed in this context.\n", arg);
-		exit(1);
-	}
 	if (get_addr_1(dst, arg, family)) {
 		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
 		exit(1);
@@ -638,6 +647,8 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
 		memcpy(dna.a_addr, addr, 2);
 		return dnet_ntop(af, &dna, buf, buflen);
 	}
+	case AF_PACKET:
+		return ll_addr_n2a(addr, len, ARPHRD_VOID, buf, buflen);
 	default:
 		return "???";
 	}
-- 
2.2.1
