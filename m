From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4_en: fix a build error on 32bit arches
Date: Tue, 30 Apr 2013 13:53:51 -0700
Message-ID: <1367355231.11020.10.camel@edumazet-glaptop>
References: <20130430165730.7779d7e5d8fdca911213cce7@canb.auug.org.au>
	  <51801449.7080600@infradead.org>
	 <1367350578.11020.4.camel@edumazet-glaptop>
	 <51802BE9.7020805@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:41150 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933255Ab3D3Uxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 16:53:54 -0400
In-Reply-To: <51802BE9.7020805@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit b6c39bfcf1d7d63 ("net/mlx4_en: Add a service task")
added a build error on 32bit arches.

ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx4/mlx4_en.ko]
undefined!

Fix this problem by using do_div()

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 2f18121..fd64410 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -114,6 +114,7 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_dev *dev = mdev->dev;
+	u64 ns;
 
 	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
 	mdev->cycles.read = mlx4_en_read_clock;
@@ -133,10 +134,9 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	/* Calculate period in seconds to call the overflow watchdog - to make
 	 * sure counter is checked at least once every wrap around.
 	 */
-	mdev->overflow_period =
-		(cyclecounter_cyc2ns(&mdev->cycles,
-				    mdev->cycles.mask) / NSEC_PER_SEC / 2)
-		* HZ;
+	ns = cyclecounter_cyc2ns(&mdev->cycles, mdev->cycles.mask);
+	do_div(ns, NSEC_PER_SEC / 2 / HZ);
+	mdev->overflow_period = ns;
 }
 
 void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
