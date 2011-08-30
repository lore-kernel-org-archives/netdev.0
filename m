From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] mac80211: handle allocation failures in
 mesh_pathtbl_init()
Date: Tue, 30 Aug 2011 22:16:15 +0300
Message-ID: <20110830191615.GY3705@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:MAC80211" <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: javier@cozybit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:33794 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262Ab1H3TSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 15:18:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calls to kzalloc() weren't checked here and it upsets the static
checkers.  Obviously they're not super likely to fail, but we might
as well add some error handling.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 1f91bce..96092e8 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -1075,6 +1075,7 @@ static int mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
 int mesh_pathtbl_init(void)
 {
 	struct mesh_table *tbl_path, *tbl_mpp;
+	int ret;
 
 	tbl_path = mesh_table_alloc(INIT_PATHS_SIZE_ORDER);
 	if (!tbl_path)
@@ -1083,19 +1084,27 @@ int mesh_pathtbl_init(void)
 	tbl_path->copy_node = &mesh_path_node_copy;
 	tbl_path->mean_chain_len = MEAN_CHAIN_LEN;
 	tbl_path->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
+	if (!tbl_path->known_gates) {
+		ret = -ENOMEM;
+		goto free_path;
+	}
 	INIT_HLIST_HEAD(tbl_path->known_gates);
 
 
 	tbl_mpp = mesh_table_alloc(INIT_PATHS_SIZE_ORDER);
 	if (!tbl_mpp) {
-		mesh_table_free(tbl_path, true);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto free_path;
 	}
 	tbl_mpp->free_node = &mesh_path_node_free;
 	tbl_mpp->copy_node = &mesh_path_node_copy;
 	tbl_mpp->mean_chain_len = MEAN_CHAIN_LEN;
 	/* XXX: not needed */
 	tbl_mpp->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
+	if (!tbl_mpp->known_gates) {
+		ret = -ENOMEM;
+		goto free_mpp;
+	}
 	INIT_HLIST_HEAD(tbl_mpp->known_gates);
 
 	/* Need no locking since this is during init */
@@ -1103,6 +1112,12 @@ int mesh_pathtbl_init(void)
 	RCU_INIT_POINTER(mpp_paths, tbl_mpp);
 
 	return 0;
+
+free_mpp:
+	mesh_table_free(tbl_mpp, true);
+free_path:
+	mesh_table_free(tbl_path, true);
+	return ret;
 }
 
 void mesh_path_expire(struct ieee80211_sub_if_data *sdata)
