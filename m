From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] utils: Review strlcpy() and strlcat()
Date: Wed,  6 Sep 2017 18:51:42 +0200
Message-ID: <20170906165142.28599-1-phil@nwl.cc>
References: <063D6719AE5E284EB5DD2968C1650D6DD006EC26@AcuExch.aculab.com>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60566 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754214AbdIFQvy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 12:51:54 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD006EC26@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As David Laight correctly pointed out, the first version of strlcpy()
modified dst buffer behind the string copied into it. Fix this by
writing NUL to the byte immediately following src string instead of to
the last byte in dst. Doing so also allows to reduce overhead by using
memcpy().

Improve strlcat() by avoiding the call to strlcpy() if dst string is
already full, not just as sanity check.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/utils.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 330ab073c2068..bbd3cbc46a0e5 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1233,18 +1233,22 @@ int get_real_family(int rtm_type, int rtm_family)
 
 size_t strlcpy(char *dst, const char *src, size_t size)
 {
+	size_t srclen = strlen(src);
+
 	if (size) {
-		strncpy(dst, src, size - 1);
-		dst[size - 1] = '\0';
+		size_t minlen = min(srclen, size - 1);
+
+		memcpy(dst, src, minlen);
+		dst[minlen] = '\0';
 	}
-	return strlen(src);
+	return srclen;
 }
 
 size_t strlcat(char *dst, const char *src, size_t size)
 {
 	size_t dlen = strlen(dst);
 
-	if (dlen > size)
+	if (dlen >= size)
 		return dlen + strlen(src);
 
 	return dlen + strlcpy(dst + dlen, src, size - dlen);
-- 
2.13.1
