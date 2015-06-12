From: Shaohua Li <shli@fb.com>
Subject: [PATCH] mlx4_en: don't wait for high order page allocation
Date: Fri, 12 Jun 2015 09:50:59 -0700
Message-ID: <7ea4f87114ef1b52e49dd90b2a32a6cde834d943.1434127734.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Kernel-team@fb.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50117 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753520AbbFLQvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:51:02 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5CGk10L019173
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:51:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1v02yp01m8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:51:02 -0700
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 34711df4112311e5a6de0002c9521c9e-3b1d82a0 for <netdev@vger.kernel.org>;	Fri,
 12 Jun 2015 09:51:00 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

High order page allocation can cause direct memory compaction and harm
performance. The patch makes the high order page allocation don't wait,
so not trigger direct memory compaction with memory pressure. More
details can be found in a similar patch for net core:
http://marc.info/?l=linux-mm&m=143406665720428&w=2

Cc: Amir Vadai <amirv@mellanox.com>
Cc: Ido Shamay <idos@mellanox.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2a77a6b..9bc4143 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -60,8 +60,11 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
 		gfp_t gfp = _gfp;
 
-		if (order)
+		if (order) {
+			if ((PAGE_SIZE << (order - 1)) >= frag_info->frag_size)
+				gfp &= ~__GFP_WAIT;
 			gfp |= __GFP_COMP | __GFP_NOWARN;
+		}
 		page = alloc_pages(gfp, order);
 		if (likely(page))
 			break;
-- 
1.8.1
