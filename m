From: pablo@netfilter.org
Subject: [PATCH 07/16] netfilter: ipset: Check and reject crazy /0 input parameters
Date: Mon, 24 Sep 2012 21:19:19 +0200
Message-ID: <1348514369-3272-8-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

bitmap:ip and bitmap:ip,mac type did not reject such a crazy range
when created and using such a set results in a kernel crash.
The hash types just silently ignored such parameters.

Reject invalid /0 input parameters explicitely.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c      |   10 ++++++----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    5 +++--
 net/netfilter/ipset/ip_set_hash_ip.c        |    2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    2 +-
 6 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 7e1b061..02184b5 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -284,7 +284,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr > 32)
+		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	} else
@@ -454,7 +454,8 @@ static int
 bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_ip *map;
-	u32 first_ip, last_ip, hosts, elements;
+	u32 first_ip, last_ip, hosts;
+	u64 elements;
 	u8 netmask = 32;
 	int ret;
 
@@ -497,7 +498,7 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	if (netmask == 32) {
 		hosts = 1;
-		elements = last_ip - first_ip + 1;
+		elements = (u64)last_ip - first_ip + 1;
 	} else {
 		u8 mask_bits;
 		u32 mask;
@@ -515,7 +516,8 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (elements > IPSET_BITMAP_MAX_RANGE + 1)
 		return -IPSET_ERR_BITMAP_RANGE_SIZE;
 
-	pr_debug("hosts %u, elements %u\n", hosts, elements);
+	pr_debug("hosts %u, elements %llu\n",
+		 hosts, (unsigned long long)elements);
 
 	map = kzalloc(sizeof(*map), GFP_KERNEL);
 	if (!map)
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index d7eaf10..6819d3c 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -557,7 +557,8 @@ static int
 bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		    u32 flags)
 {
-	u32 first_ip, last_ip, elements;
+	u32 first_ip, last_ip;
+	u64 elements;
 	struct bitmap_ipmac *map;
 	int ret;
 
@@ -588,7 +589,7 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 	} else
 		return -IPSET_ERR_PROTOCOL;
 
-	elements = last_ip - first_ip + 1;
+	elements = (u64)last_ip - first_ip + 1;
 
 	if (elements > IPSET_BITMAP_MAX_RANGE + 1)
 		return -IPSET_ERR_BITMAP_RANGE_SIZE;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 42bccd5..bc8f76e 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -179,7 +179,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr > 32)
+		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	} else
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index e0ce0dae..6760fd4 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -217,7 +217,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr > 32)
+		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	} else
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index c864bf4..ac09bec 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -225,7 +225,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr > 32)
+		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	} else
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2c704bb..242814e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -290,7 +290,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr > 32)
+		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
-- 
1.7.10.4

