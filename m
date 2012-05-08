From: pablo@netfilter.org
Subject: [PATCH 23/25] netfilter: nf_ct_expect: partially implement ctnetlink_change_expect
Date: Tue,  8 May 2012 02:22:17 +0200
Message-ID: <1336436539-5880-24-git-send-email-pablo@netfilter.org>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51851 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193Ab2EHAXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 20:23:13 -0400
In-Reply-To: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kelvie Wong <kelvie@ieee.org>

This refreshes the "timeout" attribute in existing expectations if one is
given.

The use case for this would be for userspace helpers to extend the lifetime
of the expectation when requested, as this is not possible right now
without deleting/recreating the expectation.

I use this specifically for forwarding DCERPC traffic through:

DCERPC has a port mapper daemon that chooses a (seemingly) random port for
future traffic to go to. We expect this traffic (with a reasonable
timeout), but sometimes the port mapper will tell the client to continue
using the same port. This allows us to extend the expectation accordingly.

Signed-off-by: Kelvie Wong <kelvie@ieee.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 462ec2d..6f4b00a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2080,7 +2080,15 @@ static int
 ctnetlink_change_expect(struct nf_conntrack_expect *x,
 			const struct nlattr * const cda[])
 {
-	return -EOPNOTSUPP;
+	if (cda[CTA_EXPECT_TIMEOUT]) {
+		if (!del_timer(&x->timeout))
+			return -ETIME;
+
+		x->timeout.expires = jiffies +
+			ntohl(nla_get_be32(cda[CTA_EXPECT_TIMEOUT])) * HZ;
+		add_timer(&x->timeout);
+	}
+	return 0;
 }
 
 static const struct nla_policy exp_nat_nla_policy[CTA_EXPECT_NAT_MAX+1] = {
-- 
1.7.9.5
