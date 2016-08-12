From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net v2] net: ipv6: Fix ping to link-local addresses.
Date: Sat, 13 Aug 2016 01:13:38 +0900
Message-ID: <1471018418-12212-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, ek@google.com, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com, dsa@cumulusnetworks.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33045 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbcHLQNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 12:13:47 -0400
Received: by mail-pa0-f49.google.com with SMTP id ti13so9942069pac.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 09:13:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping_v6_sendmsg does not set flowi6_oif in response to
sin6_scope_id or sk_bound_dev_if, so it is not possible to use
these APIs to ping an IPv6 address on a different interface.
Instead, it sets flowi6_iif, which is incorrect but harmless.

Stop setting flowi6_iif, and support various ways of setting oif
in the same priority order used by udpv6_sendmsg.

Tested: https://android-review.googlesource.com/#/c/254470/
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/ping.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index fed40d1..0900352 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -55,7 +55,7 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct icmp6hdr user_icmph;
 	int addr_type;
 	struct in6_addr *daddr;
-	int iif = 0;
+	int oif = 0;
 	struct flowi6 fl6;
 	int err;
 	struct dst_entry *dst;
@@ -78,25 +78,30 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		if (u->sin6_family != AF_INET6) {
 			return -EAFNOSUPPORT;
 		}
-		if (sk->sk_bound_dev_if &&
-		    sk->sk_bound_dev_if != u->sin6_scope_id) {
-			return -EINVAL;
-		}
 		daddr = &(u->sin6_addr);
-		iif = u->sin6_scope_id;
+		if (__ipv6_addr_needs_scope_id(ipv6_addr_type(daddr)))
+			oif = u->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 		daddr = &sk->sk_v6_daddr;
 	}
 
-	if (!iif)
-		iif = sk->sk_bound_dev_if;
+	if (!oif)
+		oif = sk->sk_bound_dev_if;
+
+	if (!oif)
+		oif = np->sticky_pktinfo.ipi6_ifindex;
+
+	if (!oif && ipv6_addr_is_multicast(daddr))
+		oif = np->mcast_oif;
+	else if (!oif)
+		oif = np->ucast_oif;
 
 	addr_type = ipv6_addr_type(daddr);
-	if (__ipv6_addr_needs_scope_id(addr_type) && !iif)
-		return -EINVAL;
-	if (addr_type & IPV6_ADDR_MAPPED)
+	if ((__ipv6_addr_needs_scope_id(addr_type) && !oif) ||
+	    (addr_type & IPV6_ADDR_MAPPED) ||
+	    (oif && sk->sk_bound_dev_if && oif != sk->sk_bound_dev_if))
 		return -EINVAL;
 
 	/* TODO: use ip6_datagram_send_ctl to get options from cmsg */
@@ -106,16 +111,12 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
 	fl6.saddr = np->saddr;
 	fl6.daddr = *daddr;
+	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_icmp_type = user_icmph.icmp6_type;
 	fl6.fl6_icmp_code = user_icmph.icmp6_code;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
-
 	ipc6.tclass = np->tclass;
 	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
 
-- 
2.8.0.rc3.226.g39d4020
