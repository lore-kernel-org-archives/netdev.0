From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH v2] tcp: properly handle md5sig_pool references
Date: Fri, 30 Sep 2011 11:10:10 +0800
Message-ID: <4E853312.1050107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26062 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756105Ab1I3DKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 23:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_v4_clear_md5_list() assumes that multiple tcp md5sig peers
only hold one reference to md5sig_pool. but tcp_v4_md5_do_add()
increases use count of md5sig_pool for each peer. This patch
makes tcp_v4_md5_do_add() only increases use count for the first
tcp md5sig peer.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
Changes since v1:
 Fix a line over 80 characters warning

 net/ipv4/tcp_ipv4.c |   11 +++++++----
 net/ipv6/tcp_ipv6.c |    8 +++++---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c34f015..7963e03 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -927,18 +927,21 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 			}
 			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
-		if (tcp_alloc_md5sig_pool(sk) == NULL) {
+
+		md5sig = tp->md5sig_info;
+		if (md5sig->entries4 == 0 &&
+		    tcp_alloc_md5sig_pool(sk) == NULL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
-		md5sig = tp->md5sig_info;
 
 		if (md5sig->alloced4 == md5sig->entries4) {
 			keys = kmalloc((sizeof(*keys) *
 					(md5sig->entries4 + 1)), GFP_ATOMIC);
 			if (!keys) {
 				kfree(newkey);
-				tcp_free_md5sig_pool();
+				if (md5sig->entries4 == 0)
+					tcp_free_md5sig_pool();
 				return -ENOMEM;
 			}
 
@@ -982,6 +985,7 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 				kfree(tp->md5sig_info->keys4);
 				tp->md5sig_info->keys4 = NULL;
 				tp->md5sig_info->alloced4 = 0;
+				tcp_free_md5sig_pool();
 			} else if (tp->md5sig_info->entries4 != i) {
 				/* Need to do some manipulation */
 				memmove(&tp->md5sig_info->keys4[i],
@@ -989,7 +993,6 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 					(tp->md5sig_info->entries4 - i) *
 					 sizeof(struct tcp4_md5sig_key));
 			}
-			tcp_free_md5sig_pool();
 			return 0;
 		}
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3c9fa61..20ac0fc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -591,7 +591,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 			}
 			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
-		if (tcp_alloc_md5sig_pool(sk) == NULL) {
+		if (tp->md5sig_info->entries6 == 0 &&
+			tcp_alloc_md5sig_pool(sk) == NULL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
@@ -600,8 +601,9 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
 
 			if (!keys) {
-				tcp_free_md5sig_pool();
 				kfree(newkey);
+				if (tp->md5sig_info->entries6 == 0)
+					tcp_free_md5sig_pool();
 				return -ENOMEM;
 			}
 
@@ -647,6 +649,7 @@ static int tcp_v6_md5_do_del(struct sock *sk, const struct in6_addr *peer)
 				kfree(tp->md5sig_info->keys6);
 				tp->md5sig_info->keys6 = NULL;
 				tp->md5sig_info->alloced6 = 0;
+				tcp_free_md5sig_pool();
 			} else {
 				/* shrink the database */
 				if (tp->md5sig_info->entries6 != i)
@@ -655,7 +658,6 @@ static int tcp_v6_md5_do_del(struct sock *sk, const struct in6_addr *peer)
 						(tp->md5sig_info->entries6 - i)
 						* sizeof (tp->md5sig_info->keys6[0]));
 			}
-			tcp_free_md5sig_pool();
 			return 0;
 		}
 	}
