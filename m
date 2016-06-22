From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] mellanox: mlx5: Use logging functions to reduce text ~10k/5%
Date: Wed, 22 Jun 2016 11:23:59 -0700
Message-ID: <1466619839.13093.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The logging macros create a bit of duplicated code/text.

Use specialized functions to reduce the duplication.

(defconfig/x86-64)
$ size drivers/net/ethernet/mellanox/mlx5/core/built-in.o*
=A0=A0=A0text	=A0=A0=A0data	=A0=A0=A0=A0bss	=A0=A0=A0=A0dec	=A0=A0=A0=A0=
hex	filename
=A0178634	=A0=A0=A02059	=A0=A0=A0=A0=A016	=A0180709	=A0=A02c1e5	drivers=
/net/ethernet/mellanox/mlx5/core/built-in.o.new
=A0188679	=A0=A0=A02059	=A0=A0=A0=A0=A016	=A0190754	=A0=A02e922	drivers=
/net/ethernet/mellanox/mlx5/core/built-in.o.old

The output changes now do not include line #,
but do include the function offset.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
=A0drivers/net/ethernet/mellanox/mlx5/core/main.c=A0=A0=A0=A0=A0| 34 ++=
++++++++++++++++++++
=A0.../net/ethernet/mellanox/mlx5/core/mlx5_core.h=A0=A0=A0=A0| 13 +++-=
-----
=A02 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/n=
et/ethernet/mellanox/mlx5/core/main.c
index a19b593..34cbaf0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1557,3 +1557,37 @@ static void __exit cleanup(void)
=A0
=A0module_init(init);
=A0module_exit(cleanup);
+
+void mlx5_core_err(struct mlx5_core_dev *dev, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt =3D fmt;
+	vaf.va =3D &args;
+
+	dev_err(&dev->pdev->dev, "%s:%pS:(pid %d): %pV",
+		dev->priv.name, __builtin_return_address(0), current->pid,
+		&vaf);
+
+	va_end(args);
+}
+
+void mlx5_core_warn(struct mlx5_core_dev *dev, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt =3D fmt;
+	vaf.va =3D &args;
+
+	dev_warn(&dev->pdev->dev, "%s:%pS:(pid %d): %pV",
+		=A0dev->priv.name, __builtin_return_address(0), current->pid,
+		=A0&vaf);
+
+	va_end(args);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/driv=
ers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 2f86ec6..31430a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -57,15 +57,10 @@ do {									\
=A0		mlx5_core_dbg(__dev, format, ##__VA_ARGS__);		\
=A0} while (0)
=A0
-#define mlx5_core_err(__dev, format, ...)				\
-	dev_err(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-	=A0=A0=A0=A0=A0=A0=A0(__dev)->priv.name, __func__, __LINE__, current-=
>pid,	\
-	=A0=A0=A0=A0=A0=A0=A0##__VA_ARGS__)
-
-#define mlx5_core_warn(__dev, format, ...)				\
-	dev_warn(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-		(__dev)->priv.name, __func__, __LINE__, current->pid,	\
-		##__VA_ARGS__)
+__printf(2, 3)
+void mlx5_core_err(struct mlx5_core_dev *dev, const char *fmt, ...);
+__printf(2, 3)
+void mlx5_core_warn(struct mlx5_core_dev *dev, const char *fmt, ...);
=A0
=A0#define mlx5_core_info(__dev, format, ...)				\
=A0	dev_info(&(__dev)->pdev->dev, format, ##__VA_ARGS__)


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
