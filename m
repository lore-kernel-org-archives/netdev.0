From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v2] netlabel: Fix build problems when IPv6 is not enabled
Date: Tue, 29 Nov 2011 15:10:54 -0500
Message-ID: <20111129201054.20141.86401.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent fix to the the NetLabel code caused build problem with
configurations that did not have IPv6 enabled; see below:

 netlabel_kapi.c: In function 'netlbl_cfg_unlbl_map_add':
 netlabel_kapi.c:165:4:
  error: implicit declaration of function 'netlbl_af6list_add'

This patch fixes this problem by making the IPv6 specific code conditional
on the IPv6 configuration flags as we done in the rest of NetLabel and the
network stack as a whole.  We have to move some variable declarations
around as a result so things may not be quite as pretty, but at least it
builds cleanly now.

Some additional IPv6 conditionals were added to the NetLabel code as well
for the sake of consistency.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/netlabel/netlabel_kapi.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 3735297..5952237 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -111,8 +111,6 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 	struct netlbl_domaddr_map *addrmap = NULL;
 	struct netlbl_domaddr4_map *map4 = NULL;
 	struct netlbl_domaddr6_map *map6 = NULL;
-	const struct in_addr *addr4, *mask4;
-	const struct in6_addr *addr6, *mask6;
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
@@ -133,9 +131,9 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 		INIT_LIST_HEAD(&addrmap->list6);
 
 		switch (family) {
-		case AF_INET:
-			addr4 = addr;
-			mask4 = mask;
+		case AF_INET: {
+			const struct in_addr *addr4 = addr;
+			const struct in_addr *mask4 = mask;
 			map4 = kzalloc(sizeof(*map4), GFP_ATOMIC);
 			if (map4 == NULL)
 				goto cfg_unlbl_map_add_failure;
@@ -148,9 +146,11 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			if (ret_val != 0)
 				goto cfg_unlbl_map_add_failure;
 			break;
-		case AF_INET6:
-			addr6 = addr;
-			mask6 = mask;
+			}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case AF_INET6: {
+			const struct in6_addr *addr6 = addr;
+			const struct in6_addr *mask6 = mask;
 			map6 = kzalloc(sizeof(*map6), GFP_ATOMIC);
 			if (map6 == NULL)
 				goto cfg_unlbl_map_add_failure;
@@ -167,6 +167,8 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			if (ret_val != 0)
 				goto cfg_unlbl_map_add_failure;
 			break;
+			}
+#endif /* IPv6 */
 		default:
 			goto cfg_unlbl_map_add_failure;
 			break;
@@ -225,9 +227,11 @@ int netlbl_cfg_unlbl_static_add(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
+#endif /* IPv6 */
 	default:
 		return -EPFNOSUPPORT;
 	}
@@ -266,9 +270,11 @@ int netlbl_cfg_unlbl_static_del(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
+#endif /* IPv6 */
 	default:
 		return -EPFNOSUPPORT;
 	}
