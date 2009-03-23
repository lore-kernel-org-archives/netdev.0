From: "Mark H. Weaver" <mhw@netris.org>
Subject: [PATCH] netfilter: fix unaligned memory access in tcp_sack
Date: Sun, 22 Mar 2009 23:09:51 -0400
Message-ID: <878wmx3pfk.fsf@netris.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes an unaligned memory access in tcp_sack while reading
sequence numbers from TCP selective acknowledgement options.  Prior to
applying this patch, upstream linux-2.6.27.20 was occasionally
generating messages like this on my sparc64 system:

  [54678.532071] Kernel unaligned access at TPC[6b17d4] tcp_packet+0xcd4/0xd00

More details provided upon request.  Apologies in advance if I've sent
this to the wrong place or not followed proper procedures.

   Best,
    Mark


--- linux-2.6/net/netfilter/nf_conntrack_proto_tcp.c.orig	2009-03-22 17:51:47.000000000 -0400
+++ linux-2.6/net/netfilter/nf_conntrack_proto_tcp.c	2009-03-22 22:49:23.000000000 -0400
@@ -15,6 +15,7 @@
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
 #include <net/ip6_checksum.h>
+#include <asm/unaligned.h>
 
 #include <net/tcp.h>
 
@@ -466,7 +467,7 @@ static void tcp_sack(const struct sk_buf
 				for (i = 0;
 				     i < (opsize - TCPOLEN_SACK_BASE);
 				     i += TCPOLEN_SACK_PERBLOCK) {
-					tmp = ntohl(*((__be32 *)(ptr+i)+1));
+					tmp = get_unaligned_be32((__be32 *)(ptr+i)+1);
 
 					if (after(tmp, *sack))
 						*sack = tmp;
