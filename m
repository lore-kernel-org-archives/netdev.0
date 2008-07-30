From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MD5: don't warn when an unexpected signature is seen.
Date: Wed, 30 Jul 2008 03:08:30 -0700 (PDT)
Message-ID: <20080730.030830.229158162.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069040@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40418
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752858AbYG3KIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 06:08:30 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069040@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 29 Jul 2008 10:36:00 -0700

> Currently, connecting to a listening socket with an MD5 signature option, when
> MD5 is not configured on the listening socket, will generate the following
> warning:
>   MD5 Hash NOT expected but found
> 
> This is rate limited, but too verbose given that it can be induced with an
> unverified SYN packet.
> 
> This patch removes the warning
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

As I mentioned in another reply, we should at least capture such
events in a MIB counter.

Thus I've checked in the following patch.

tcp: MD5: Use MIB counter instead of warning for MD5 mismatch.

>From a report by Matti Aarnio, and preliminary patch by Adam Langley.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/snmp.h |    2 ++
 net/ipv4/proc.c      |    2 ++
 net/ipv4/tcp_ipv4.c  |   10 ++--------
 net/ipv6/tcp_ipv6.c  |   27 ++++++++-------------------
 4 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 5df62ef..7a6e6bb 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -214,6 +214,8 @@ enum
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
+	LINUX_MIB_TCPMD5NOTFOUND,		/* TCPMD5NotFound */
+	LINUX_MIB_TCPMD5UNEXPECTED,		/* TCPMD5Unexpected */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 834356e..8f5a403 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -232,6 +232,8 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUNDO),
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
+	SNMP_MIB_ITEM("TCPMD5NotFound", LINUX_MIB_TCPMD5NOTFOUND),
+	SNMP_MIB_ITEM("TCPMD5Unexpected", LINUX_MIB_TCPMD5UNEXPECTED),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a2b06d0..4607ec1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1116,18 +1116,12 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 		return 0;
 
 	if (hash_expected && !hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash expected but NOT found "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest));
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_MD5NOTFOUND);
 		return 1;
 	}
 
 	if (!hash_expected && hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest));
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_MD5UNEXPECTED);
 		return 1;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index cff778b..0ab09c6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -849,28 +849,17 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
 	hash_location = tcp_parse_md5sig_option(th);
 
-	/* do we have a hash as expected? */
-	if (!hash_expected) {
-		if (!hash_location)
-			return 0;
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash NOT expected but found "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
+	/* We've parsed the options - do we have a hash? */
+	if (!hash_expected && !hash_location)
+		return 0;
+
+	if (hash_expected && !hash_location) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_MD5NOTFOUND);
 		return 1;
 	}
 
-	if (!hash_location) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash expected but NOT found "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
+	if (!hash_expected && hash_location) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_MD5UNEXPECTED);
 		return 1;
 	}
 
-- 
1.5.6.GIT

