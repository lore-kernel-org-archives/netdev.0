From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 6/8] sctp: Use ipv4_is_<type>
Date: Thu, 13 Dec 2007 15:38:59 -0800
Message-ID: <1197589141-7020-6-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
 <1197589141-7020-2-git-send-email-joe@perches.com>
 <1197589141-7020-3-git-send-email-joe@perches.com>
 <1197589141-7020-4-git-send-email-joe@perches.com>
 <1197589141-7020-5-git-send-email-joe@perches.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4215 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759658AbXLMXjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 18:39:10 -0500
In-Reply-To: <1197589141-7020-5-git-send-email-joe@perches.com>
Message-Id: <1bb329b93a1f75766b7b89afdfa5ae673e9355ec.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/sctp/constants.h |   36 ++++++------------------------------
 net/sctp/protocol.c          |   12 +++++++-----
 2 files changed, 13 insertions(+), 35 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 05f22a6..fefcba6 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -365,36 +365,12 @@ typedef enum {
  * Also, RFC 8.4, non-unicast addresses are not considered valid SCTP
  * addresses.
  */
-#define IS_IPV4_UNUSABLE_ADDRESS(a) \
-	((htonl(INADDR_BROADCAST) == *a) || \
-	(MULTICAST(*a)) || \
-	(((unsigned char *)(a))[0] == 0) || \
-	((((unsigned char *)(a))[0] == 198) && \
-	(((unsigned char *)(a))[1] == 18) && \
-	(((unsigned char *)(a))[2] == 0)) || \
-	((((unsigned char *)(a))[0] == 192) && \
-	(((unsigned char *)(a))[1] == 88) && \
-	(((unsigned char *)(a))[2] == 99)))
-
-/* IPv4 Link-local addresses: 169.254.0.0/16.  */
-#define IS_IPV4_LINK_ADDRESS(a) \
-	((((unsigned char *)(a))[0] == 169) && \
-	(((unsigned char *)(a))[1] == 254))
-
-/* RFC 1918 "Address Allocation for Private Internets" defines the IPv4
- * private address space as the following:
- *
- * 10.0.0.0 - 10.255.255.255 (10/8 prefix)
- * 172.16.0.0.0 - 172.31.255.255 (172.16/12 prefix)
- * 192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
- */
-#define IS_IPV4_PRIVATE_ADDRESS(a) \
-	((((unsigned char *)(a))[0] == 10) || \
-	((((unsigned char *)(a))[0] == 172) && \
-	(((unsigned char *)(a))[1] >= 16) && \
-	(((unsigned char *)(a))[1] < 32)) || \
-	((((unsigned char *)(a))[0] == 192) && \
-	(((unsigned char *)(a))[1] == 168)))
+#define IS_IPV4_UNUSABLE_ADDRESS(a)	    \
+	((htonl(INADDR_BROADCAST) == a) ||  \
+	 ipv4_is_multicast(a) ||	    \
+	 ipv4_is_zeronet(a) ||		    \
+	 ipv4_is_test_198(a) ||		    \
+	 ipv4_is_anycast_6to4(a))
 
 /* Flags used for the bind address copy functions.  */
 #define SCTP_ADDR6_ALLOWED	0x00000001	/* IPv6 address is allowed by
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d50f610..dc22d71 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -359,7 +359,7 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 			      const struct sk_buff *skb)
 {
 	/* Is this a non-unicast address or a unusable SCTP address? */
-	if (IS_IPV4_UNUSABLE_ADDRESS(&addr->v4.sin_addr.s_addr))
+	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr))
 		return 0;
 
 	/* Is this a broadcast address? */
@@ -408,13 +408,15 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
 	 */
 
 	/* Check for unusable SCTP addresses. */
-	if (IS_IPV4_UNUSABLE_ADDRESS(&addr->v4.sin_addr.s_addr)) {
+	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr)) {
 		retval =  SCTP_SCOPE_UNUSABLE;
-	} else if (LOOPBACK(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_loopback(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LOOPBACK;
-	} else if (IS_IPV4_LINK_ADDRESS(&addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_linklocal_169(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LINK;
-	} else if (IS_IPV4_PRIVATE_ADDRESS(&addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_private_10(addr->v4.sin_addr.s_addr) ||
+		   ipv4_is_private_172(addr->v4.sin_addr.s_addr) ||
+		   ipv4_is_private_192(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_PRIVATE;
 	} else {
 		retval = SCTP_SCOPE_GLOBAL;
-- 
1.5.3.7.949.g2221a6

