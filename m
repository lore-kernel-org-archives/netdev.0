From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 04/10] net/mlx4_en: Resolve dividing by zero in 32-bit system
Date: Thu, 27 Oct 2016 16:27:16 +0300
Message-ID: <1477574842-29688-5-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57539 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941570AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

When doing roundup_pow_of_two for large enough number with
bit 31, an overflow will occur and a value equal to 1 will
be returned. In this case 1 will be subtracted from the return
value and division by zero will be reached.

Fixes: 31c128b66e5b ("net/mlx4_en: Choose time-stamping shift value according to HW frequency")
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 08fc5fc56d43..a5fc46bbcbe2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -245,8 +245,11 @@ static u32 freq_to_shift(u16 freq)
 {
 	u32 freq_khz = freq * 1000;
 	u64 max_val_cycles = freq_khz * 1000 * MLX4_EN_WRAP_AROUND_SEC;
+	u64 tmp_rounded =
+		roundup_pow_of_two(max_val_cycles) > max_val_cycles ?
+		roundup_pow_of_two(max_val_cycles) - 1 : UINT_MAX;
 	u64 max_val_cycles_rounded = is_power_of_2(max_val_cycles + 1) ?
-		max_val_cycles : roundup_pow_of_two(max_val_cycles) - 1;
+		max_val_cycles : tmp_rounded;
 	/* calculate max possible multiplier in order to fit in 64bit */
 	u64 max_mul = div_u64(0xffffffffffffffffULL, max_val_cycles_rounded);
 
-- 
1.8.3.1
