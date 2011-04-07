From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4: Sensing link type at device initialization
Date: Thu, 7 Apr 2011 12:24:42 +0300
Message-ID: <4D9D82DA.2090301@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:52875 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751646Ab1DGJYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 05:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When bringing the port up, performing a SENSE_PORT command
To try and check to which physical link type (IB or Ethernet) the physical
port is connected.
In case there is no valid link partner, the port will come up as its
supported default.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/main.c  |    5 +++++
 drivers/net/mlx4/mlx4.h  |    2 ++
 drivers/net/mlx4/sense.c |    4 ++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 62fa7ee..3814fc9 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -944,6 +944,10 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 	}
 
 	for (port = 1; port <= dev->caps.num_ports; port++) {
+		enum mlx4_port_type port_type = 0;
+		mlx4_SENSE_PORT(dev, port, &port_type);
+		if (port_type)
+			dev->caps.port_type[port] = port_type;
 		ib_port_default_caps = 0;
 		err = mlx4_get_port_ib_caps(dev, port, &ib_port_default_caps);
 		if (err)
@@ -958,6 +962,7 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 			goto err_mcg_table_free;
 		}
 	}
+	mlx4_set_port_mask(dev);
 
 	return 0;
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index c1e0e5f..dd7d745 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -431,6 +431,8 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type);
 
 void mlx4_handle_catas_err(struct mlx4_dev *dev);
 
+int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
+		    enum mlx4_port_type *type);
 void mlx4_do_sense_ports(struct mlx4_dev *dev,
 			 enum mlx4_port_type *stype,
 			 enum mlx4_port_type *defaults);
diff --git a/drivers/net/mlx4/sense.c b/drivers/net/mlx4/sense.c
index 015fbe7..e2337a7 100644
--- a/drivers/net/mlx4/sense.c
+++ b/drivers/net/mlx4/sense.c
@@ -38,8 +38,8 @@
 
 #include "mlx4.h"
 
-static int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
-			   enum mlx4_port_type *type)
+int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
+		    enum mlx4_port_type *type)
 {
 	u64 out_param;
 	int err = 0;
-- 
1.6.0.2



