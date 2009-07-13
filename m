From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general][PATCH] mlx4_core: Synch catastrophic flow with module
	unload
Date: Mon, 13 Jul 2009 18:27:48 +0300
Message-ID: <4A5B5274.2020801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

There is a race condition when the mlx4_core module is being unloaded
during the execution of restart task due to catastrophic error.
Added a global mutex that synchs those operations. If the catastrophic task
tries to catch the mutex, and it is already taken, it means that somebody is unloading the
module, and there is no point in executing the restart operation.
If the unload function tries to catch the mutex and it is taken,
it would wait for the catas task to finish and then unload the module.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/catas.c |    4 ++++
 drivers/net/mlx4/main.c  |    6 ++++++
 drivers/net/mlx4/mlx4.h  |    2 ++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/catas.c b/drivers/net/mlx4/catas.c
index aa9674b..e3aa7e9 100644
--- a/drivers/net/mlx4/catas.c
+++ b/drivers/net/mlx4/catas.c
@@ -91,6 +91,9 @@ static void catas_reset(struct work_struct *work)
 	LIST_HEAD(tlist);
 	int ret;
 
+	if (!mutex_trylock(&drv_mutex))
+		return;
+
 	spin_lock_irq(&catas_lock);
 	list_splice_init(&catas_list, &tlist);
 	spin_unlock_irq(&catas_lock);
@@ -103,6 +106,7 @@ static void catas_reset(struct work_struct *work)
 		else
 			mlx4_dbg(dev, "Reset succeeded\n");
 	}
+	mutex_unlock(&drv_mutex);
 }
 
 void mlx4_start_catas_poll(struct mlx4_dev *dev)
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index dac621b..9cd5123 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -77,6 +77,8 @@ static char mlx4_version[] __devinitdata =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
+struct mutex drv_mutex;
+
 static struct mlx4_profile default_profile = {
 	.num_qp		= 1 << 17,
 	.num_srq	= 1 << 16,
@@ -1325,6 +1327,8 @@ static int __init mlx4_init(void)
 {
 	int ret;
 
+	mutex_init(&drv_mutex);
+
 	if (mlx4_verify_params())
 		return -EINVAL;
 
@@ -1340,7 +1344,9 @@ static int __init mlx4_init(void)
 
 static void __exit mlx4_cleanup(void)
 {
+	mutex_lock(&drv_mutex);
 	pci_unregister_driver(&mlx4_driver);
+	mutex_unlock(&drv_mutex);
 	destroy_workqueue(mlx4_wq);
 }
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 5bd79c2..bd8fb43 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -284,6 +284,8 @@ struct mlx4_sense {
 	struct delayed_work	sense_poll;
 };
 
+extern struct mutex drv_mutex;
+
 struct mlx4_priv {
 	struct mlx4_dev		dev;
 
-- 
1.6.0
