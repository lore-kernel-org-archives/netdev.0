From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPV6]: Mischecked tw match in __inet6_check_established.
Date: Tue, 15 Jan 2008 12:22:52 +0300
Message-ID: <478C7B6C.3030002@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59644 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYAOJWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 04:22:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking for a conflicting connection the !sk->sk_bound_dev_if
check is performed only for live sockets, but not for timewait-ed.

This is not the case for ipv4, for __inet6_lookup_established in
both ipv4 and ipv6 and for other places that check for tw-s.

Was this missed accidentally? If so, then this patch fixes it and
besides makes use if the dif variable declared in the function.

Fits both, net-2.6 and net-2.6.25.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index d0b3447..a66a7d8 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -193,7 +193,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		   sk2->sk_family	       == PF_INET6	 &&
 		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	 &&
 		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr) &&
-		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
+		   (!sk2->sk_bound_dev_if || sk2->sk_bound_dev_if == dif)) {
 			if (twsk_unique(sk, sk2, twp))
 				goto unique;
 			else
