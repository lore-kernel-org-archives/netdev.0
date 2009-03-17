From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATCH 2/4] ipv6: Allow ipv4 wildcard binds after ipv6 address binds
Date: Tue, 17 Mar 2009 17:06:00 -0400
Message-ID: <1237323962-18635-3-git-send-email-vladislav.yasevich@hp.com>
References: <20090317.123146.210941276.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:35210 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbZCQVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:06:08 -0400
In-Reply-To: <20090317.123146.210941276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IPv4 wildcard (0.0.0.0) address does not intersect
in any way with explicit IPv6 addresses.  These two should
be permitted, but the IPv4 conflict code checks the ipv6only
bit as part of the test.  Since binding to an explicit IPv6
address restricts the socket to only that IPv6 address, the
side-effect is that the socket behaves as v6-only.  By
explicitely setting ipv6only in this case, allows the 2 binds
to succeed.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/ipv6/af_inet6.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 07b9f3c..0adce8e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -346,8 +346,11 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
-	if (addr_type != IPV6_ADDR_ANY)
+	if (addr_type != IPV6_ADDR_ANY) {
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
+		if (addr_type != IPV6_ADDR_MAPPED)
+			np->ipv6only = 1;
+	}
 	if (snum)
 		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
 	inet->sport = htons(inet->num);
-- 
1.5.4.3

