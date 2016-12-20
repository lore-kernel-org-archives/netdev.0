From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] qed: fix memory leak of a qed_spq_entry on error failure paths
Date: Tue, 20 Dec 2016 11:44:24 +0000
Message-ID: <20161220114424.11244-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

A qed_spq_entry entry is allocated by qed_sp_init_request but is not
kfree'd if an error occurs, causing a memory leak. Fix this by
returning the previously allocated spq entry and also setting *pp_ent
to NULL to be safe.

Thanks to Yuval Mintz for suggestions on how to improve my original
fix.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index a39ef2e..d2034fa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -55,8 +55,10 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 		break;
 
 	case QED_SPQ_MODE_BLOCK:
-		if (!p_data->p_comp_data)
-			return -EINVAL;
+		if (!p_data->p_comp_data) {
+			rc = -EINVAL;
+			goto err;
+		}
 
 		p_ent->comp_cb.cookie = p_data->p_comp_data->cookie;
 		break;
@@ -71,7 +73,8 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 	default:
 		DP_NOTICE(p_hwfn, "Unknown SPQE completion mode %d\n",
 			  p_ent->comp_mode);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto err;
 	}
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
@@ -85,6 +88,10 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 	memset(&p_ent->ramrod, 0, sizeof(p_ent->ramrod));
 
 	return 0;
+err:
+	qed_spq_return_entry(p_hwfn, *pp_ent);
+	*pp_ent = NULL;
+	return rc;
 }
 
 static enum tunnel_clss qed_tunn_get_clss_type(u8 type)
-- 
2.10.2
