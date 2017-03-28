From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 09/15] mlx/tls: Sysfs configuration interface Configure the driver/hardware interface via sysfs.
Date: Tue, 28 Mar 2017 16:26:26 +0300
Message-ID: <1490707592-1430-10-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47743 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932585AbdC1N1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:27:14 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 .../ethernet/mellanox/accelerator/tls/tls_sysfs.c  | 194 +++++++++++++++++++++
 .../ethernet/mellanox/accelerator/tls/tls_sysfs.h  |  45 +++++
 2 files changed, 239 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h

diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
new file mode 100644
index 0000000..2860fc3
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
@@ -0,0 +1,194 @@
+/*
+ * Copyright (c) 2015-2017 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <rdma/ib_verbs.h>
+
+#include "tls_sysfs.h"
+#include "tls_cmds.h"
+
+#ifdef MLX_TLS_SADB_RDMA
+struct mlx_tls_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct mlx_tls_dev *dev, char *buf);
+	ssize_t (*store)(struct mlx_tls_dev *dev, const char *buf,
+			 size_t count);
+};
+
+#define MLX_TLS_ATTR(_name, _mode, _show, _store) \
+	struct mlx_tls_attribute mlx_tls_attr_##_name = { \
+			.attr = {.name = __stringify(_name), .mode = _mode}, \
+			.show = _show, \
+			.store = _store, \
+	}
+#define to_mlx_tls_dev(obj)	\
+		container_of(kobj, struct mlx_tls_dev, kobj)
+#define to_mlx_tls_attr(_attr)	\
+		container_of(attr, struct mlx_tls_attribute, attr)
+
+static ssize_t mlx_tls_attr_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
+{
+	struct mlx_tls_dev *dev = to_mlx_tls_dev(kobj);
+	struct mlx_tls_attribute *mlx_tls_attr = to_mlx_tls_attr(attr);
+	ssize_t ret = -EIO;
+
+	if (mlx_tls_attr->show)
+		ret = mlx_tls_attr->show(dev, buf);
+
+	return ret;
+}
+
+static ssize_t mlx_tls_attr_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct mlx_tls_dev *dev = to_mlx_tls_dev(kobj);
+	struct mlx_tls_attribute *mlx_tls_attr = to_mlx_tls_attr(attr);
+	ssize_t ret = -EIO;
+
+	if (mlx_tls_attr->store)
+		ret = mlx_tls_attr->store(dev, buf, count);
+
+	return ret;
+}
+
+static ssize_t mlx_tls_sqpn_read(struct mlx_tls_dev *dev, char *buf)
+{
+	return sprintf(buf, "%u\n", dev->conn->qp->qp_num);
+}
+
+static ssize_t mlx_tls_sgid_read(struct mlx_tls_dev *dev, char *buf)
+{
+	union ib_gid *sgid = (union ib_gid *)&dev->conn->fpga_qpc.remote_ip;
+
+	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
+		       be16_to_cpu(((__be16 *)sgid->raw)[0]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[1]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[2]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[3]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[4]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[5]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[6]),
+		       be16_to_cpu(((__be16 *)sgid->raw)[7]));
+}
+
+static ssize_t mlx_tls_dqpn_read(struct mlx_tls_dev *dev, char *buf)
+{
+	return sprintf(buf, "%u\n", dev->conn->fpga_qpn);
+}
+
+static ssize_t mlx_tls_dqpn_write(struct mlx_tls_dev *dev, const char *buf,
+				  size_t count)
+{
+	int tmp;
+
+	tmp = sscanf(buf, "%u\n", &dev->conn->fpga_qpn);
+	mlx_accel_core_connect(dev->conn);
+
+	return count;
+}
+
+static ssize_t mlx_tls_dgid_read(struct mlx_tls_dev *dev, char *buf)
+{
+	union ib_gid *dgid = (union ib_gid *)&dev->conn->fpga_qpc.fpga_ip;
+
+	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
+		       be16_to_cpu(((__be16 *)dgid->raw)[0]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[1]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[2]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[3]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[4]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[5]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[6]),
+		       be16_to_cpu(((__be16 *)dgid->raw)[7]));
+}
+
+static ssize_t mlx_tls_dgid_write(struct mlx_tls_dev *dev, const char *buf,
+				  size_t count)
+{
+	union ib_gid *dgid = (union ib_gid *)&dev->conn->fpga_qpc.fpga_ip;
+	int i = 0;
+	int tmp;
+
+	tmp = sscanf(buf,
+		     "%04hx:%04hx:%04hx:%04hx:%04hx:%04hx:%04hx:%04hx\n",
+		     &(((__be16 *)dgid->raw)[0]),
+		     &(((__be16 *)dgid->raw)[1]),
+		     &(((__be16 *)dgid->raw)[2]),
+		     &(((__be16 *)dgid->raw)[3]),
+		     &(((__be16 *)dgid->raw)[4]),
+		     &(((__be16 *)dgid->raw)[5]),
+		     &(((__be16 *)dgid->raw)[6]),
+		     &(((__be16 *)dgid->raw)[7]));
+
+	for (i = 0; i < 8; i++)
+		((__be16 *)dgid->raw)[i] = cpu_to_be16(((u16 *)dgid->raw)[i]);
+
+	return count;
+}
+
+static void mlx_tls_dev_release(struct kobject *kobj)
+{
+}
+
+static MLX_TLS_ATTR(sqpn, 0444, mlx_tls_sqpn_read, NULL);
+static MLX_TLS_ATTR(sgid, 0444, mlx_tls_sgid_read, NULL);
+static MLX_TLS_ATTR(dqpn, 0666, mlx_tls_dqpn_read, mlx_tls_dqpn_write);
+static MLX_TLS_ATTR(dgid, 0666, mlx_tls_dgid_read, mlx_tls_dgid_write);
+
+struct attribute *mlx_tls_def_attrs[] = {
+		&mlx_tls_attr_sqpn.attr,
+		&mlx_tls_attr_sgid.attr,
+		&mlx_tls_attr_dqpn.attr,
+		&mlx_tls_attr_dgid.attr,
+		NULL,
+};
+
+const struct sysfs_ops mlx_tls_dev_sysfs_ops = {
+	.show  = mlx_tls_attr_show,
+	.store = mlx_tls_attr_store,
+};
+
+static struct kobj_type mlx_tls_dev_type = {
+	.release        = mlx_tls_dev_release,
+	.sysfs_ops      = &mlx_tls_dev_sysfs_ops,
+	.default_attrs  = mlx_tls_def_attrs,
+};
+
+int tls_sysfs_init_and_add(struct kobject *kobj, struct kobject *parent,
+			   const char *fmt, char *arg)
+{
+	return kobject_init_and_add(kobj, &mlx_tls_dev_type,
+			parent,
+			fmt, arg);
+}
+#endif
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
new file mode 100644
index 0000000..bfaa857
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright (c) 2015-2017 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#ifndef __TLS_SYSFS_H__
+#define __TLS_SYSFS_H__
+
+#include <linux/sysfs.h>
+
+#include "tls.h"
+
+#ifdef MLX_TLS_SADB_RDMA
+int tls_sysfs_init_and_add(struct kobject *kobj, struct kobject *parent,
+			   const char *fmt, char *arg);
+#endif
+
+#endif	/* __TLS_SYSFS_H__ */
-- 
2.7.4
