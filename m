From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 3/5] ipv6: Optimize ipv6_addr_is_solict_mult().
Date: Mon, 21 Jan 2013 02:39:07 +0900
Message-ID: <50FC2BBB.6040404@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48883 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752440Ab3ATRjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:39:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/addrconf.h |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 3a3eeb4..9dc5efc 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -307,10 +307,17 @@ static inline bool ipv6_addr_is_isatap(const struct in6_addr *addr)
 
 static inline bool ipv6_addr_is_solict_mult(const struct in6_addr *addr)
 {
-	return (addr->s6_addr32[0] == htonl(0xff020000) &&
-		addr->s6_addr32[1] == htonl(0x00000000) &&
-		addr->s6_addr32[2] == htonl(0x00000001) &&
-		addr->s6_addr[12] == 0xff);
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	__u64 *p = (__u64 *)addr;
+	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) |
+		((p[1] ^ cpu_to_be64(0x00000001ff000000UL)) &
+		 cpu_to_be64(0xffffffffff000000UL))) == 0UL;
+#else
+	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
+		addr->s6_addr32[1] |
+		(addr->s6_addr32[2] ^ htonl(0x00000001)) |
+		(addr->s6_addr[12] ^ 0xff)) == 0;
+#endif
 }
 
 #ifdef CONFIG_PROC_FS
-- 
1.7.9.5
