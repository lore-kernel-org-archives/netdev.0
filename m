From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the rdma tree
Date: Wed, 13 Jan 2016 12:35:49 +1100
Message-ID: <20160113123549.7293b76a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Maor Gottlieb <maorg@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Doug,

After merging the rdma tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/infiniband/hw/mlx5/main.c: In function 'mlx5_ib_add':
drivers/infiniband/hw/mlx5/main.c:2255:6: error: too few arguments to function 'mlx5_ib_port_link_layer'
  if (mlx5_ib_port_link_layer(&dev->ib_dev) ==
      ^
drivers/infiniband/hw/mlx5/main.c:89:1: note: declared here
 mlx5_ib_port_link_layer(struct ib_device *device, u8 port_num)
 ^

Caused by commit

  ebd61f68e1c7 ("IB/mlx5: Support IB device's callback for getting the link layer")

interacting with commit

  038d2ef87572 ("IB/mlx5: Add flow steering support")

from the net-next tree.

I have added the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 13 Jan 2016 12:30:50 +1100
Subject: [PATCH] IB/mlx5: merge fix for mlx5_ib_port_link_layer API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/infiniband/hw/mlx5/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 307a8c040a11..a2613d828578 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -2252,7 +2252,7 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 			(1ull << IB_USER_VERBS_CMD_CLOSE_XRCD);
 	}
 
-	if (mlx5_ib_port_link_layer(&dev->ib_dev) ==
+	if (mlx5_ib_port_link_layer(&dev->ib_dev, 1) ==
 	    IB_LINK_LAYER_ETHERNET) {
 		dev->ib_dev.create_flow	= mlx5_ib_create_flow;
 		dev->ib_dev.destroy_flow = mlx5_ib_destroy_flow;
-- 
2.6.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
