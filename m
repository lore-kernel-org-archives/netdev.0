From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH]  net: mvpp2: fix possible memory leak
Date: Sat,  1 Nov 2014 16:59:34 +0530
Message-ID: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:59129 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbaKAL3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 07:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we are allocating memory using kzalloc for struct mvpp2_prs_entry,
but later when we are getting error we were just returning the error
value without releasing the memory.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

hi,
i could not build test after modifying it. I tried to compile using
multi_v7_defconfig , but the cross compiler i have is not able to
compile it and giving sevaral warnings from the assembler.

 drivers/net/ethernet/marvell/mvpp2.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index ece83f1..c4382b3 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -1692,6 +1692,7 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 {
 	struct mvpp2_prs_entry *pe;
 	int tid_aux, tid;
+	int ret = 0;
 
 	pe = mvpp2_prs_vlan_find(priv, tpid, ai);
 
@@ -1723,8 +1724,10 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 				break;
 		}
 
-		if (tid <= tid_aux)
-			return -EINVAL;
+		if (tid <= tid_aux) {
+			ret = -EINVAL;
+			goto error;
+		}
 
 		memset(pe, 0 , sizeof(struct mvpp2_prs_entry));
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
@@ -1756,9 +1759,10 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 
 	mvpp2_prs_hw_write(priv, pe);
 
+error:
 	kfree(pe);
 
-	return 0;
+	return ret;
 }
 
 /* Get first free double vlan ai number */
@@ -1821,7 +1825,7 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 				     unsigned int port_map)
 {
 	struct mvpp2_prs_entry *pe;
-	int tid_aux, tid, ai;
+	int tid_aux, tid, ai, ret = 0;
 
 	pe = mvpp2_prs_double_vlan_find(priv, tpid1, tpid2);
 
@@ -1838,8 +1842,10 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 
 		/* Set ai value for new double vlan entry */
 		ai = mvpp2_prs_double_vlan_ai_free_get(priv);
-		if (ai < 0)
-			return ai;
+		if (ai < 0) {
+			ret = ai;
+			goto error;
+		}
 
 		/* Get first single/triple vlan tid */
 		for (tid_aux = MVPP2_PE_FIRST_FREE_TID;
@@ -1859,8 +1865,10 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 				break;
 		}
 
-		if (tid >= tid_aux)
-			return -ERANGE;
+		if (tid >= tid_aux) {
+			ret = -ERANGE;
+			goto error;
+		}
 
 		memset(pe, 0, sizeof(struct mvpp2_prs_entry));
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
@@ -1887,8 +1895,9 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 	mvpp2_prs_tcam_port_map_set(pe, port_map);
 	mvpp2_prs_hw_write(priv, pe);
 
+error:
 	kfree(pe);
-	return 0;
+	return ret;
 }
 
 /* IPv4 header parsing for fragmentation and L4 offset */
-- 
1.8.1.2
