From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH] netfilter: log: protect nf_log_register against double registering
Date: Mon, 20 Oct 2014 19:58:03 -0200
Message-ID: <c7fcb46fa24c1a64f00c9322bb5cddbde977da0a.1413842217.git.mleitner@redhat.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, despite the comment right before the function,
nf_log_register allows registering two loggers on with the same type and
end up overwriting the previous register.

Not a real issue today as current tree doesn't have two loggers for the
same type but it's better to get this protected.

Also make sure that all of its callers do error checking.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---

Notes:
    Please let me know if you have any issues with the identation on
    nf_log_register. I just couldn't find a better one.
    
    Thanks

 net/ipv4/netfilter/nf_log_arp.c  |  8 +++++++-
 net/ipv4/netfilter/nf_log_ipv4.c |  8 +++++++-
 net/ipv6/netfilter/nf_log_ipv6.c |  8 +++++++-
 net/netfilter/nf_log.c           | 13 ++++++++++++-
 4 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index ccfc78db12ee8acae68faf451f2cf6bc5597f2c1..8b39174b7be390397a110ec9d3ed497bf8ce6d26 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -130,7 +130,13 @@ static int __init nf_log_arp_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_ARP, &nf_arp_logger);
+	ret = nf_log_register(NFPROTO_ARP, &nf_arp_logger);
+	if (ret < 0) {
+		pr_err("log: failed to register logger\n");
+		unregister_pernet_subsys(&nf_log_arp_net_ops);
+		return ret;
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 078bdca1b607a167e05e7cf1bdfedccdd5aca92a..b3cb2ff6580343a9f7537aa2f48fd23858872b4d 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -366,7 +366,13 @@ static int __init nf_log_ipv4_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_IPV4, &nf_ip_logger);
+	ret = nf_log_register(NFPROTO_IPV4, &nf_ip_logger);
+	if (ret < 0) {
+		pr_err("log: failed to register logger\n");
+		unregister_pernet_subsys(&nf_log_ipv4_net_ops);
+		return ret;
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 7b17a0be93e7eccb2a26cd3294713d0f1112158d..b89576a5ca3e2b3964b8ce4aec09c8965496c2f2 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -398,7 +398,13 @@ static int __init nf_log_ipv6_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_IPV6, &nf_ip6_logger);
+	ret = nf_log_register(NFPROTO_IPV6, &nf_ip6_logger);
+	if (ret < 0) {
+		pr_err("log: failed to register logger\n");
+		unregister_pernet_subsys(&nf_log_ipv6_net_ops);
+		return ret;
+	}
+
 	return 0;
 }
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index daad6022c689c47a66a47e7a89a83c0c848c53d6..04495d9debe784827fd0cbcf5e541f10fa06839d 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -82,10 +82,21 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	mutex_lock(&nf_log_mutex);
 
 	if (pf == NFPROTO_UNSPEC) {
+		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
+			if (rcu_dereference_protected(loggers[i][logger->type],
+					lockdep_is_held(&nf_log_mutex))) {
+				mutex_unlock(&nf_log_mutex);
+				return -EEXIST;
+			}
+		}
 		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 			rcu_assign_pointer(loggers[i][logger->type], logger);
 	} else {
-		/* register at end of list to honor first register win */
+		if (rcu_dereference_protected(loggers[pf][logger->type],
+				lockdep_is_held(&nf_log_mutex))) {
+			mutex_unlock(&nf_log_mutex);
+			return -EEXIST;
+		}
 		rcu_assign_pointer(loggers[pf][logger->type], logger);
 	}
 
-- 
1.9.3

