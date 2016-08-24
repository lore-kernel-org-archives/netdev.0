From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: add LINUX_MIB_TCPMD5FAILURE counter
Date: Wed, 24 Aug 2016 09:01:23 -0700
Message-ID: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Julien Goodwin <julieng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36573 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756561AbcHXQPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:15:24 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so1475993pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:15:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Adds SNMP counter for drops caused by MD5 mismatches.

The current syslog might help, but a counter is more precise and helps
monitoring.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/snmp.h |    1 +
 net/ipv4/proc.c           |    1 +
 net/ipv4/tcp_ipv4.c       |    1 +
 net/ipv6/tcp_ipv6.c       |    1 +
 4 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 25a9ad8bcef1240915f2553a8acade447186d869..e7a31f8306903f53bc5881ae4c271f85cad2e361 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -235,6 +235,7 @@ enum
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
 	LINUX_MIB_TCPMD5NOTFOUND,		/* TCPMD5NotFound */
 	LINUX_MIB_TCPMD5UNEXPECTED,		/* TCPMD5Unexpected */
+	LINUX_MIB_TCPMD5FAILURE,		/* TCPMD5Failure */
 	LINUX_MIB_SACKSHIFTED,
 	LINUX_MIB_SACKMERGED,
 	LINUX_MIB_SACKSHIFTFALLBACK,
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b63a927202b9aaf2b6b3d42205058a2ae59..1ed015e4bc792acdd520a5df95ffac33ebefc4db 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -257,6 +257,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
 	SNMP_MIB_ITEM("TCPMD5NotFound", LINUX_MIB_TCPMD5NOTFOUND),
 	SNMP_MIB_ITEM("TCPMD5Unexpected", LINUX_MIB_TCPMD5UNEXPECTED),
+	SNMP_MIB_ITEM("TCPMD5Failure", LINUX_MIB_TCPMD5FAILURE),
 	SNMP_MIB_ITEM("TCPSackShifted", LINUX_MIB_SACKSHIFTED),
 	SNMP_MIB_ITEM("TCPSackMerged", LINUX_MIB_SACKMERGED),
 	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 32b048e524d6773538918eca175b3f422f9c2aa7..45aac7ada13592c6f1c9f28aea4426b40520e0c8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1169,6 +1169,7 @@ static bool tcp_v4_inbound_md5_hash(const struct sock *sk,
 				      NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMD5FAILURE);
 		net_info_ratelimited("MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
 				     &iph->saddr, ntohs(th->source),
 				     &iph->daddr, ntohs(th->dest),
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e0f46439e391f2a8b2fac2e13b6f61a11c082715..60a65d058349c93fb66275434f6fe162a621782e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -671,6 +671,7 @@ static bool tcp_v6_inbound_md5_hash(const struct sock *sk,
 				      NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMD5FAILURE);
 		net_info_ratelimited("MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
 				     genhash ? "failed" : "mismatch",
 				     &ip6h->saddr, ntohs(th->source),
