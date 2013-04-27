From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/18] netfilter: ipset: Make possible to test elements marked with nomatch
Date: Sat, 27 Apr 2013 20:58:06 +0200
Message-ID: <1367089103-8394-2-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42551 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985Ab3D0S6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:58:37 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    8 ++++++++
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   14 ++++++++------
 net/netfilter/ipset/ip_set_hash_net.c       |   14 ++++++++------
 net/netfilter/ipset/ip_set_hash_netiface.c  |   14 ++++++++------
 net/netfilter/ipset/ip_set_hash_netport.c   |   14 ++++++++------
 5 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 7958e84..9701871 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -200,6 +200,14 @@ ip_set_eexist(int ret, u32 flags)
 	return ret == -IPSET_ERR_EXIST && (flags & IPSET_FLAG_EXIST);
 }
 
+/* Match elements marked with nomatch */
+static inline bool
+ip_set_enomatch(int ret, u32 flags, enum ipset_adt adt)
+{
+	return adt == IPSET_TEST &&
+	       ret == -ENOTEMPTY && ((flags >> 16) & IPSET_FLAG_NOMATCH);
+}
+
 /* Check the NLA_F_NET_BYTEORDER flag */
 static inline bool
 ip_set_attr_netorder(struct nlattr *tb[], int type)
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 10a30b4..b4836c8 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -279,10 +279,10 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
@@ -292,7 +292,8 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		data.ip = htonl(ip);
 		data.ip2 = htonl(ip2_from & ip_set_hostmask(data.cidr + 1));
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	ip_to = ip;
@@ -610,15 +611,16 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	port = ntohs(data.port);
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index d6a5915..6dbe0af 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -225,16 +225,17 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	ip_to = ip;
@@ -466,15 +467,16 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	ret = adtfn(set, &data, timeout, flags);
 
-	return ip_set_eexist(ret, flags) ? 0 : ret;
+	return ip_set_enomatch(ret, flags, adt) ? 1 :
+	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
 /* Create hash:ip type of sets */
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index f2b0a3c..2481620 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -396,13 +396,14 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
 			data.physdev = 1;
-		if (adt == IPSET_ADD && (cadt_flags & IPSET_FLAG_NOMATCH))
-			flags |= (cadt_flags << 16);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	if (tb[IPSET_ATTR_IP_TO]) {
@@ -704,13 +705,14 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
 			data.physdev = 1;
-		if (adt == IPSET_ADD && (cadt_flags & IPSET_FLAG_NOMATCH))
-			flags |= (cadt_flags << 16);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	ret = adtfn(set, &data, timeout, flags);
 
-	return ip_set_eexist(ret, flags) ? 0 : ret;
+	return ip_set_enomatch(ret, flags, adt) ? 1 :
+	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
 /* Create hash:ip type of sets */
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 349deb6..57b0550 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -272,16 +272,17 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	if (adt == IPSET_TEST || !(with_ports || tb[IPSET_ATTR_IP_TO])) {
 		data.ip = htonl(ip & ip_set_hostmask(data.cidr + 1));
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	port = port_to = ntohs(data.port);
@@ -561,15 +562,16 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
-			flags |= (cadt_flags << 16);
+			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout, flags);
-		return ip_set_eexist(ret, flags) ? 0 : ret;
+		return ip_set_enomatch(ret, flags, adt) ? 1 :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
 	port = ntohs(data.port);
-- 
1.7.10.4
