From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/mlx5e: add IPV6 dependency
Date: Tue, 28 Feb 2017 22:12:04 +0100
Message-ID: <20170228211226.3655526-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Matthew Finlay <matt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:52712 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbdB1VXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:23:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethernet support now calls directly into the ipv6 core code, which
fails if IPV6 is a loadable module but mlx5 is built-in:

drivers/net/ethernet/mellanox/mlx5/core/en_tc.o: In function `mlx5e_create_encap_header_ipv6':
en_tc.c:(.text.mlx5e_create_encap_header_ipv6+0x110): undefined reference to `ip6_route_output_flags'

This adds a dependency to ensure that MLX5_CORE_EN can only be built
if we are able link the kernel successfully. The downside is that the
ethernet option can be hidden. Alternatively we could make MLX5_CORE
depend on "IPV6 || !IPV6", which would force MLX5_CORE to be a module
when IPV6 is, including in configurations where we don't use the ethernet
support at all.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index ddb4ca4ff930..117170014e88 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -14,6 +14,7 @@ config MLX5_CORE
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
+	depends on IPV6=y || IPV6=n || MLX5_CORE=m
 	imply PTP_1588_CLOCK
 	default n
 	---help---
-- 
2.9.0
