From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net] geneve: Fix function matching VNI and tunnel ID on big-endian
Date: Thu, 19 Oct 2017 13:31:28 +0200
Message-ID: <7fb32cd5779c5c0133754194aa6914fa8689853e.1508412016.git.sbrivio@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752422AbdJSLf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 07:35:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On big-endian machines, functions converting between tunnel ID
and VNI use the three LSBs of tunnel ID storage to map VNI.

The comparison function eq_tun_id_and_vni(), on the other hand,
attempted to map the VNI from the three MSBs. Fix it by using
the same check implemented on LE, which maps VNI from the three
LSBs of tunnel ID.

Fixes: 2e0b26e10352 ("geneve: Optimize geneve device lookup.")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
I guess this should be queued up for -stable, back to 4.10

 drivers/net/geneve.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f6404074b7b0..ed51018a813e 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -113,13 +113,7 @@ static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 
 static bool eq_tun_id_and_vni(u8 *tun_id, u8 *vni)
 {
-#ifdef __BIG_ENDIAN
-	return (vni[0] == tun_id[2]) &&
-	       (vni[1] == tun_id[1]) &&
-	       (vni[2] == tun_id[0]);
-#else
 	return !memcmp(vni, &tun_id[5], 3);
-#endif
 }
 
 static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
-- 
2.9.4
