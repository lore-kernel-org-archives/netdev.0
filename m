From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 07/14] QLogic VNIC: Handling configurable
	parameters of the driver
Date: Tue, 10 Jun 2008 17:05:46 -0400
Message-ID: <20080610210546.11186.63864.stgit@dale>
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

From: Poornima Kamath <poornima.kamath@qlogic.com>

This patch adds the files that handle various configurable parameters
of the VNIC driver ---- configuration of virtual NIC, control, data 
connections to the EVIC and general IB connection parameters.

Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c |  379 ++++++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h |  240 +++++++++++++++
 2 files changed, 619 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h

diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_config.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_config.c
new file mode 100644
index 0000000..cf120a6
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_config.c
@@ -0,0 +1,379 @@
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
+#include <linux/netdevice.h>
+#include <linux/string.h>
+#include <linux/utsname.h>
+#include <linux/if_vlan.h>
+
+#include "vnic_util.h"
+#include "vnic_config.h"
+#include "vnic_trailer.h"
+#include "vnic_main.h"
+
+u16 vnic_max_mtu = MAX_MTU;
+
+static u32 default_no_path_timeout = DEFAULT_NO_PATH_TIMEOUT;
+static u32 sa_path_rec_get_timeout = SA_PATH_REC_GET_TIMEOUT;
+static u32 default_primary_reconnect_timeout =
+				    DEFAULT_PRIMARY_RECONNECT_TIMEOUT;
+static u32 default_primary_switch_timeout = DEFAULT_PRIMARY_SWITCH_TIMEOUT;
+static int default_prefer_primary         = DEFAULT_PREFER_PRIMARY;
+
+static int use_rx_csum = VNIC_USE_RX_CSUM;
+static int use_tx_csum = VNIC_USE_TX_CSUM;
+
+static u32 control_response_timeout = CONTROL_RSP_TIMEOUT;
+static u32 completion_limit = DEFAULT_COMPLETION_LIMIT;
+
+module_param(vnic_max_mtu, ushort, 0444);
+MODULE_PARM_DESC(vnic_max_mtu, "Maximum MTU size (1500-9500). Default is 9500");
+
+module_param(default_prefer_primary, bool, 0444);
+MODULE_PARM_DESC(default_prefer_primary, "Determines if primary path is"
+		 " preferred (1) or not (0). Defaults to 0");
+module_param(use_rx_csum, bool, 0444);
+MODULE_PARM_DESC(use_rx_csum, "Determines if RX checksum is done on VEx (1)"
+		 " or not (0). Defaults to 1");
+module_param(use_tx_csum, bool, 0444);
+MODULE_PARM_DESC(use_tx_csum, "Determines if TX checksum is done on VEx (1)"
+		 " or not (0). Defaults to 1");
+module_param(default_no_path_timeout, uint, 0444);
+MODULE_PARM_DESC(default_no_path_timeout, "Time to wait in milliseconds"
+		 " before reconnecting to VEx after connection loss");
+module_param(default_primary_reconnect_timeout, uint, 0444);
+MODULE_PARM_DESC(default_primary_reconnect_timeout,  "Time to wait in"
+		 " milliseconds before reconnecting the"
+		 " primary path to VEx");
+module_param(default_primary_switch_timeout, uint, 0444);
+MODULE_PARM_DESC(default_primary_switch_timeout, "Time to wait before"
+		 " switching back to primary path if"
+		 " primary path is preferred");
+module_param(sa_path_rec_get_timeout, uint, 0444);
+MODULE_PARM_DESC(sa_path_rec_get_timeout, "Time out value in milliseconds"
+		 " for SA path record get queries");
+
+module_param(control_response_timeout, uint, 0444);
+MODULE_PARM_DESC(control_response_timeout, "Time out value in milliseconds"
+		 " to wait for response to control requests");
+
+module_param(completion_limit, uint, 0444);
+MODULE_PARM_DESC(completion_limit, "Maximum completions to process"
+		" in a single completion callback invocation. Default is 100"
+		" Minimum value is 10");
+
+static void config_control_defaults(struct control_config *control_config,
+				    struct vnic_path_param *params)
+{
+	int len;
+	char *dot;
+	u64 sid;
+
+	sid = (SST_AGN << 56) | (SST_OUI << 32) | (CONTROL_PATH_ID << 8)
+	      |	IOC_NUMBER(be64_to_cpu(params->ioc_guid));
+
+	control_config->ib_config.service_id = cpu_to_be64(sid);
+	control_config->ib_config.conn_data.path_id = 0;
+	control_config->ib_config.conn_data.vnic_instance = params->instance;
+	control_config->ib_config.conn_data.path_num = 0;
+	control_config->ib_config.conn_data.features_supported =
+			__constant_cpu_to_be32((u32) (VNIC_FEAT_IGNORE_VLAN |
+						      VNIC_FEAT_RDMA_IMMED));
+	dot = strchr(init_utsname()->nodename, '.');
+
+	if (dot)
+		len = dot - init_utsname()->nodename;
+	else
+		len = strlen(init_utsname()->nodename);
+
+	if (len > VNIC_MAX_NODENAME_LEN)
+		len = VNIC_MAX_NODENAME_LEN;
+
+	memcpy(control_config->ib_config.conn_data.nodename,
+					init_utsname()->nodename, len);
+
+	if (params->ib_multicast == 1)
+		control_config->ib_multicast = 1;
+	else if (params->ib_multicast == 0)
+		control_config->ib_multicast = 0;
+	else {
+		/* parameter is not set - enable it by default */
+		control_config->ib_multicast = 1;
+		CONFIG_ERROR("IOCGUID=%llx INSTANCE=%d IB_MULTICAST defaulted"
+					" to TRUE\n",
+					be64_to_cpu(params->ioc_guid),
+					(char)params->instance);
+	}
+
+	if (control_config->ib_multicast)
+		control_config->ib_config.conn_data.features_supported |=
+			__constant_cpu_to_be32(VNIC_FEAT_INBOUND_IB_MC);
+
+	control_config->ib_config.retry_count = RETRY_COUNT;
+	control_config->ib_config.rnr_retry_count = RETRY_COUNT;
+	control_config->ib_config.min_rnr_timer = MIN_RNR_TIMER;
+
+	/* These values are not configurable*/
+	control_config->ib_config.num_recvs    = 5;
+	control_config->ib_config.num_sends    = 1;
+	control_config->ib_config.recv_scatter = 1;
+	control_config->ib_config.send_gather  = 1;
+	control_config->ib_config.completion_limit = completion_limit;
+
+	control_config->num_recvs = control_config->ib_config.num_recvs;
+
+	control_config->vnic_instance = params->instance;
+	control_config->max_address_entries = MAX_ADDRESS_ENTRIES;
+	control_config->min_address_entries = MIN_ADDRESS_ENTRIES;
+	control_config->rsp_timeout = msecs_to_jiffies(control_response_timeout);
+}
+
+static void config_data_defaults(struct data_config *data_config,
+				 struct vnic_path_param *params)
+{
+	u64 sid;
+
+	sid = (SST_AGN << 56) | (SST_OUI << 32) | (DATA_PATH_ID << 8)
+	      |	IOC_NUMBER(be64_to_cpu(params->ioc_guid));
+
+	data_config->ib_config.service_id = cpu_to_be64(sid);
+	data_config->ib_config.conn_data.path_id = jiffies; /* random */
+	data_config->ib_config.conn_data.vnic_instance = params->instance;
+	data_config->ib_config.conn_data.path_num = 0;
+
+	data_config->ib_config.retry_count = RETRY_COUNT;
+	data_config->ib_config.rnr_retry_count = RETRY_COUNT;
+	data_config->ib_config.min_rnr_timer = MIN_RNR_TIMER;
+
+	/*
+	 * NOTE: the num_recvs size assumes that the EIOC could
+	 * RDMA enough packets to fill all of the host recv
+	 * pool entries, plus send a kick message after each
+	 * packet, plus RDMA new buffers for the size of
+	 * the EIOC recv buffer pool, plus send kick messages
+	 * after each min_host_update_sz of new buffers all
+	 * before the host can even pull off the first completed
+	 * receive off the completion queue, and repost the
+	 * receive. NOT LIKELY!
+	 */
+	data_config->ib_config.num_recvs = HOST_RECV_POOL_ENTRIES +
+	    (MAX_EIOC_POOL_SZ / MIN_HOST_UPDATE_SZ);
+
+	data_config->ib_config.num_sends = (2 * NOTIFY_BUNDLE_SZ) +
+	    (HOST_RECV_POOL_ENTRIES / MIN_EIOC_UPDATE_SZ) + 1;
+
+	data_config->ib_config.recv_scatter = 1; /* not configurable */
+	data_config->ib_config.send_gather = 2;	 /* not configurable */
+	data_config->ib_config.completion_limit = completion_limit;
+
+	data_config->num_recvs = data_config->ib_config.num_recvs;
+	data_config->path_id = data_config->ib_config.conn_data.path_id;
+
+
+	data_config->host_recv_pool_entries = HOST_RECV_POOL_ENTRIES;
+
+	data_config->host_min.size_recv_pool_entry =
+			cpu_to_be32(BUFFER_SIZE(VLAN_ETH_HLEN + MIN_MTU));
+	data_config->host_max.size_recv_pool_entry =
+			cpu_to_be32(BUFFER_SIZE(VLAN_ETH_HLEN + vnic_max_mtu));
+	data_config->eioc_min.size_recv_pool_entry =
+			cpu_to_be32(BUFFER_SIZE(VLAN_ETH_HLEN + MIN_MTU));
+	data_config->eioc_max.size_recv_pool_entry =
+			__constant_cpu_to_be32(MAX_PARAM_VALUE);
+
+	data_config->host_min.num_recv_pool_entries =
+				__constant_cpu_to_be32(MIN_HOST_POOL_SZ);
+	data_config->host_max.num_recv_pool_entries =
+				__constant_cpu_to_be32(MAX_PARAM_VALUE);
+	data_config->eioc_min.num_recv_pool_entries =
+				__constant_cpu_to_be32(MIN_EIOC_POOL_SZ);
+	data_config->eioc_max.num_recv_pool_entries =
+				__constant_cpu_to_be32(MAX_EIOC_POOL_SZ);
+
+	data_config->host_min.timeout_before_kick =
+			__constant_cpu_to_be32(MIN_HOST_KICK_TIMEOUT);
+	data_config->host_max.timeout_before_kick =
+			__constant_cpu_to_be32(MAX_HOST_KICK_TIMEOUT);
+	data_config->eioc_min.timeout_before_kick = 0;
+	data_config->eioc_max.timeout_before_kick =
+			__constant_cpu_to_be32(MAX_PARAM_VALUE);
+
+	data_config->host_min.num_recv_pool_entries_before_kick =
+			__constant_cpu_to_be32(MIN_HOST_KICK_ENTRIES);
+	data_config->host_max.num_recv_pool_entries_before_kick =
+			__constant_cpu_to_be32(MAX_HOST_KICK_ENTRIES);
+	data_config->eioc_min.num_recv_pool_entries_before_kick = 0;
+	data_config->eioc_max.num_recv_pool_entries_before_kick =
+				__constant_cpu_to_be32(MAX_PARAM_VALUE);
+
+	data_config->host_min.num_recv_pool_bytes_before_kick =
+			__constant_cpu_to_be32(MIN_HOST_KICK_BYTES);
+	data_config->host_max.num_recv_pool_bytes_before_kick =
+			__constant_cpu_to_be32(MAX_HOST_KICK_BYTES);
+	data_config->eioc_min.num_recv_pool_bytes_before_kick = 0;
+	data_config->eioc_max.num_recv_pool_bytes_before_kick =
+				__constant_cpu_to_be32(MAX_PARAM_VALUE);
+
+	data_config->host_min.free_recv_pool_entries_per_update =
+				__constant_cpu_to_be32(MIN_HOST_UPDATE_SZ);
+	data_config->host_max.free_recv_pool_entries_per_update =
+				__constant_cpu_to_be32(MAX_HOST_UPDATE_SZ);
+	data_config->eioc_min.free_recv_pool_entries_per_update =
+				__constant_cpu_to_be32(MIN_EIOC_UPDATE_SZ);
+	data_config->eioc_max.free_recv_pool_entries_per_update =
+				__constant_cpu_to_be32(MAX_EIOC_UPDATE_SZ);
+
+	data_config->notify_bundle = NOTIFY_BUNDLE_SZ;
+}
+
+static void config_path_info_defaults(struct viport_config *config,
+				      struct vnic_path_param *params)
+{
+	int i;
+	ib_query_gid(config->ibdev, config->port, 0,
+			  &config->path_info.path.sgid);
+	for (i = 0; i < 16; i++)
+		config->path_info.path.dgid.raw[i] = params->dgid[i];
+
+	config->path_info.path.pkey = params->pkey;
+	config->path_info.path.numb_path = 1;
+	config->sa_path_rec_get_timeout = sa_path_rec_get_timeout;
+
+}
+
+static void config_viport_defaults(struct viport_config *config,
+				      struct vnic_path_param *params)
+{
+	config->ibdev = params->ibdev;
+	config->port = params->port;
+	config->ioc_guid = params->ioc_guid;
+	config->stats_interval = msecs_to_jiffies(VIPORT_STATS_INTERVAL);
+	config->hb_interval = msecs_to_jiffies(VIPORT_HEARTBEAT_INTERVAL);
+	config->hb_timeout = VIPORT_HEARTBEAT_TIMEOUT * 1000;
+				/*hb_timeout needs to be in usec*/
+	strcpy(config->ioc_string, params->ioc_string);
+	config_path_info_defaults(config, params);
+
+	config_control_defaults(&config->control_config, params);
+	config_data_defaults(&config->data_config, params);
+}
+
+static void config_vnic_defaults(struct vnic_config *config)
+{
+	config->no_path_timeout = msecs_to_jiffies(default_no_path_timeout);
+	config->primary_connect_timeout =
+	    msecs_to_jiffies(DEFAULT_PRIMARY_CONNECT_TIMEOUT);
+	config->primary_reconnect_timeout =
+	    msecs_to_jiffies(default_primary_reconnect_timeout);
+	config->primary_switch_timeout =
+	    msecs_to_jiffies(default_primary_switch_timeout);
+	config->prefer_primary = default_prefer_primary;
+	config->use_rx_csum = use_rx_csum;
+	config->use_tx_csum = use_tx_csum;
+}
+
+struct viport_config *config_alloc_viport(struct vnic_path_param *params)
+{
+	struct viport_config *config;
+
+	config = kzalloc(sizeof *config, GFP_KERNEL);
+	if (!config) {
+		CONFIG_ERROR("could not allocate memory for"
+			     " struct viport_config\n");
+		return NULL;
+	}
+
+	config_viport_defaults(config, params);
+
+	return config;
+}
+
+struct vnic_config *config_alloc_vnic(void)
+{
+	struct vnic_config *config;
+
+	config = kzalloc(sizeof *config, GFP_KERNEL);
+	if (!config) {
+		CONFIG_ERROR("couldn't allocate memory for"
+			     " struct vnic_config\n");
+
+		return NULL;
+	}
+
+	config_vnic_defaults(config);
+	return config;
+}
+
+char *config_viport_name(struct viport_config *config)
+{
+	/* function only called by one thread, can return a static string */
+	static char str[64];
+
+	sprintf(str, "GUID %llx instance %d",
+		be64_to_cpu(config->ioc_guid),
+		config->control_config.vnic_instance);
+	return str;
+}
+
+int config_start(void)
+{
+	vnic_max_mtu = min_t(u16, vnic_max_mtu, MAX_MTU);
+	vnic_max_mtu = max_t(u16, vnic_max_mtu, MIN_MTU);
+
+	sa_path_rec_get_timeout = min_t(u32, sa_path_rec_get_timeout,
+					MAX_SA_TIMEOUT);
+	sa_path_rec_get_timeout = max_t(u32, sa_path_rec_get_timeout,
+					MIN_SA_TIMEOUT);
+
+	control_response_timeout = min_t(u32, control_response_timeout,
+					 MAX_CONTROL_RSP_TIMEOUT);
+
+	control_response_timeout = max_t(u32, control_response_timeout,
+					 MIN_CONTROL_RSP_TIMEOUT);
+
+	completion_limit	 = max_t(u32, completion_limit,
+					 MIN_COMPLETION_LIMIT);
+
+	if (!default_no_path_timeout)
+		default_no_path_timeout = DEFAULT_NO_PATH_TIMEOUT;
+
+	if (!default_primary_reconnect_timeout)
+		default_primary_reconnect_timeout =
+					 DEFAULT_PRIMARY_RECONNECT_TIMEOUT;
+
+	if (!default_primary_switch_timeout)
+		default_primary_switch_timeout =
+					DEFAULT_PRIMARY_SWITCH_TIMEOUT;
+
+	return 0;
+
+}
diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_config.h b/drivers/infiniband/ulp/qlgc_vnic/vnic_config.h
new file mode 100644
index 0000000..d8e0e0f
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_config.h
@@ -0,0 +1,240 @@
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
+#ifndef VNIC_CONFIG_H_INCLUDED
+#define VNIC_CONFIG_H_INCLUDED
+
+#include <rdma/ib_verbs.h>
+#include <linux/types.h>
+#include <linux/if.h>
+
+#include "vnic_control.h"
+#include "vnic_ib.h"
+
+#define SST_AGN         0x10ULL
+#define SST_OUI         0x00066AULL
+
+enum {
+	CONTROL_PATH_ID = 0x0,
+	DATA_PATH_ID    = 0x1
+};
+
+#define IOC_NUMBER(GUID)        (((GUID) >> 32) & 0xFF)
+
+enum {
+	VNIC_CLASS_SUBCLASS	= 0x2000066A,
+	VNIC_PROTOCOL		= 0,
+	VNIC_PROT_VERSION	= 1
+};
+
+enum {
+	MIN_MTU	= 1500,	/* minimum negotiated MTU size */
+	MAX_MTU	= 9500	/* jumbo frame */
+};
+
+/*
+ * TODO: tune the pool parameter values
+ */
+enum {
+	MIN_ADDRESS_ENTRIES = 16,
+	MAX_ADDRESS_ENTRIES = 64
+};
+
+enum {
+	HOST_RECV_POOL_ENTRIES	= 512,
+	MIN_HOST_POOL_SZ	= 64,
+	MIN_EIOC_POOL_SZ	= 64,
+	MAX_EIOC_POOL_SZ	= 256,
+	MIN_HOST_UPDATE_SZ	= 8,
+	MAX_HOST_UPDATE_SZ	= 32,
+	MIN_EIOC_UPDATE_SZ	= 8,
+	MAX_EIOC_UPDATE_SZ	= 32,
+	NOTIFY_BUNDLE_SZ	= 32
+};
+
+enum {
+	MIN_HOST_KICK_TIMEOUT = 10,	/* in usec */
+	MAX_HOST_KICK_TIMEOUT = 100	/* in usec */
+};
+
+enum {
+	MIN_HOST_KICK_ENTRIES = 1,
+	MAX_HOST_KICK_ENTRIES = 128
+};
+
+enum {
+	MIN_HOST_KICK_BYTES = 0,
+	MAX_HOST_KICK_BYTES = 5000
+};
+
+enum {
+	DEFAULT_NO_PATH_TIMEOUT			= 10000,
+	DEFAULT_PRIMARY_CONNECT_TIMEOUT		= 10000,
+	DEFAULT_PRIMARY_RECONNECT_TIMEOUT	= 10000,
+	DEFAULT_PRIMARY_SWITCH_TIMEOUT		= 10000
+};
+
+enum {
+	VIPORT_STATS_INTERVAL		= 500,	/* .5 sec */
+	VIPORT_HEARTBEAT_INTERVAL	= 1000,	/* 1 second */
+	VIPORT_HEARTBEAT_TIMEOUT	= 64000	/* 64 sec */
+};
+
+enum {
+	/* 5 sec increased for EVIC support for large number of
+	 * host connections
+	 */
+	CONTROL_RSP_TIMEOUT		= 5000,
+	MIN_CONTROL_RSP_TIMEOUT		= 1000,	/* 1  sec */
+	MAX_CONTROL_RSP_TIMEOUT		= 60000	/* 60 sec */
+};
+
+/* Maximum number of completions to be processed
+ * during a single completion callback invocation
+ */
+enum {
+	DEFAULT_COMPLETION_LIMIT 	= 100,
+	MIN_COMPLETION_LIMIT		= 10
+};
+
+/* infiniband connection parameters */
+enum {
+	RETRY_COUNT		= 3,
+	MIN_RNR_TIMER		= 22,	/* 20 ms */
+	DEFAULT_PKEY		= 0	/* pkey table index */
+};
+
+enum {
+	SA_PATH_REC_GET_TIMEOUT	= 1000,	/* 1000 ms */
+	MIN_SA_TIMEOUT		= 100,	/* 100 ms */
+	MAX_SA_TIMEOUT		= 20000	/* 20s */
+};
+
+#define MAX_PARAM_VALUE                 0x40000000
+#define VNIC_USE_RX_CSUM		1
+#define VNIC_USE_TX_CSUM		1
+#define	DEFAULT_PREFER_PRIMARY		0
+
+/* As per IBTA specification, IOCString Maximum length can be 512 bits. */
+#define MAX_IOC_STRING_LEN 		(512/8)
+
+struct vnic_path_param {
+	__be64			ioc_guid;
+	u8			ioc_string[MAX_IOC_STRING_LEN+1];
+	u8			port;
+	u8			instance;
+	struct ib_device	*ibdev;
+	struct vnic_ib_port	*ibport;
+	u8			dgid[16];
+	__be16			pkey;
+	int			heartbeat;
+	int			ib_multicast;
+	int			opt_mask;
+};
+
+struct vnic_ib_config {
+	__be64				service_id;
+	struct vnic_connection_data	conn_data;
+	u32				retry_count;
+	u32				rnr_retry_count;
+	u8				min_rnr_timer;
+	u32				num_sends;
+	u32				num_recvs;
+	u32				recv_scatter;	/* 1 */
+	u32				send_gather;	/* 1 or 2 */
+	u32				completion_limit;
+};
+
+struct control_config {
+	struct vnic_ib_config	ib_config;
+	u32			num_recvs;
+	u8			vnic_instance;
+	u16			max_address_entries;
+	u16			min_address_entries;
+	u32			rsp_timeout;
+	u32			ib_multicast;
+};
+
+struct data_config {
+	struct vnic_ib_config		ib_config;
+	u64				path_id;
+	u32				num_recvs;
+	u32				host_recv_pool_entries;
+	struct vnic_recv_pool_config	host_min;
+	struct vnic_recv_pool_config	host_max;
+	struct vnic_recv_pool_config	eioc_min;
+	struct vnic_recv_pool_config	eioc_max;
+	u32				notify_bundle;
+};
+
+struct viport_config {
+	struct viport			*viport;
+	struct control_config		control_config;
+	struct data_config		data_config;
+	struct vnic_ib_path_info	path_info;
+	u32				sa_path_rec_get_timeout;
+	struct ib_device		*ibdev;
+	u32				port;
+	unsigned long			stats_interval;
+	u32				hb_interval;
+	u32				hb_timeout;
+	__be64				ioc_guid;
+	u8				ioc_string[MAX_IOC_STRING_LEN+1];
+	size_t				path_idx;
+};
+
+/*
+ * primary_connect_timeout   - if the secondary connects first,
+ *                             how long do we give the primary?
+ * primary_reconnect_timeout - same as above, but used when recovering
+ *                             from the case where both paths fail
+ * primary_switch_timeout -    how long do we wait before switching to the
+ *                             primary when it comes back?
+ */
+struct vnic_config {
+	struct vnic	*vnic;
+	char		name[IFNAMSIZ];
+	unsigned long	no_path_timeout;
+	u32 		primary_connect_timeout;
+	u32		primary_reconnect_timeout;
+	u32		primary_switch_timeout;
+	int		prefer_primary;
+	int		use_rx_csum;
+	int		use_tx_csum;
+};
+
+int config_start(void);
+struct viport_config *config_alloc_viport(struct vnic_path_param *params);
+struct vnic_config   *config_alloc_vnic(void);
+char *config_viport_name(struct viport_config *config);
+
+#endif	/* VNIC_CONFIG_H_INCLUDED */
