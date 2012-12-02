From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix sparse endianness warnings on sock_common
Date: Sun, 02 Dec 2012 09:33:10 -0800
Message-ID: <1354469590.20109.585.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Ling Ma <ling.ma.program@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63125 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab2LBRdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 12:33:15 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so928027vby.19
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2012 09:33:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

# make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/inet_hashtables.o
...
net/ipv4/inet_hashtables.c:242:7: warning: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:242:7: warning: restricted __addrpair degrades to integer
...

Move __portpair/__addrpair from include/net/inet_hashtables.h
to include/net/sock.h where we need them in struct sock_common

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ling Ma <ling.ma.program@gmail.com>
---
 include/net/inet_hashtables.h |    2 --
 include/net/sock.h            |    7 +++++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d1de4fb..67a8fa0 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -277,7 +277,6 @@ static inline struct sock *inet_lookup_listener(struct net *net,
    On 64bit targets we combine comparisons with pair of adjacent __be32
    fields in the same way.
 */
-typedef __u32 __bitwise __portpair;
 #ifdef __BIG_ENDIAN
 #define INET_COMBINED_PORTS(__sport, __dport) \
 	((__force __portpair)(((__force __u32)(__be16)(__sport) << 16) | (__u32)(__dport)))
@@ -287,7 +286,6 @@ typedef __u32 __bitwise __portpair;
 #endif
 
 #if (BITS_PER_LONG == 64)
-typedef __u64 __bitwise __addrpair;
 #ifdef __BIG_ENDIAN
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const __addrpair __name = (__force __addrpair) ( \
diff --git a/include/net/sock.h b/include/net/sock.h
index c4132c1..0a9a01a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -126,6 +126,9 @@ struct sock;
 struct proto;
 struct net;
 
+typedef __u32 __bitwise __portpair;
+typedef __u64 __bitwise __addrpair;
+
 /**
  *	struct sock_common - minimal network layer representation of sockets
  *	@skc_daddr: Foreign IPv4 addr
@@ -155,7 +158,7 @@ struct sock_common {
 	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
 	 */
 	union {
-		unsigned long	skc_addrpair;
+		__addrpair	skc_addrpair;
 		struct {
 			__be32	skc_daddr;
 			__be32	skc_rcv_saddr;
@@ -167,7 +170,7 @@ struct sock_common {
 	};
 	/* skc_dport && skc_num must be grouped as well */
 	union {
-		u32		skc_portpair;
+		__portpair	skc_portpair;
 		struct {
 			__be16	skc_dport;
 			__u16	skc_num;
