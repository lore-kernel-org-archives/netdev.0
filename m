From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 3.12 065/122] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Tue, 17 Feb 2015 12:34:12 +0100
Message-ID: <07707a797d6c3cd0bfe86f037d3d1eb329acbc86.1424099973.git.jslaby@suse.cz>
References: <09e6fe32192a77f6e2e60cc0f4103e630c7ecf20.1424099973.git.jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, karl beldan <karl.beldan@gmail.com>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Slaby <jslaby@suse.cz>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip4-83-240-67-251.cust.nbox.cz ([83.240.67.251]:39872 "EHLO
	ip4-83-240-18-248.cust.nbox.cz" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756942AbbBQLfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 06:35:14 -0500
In-Reply-To: <09e6fe32192a77f6e2e60cc0f4103e630c7ecf20.1424099973.git.jslaby@suse.cz>
In-Reply-To: <cover.1424099973.git.jslaby@suse.cz>
References: <cover.1424099973.git.jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: karl beldan <karl.beldan@gmail.com>

3.12-stable review patch.  If anyone has any objections, please let me know.

===============

commit 150ae0e94634714b23919f0c333fee28a5b199d5 upstream.

The carry from the 64->32bits folding was dropped, e.g with:
saddr=0xFFFFFFFF daddr=0xFF0000FF len=0xFFFF proto=0 sum=1,
csum_tcpudp_nofold returned 0 instead of 1.

Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 lib/checksum.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/lib/checksum.c b/lib/checksum.c
index 129775eb6de6..fcf38943132c 100644
--- a/lib/checksum.c
+++ b/lib/checksum.c
@@ -47,6 +47,15 @@ static inline unsigned short from32to16(unsigned int x)
 	return x;
 }
 
+static inline u32 from64to32(u64 x)
+{
+	/* add up 32-bit and 32-bit for 32+c bit */
+	x = (x & 0xffffffff) + (x >> 32);
+	/* add up carry.. */
+	x = (x & 0xffffffff) + (x >> 32);
+	return (u32)x;
+}
+
 static unsigned int do_csum(const unsigned char *buff, int len)
 {
 	int odd;
@@ -195,8 +204,7 @@ __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
 #else
 	s += (proto + len) << 8;
 #endif
-	s += (s >> 32);
-	return (__force __wsum)s;
+	return (__force __wsum)from64to32(s);
 }
 EXPORT_SYMBOL(csum_tcpudp_nofold);
 #endif
-- 
2.2.2
