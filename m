From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2 06/24] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Tue, 03 Mar 2015 22:11:28 +0000
Message-ID: <lsq.1425420688.754261621@decadent.org.uk>
References: <lsq.1425420688.806916072@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, "Al Viro" <viro@ZenIV.linux.org.uk>,
	netdev@vger.kernel.org, "karl beldan" <karl.beldan@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Karl Beldan" <karl.beldan@rivierawaves.com>,
	"Eric Dumazet" <edumazet@google.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Mike Frysinger" <vapier@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <lsq.1425420688.806916072@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.2.68-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: karl beldan <karl.beldan@gmail.com>

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
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 lib/checksum.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

--- a/lib/checksum.c
+++ b/lib/checksum.c
@@ -47,6 +47,15 @@ static inline unsigned short from32to16(
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
@@ -193,8 +202,7 @@ __wsum csum_tcpudp_nofold(__be32 saddr,
 #else
 	s += (proto + len) << 8;
 #endif
-	s += (s >> 32);
-	return (__force __wsum)s;
+	return (__force __wsum)from64to32(s);
 }
 EXPORT_SYMBOL(csum_tcpudp_nofold);
 #endif
