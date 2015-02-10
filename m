From: Luis Henriques <luis.henriques@canonical.com>
Subject: [3.16.y-ckt stable] Patch "lib/checksum.c: fix carry in csum_tcpudp_nofold" has been added to staging queue
Date: Tue, 10 Feb 2015 14:09:21 +0000
Message-ID: <1423577361-24529-1-git-send-email-luis.henriques@canonical.com>
Cc: Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Luis Henriques <luis.henriques@canonical.com>,
	kernel-team@lists.ubuntu.com
To: karl beldan <karl.beldan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a note to let you know that I have just added a patch titled

    lib/checksum.c: fix carry in csum_tcpudp_nofold

to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.16.y-queue

This patch is scheduled to be released in version 3.16.7-ckt7.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.16.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------

>From 0a7d96f7a48c2bc383d413bb9ca999704eace496 Mon Sep 17 00:00:00 2001
From: karl beldan <karl.beldan@gmail.com>
Date: Wed, 28 Jan 2015 10:58:11 +0100
Subject: lib/checksum.c: fix carry in csum_tcpudp_nofold

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
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
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
2.1.4
