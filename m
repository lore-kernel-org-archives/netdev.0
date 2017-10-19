From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net-next] geneve: Get rid of is_all_zero(), streamline is_tnl_info_zero()
Date: Thu, 19 Oct 2017 13:31:39 +0200
Message-ID: <94e6eb12a3260e8f569dd072686067ff52c89199.1508411792.git.sbrivio@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38414 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752705AbdJSLfa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 07:35:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to re-invent memchr_inv() with !is_all_zero(). While at
it, replace conditional and return clauses with a single return
clause in is_tnl_info_zero().

Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 drivers/net/geneve.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f6404074b7b0..869726660b83 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1140,24 +1140,11 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
 	return t;
 }
 
-static bool is_all_zero(const u8 *fp, size_t size)
-{
-	int i;
-
-	for (i = 0; i < size; i++)
-		if (fp[i])
-			return false;
-	return true;
-}
-
 static bool is_tnl_info_zero(const struct ip_tunnel_info *info)
 {
-	if (info->key.tun_id || info->key.tun_flags || info->key.tos ||
-	    info->key.ttl || info->key.label || info->key.tp_src ||
-	    !is_all_zero((const u8 *)&info->key.u, sizeof(info->key.u)))
-		return false;
-	else
-		return true;
+	return !(info->key.tun_id || !info->key.tun_flags || !info->key.tos ||
+		 info->key.ttl || !info->key.label || !info->key.tp_src ||
+		 memchr_inv(&info->key.u, 0, sizeof(info->key.u)));
 }
 
 static bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
-- 
2.9.4
