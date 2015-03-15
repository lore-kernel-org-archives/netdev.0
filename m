From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/8] iproute2: Add support for printing AF_PACKET addresses
Date: Sun, 15 Mar 2015 14:49:35 -0500
Message-ID: <87twxmnir4.fsf_-_@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
	<87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54119 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbbCOTxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:53:19 -0400
In-Reply-To: <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 15 Mar 2015 14:47:59 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 lib/utils.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 4b4f20126822..af98c42565a5 100644
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
@@ -497,10 +510,6 @@ done:
 
 int get_addr(inet_prefix *dst, const char *arg, int family)
 {
-	if (family == AF_PACKET) {
-		fprintf(stderr, "Error: \"%s\" may be inet address, but it is not allowed in this context.\n", arg);
-		exit(1);
-	}
 	if (get_addr_1(dst, arg, family)) {
 		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
 		exit(1);
@@ -650,6 +659,8 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
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
