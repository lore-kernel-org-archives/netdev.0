From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] inet: Get critical word in first 64bit of cache
 line
Date: Sat, 02 Feb 2013 07:03:55 -0800
Message-ID: <1359817435.30177.70.camel@edumazet-glaptop>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: ling.ma.program@gmail.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33503 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757722Ab3BBPD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 10:03:58 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so2684569pac.15
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2013 07:03:58 -0800 (PST)
In-Reply-To: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ma Ling <ling.ma.program@gmail.com>

In order to reduce memory latency when last level cache miss occurs,
modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
Early Restart(ER) to get data ASAP. For CWF if critical word is first
member
in cache line, memory feed CPU with critical word, then fill others
data in cache line one by one, otherwise after critical word it must
cost more cycle to fill the remaining cache line. For Early First CPU
will restart until critical word in cache line reaches.

Hash value is critical word, so in this patch we place it as first
member in cache line (sock address is cache-line aligned), and it is
also good for Early Restart platform as well .

[edumazet: respin on net-next after commit ce43b03e8889]

Signed-off-by: Ma Ling <ling.ma.program@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/net/sock.h |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a340ab4..efabd9a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -131,12 +131,12 @@ typedef __u64 __bitwise __addrpair;
=20
 /**
  *	struct sock_common - minimal network layer representation of socket=
s
- *	@skc_daddr: Foreign IPv4 addr
- *	@skc_rcv_saddr: Bound local IPv4 addr
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
  *	@skc_dport: placeholder for inet_dport/tw_dport
  *	@skc_num: placeholder for inet_num/tw_num
+ *	@skc_daddr: Foreign IPv4 addr
+ *	@skc_rcv_saddr: Bound local IPv4 addr
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
@@ -153,18 +153,10 @@ typedef __u64 __bitwise __addrpair;
  *
  *	This is the minimal network layer representation of sockets, the he=
ader
  *	for struct sock and struct inet_timewait_sock.
+ *	Order of first fields is critical for __inet_lookup_established() :
+ *	skc_hash, skc_portpair, skc_addrpair
  */
 struct sock_common {
-	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
-	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
-	 */
-	union {
-		__addrpair	skc_addrpair;
-		struct {
-			__be32	skc_daddr;
-			__be32	skc_rcv_saddr;
-		};
-	};
 	union  {
 		unsigned int	skc_hash;
 		__u16		skc_u16hashes[2];
@@ -178,6 +170,16 @@ struct sock_common {
 		};
 	};
=20
+	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
+	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
+	 */
+	union {
+		__addrpair	skc_addrpair;
+		struct {
+			__be32	skc_daddr;
+			__be32	skc_rcv_saddr;
+		};
+	};
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse:4;
