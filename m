From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 4/5] net/mlx4_en: Fix type mismatch for 32-bit systems
Date: Thu, 29 Dec 2016 18:37:12 +0200
Message-ID: <1483029433-3624-5-git-send-email-tariqt@mellanox.com>
References: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Slava Shwartsman <slavash@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51875 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753003AbcL2Qh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:37:58 -0500
In-Reply-To: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Slava Shwartsman <slavash@mellanox.com>

is_power_of_2 expects unsigned long and we pass u64 max_val_cycles,
this will be truncated on 32 bit systems, and the result is not what we
were expecting.
div_u64 expects u32 as a second argument and we pass
max_val_cycles_rounded which is u64 hence it will always be truncated.
Fix was tested on both 64 and 32 bit systems and got same results for
max_val_cycles and max_val_cycles_rounded.

Fixes: 4850cf458157 ("net/mlx4_en: Resolve dividing by zero in 32-bit system")
Signed-off-by: Slava Shwartsman <slavash@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 015198c14fa8..504461a464c5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -245,13 +245,9 @@ static u32 freq_to_shift(u16 freq)
 {
 	u32 freq_khz = freq * 1000;
 	u64 max_val_cycles = freq_khz * 1000 * MLX4_EN_WRAP_AROUND_SEC;
-	u64 tmp_rounded =
-		roundup_pow_of_two(max_val_cycles) > max_val_cycles ?
-		roundup_pow_of_two(max_val_cycles) - 1 : UINT_MAX;
-	u64 max_val_cycles_rounded = is_power_of_2(max_val_cycles + 1) ?
-		max_val_cycles : tmp_rounded;
+	u64 max_val_cycles_rounded = 1ULL << fls64(max_val_cycles - 1);
 	/* calculate max possible multiplier in order to fit in 64bit */
-	u64 max_mul = div_u64(0xffffffffffffffffULL, max_val_cycles_rounded);
+	u64 max_mul = div64_u64(ULLONG_MAX, max_val_cycles_rounded);
 
 	/* This comes from the reverse of clocksource_khz2mult */
 	return ilog2(div_u64(max_mul * freq_khz, 1000000));
-- 
1.8.3.1
