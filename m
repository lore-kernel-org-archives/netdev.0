From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 03/21] odp-util: Add tun_key to parse_odp_key_attr()
Date: Thu, 24 May 2012 18:08:56 +0900
Message-ID: <1337850554-10339-4-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46648 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab2EXJJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:21 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v4
Correct parsing of tunnel key in parse_odp_key_attr()
so that it matches the out put of format_odp_key_attr()

TODO: fix test suite

v3
* Initial post
---
 lib/odp-util.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 23d1efe..7cff00c 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -925,6 +925,35 @@ parse_odp_key_attr(const char *s, const struct simap *port_names,
     }
 
     {
+        ovs_be32 ipv4_src;
+        ovs_be32 ipv4_dst;
+        unsigned long long tun_flags;
+        int ipv4_tos;
+        int ipv4_ttl;
+        int n = -1;
+
+        if (sscanf(s, "ipv4_tunnel(tun_id=%31[x0123456789abcdefABCDEF]"
+                   ",flags=%llx,src="IP_SCAN_FMT",dst="IP_SCAN_FMT
+                   ",tos=%i,ttl=%i)%n",
+                   tun_id_s, &tun_flags,
+                   IP_SCAN_ARGS(&ipv4_src), IP_SCAN_ARGS(&ipv4_dst),
+                   &ipv4_tos, &ipv4_ttl, &n) > 0
+            && n > 0) {
+            struct ovs_key_ipv4_tunnel tun_key;
+
+            tun_key.tun_id = htonll(strtoull(tun_id_s, NULL, 0));
+            tun_key.tun_flags = tun_flags;
+            tun_key.ipv4_src = ipv4_src;
+            tun_key.ipv4_dst = ipv4_dst;
+            tun_key.ipv4_tos = ipv4_tos;
+            tun_key.ipv4_ttl = ipv4_ttl;
+            nl_msg_put_unspec(key, OVS_KEY_ATTR_IPV4_TUNNEL,
+                              &tun_key, sizeof tun_key);
+            return n;
+        }
+    }
+
+    {
         unsigned long long int in_port;
         int n = -1;
 
-- 
1.7.10.2.484.gcd07cc5
