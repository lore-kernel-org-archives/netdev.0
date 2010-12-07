From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: protect sysctl_tcp_cookie_size reads
Date: Tue, 07 Dec 2010 23:20:47 +0100
Message-ID: <1291760447.5324.31.camel@edumazet-laptop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291738321.2695.338.camel@edumazet-laptop>
	 <1291755776.21627.13.camel@bwh-desktop>
	 <1291757288.5324.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Steigerwald <Martin@lichtvoll.de>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57598 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab0LGWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 17:20:52 -0500
Received: by wwa36 with SMTP id 36so457101wwa.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 14:20:51 -0800 (PST)
In-Reply-To: <1291757288.5324.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure sysctl_tcp_cookie_size is read once in
tcp_cookie_size_check(), or we might return an illegal value to caller
if sysctl_tcp_cookie_size is changed by another cpu.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: William Allen Simpson <william.allen.simpson@gmail.com>
---
 net/ipv4/tcp_output.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..8cecb30 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -386,27 +386,30 @@ struct tcp_out_options {
  */
 static u8 tcp_cookie_size_check(u8 desired)
 {
-	if (desired > 0) {
+	int cookie_size;
+
+	if (desired > 0)
 		/* previously specified */
 		return desired;
-	}
-	if (sysctl_tcp_cookie_size <= 0) {
+
+	cookie_size = ACCESS_ONCE(sysctl_tcp_cookie_size);
+	if (cookie_size <= 0)
 		/* no default specified */
 		return 0;
-	}
-	if (sysctl_tcp_cookie_size <= TCP_COOKIE_MIN) {
+
+	if (cookie_size <= TCP_COOKIE_MIN)
 		/* value too small, specify minimum */
 		return TCP_COOKIE_MIN;
-	}
-	if (sysctl_tcp_cookie_size >= TCP_COOKIE_MAX) {
+
+	if (cookie_size >= TCP_COOKIE_MAX)
 		/* value too large, specify maximum */
 		return TCP_COOKIE_MAX;
-	}
-	if (0x1 & sysctl_tcp_cookie_size) {
+
+	if (cookie_size & 1)
 		/* 8-bit multiple, illegal, fix it */
-		return (u8)(sysctl_tcp_cookie_size + 0x1);
-	}
-	return (u8)sysctl_tcp_cookie_size;
+		cookie_size++;
+
+	return (u8)cookie_size;
 }
 
 /* Write previously computed TCP options to the packet.


