From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V2] net/mlx5e: Fix a -Wmaybe-uninitialized warning
Date: Sun, 15 Jan 2017 19:50:46 +0200
Message-ID: <1484502646-29692-1-git-send-email-ogerlitz@mellanox.com>
Cc: Hadar Har-Zion <hadarh@mellanox.com>, netdev@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57784 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751153AbdAORu7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 12:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

As found by Olof's build bot, we gain a harmless warning about a
potential uninitialized variable reference in mlx5:

drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'parse_tc_fdb_actions':
drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:769:13: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:811:21: note: 'out_dev' was declared here

This was introduced through the addition of an 'IS_ERR/PTR_ERR' pair
that gcc is unfortunately unable to completely figure out.

The problem being gcc cannot tell that if(IS_ERR()) in
mlx5e_route_lookup_ipv4() is equivalent to checking if(err) later,
so it assumes that 'out_dev' is used after the 'return PTR_ERR(rt)'.

The PTR_ERR_OR_ZERO() case by comparison is fairly easy to detect
by gcc, so it can't get that wrong, so it no longer warns.

Hadar Hen Zion already attempted to fix the warning earlier by adding fake
initializations, but that ended up not fully addressing all warnings, so
I'm reverting it now that it is no longer needed.

Link: http://arm-soc.lixom.net/buildlogs/mainline/v4.10-rc3-98-gcff3b2c/
Fixes: a42485eb0ee4 ("net/mlx5e: TC ipv4 tunnel encap offload error flow fixes")
Fixes: a757d108dc1a ("net/mlx5e: Fix kbuild warnings for uninitialized parameters")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
changes from V1:
 - kept calling ip_route_output_key() only when CONFIG_INET is defined

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 118cea5..46bef6a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -668,9 +668,12 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 	int ttl;
 
 #if IS_ENABLED(CONFIG_INET)
+	int ret;
+
 	rt = ip_route_output_key(dev_net(mirred_dev), fl4);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
+	ret = PTR_ERR_OR_ZERO(rt);
+	if (ret)
+		return ret;
 #else
 	return -EOPNOTSUPP;
 #endif
@@ -741,8 +744,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	struct flowi4 fl4 = {};
 	char *encap_header;
 	int encap_size;
-	__be32 saddr = 0;
-	int ttl = 0;
+	__be32 saddr;
+	int ttl;
 	int err;
 
 	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
-- 
2.3.7
