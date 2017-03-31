From: akpm@linux-foundation.org
Subject: [patch 1/2] drivers/net/ethernet/mellanox/mlx5/core/en_main.c:
 fix build with gcc-4.4.4
Date: Fri, 31 Mar 2017 13:09:38 -0700
Message-ID: <58deb782.4aWRKEOlfxaAvBBc%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: saeedm@mellanox.com, netdev@vger.kernel.org,
        akpm@linux-foundation.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:49360 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933339AbdCaUJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 16:09:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: drivers/net/ethernet/mellanox/mlx5/core/en_main.c: fix build with gcc-4.4.4

drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts':
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2210: error: unknown field 'rqn' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2211: warning: missing braces around initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2211: warning: (near initialization for 'direct_rrp.<anonymous>')
drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts_to_channels':
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: error: unknown field 'rss' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: missing braces around initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: (near initialization for 'rrp.<anonymous>')
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: initialization makes integer from pointer without a cast
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2228: error: unknown field 'rss' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2229: warning: excess elements in struct initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2229: warning: (near initialization for 'rrp')
drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts_to_drop':
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2238: error: unknown field 'rqn' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2239: warning: missing braces around initializer
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2239: warning: (near initialization for 'drop_rrp.<anonymous>')

gcc-4.4.4 has issues with anonymous union initializers.  Work around this.

Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   16 +++++++++---
 1 file changed, 12 insertions(+), 4 deletions(-)

diff -puN drivers/net/ethernet/mellanox/mlx5/core/en_main.c~drivers-net-ethernet-mellanox-mlx5-core-en_mainc-fix-build-with-gcc-444 drivers/net/ethernet/mellanox/mlx5/core/en_main.c
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c~drivers-net-ethernet-mellanox-mlx5-core-en_mainc-fix-build-with-gcc-444
+++ a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2207,7 +2207,9 @@ static void mlx5e_redirect_rqts(struct m
 	for (ix = 0; ix < priv->profile->max_nch(priv->mdev); ix++) {
 		struct mlx5e_redirect_rqt_param direct_rrp = {
 			.is_rss = false,
-			.rqn    = mlx5e_get_direct_rqn(priv, ix, rrp)
+			{
+				.rqn    = mlx5e_get_direct_rqn(priv, ix, rrp)
+			},
 		};
 
 		/* Direct RQ Tables */
@@ -2224,8 +2226,12 @@ static void mlx5e_redirect_rqts_to_chann
 {
 	struct mlx5e_redirect_rqt_param rrp = {
 		.is_rss        = true,
-		.rss.channels  = chs,
-		.rss.hfunc     = chs->params.rss_hfunc
+		{
+			.rss = {
+				.channels  = chs,
+				.hfunc     = chs->params.rss_hfunc,
+			}
+		},
 	};
 
 	mlx5e_redirect_rqts(priv, rrp);
@@ -2235,7 +2241,9 @@ static void mlx5e_redirect_rqts_to_drop(
 {
 	struct mlx5e_redirect_rqt_param drop_rrp = {
 		.is_rss = false,
-		.rqn = priv->drop_rq.rqn
+		{
+			.rqn = priv->drop_rq.rqn,
+		},
 	};
 
 	mlx5e_redirect_rqts(priv, drop_rrp);
_
