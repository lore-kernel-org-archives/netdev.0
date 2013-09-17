From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: ipset: Consistent userspace testing with nomatch flag
Date: Wed, 18 Sep 2013 00:07:31 +0200
Message-ID: <1379455654-3905-5-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34751 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754072Ab3IQWII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:08 -0400
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The "nomatch" commandline flag should invert the matching at testing,
similarly to the --return-nomatch flag of the "set" match of iptables.
Until now it worked with the elements with "nomatch" flag only. From
now on it works with elements without the flag too, i.e:

 # ipset n test hash:net
 # ipset a test 10.0.0.0/24 nomatch
 # ipset t test 10.0.0.1
 10.0.0.1 is NOT in set test.
 # ipset t test 10.0.0.1 nomatch
 10.0.0.1 is in set test.

 # ipset a test 192.168.0.0/24
 # ipset t test 192.168.0.1
 192.168.0.1 is in set test.
 # ipset t test 192.168.0.1 nomatch
 192.168.0.1 is NOT in set test.

 Before the patch the results were

 ...
 # ipset t test 192.168.0.1
 192.168.0.1 is in set test.
 # ipset t test 192.168.0.1 nomatch
 192.168.0.1 is in set test.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    6 ++++--
 net/netfilter/ipset/ip_set_core.c           |    3 +--
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 ++--
 net/netfilter/ipset/ip_set_hash_net.c       |    4 ++--
 net/netfilter/ipset/ip_set_hash_netiface.c  |    4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c   |    4 ++--
 6 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index d80e275..9ac9fbd 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -296,10 +296,12 @@ ip_set_eexist(int ret, u32 flags)
 
 /* Match elements marked with nomatch */
 static inline bool
-ip_set_enomatch(int ret, u32 flags, enum ipset_adt adt)
+ip_set_enomatch(int ret, u32 flags, enum ipset_adt adt, struct ip_set *set)
 {
 	return adt == IPSET_TEST &&
-	       ret == -ENOTEMPTY && ((flags >> 16) & IPSET_FLAG_NOMATCH);
+	       (set->type->features & IPSET_TYPE_NOMATCH) &&
+	       ((flags >> 16) & IPSET_FLAG_NOMATCH) &&
+	       (ret > 0 || ret == -ENOTEMPTY);
 }
 
 /* Check the NLA_F_NET_BYTEORDER flag */
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index f771390..c8c303c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1489,8 +1489,7 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 	if (ret == -EAGAIN)
 		ret = 1;
 
-	return (ret < 0 && ret != -ENOTEMPTY) ? ret :
-		ret > 0 ? 0 : -IPSET_ERR_EXIST;
+	return ret > 0 ? 0 : -IPSET_ERR_EXIST;
 }
 
 /* Get headed data of a set */
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index c6a5253..f15f3e2 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -260,7 +260,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		e.ip = htonl(ip);
 		e.ip2 = htonl(ip2_from & ip_set_hostmask(e.cidr + 1));
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
@@ -544,7 +544,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index da740ce..223e9f5 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -199,7 +199,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		e.ip = htonl(ip & ip_set_hostmask(e.cidr));
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret:
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
@@ -396,7 +396,7 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	ret = adtfn(set, &e, &ext, &ext, flags);
 
-	return ip_set_enomatch(ret, flags, adt) ? 1 :
+	return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 84ae6f6..7d798d5 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -368,7 +368,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		e.ip = htonl(ip & ip_set_hostmask(e.cidr));
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
@@ -634,7 +634,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	ret = adtfn(set, &e, &ext, &ext, flags);
 
-	return ip_set_enomatch(ret, flags, adt) ? 1 :
+	return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 9a08698..09d6690 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -244,7 +244,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (adt == IPSET_TEST || !(with_ports || tb[IPSET_ATTR_IP_TO])) {
 		e.ip = htonl(ip & ip_set_hostmask(e.cidr + 1));
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
@@ -489,7 +489,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &e, &ext, &ext, flags);
-		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-- 
1.7.10.4
