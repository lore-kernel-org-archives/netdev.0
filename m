From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/25] netfilter: ipset: netnet,netportnet: Fix value range support for IPv4
Date: Wed, 10 Sep 2014 17:10:22 +0200
Message-ID: <1410361842-4656-6-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55803 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbaIJPKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 11:10:05 -0400
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>

Ranges of values are broken with hash:net,net and hash:net,port,net.

hash:net,net
============

   # ipset create test-nn hash:net,net
   # ipset add test-nn 10.0.10.1-10.0.10.127,10.0.0.0/8

   # ipset list test-nn
   Name: test-nn
   Type: hash:net,net
   Revision: 0
   Header: family inet hashsize 1024 maxelem 65536
   Size in memory: 16960
   References: 0
   Members:
   10.0.10.1,10.0.0.0/8

   # ipset test test-nn 10.0.10.65,10.0.0.1
   10.0.10.65,10.0.0.1 is NOT in set test-nn.
   # ipset test test-nn 10.0.10.1,10.0.0.1
   10.0.10.1,10.0.0.1 is in set test-nn.

hash:net,port,net
=================

   # ipset create test-npn hash:net,port,net
   # ipset add test-npn 10.0.10.1-10.0.10.127,tcp:80,10.0.0.0/8
   # ipset list test-npn
   Name: test-npn
   Type: hash:net,port,net
   Revision: 0
   Header: family inet hashsize 1024 maxelem 65536
   Size in memory: 17344
   References: 0
   Members:
   10.0.10.8/29,tcp:80,10.0.0.0
   10.0.10.16/28,tcp:80,10.0.0.0
   10.0.10.2/31,tcp:80,10.0.0.0
   10.0.10.64/26,tcp:80,10.0.0.0
   10.0.10.32/27,tcp:80,10.0.0.0
   10.0.10.4/30,tcp:80,10.0.0.0
   10.0.10.1,tcp:80,10.0.0.0
   # ipset list test-npn
   # ipset test test-npn 10.0.10.126,tcp:80,10.0.0.2
   10.0.10.126,tcp:80,10.0.0.2 is NOT in set test-npn.
   # ipset test test-npn 10.0.10.126,tcp:80,10.0.0.0
   10.0.10.126,tcp:80,10.0.0.0 is in set test-npn.

   # ipset create test-npn hash:net,port,net
   # ipset add test-npn 10.0.10.0/24,tcp:80-81,10.0.0.0/8
   # ipset list test-npn
   Name: test-npn
   Type: hash:net,port,net
   Revision: 0
   Header: family inet hashsize 1024 maxelem 65536
   Size in memory: 17024
   References: 0
   Members:
   10.0.10.0,tcp:80,10.0.0.0
   10.0.10.0,tcp:81,10.0.0.0
   # ipset test test-npn 10.0.10.126,tcp:80,10.0.0.0
   10.0.10.126,tcp:80,10.0.0.0 is NOT in set test-npn.
   # ipset test test-npn 10.0.10.0,tcp:80,10.0.0.0
   10.0.10.0,tcp:80,10.0.0.0 is in set test-npn.

Correctly setup from..to variables where no IPSET_ATTR_IP_TO{,2}
attribute is given, so in range processing loop we construct proper
cidr value. Check whenever we have no ranges and can short cut in
hash:net,net properly. Use unlikely() where appropriate, to comply
with other modules.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_netnet.c     |   13 +++++++------
 net/netfilter/ipset/ip_set_hash_netportnet.c |    6 ++++--
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 3e99987..96b1313 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -203,7 +203,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
-	if (adt == IPSET_TEST || !(tb[IPSET_ATTR_IP_TO] &&
+	if (adt == IPSET_TEST || !(tb[IPSET_ATTR_IP_TO] ||
 				   tb[IPSET_ATTR_IP2_TO])) {
 		e.ip[0] = htonl(ip & ip_set_hostmask(e.cidr[0]));
 		e.ip[1] = htonl(ip2_from & ip_set_hostmask(e.cidr[1]));
@@ -219,9 +219,10 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			return ret;
 		if (ip_to < ip)
 			swap(ip, ip_to);
-		if (ip + UINT_MAX == ip_to)
+		if (unlikely(ip + UINT_MAX == ip_to))
 			return -IPSET_ERR_HASH_RANGE;
-	}
+	} else
+		ip_set_mask_from_to(ip, ip_to, e.cidr[0]);
 
 	ip2_to = ip2_from;
 	if (tb[IPSET_ATTR_IP2_TO]) {
@@ -230,10 +231,10 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			return ret;
 		if (ip2_to < ip2_from)
 			swap(ip2_from, ip2_to);
-		if (ip2_from + UINT_MAX == ip2_to)
+		if (unlikely(ip2_from + UINT_MAX == ip2_to))
 			return -IPSET_ERR_HASH_RANGE;
-
-	}
+	} else
+		ip_set_mask_from_to(ip2_from, ip2_to, e.cidr[1]);
 
 	if (retried)
 		ip = ntohl(h->next.ip[0]);
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index c0d2ba7..2f00343 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -257,7 +257,8 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			swap(ip, ip_to);
 		if (unlikely(ip + UINT_MAX == ip_to))
 			return -IPSET_ERR_HASH_RANGE;
-	}
+	} else
+		ip_set_mask_from_to(ip, ip_to, e.cidr[0]);
 
 	port_to = port = ntohs(e.port);
 	if (tb[IPSET_ATTR_PORT_TO]) {
@@ -275,7 +276,8 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			swap(ip2_from, ip2_to);
 		if (unlikely(ip2_from + UINT_MAX == ip2_to))
 			return -IPSET_ERR_HASH_RANGE;
-	}
+	} else
+		ip_set_mask_from_to(ip2_from, ip2_to, e.cidr[1]);
 
 	if (retried)
 		ip = ntohl(h->next.ip[0]);
-- 
1.7.10.4
