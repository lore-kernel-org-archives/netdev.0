From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 4/4] geneve: Optimize geneve device lookup.
Date: Fri, 18 Nov 2016 18:10:11 -0800
Message-ID: <1479521411-53012-5-git-send-email-pshelar@ovn.org>
References: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:41948 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcKSCKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 21:10:23 -0500
In-Reply-To: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than comparing 64-bit tunnel-id, compare tunnel vni
which is 24-bit id. This also save conversion from vni
to tunnel id on each tunnel packet receive.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/geneve.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f2912ca..930b1b0 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -103,6 +103,17 @@ static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 #endif
 }
 
+static bool eq_tun_id_and_vni(u8 *tun_id, u8 *vni)
+{
+#ifdef __BIG_ENDIAN
+	return (vni[0] == tun_id[2]) &&
+	       (vni[1] == tun_id[1]) &&
+	       (vni[2] == tun_id[0]);
+#else
+	return !memcmp(vni, &tun_id[5], 3);
+#endif
+}
+
 static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
 {
 	return gs->sock->sk->sk_family;
@@ -111,7 +122,6 @@ static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
 static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 					__be32 addr, u8 vni[])
 {
-	__be64 id = vni_to_tunnel_id(vni);
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
 	__u32 hash;
@@ -120,7 +130,7 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 	hash = geneve_net_vni_hash(vni);
 	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
-		if (!memcmp(&id, &geneve->info.key.tun_id, sizeof(id)) &&
+		if (eq_tun_id_and_vni((u8 *)&geneve->info.key.tun_id, vni) &&
 		    addr == geneve->info.key.u.ipv4.dst)
 			return geneve;
 	}
@@ -131,7 +141,6 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
 					 struct in6_addr addr6, u8 vni[])
 {
-	__be64 id = vni_to_tunnel_id(vni);
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
 	__u32 hash;
@@ -140,7 +149,7 @@ static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
 	hash = geneve_net_vni_hash(vni);
 	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
-		if (!memcmp(&id, &geneve->info.key.tun_id, sizeof(id)) &&
+		if (eq_tun_id_and_vni((u8 *)&geneve->info.key.tun_id, vni) &&
 		    ipv6_addr_equal(&addr6, &geneve->info.key.u.ipv6.dst))
 			return geneve;
 	}
-- 
1.8.3.1
