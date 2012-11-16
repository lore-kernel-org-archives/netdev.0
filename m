From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: ipv6: only provide sk_bound_dev_if for link-local addr
Date: Fri, 16 Nov 2012 13:40:53 +0100
Message-ID: <1353069653-3231-5-git-send-email-pablo@netfilter.org>
References: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44474 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab2KPMlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 07:41:03 -0500
In-Reply-To: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

yoshfuji points out that sk_bound_dev_if should only be provided
for link-local addresses.

IPv6 getpeer/sockname also has this test, i.e. we will now
only set sin6_scope_id if the original(!) destination
was a link-local address.

Reported-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 02dcafd..e5f6cf7 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -334,9 +334,14 @@ ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	memcpy(&sin6.sin6_addr,
 		&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.in6,
 					sizeof(sin6.sin6_addr));
-	sin6.sin6_scope_id = sk->sk_bound_dev_if;
 
 	nf_ct_put(ct);
+
+	if (ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		sin6.sin6_scope_id = sk->sk_bound_dev_if;
+	else
+		sin6.sin6_scope_id = 0;
+
 	return copy_to_user(user, &sin6, sizeof(sin6)) ? -EFAULT : 0;
 }
 
-- 
1.7.10.4
