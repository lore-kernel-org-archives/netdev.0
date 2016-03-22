From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 7/7] lib/ll_addr: improve ll_addr_n2a() a bit
Date: Tue, 22 Mar 2016 19:35:19 +0100
Message-ID: <1458671719-14361-8-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34750 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbcCVSfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:35:51 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apart from making the code a bit more compact and efficient, this also
prevents a potential buffer overflow if the passed buffer is really too
small: Although correctly decrementing the size parameter passed to
snprintf, it could become negative which would then wrap since snprintf
uses (unsigned) size_t for the parameter.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/ll_addr.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/lib/ll_addr.c b/lib/ll_addr.c
index 2ce9abfbb8c69..465ed6fa4d9a2 100644
--- a/lib/ll_addr.c
+++ b/lib/ll_addr.c
@@ -41,18 +41,9 @@ const char *ll_addr_n2a(const unsigned char *addr, int alen, int type, char *buf
 	if (alen == 16 && type == ARPHRD_TUNNEL6) {
 		return inet_ntop(AF_INET6, addr, buf, blen);
 	}
-	l = 0;
-	for (i=0; i<alen; i++) {
-		if (i==0) {
-			snprintf(buf+l, blen, "%02x", addr[i]);
-			blen -= 2;
-			l += 2;
-		} else {
-			snprintf(buf+l, blen, ":%02x", addr[i]);
-			blen -= 3;
-			l += 3;
-		}
-	}
+	snprintf(buf, blen, "%02x", addr[0]);
+	for (i = 1, l = 2; i < alen && l < blen; i++, l += 3)
+		snprintf(buf + l, blen - l, ":%02x", addr[i]);
 	return buf;
 }
 
-- 
2.7.2
