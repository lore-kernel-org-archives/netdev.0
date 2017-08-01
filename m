From: Florian Lehner <dev@der-flo.net>
Subject: [PATCH v4] ss: Enclose IPv6 address in brackets
Date: Tue, 1 Aug 2017 18:54:33 +0200
Message-ID: <821a72fb-3758-8a44-2b1e-727a73208e14@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:45948 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751804AbdHAQyf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:54:35 -0400
Received: from [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179] (unknown [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.der-flo.net (Postfix) with ESMTPSA id 50AE545A48
        for <netdev@vger.kernel.org>; Tue,  1 Aug 2017 18:54:34 +0200 (CEST)
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updated patch adds support for RFC2732 IPv6 address format with
brackets for the tool ss.

Following the advice by David Laight I used strchr().
Also, IN6ADDR_ANY and INADDR_ANY will return "*".


Signed-off-by: Lehner Florian <dev@der-flo.net>
---
 misc/ss.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 12763c9..d40ad00 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1046,25 +1046,31 @@ do_numeric:

 static void inet_addr_print(const inet_prefix *a, int port, unsigned
int ifindex)
 {
-	char buf[1024];
+	char buf[1024], buf2[1024];
 	const char *ap = buf;
+	char *c = NULL;
 	int est_len = addr_width;
 	const char *ifname = NULL;

-	if (a->family == AF_INET) {
-		if (a->data[0] == 0) {
+	if (a->data[0] == 0) {
 			buf[0] = '*';
 			buf[1] = 0;
-		} else {
+	} else {
+		if (a->family == AF_INET) {
 			ap = format_host(AF_INET, 4, a->data);
+		} else {
+			ap = format_host(a->family, 16, a->data);
+			c = strchr(ap, ':');
+			if (c != NULL && a->family == AF_INET6) {
+				sprintf(buf2, "[%s]", ap);
+				ap = buf2;
+			}
+			est_len = strlen(ap);
+			if (est_len <= addr_width)
+				est_len = addr_width;
+			else
+				est_len = addr_width + ((est_len-addr_width+3)/4)*4;
 		}
-	} else {
-		ap = format_host(a->family, 16, a->data);
-		est_len = strlen(ap);
-		if (est_len <= addr_width)
-			est_len = addr_width;
-		else
-			est_len = addr_width + ((est_len-addr_width+3)/4)*4;
 	}

 	if (ifindex) {
-- 
2.9.4
