From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: remove NIP6(), NIP6_FMT, NIP6_SEQFMT and final users
Date: Tue, 28 Oct 2008 16:19:10 -0700
Message-ID: <1225235950.11483.66.camel@brick>
References: <1225223616.11483.40.camel@brick>
	 <20081028.160612.90419792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:24932 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbYJ1XTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:19:15 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2977344rvb.1
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 16:19:14 -0700 (PDT)
In-Reply-To: <20081028.160612.90419792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Open code NIP6_FMT in the one call inside sscanf and one user
of NIP6() that could use %p6 in the netfilter code.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/linux/kernel.h         |   12 ------------
 net/bridge/netfilter/ebt_log.c |    6 ++----
 net/sunrpc/svcauth_unix.c      |    2 +-
 3 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 396a350..77777c4 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -357,18 +357,6 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 	((unsigned char *)&addr)[3]
 #define NIPQUAD_FMT "%u.%u.%u.%u"
 
-#define NIP6(addr) \
-	ntohs((addr).s6_addr16[0]), \
-	ntohs((addr).s6_addr16[1]), \
-	ntohs((addr).s6_addr16[2]), \
-	ntohs((addr).s6_addr16[3]), \
-	ntohs((addr).s6_addr16[4]), \
-	ntohs((addr).s6_addr16[5]), \
-	ntohs((addr).s6_addr16[6]), \
-	ntohs((addr).s6_addr16[7])
-#define NIP6_FMT "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
-#define NIP6_SEQFMT "%04x%04x%04x%04x%04x%04x%04x%04x"
-
 #if defined(__LITTLE_ENDIAN)
 #define HIPQUAD(addr) \
 	((unsigned char *)&addr)[3], \
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 3d33c60..3654f3e 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -133,10 +133,8 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 			printk(" INCOMPLETE IPv6 header");
 			goto out;
 		}
-		printk(" IPv6 SRC=%x:%x:%x:%x:%x:%x:%x:%x "
-		       "IPv6 DST=%x:%x:%x:%x:%x:%x:%x:%x, IPv6 "
-		       "priority=0x%01X, Next Header=%d", NIP6(ih->saddr),
-		       NIP6(ih->daddr), ih->priority, ih->nexthdr);
+		printk(" IPv6 SRC=%p6 IPv6 DST=%p6, IPv6 priority=0x%01X, Next Header=%d",
+		       &ih->saddr, &ih->daddr, ih->priority, ih->nexthdr);
 		nexthdr = ih->nexthdr;
 		offset_ph = ipv6_skip_exthdr(skb, sizeof(_iph), &nexthdr);
 		if (offset_ph == -1)
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 9a6d0cf..eb640c1 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -214,7 +214,7 @@ static int ip_map_parse(struct cache_detail *cd,
 		addr.s6_addr32[2] = htonl(0xffff);
 		addr.s6_addr32[3] =
 			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-       } else if (sscanf(buf, NIP6_FMT "%c",
+       } else if (sscanf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x%c",
 			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
 		addr.s6_addr16[0] = htons(b1);
 		addr.s6_addr16[1] = htons(b2);
-- 
1.6.0.3.756.gb776d



