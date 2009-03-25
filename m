From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH v2 1/4] ipv6: Disallow binding to v4-mapped address on v6-only socket.
Date: Tue, 24 Mar 2009 22:24:48 -0400
Message-ID: <1237947891-26825-2-git-send-email-vladislav.yasevich@hp.com>
References: <1237947891-26825-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:5792 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755971AbZCYCY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 22:24:57 -0400
In-Reply-To: <1237947891-26825-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A socket marked v6-only, can not receive or send traffic to v4-mapped
addresses.  Thus allowing binding to v4-mapped address on such a
socket makes no sense.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/ipv6/af_inet6.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index fbf533c..7f092fa 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -276,6 +276,13 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	/* Check if the address belongs to the host. */
 	if (addr_type == IPV6_ADDR_MAPPED) {
+		/* Binding to v4-mapped address on a v6-only socket
+		 * makes no sense
+		 */
+		if (np->ipv6only) {
+			err = -EINVAL;
+			goto out;
+		}
 		v4addr = addr->sin6_addr.s6_addr32[3];
 		if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
 			err = -EADDRNOTAVAIL;
-- 
1.5.4.3

