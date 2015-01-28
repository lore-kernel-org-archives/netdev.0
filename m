From: Karl Beldan <karl.beldan@gmail.com>
Subject: [PATCH v2] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Wed, 28 Jan 2015 10:58:11 +0100
Message-ID: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
Cc: Karl Beldan <karl.beldan@gmail.com>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
Cc: stable@vger.kernel.org
---
 lib/checksum.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/lib/checksum.c b/lib/checksum.c
index 129775e..fcf3894 100644
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
2.0.1
