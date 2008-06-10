From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 10/14] QLogic VNIC: Driver Statistics
	collection
Date: Tue, 10 Jun 2008 17:07:17 -0400
Message-ID: <20080610210717.11186.54173.stgit@dale>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
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

From: Amar Mudrankit <amar.mudrankit@qlogic.com>

Collection of statistics about QLogic VNIC interfaces is implemented
in this patch.

Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
---

 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c |  234 ++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h |  497 +++++++++++++++++++++++++
 2 files changed, 731 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h

diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c
new file mode 100644
index 0000000..d11a8df
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c
@@ -0,0 +1,234 @@
+/*
+ * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
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
+ */
+
+#include <linux/types.h>
+#include <linux/device.h>
+#include <linux/kernel.h>
+
+#include "vnic_main.h"
+
+cycles_t vnic_recv_ref;
+
+/*
+ * TODO: Statistics reporting for control path, data path,
+ *       RDMA times, IOs etc
+ *
+ */
+static ssize_t show_lifetime(struct device *dev,
+			     struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+	cycles_t time = get_cycles() - vnic->statistics.start_time;
+
+	return sprintf(buf, "%llu\n", (unsigned long long)time);
+}
+
+static DEVICE_ATTR(lifetime, S_IRUGO, show_lifetime, NULL);
+
+static ssize_t show_conntime(struct device *dev,
+			     struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	if (vnic->statistics.conn_time)
+		return sprintf(buf, "%llu\n",
+			   (unsigned long long)vnic->statistics.conn_time);
+	return 0;
+}
+
+static DEVICE_ATTR(connection_time, S_IRUGO, show_conntime, NULL);
+
+static ssize_t show_disconnects(struct device *dev,
+				struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+	u32 num;
+
+	if (vnic->statistics.disconn_ref)
+		num = vnic->statistics.disconn_num + 1;
+	else
+		num = vnic->statistics.disconn_num;
+
+	return sprintf(buf, "%d\n", num);
+}
+
+static DEVICE_ATTR(disconnects, S_IRUGO, show_disconnects, NULL);
+
+static ssize_t show_total_disconn_time(struct device *dev,
+				       struct device_attribute *dev_attr,
+				       char *buf)
+{
+	struct dev_info *info = container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+	cycles_t time;
+
+	if (vnic->statistics.disconn_ref)
+		time = vnic->statistics.disconn_time +
+		       get_cycles() - vnic->statistics.disconn_ref;
+	else
+		time = vnic->statistics.disconn_time;
+
+	return sprintf(buf, "%llu\n", (unsigned long long)time);
+}
+
+static DEVICE_ATTR(total_disconn_time, S_IRUGO, show_total_disconn_time, NULL);
+
+static ssize_t show_carrier_losses(struct device *dev,
+				   struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+	u32 num;
+
+	if (vnic->statistics.carrier_ref)
+		num = vnic->statistics.carrier_off_num + 1;
+	else
+		num = vnic->statistics.carrier_off_num;
+
+	return sprintf(buf, "%d\n", num);
+}
+
+static DEVICE_ATTR(carrier_losses, S_IRUGO, show_carrier_losses, NULL);
+
+static ssize_t show_total_carr_loss_time(struct device *dev,
+					 struct device_attribute *dev_attr,
+					 char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+	cycles_t time;
+
+	if (vnic->statistics.carrier_ref)
+		time = vnic->statistics.carrier_off_time +
+		       get_cycles() - vnic->statistics.carrier_ref;
+	else
+		time = vnic->statistics.carrier_off_time;
+
+	return sprintf(buf, "%llu\n", (unsigned long long)time);
+}
+
+static DEVICE_ATTR(total_carrier_loss_time, S_IRUGO,
+			 show_total_carr_loss_time, NULL);
+
+static ssize_t show_total_recv_time(struct device *dev,
+				    struct device_attribute *dev_attr,
+				    char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%llu\n",
+		       (unsigned long long)vnic->statistics.recv_time);
+}
+
+static DEVICE_ATTR(total_recv_time, S_IRUGO, show_total_recv_time, NULL);
+
+static ssize_t show_recvs(struct device *dev,
+			  struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%d\n", vnic->statistics.recv_num);
+}
+
+static DEVICE_ATTR(recvs, S_IRUGO, show_recvs, NULL);
+
+static ssize_t show_multicast_recvs(struct device *dev,
+				    struct device_attribute *dev_attr,
+				    char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%d\n", vnic->statistics.multicast_recv_num);
+}
+
+static DEVICE_ATTR(multicast_recvs, S_IRUGO, show_multicast_recvs, NULL);
+
+static ssize_t show_total_xmit_time(struct device *dev,
+				    struct device_attribute *dev_attr,
+				    char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%llu\n",
+		       (unsigned long long)vnic->statistics.xmit_time);
+}
+
+static DEVICE_ATTR(total_xmit_time, S_IRUGO, show_total_xmit_time, NULL);
+
+static ssize_t show_xmits(struct device *dev,
+			  struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%d\n", vnic->statistics.xmit_num);
+}
+
+static DEVICE_ATTR(xmits, S_IRUGO, show_xmits, NULL);
+
+static ssize_t show_failed_xmits(struct device *dev,
+				 struct device_attribute *dev_attr, char *buf)
+{
+	struct dev_info *info =	container_of(dev, struct dev_info, dev);
+	struct vnic *vnic = container_of(info, struct vnic, stat_info);
+
+	return sprintf(buf, "%d\n", vnic->statistics.xmit_fail);
+}
+
+static DEVICE_ATTR(failed_xmits, S_IRUGO, show_failed_xmits, NULL);
+
+static struct attribute *vnic_stats_attrs[] = {
+	&dev_attr_lifetime.attr,
+	&dev_attr_xmits.attr,
+	&dev_attr_total_xmit_time.attr,
+	&dev_attr_failed_xmits.attr,
+	&dev_attr_recvs.attr,
+	&dev_attr_multicast_recvs.attr,
+	&dev_attr_total_recv_time.attr,
+	&dev_attr_connection_time.attr,
+	&dev_attr_disconnects.attr,
+	&dev_attr_total_disconn_time.attr,
+	&dev_attr_carrier_losses.attr,
+	&dev_attr_total_carrier_loss_time.attr,
+	NULL
+};
+
+struct attribute_group vnic_stats_attr_group = {
+	.attrs = vnic_stats_attrs,
+};
diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h b/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h
new file mode 100644
index 0000000..a241b71
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h
@@ -0,0 +1,497 @@
+/*
+ * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
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
+ */
+
+#ifndef VNIC_STATS_H_INCLUDED
+#define VNIC_STATS_H_INCLUDED
+
+#include "vnic_main.h"
+#include "vnic_ib.h"
+#include "vnic_sys.h"
+
+#ifdef CONFIG_INFINIBAND_QLGC_VNIC_STATS
+
+static inline void vnic_connected_stats(struct vnic *vnic)
+{
+	if (vnic->statistics.conn_time == 0) {
+		vnic->statistics.conn_time =
+		    get_cycles() - vnic->statistics.start_time;
+	}
+
+	if (vnic->statistics.disconn_ref != 0) {
+		vnic->statistics.disconn_time +=
+		    get_cycles() - vnic->statistics.disconn_ref;
+		vnic->statistics.disconn_num++;
+		vnic->statistics.disconn_ref = 0;
+	}
+
+}
+
+static inline void vnic_stop_xmit_stats(struct vnic *vnic)
+{
+	if (vnic->statistics.xmit_ref == 0)
+		vnic->statistics.xmit_ref = get_cycles();
+}
+
+static inline void vnic_restart_xmit_stats(struct vnic *vnic)
+{
+	if (vnic->statistics.xmit_ref != 0) {
+		vnic->statistics.xmit_off_time +=
+		    get_cycles() - vnic->statistics.xmit_ref;
+		vnic->statistics.xmit_off_num++;
+		vnic->statistics.xmit_ref = 0;
+	}
+}
+
+static inline void vnic_recv_pkt_stats(struct vnic *vnic)
+{
+	vnic->statistics.recv_time += get_cycles() - vnic_recv_ref;
+	vnic->statistics.recv_num++;
+}
+
+static inline void vnic_multicast_recv_pkt_stats(struct vnic *vnic)
+{
+	vnic->statistics.multicast_recv_num++;
+}
+
+static inline void vnic_pre_pkt_xmit_stats(cycles_t *time)
+{
+	*time = get_cycles();
+}
+
+static inline void vnic_post_pkt_xmit_stats(struct vnic *vnic,
+					    cycles_t time)
+{
+	vnic->statistics.xmit_time += get_cycles() - time;
+	vnic->statistics.xmit_num++;
+
+}
+
+static inline void vnic_xmit_fail_stats(struct vnic *vnic)
+{
+	vnic->statistics.xmit_fail++;
+}
+
+static inline void vnic_carrier_loss_stats(struct vnic *vnic)
+{
+	if (vnic->statistics.carrier_ref != 0) {
+		vnic->statistics.carrier_off_time +=
+			get_cycles() -  vnic->statistics.carrier_ref;
+		vnic->statistics.carrier_off_num++;
+		vnic->statistics.carrier_ref = 0;
+	}
+}
+
+static inline int vnic_setup_stats_files(struct vnic *vnic)
+{
+	init_completion(&vnic->stat_info.released);
+	vnic->stat_info.dev.class = NULL;
+	vnic->stat_info.dev.parent = &vnic->dev_info.dev;
+	vnic->stat_info.dev.release = vnic_release_dev;
+	snprintf(vnic->stat_info.dev.bus_id, BUS_ID_SIZE,
+		 "stats");
+
+	if (device_register(&vnic->stat_info.dev)) {
+		SYS_ERROR("create_vnic: error in registering"
+			  " stat class dev\n");
+		goto stats_out;
+	}
+
+	if (sysfs_create_group(&vnic->stat_info.dev.kobj,
+			       &vnic_stats_attr_group))
+		goto err_stats_file;
+
+	return 0;
+err_stats_file:
+	device_unregister(&vnic->stat_info.dev);
+	wait_for_completion(&vnic->stat_info.released);
+stats_out:
+	return -1;
+}
+
+static inline void vnic_cleanup_stats_files(struct vnic *vnic)
+{
+	sysfs_remove_group(&vnic->dev_info.dev.kobj,
+			   &vnic_stats_attr_group);
+	device_unregister(&vnic->stat_info.dev);
+	wait_for_completion(&vnic->stat_info.released);
+}
+
+static inline void vnic_disconn_stats(struct vnic *vnic)
+{
+	if (!vnic->statistics.disconn_ref)
+		vnic->statistics.disconn_ref = get_cycles();
+
+	if (vnic->statistics.carrier_ref == 0)
+		vnic->statistics.carrier_ref = get_cycles();
+}
+
+static inline void vnic_alloc_stats(struct vnic *vnic)
+{
+	vnic->statistics.start_time = get_cycles();
+}
+
+static inline void control_note_rsptime_stats(cycles_t *time)
+{
+	*time = get_cycles();
+}
+
+static inline void control_update_rsptime_stats(struct control *control,
+						cycles_t response_time)
+{
+	response_time -= control->statistics.request_time;
+	control->statistics.response_time += response_time;
+	control->statistics.response_num++;
+	if (control->statistics.response_max < response_time)
+		control->statistics.response_max = response_time;
+	if ((control->statistics.response_min == 0) ||
+	    (control->statistics.response_min > response_time))
+		control->statistics.response_min =  response_time;
+
+}
+
+static inline void control_note_reqtime_stats(struct control *control)
+{
+	control->statistics.request_time = get_cycles();
+}
+
+static inline void control_timeout_stats(struct control *control)
+{
+	control->statistics.timeout_num++;
+}
+
+static inline void data_kickreq_stats(struct data *data)
+{
+	data->statistics.kick_reqs++;
+}
+
+static inline void data_no_xmitbuf_stats(struct data *data)
+{
+	data->statistics.no_xmit_bufs++;
+}
+
+static inline void data_xmits_stats(struct data *data)
+{
+	data->statistics.xmit_num++;
+}
+
+static inline void data_recvs_stats(struct data *data)
+{
+	data->statistics.recv_num++;
+}
+
+static inline void data_note_kickrcv_time(void)
+{
+	vnic_recv_ref = get_cycles();
+}
+
+static inline void data_rcvkicks_stats(struct data *data)
+{
+	data->statistics.kick_recvs++;
+}
+
+
+static inline void vnic_ib_conntime_stats(struct vnic_ib_conn *ib_conn)
+{
+	ib_conn->statistics.connection_time = get_cycles();
+}
+
+static inline void vnic_ib_note_comptime_stats(cycles_t *time)
+{
+	*time = get_cycles();
+}
+
+static inline void vnic_ib_callback_stats(struct vnic_ib_conn *ib_conn)
+{
+	ib_conn->statistics.num_callbacks++;
+}
+
+static inline void vnic_ib_comp_stats(struct vnic_ib_conn *ib_conn,
+				      u32 *comp_num)
+{
+	ib_conn->statistics.num_ios++;
+	*comp_num = *comp_num + 1;
+
+}
+
+static inline void vnic_ib_io_stats(struct io *io,
+				    struct vnic_ib_conn *ib_conn,
+				    cycles_t comp_time)
+{
+	if ((io->type == RECV) || (io->type == RECV_UD))
+		io->time = comp_time;
+	else if (io->type == RDMA) {
+		ib_conn->statistics.rdma_comp_time += comp_time - io->time;
+		ib_conn->statistics.rdma_comp_ios++;
+	} else if (io->type == SEND) {
+		ib_conn->statistics.send_comp_time += comp_time - io->time;
+		ib_conn->statistics.send_comp_ios++;
+	}
+}
+
+static inline void vnic_ib_maxio_stats(struct vnic_ib_conn *ib_conn,
+				       u32 comp_num)
+{
+	if (comp_num > ib_conn->statistics.max_ios)
+		ib_conn->statistics.max_ios = comp_num;
+}
+
+static inline void vnic_ib_connected_time_stats(struct vnic_ib_conn *ib_conn)
+{
+	ib_conn->statistics.connection_time =
+			 get_cycles() - ib_conn->statistics.connection_time;
+
+}
+
+static inline void vnic_ib_pre_rcvpost_stats(struct vnic_ib_conn *ib_conn,
+					     struct io *io,
+					     cycles_t *time)
+{
+	*time = get_cycles();
+	if (io->time != 0) {
+		ib_conn->statistics.recv_comp_time += *time - io->time;
+		ib_conn->statistics.recv_comp_ios++;
+	}
+
+}
+
+static inline void vnic_ib_post_rcvpost_stats(struct vnic_ib_conn *ib_conn,
+					      cycles_t time)
+{
+	ib_conn->statistics.recv_post_time += get_cycles() - time;
+	ib_conn->statistics.recv_post_ios++;
+}
+
+static inline void vnic_ib_pre_sendpost_stats(struct io *io,
+					      cycles_t *time)
+{
+	io->time = *time = get_cycles();
+}
+
+static inline void vnic_ib_post_sendpost_stats(struct vnic_ib_conn *ib_conn,
+					       struct io *io,
+					       cycles_t time)
+{
+	time = get_cycles() - time;
+	if (io->swr.opcode == IB_WR_RDMA_WRITE) {
+		ib_conn->statistics.rdma_post_time += time;
+		ib_conn->statistics.rdma_post_ios++;
+	} else {
+		ib_conn->statistics.send_post_time += time;
+		ib_conn->statistics.send_post_ios++;
+	}
+}
+#else	/*CONFIG_INIFINIBAND_VNIC_STATS*/
+
+static inline void vnic_connected_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_stop_xmit_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_restart_xmit_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_recv_pkt_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_multicast_recv_pkt_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_pre_pkt_xmit_stats(cycles_t *time)
+{
+	;
+}
+
+static inline void vnic_post_pkt_xmit_stats(struct vnic *vnic,
+					    cycles_t time)
+{
+	;
+}
+
+static inline void vnic_xmit_fail_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline int vnic_setup_stats_files(struct vnic *vnic)
+{
+	return 0;
+}
+
+static inline void vnic_cleanup_stats_files(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_carrier_loss_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_disconn_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void vnic_alloc_stats(struct vnic *vnic)
+{
+	;
+}
+
+static inline void control_note_rsptime_stats(cycles_t *time)
+{
+	;
+}
+
+static inline void control_update_rsptime_stats(struct control *control,
+						cycles_t response_time)
+{
+	;
+}
+
+static inline void control_note_reqtime_stats(struct control *control)
+{
+	;
+}
+
+static inline void control_timeout_stats(struct control *control)
+{
+	;
+}
+
+static inline void data_kickreq_stats(struct data *data)
+{
+	;
+}
+
+static inline void data_no_xmitbuf_stats(struct data *data)
+{
+	;
+}
+
+static inline void data_xmits_stats(struct data *data)
+{
+	;
+}
+
+static inline void data_recvs_stats(struct data *data)
+{
+	;
+}
+
+static inline void data_note_kickrcv_time(void)
+{
+	;
+}
+
+static inline void data_rcvkicks_stats(struct data *data)
+{
+	;
+}
+
+static inline void vnic_ib_conntime_stats(struct vnic_ib_conn *ib_conn)
+{
+	;
+}
+
+static inline void vnic_ib_note_comptime_stats(cycles_t *time)
+{
+	;
+}
+
+static inline void vnic_ib_callback_stats(struct vnic_ib_conn *ib_conn)
+
+{
+	;
+}
+static inline void vnic_ib_comp_stats(struct vnic_ib_conn *ib_conn,
+				      u32 *comp_num)
+{
+	;
+}
+
+static inline void vnic_ib_io_stats(struct io *io,
+				    struct vnic_ib_conn *ib_conn,
+				    cycles_t comp_time)
+{
+	;
+}
+
+static inline void vnic_ib_maxio_stats(struct vnic_ib_conn *ib_conn,
+				       u32 comp_num)
+{
+	;
+}
+
+static inline void vnic_ib_connected_time_stats(struct vnic_ib_conn *ib_conn)
+{
+	;
+}
+
+static inline void vnic_ib_pre_rcvpost_stats(struct vnic_ib_conn *ib_conn,
+					     struct io *io,
+					     cycles_t *time)
+{
+	;
+}
+
+static inline void vnic_ib_post_rcvpost_stats(struct vnic_ib_conn *ib_conn,
+					      cycles_t time)
+{
+	;
+}
+
+static inline void vnic_ib_pre_sendpost_stats(struct io *io,
+					      cycles_t *time)
+{
+	;
+}
+
+static inline void vnic_ib_post_sendpost_stats(struct vnic_ib_conn *ib_conn,
+					       struct io *io,
+					       cycles_t time)
+{
+	;
+}
+#endif	/*CONFIG_INIFINIBAND_VNIC_STATS*/
+
+#endif	/*VNIC_STATS_H_INCLUDED*/
