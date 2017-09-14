From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] net/mlx5: fpga: avoid uninitialized return codes
Date: Thu, 14 Sep 2017 13:06:18 +0200
Message-ID: <20170914110628.3590833-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

calling mlx5_fpga_mem_{read,write}_i2c() with a zero length on
older compiler version such as gcc-4.6 results in a warning that
the return code is not initialized:

drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:147:6: error: ‘err’ may be used uninitialized in this function [-Werror=uninitialized]
drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:126:6: error: ‘err’ may be used uninitialized in this function [-Werror=uninitialized]

On newer compilers, the 'err' variable is optimized away in this
code path and assumed to be zero when the loop completes, so we
don't get this warning.

I'm changing the function here to instead return -EINVAL for the
case, under the assumption that it was never meant to be called
with a zero length argument.

Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=82203
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
index 3c11d6e2160a..914fb9d77a1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
@@ -64,7 +64,7 @@ static int mlx5_fpga_mem_read_i2c(struct mlx5_fpga_device *fdev, size_t size,
 	size_t max_size = MLX5_FPGA_ACCESS_REG_SIZE_MAX;
 	size_t bytes_done = 0;
 	u8 actual_size;
-	int err;
+	int err = -EINVAL;
 
 	if (!fdev->mdev)
 		return -ENOTCONN;
@@ -93,7 +93,7 @@ static int mlx5_fpga_mem_write_i2c(struct mlx5_fpga_device *fdev, size_t size,
 	size_t max_size = MLX5_FPGA_ACCESS_REG_SIZE_MAX;
 	size_t bytes_done = 0;
 	u8 actual_size;
-	int err;
+	int err = -EINVAL;
 
 	if (!fdev->mdev)
 		return -ENOTCONN;
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
