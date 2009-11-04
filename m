From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sctp: ipv6: avoid touching device refcount
Date: Wed, 04 Nov 2009 22:06:02 +0100
Message-ID: <4AF1ECBA.6070301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45724 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbZKDVGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:06:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid touching device refcount in sctp/ipv6, thanks to RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sctp/ipv6.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index bb280e6..7691527 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -837,15 +837,16 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 		if (type & IPV6_ADDR_LINKLOCAL) {
 			if (!addr->v6.sin6_scope_id)
 				return 0;
-			dev = dev_get_by_index(&init_net, addr->v6.sin6_scope_id);
-			if (!dev)
-				return 0;
-			if (!ipv6_chk_addr(&init_net, &addr->v6.sin6_addr,
+			rcu_read_lock();
+			dev = dev_get_by_index_rcu(&init_net,
+						   addr->v6.sin6_scope_id);
+			if (!dev ||
+			    !ipv6_chk_addr(&init_net, &addr->v6.sin6_addr,
 					   dev, 0)) {
-				dev_put(dev);
+				rcu_read_unlock();
 				return 0;
 			}
-			dev_put(dev);
+			rcu_read_unlock();
 		} else if (type == IPV6_ADDR_MAPPED) {
 			if (!opt->v4mapped)
 				return 0;
@@ -873,10 +874,12 @@ static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
 		if (type & IPV6_ADDR_LINKLOCAL) {
 			if (!addr->v6.sin6_scope_id)
 				return 0;
-			dev = dev_get_by_index(&init_net, addr->v6.sin6_scope_id);
+			rcu_read_lock();
+			dev = dev_get_by_index_rcu(&init_net,
+						   addr->v6.sin6_scope_id);
+			rcu_read_unlock();
 			if (!dev)
 				return 0;
-			dev_put(dev);
 		}
 		af = opt->pf->af;
 	}
