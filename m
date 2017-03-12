From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 11/27] afnetns: validate afnetns in inet_allow_bind
Date: Mon, 13 Mar 2017 00:01:35 +0100
Message-ID: <20170312230151.5185-12-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39683 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935604AbdCLXCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:08 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 0BF9E20757
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:02 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 3DF322423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:01 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/af_inet.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index aee599e23137e7..5f11399bafd16f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -453,6 +453,17 @@ int inet_allow_bind(struct sock *sk, __be32 addr)
 	    chk_addr_ret != RTN_BROADCAST)
 		return -EADDRNOTAVAIL;
 
+	if (chk_addr_ret == RTN_LOCAL &&
+	    net_afnetns(net) != sock_afnetns(sk)) {
+		struct afnetns *afnetns;
+
+		rcu_read_lock();
+		afnetns = ifa_find_afnetns_rcu(net, addr);
+		if (afnetns != sock_afnetns(sk))
+			chk_addr_ret = -EADDRNOTAVAIL;
+		rcu_read_unlock();
+	}
+
 	return chk_addr_ret;
 }
 EXPORT_SYMBOL(inet_allow_bind);
-- 
2.9.3
