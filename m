From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/32] netfilter: ipset: Permit CIDR equal to the host address CIDR in IPv6
Date: Mon, 15 Jun 2015 23:26:13 +0200
Message-ID: <1434403589-24796-17-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58784 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147AbbFOVVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:31 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

Permit userspace to supply CIDR length equal to the host address CIDR
length in netlink message. Prohibit any other CIDR length for IPv6
variant of the set.

Also return -IPSET_ERR_HASH_RANGE_UNSUPPORTED instead of generic
-IPSET_ERR_PROTOCOL in IPv6 variant of hash:ip,port,net when
IPSET_ATTR_IP_TO attribute is given.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_ip.c        |   12 +++++++++---
 net/netfilter/ipset/ip_set_hash_ipmark.c    |   12 +++++++++---
 net/netfilter/ipset/ip_set_hash_ipport.c    |   12 +++++++++---
 net/netfilter/ipset/ip_set_hash_ipportip.c  |   12 +++++++++---
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   10 +++++++---
 5 files changed, 43 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 0d955a4..2b08b1b 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -240,10 +240,16 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
-	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     tb[IPSET_ATTR_IP_TO] ||
-		     tb[IPSET_ATTR_CIDR]))
+	if (unlikely(!tb[IPSET_ATTR_IP]))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+	if (unlikely(tb[IPSET_ATTR_CIDR])) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (cidr != HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index f4e14ec..68fe40c 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -235,10 +235,16 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
-		     tb[IPSET_ATTR_IP_TO] ||
-		     tb[IPSET_ATTR_CIDR]))
+		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK)))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+	if (unlikely(tb[IPSET_ATTR_CIDR])) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (cidr != HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 02d9dba..9f03639 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -275,10 +275,16 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     tb[IPSET_ATTR_IP_TO] ||
-		     tb[IPSET_ATTR_CIDR]))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+	if (unlikely(tb[IPSET_ATTR_CIDR])) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (cidr != HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 4e3b1c3..aa0966b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -286,10 +286,16 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     tb[IPSET_ATTR_IP_TO] ||
-		     tb[IPSET_ATTR_CIDR]))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+	if (unlikely(tb[IPSET_ATTR_CIDR])) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (cidr != HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 988567e..f3c6256 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -423,12 +423,16 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     tb[IPSET_ATTR_IP_TO] ||
-		     tb[IPSET_ATTR_CIDR]))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+	if (unlikely(tb[IPSET_ATTR_CIDR])) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (cidr != HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-- 
1.7.10.4
