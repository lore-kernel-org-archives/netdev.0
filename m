From: kaber@trash.net
Subject: [PATCH 3/3] netfilter: ipset: SCTP, UDPLITE support added
Date: Tue, 19 Apr 2011 16:31:32 +0200
Message-ID: <1303223492-13549-4-git-send-email-kaber@trash.net>
References: <1303223492-13549-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303223492-13549-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

SCTP and UDPLITE port support added to the hash:*port* set types.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_getport.h |    2 ++
 net/netfilter/ipset/ip_set_getport.c           |   16 +++++++++++++++-
 net/netfilter/ipset/ip_set_hash_ipport.c       |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_netport.c      |    2 +-
 6 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_getport.h b/include/linux/netfilter/ipset/ip_set_getport.h
index 5aebd17..90d0930 100644
--- a/include/linux/netfilter/ipset/ip_set_getport.h
+++ b/include/linux/netfilter/ipset/ip_set_getport.h
@@ -22,7 +22,9 @@ static inline bool ip_set_proto_with_ports(u8 proto)
 {
 	switch (proto) {
 	case IPPROTO_TCP:
+	case IPPROTO_SCTP:
 	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
 		return true;
 	}
 	return false;
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 8d52272..757143b 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -11,6 +11,7 @@
 #include <linux/skbuff.h>
 #include <linux/icmp.h>
 #include <linux/icmpv6.h>
+#include <linux/sctp.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -35,7 +36,20 @@ get_port(const struct sk_buff *skb, int protocol, unsigned int protooff,
 		*port = src ? th->source : th->dest;
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_SCTP: {
+		sctp_sctphdr_t _sh;
+		const sctp_sctphdr_t *sh;
+
+		sh = skb_header_pointer(skb, protooff, sizeof(_sh), &_sh);
+		if (sh == NULL)
+			/* No choice either */
+			return false;
+
+		*port = src ? sh->source : sh->dest;
+		break;
+	}
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph;
 		const struct udphdr *uh;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index b921414..14281b6 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -491,7 +491,7 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision	= 1,
 	.create		= hash_ipport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 4642872..401c8a2 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -509,7 +509,7 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision	= 1,
 	.create		= hash_ipportip_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2cb84a5..4743e54 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -574,7 +574,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision	= 1,
 	.create		= hash_ipportnet_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 8598676..d2a4036 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -526,7 +526,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision	= 1,
 	.create		= hash_netport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
-- 
1.7.4.4

