From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] IPV6 : Some cleanups in include/net/ipv6.h
Date: Thu, 3 May 2007 18:32:08 +0200
Message-ID: <20070503183208.8e4c325b.dada1@cosmosbay.com>
References: <4636BB49.8050307@cosmosbay.com>
	<20070503.030903.123997453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57323 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767490AbXECQcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 12:32:12 -0400
In-Reply-To: <20070503.030903.123997453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) struct ip6_flowlabel : moves 'users' field to avoid two 32bits holes for 64bit arches. Shrinks by 8 bytes sizeof(struct ip6_flowlabel)

2) ipv6_addr_cmp() and ipv6_addr_copy() dont need (void *) casts :
Compiler might take into account natural alignement of in6_addr structs to emit better code for memcpy()/memcmp()
Casts to (void *) force byte accesses.

3) ipv6_addr_prefix() optimization :
Better to clear whole struct, as compiler can emit better code for memset(addr, 0, 16) (2 stores on x86_64), and avoid some conditional branches.

# size vmlinux.after vmlinux.before
   text    data     bss     dec     hex filename
5262262  647612  557432 6467306  62aeea vmlinux.after
5262550  647612  557432 6467594  62b00a vmlinux.before

thats 288 bytes saved.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2ce3941..e4b16b7 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -204,9 +204,9 @@ struct ip6_flowlabel
 {
 	struct ip6_flowlabel	*next;
 	__be32			label;
+	atomic_t		users;
 	struct in6_addr		dst;
 	struct ipv6_txoptions	*opt;
-	atomic_t		users;
 	unsigned long		linger;
 	u8			share;
 	u32			owner;
@@ -291,7 +291,7 @@ static inline int ipv6_addr_src_scope(co
 
 static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
 {
-	return memcmp((const void *) a1, (const void *) a2, sizeof(struct in6_addr));
+	return memcmp(a1, a2, sizeof(struct in6_addr));
 }
 
 static inline int
@@ -308,7 +308,7 @@ ipv6_masked_addr_cmp(const struct in6_ad
 
 static inline void ipv6_addr_copy(struct in6_addr *a1, const struct in6_addr *a2)
 {
-	memcpy((void *) a1, (const void *) a2, sizeof(struct in6_addr));
+	memcpy(a1, a2, sizeof(struct in6_addr));
 }
 
 static inline void ipv6_addr_prefix(struct in6_addr *pfx, 
@@ -319,13 +319,10 @@ static inline void ipv6_addr_prefix(stru
 	int o = plen >> 3,
 	    b = plen & 0x7;
 
+	memset(pfx->s6_addr, 0, sizeof(pfx->s6_addr));
 	memcpy(pfx->s6_addr, addr, o);
-	if (b != 0) {
+	if (b != 0)
 		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
-		o++;
-	}
-	if (o < 16)
-		memset(pfx->s6_addr + o, 0, 16 - o);
 }
 
 static inline void ipv6_addr_set(struct in6_addr *addr, 
