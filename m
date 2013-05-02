From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/3] tcm_vhost: header split up
Date: Thu, 2 May 2013 04:45:41 +0300
Message-ID: <095608213e0b1afa0d212c45638960062252503e.1367459046.git.mst@redhat.com>
References: <cover.1367459045.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1367459045.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

move uapi parts to vhost.h
move .c private parts to .c itself

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/scsi.c       | 112 +++++++++++++++++++++++++++++++++++---
 drivers/vhost/tcm_vhost.h  | 131 ---------------------------------------------
 include/uapi/linux/vhost.h |  28 ++++++++++
 3 files changed, 132 insertions(+), 139 deletions(-)
 delete mode 100644 drivers/vhost/tcm_vhost.h

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 19ca021..eb1aa56 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -51,7 +51,110 @@
 
 #include "vhost.c"
 #include "vhost.h"
-#include "tcm_vhost.h"
+
+#define TCM_VHOST_VERSION  "v0.1"
+#define TCM_VHOST_NAMELEN 256
+#define TCM_VHOST_MAX_CDB_SIZE 32
+
+struct vhost_scsi_inflight {
+	/* Wait for the flush operation to finish */
+	struct completion comp;
+	/* Refcount for the inflight reqs */
+	struct kref kref;
+};
+
+struct tcm_vhost_cmd {
+	/* Descriptor from vhost_get_vq_desc() for virt_queue segment */
+	int tvc_vq_desc;
+	/* virtio-scsi initiator task attribute */
+	int tvc_task_attr;
+	/* virtio-scsi initiator data direction */
+	enum dma_data_direction tvc_data_direction;
+	/* Expected data transfer length from virtio-scsi header */
+	u32 tvc_exp_data_len;
+	/* The Tag from include/linux/virtio_scsi.h:struct virtio_scsi_cmd_req */
+	u64 tvc_tag;
+	/* The number of scatterlists associated with this cmd */
+	u32 tvc_sgl_count;
+	/* Saved unpacked SCSI LUN for tcm_vhost_submission_work() */
+	u32 tvc_lun;
+	/* Pointer to the SGL formatted memory from virtio-scsi */
+	struct scatterlist *tvc_sgl;
+	/* Pointer to response */
+	struct virtio_scsi_cmd_resp __user *tvc_resp;
+	/* Pointer to vhost_scsi for our device */
+	struct vhost_scsi *tvc_vhost;
+	/* Pointer to vhost_virtqueue for the cmd */
+	struct vhost_virtqueue *tvc_vq;
+	/* Pointer to vhost nexus memory */
+	struct tcm_vhost_nexus *tvc_nexus;
+	/* The TCM I/O descriptor that is accessed via container_of() */
+	struct se_cmd tvc_se_cmd;
+	/* work item used for cmwq dispatch to tcm_vhost_submission_work() */
+	struct work_struct work;
+	/* Copy of the incoming SCSI command descriptor block (CDB) */
+	unsigned char tvc_cdb[TCM_VHOST_MAX_CDB_SIZE];
+	/* Sense buffer that will be mapped into outgoing status */
+	unsigned char tvc_sense_buf[TRANSPORT_SENSE_BUFFER];
+	/* Completed commands list, serviced from vhost worker thread */
+	struct llist_node tvc_completion_list;
+	/* Used to track inflight cmd */
+	struct vhost_scsi_inflight *inflight;
+};
+
+struct tcm_vhost_nexus {
+	/* Pointer to TCM session for I_T Nexus */
+	struct se_session *tvn_se_sess;
+};
+
+struct tcm_vhost_nacl {
+	/* Binary World Wide unique Port Name for Vhost Initiator port */
+	u64 iport_wwpn;
+	/* ASCII formatted WWPN for Sas Initiator port */
+	char iport_name[TCM_VHOST_NAMELEN];
+	/* Returned by tcm_vhost_make_nodeacl() */
+	struct se_node_acl se_node_acl;
+};
+
+struct vhost_scsi;
+struct tcm_vhost_tpg {
+	/* Vhost port target portal group tag for TCM */
+	u16 tport_tpgt;
+	/* Used to track number of TPG Port/Lun Links wrt to explict I_T Nexus shutdown */
+	int tv_tpg_port_count;
+	/* Used for vhost_scsi device reference to tpg_nexus, protected by tv_tpg_mutex */
+	int tv_tpg_vhost_count;
+	/* list for tcm_vhost_list */
+	struct list_head tv_tpg_list;
+	/* Used to protect access for tpg_nexus */
+	struct mutex tv_tpg_mutex;
+	/* Pointer to the TCM VHost I_T Nexus for this TPG endpoint */
+	struct tcm_vhost_nexus *tpg_nexus;
+	/* Pointer back to tcm_vhost_tport */
+	struct tcm_vhost_tport *tport;
+	/* Returned by tcm_vhost_make_tpg() */
+	struct se_portal_group se_tpg;
+	/* Pointer back to vhost_scsi, protected by tv_tpg_mutex */
+	struct vhost_scsi *vhost_scsi;
+};
+
+struct tcm_vhost_tport {
+	/* SCSI protocol the tport is providing */
+	u8 tport_proto_id;
+	/* Binary World Wide unique Port Name for Vhost Target port */
+	u64 tport_wwpn;
+	/* ASCII formatted WWPN for Vhost Target port */
+	char tport_name[TCM_VHOST_NAMELEN];
+	/* Returned by tcm_vhost_make_tport() */
+	struct se_wwn tport_wwn;
+};
+
+struct tcm_vhost_evt {
+	/* event to be sent to guest */
+	struct virtio_scsi_event event;
+	/* event list, serviced from vhost worker thread */
+	struct llist_node list;
+};
 
 enum {
 	VHOST_SCSI_VQ_CTL = 0,
@@ -73,13 +176,6 @@ enum {
 #define VHOST_SCSI_MAX_VQ	128
 #define VHOST_SCSI_MAX_EVENT	128
 
-struct vhost_scsi_inflight {
-	/* Wait for the flush operation to finish */
-	struct completion comp;
-	/* Refcount for the inflight reqs */
-	struct kref kref;
-};
-
 struct vhost_scsi_virtqueue {
 	struct vhost_virtqueue vq;
 	/*
diff --git a/drivers/vhost/tcm_vhost.h b/drivers/vhost/tcm_vhost.h
deleted file mode 100644
index 26a57c2..0000000
--- a/drivers/vhost/tcm_vhost.h
+++ /dev/null
@@ -1,131 +0,0 @@
-#define TCM_VHOST_VERSION  "v0.1"
-#define TCM_VHOST_NAMELEN 256
-#define TCM_VHOST_MAX_CDB_SIZE 32
-
-struct vhost_scsi_inflight;
-struct tcm_vhost_cmd {
-	/* Descriptor from vhost_get_vq_desc() for virt_queue segment */
-	int tvc_vq_desc;
-	/* virtio-scsi initiator task attribute */
-	int tvc_task_attr;
-	/* virtio-scsi initiator data direction */
-	enum dma_data_direction tvc_data_direction;
-	/* Expected data transfer length from virtio-scsi header */
-	u32 tvc_exp_data_len;
-	/* The Tag from include/linux/virtio_scsi.h:struct virtio_scsi_cmd_req */
-	u64 tvc_tag;
-	/* The number of scatterlists associated with this cmd */
-	u32 tvc_sgl_count;
-	/* Saved unpacked SCSI LUN for tcm_vhost_submission_work() */
-	u32 tvc_lun;
-	/* Pointer to the SGL formatted memory from virtio-scsi */
-	struct scatterlist *tvc_sgl;
-	/* Pointer to response */
-	struct virtio_scsi_cmd_resp __user *tvc_resp;
-	/* Pointer to vhost_scsi for our device */
-	struct vhost_scsi *tvc_vhost;
-	/* Pointer to vhost_virtqueue for the cmd */
-	struct vhost_virtqueue *tvc_vq;
-	/* Pointer to vhost nexus memory */
-	struct tcm_vhost_nexus *tvc_nexus;
-	/* The TCM I/O descriptor that is accessed via container_of() */
-	struct se_cmd tvc_se_cmd;
-	/* work item used for cmwq dispatch to tcm_vhost_submission_work() */
-	struct work_struct work;
-	/* Copy of the incoming SCSI command descriptor block (CDB) */
-	unsigned char tvc_cdb[TCM_VHOST_MAX_CDB_SIZE];
-	/* Sense buffer that will be mapped into outgoing status */
-	unsigned char tvc_sense_buf[TRANSPORT_SENSE_BUFFER];
-	/* Completed commands list, serviced from vhost worker thread */
-	struct llist_node tvc_completion_list;
-	/* Used to track inflight cmd */
-	struct vhost_scsi_inflight *inflight;
-};
-
-struct tcm_vhost_nexus {
-	/* Pointer to TCM session for I_T Nexus */
-	struct se_session *tvn_se_sess;
-};
-
-struct tcm_vhost_nacl {
-	/* Binary World Wide unique Port Name for Vhost Initiator port */
-	u64 iport_wwpn;
-	/* ASCII formatted WWPN for Sas Initiator port */
-	char iport_name[TCM_VHOST_NAMELEN];
-	/* Returned by tcm_vhost_make_nodeacl() */
-	struct se_node_acl se_node_acl;
-};
-
-struct vhost_scsi;
-struct tcm_vhost_tpg {
-	/* Vhost port target portal group tag for TCM */
-	u16 tport_tpgt;
-	/* Used to track number of TPG Port/Lun Links wrt to explict I_T Nexus shutdown */
-	int tv_tpg_port_count;
-	/* Used for vhost_scsi device reference to tpg_nexus, protected by tv_tpg_mutex */
-	int tv_tpg_vhost_count;
-	/* list for tcm_vhost_list */
-	struct list_head tv_tpg_list;
-	/* Used to protect access for tpg_nexus */
-	struct mutex tv_tpg_mutex;
-	/* Pointer to the TCM VHost I_T Nexus for this TPG endpoint */
-	struct tcm_vhost_nexus *tpg_nexus;
-	/* Pointer back to tcm_vhost_tport */
-	struct tcm_vhost_tport *tport;
-	/* Returned by tcm_vhost_make_tpg() */
-	struct se_portal_group se_tpg;
-	/* Pointer back to vhost_scsi, protected by tv_tpg_mutex */
-	struct vhost_scsi *vhost_scsi;
-};
-
-struct tcm_vhost_tport {
-	/* SCSI protocol the tport is providing */
-	u8 tport_proto_id;
-	/* Binary World Wide unique Port Name for Vhost Target port */
-	u64 tport_wwpn;
-	/* ASCII formatted WWPN for Vhost Target port */
-	char tport_name[TCM_VHOST_NAMELEN];
-	/* Returned by tcm_vhost_make_tport() */
-	struct se_wwn tport_wwn;
-};
-
-struct tcm_vhost_evt {
-	/* event to be sent to guest */
-	struct virtio_scsi_event event;
-	/* event list, serviced from vhost worker thread */
-	struct llist_node list;
-};
-
-/*
- * As per request from MST, keep TCM_VHOST related ioctl defines out of
- * linux/vhost.h (user-space) for now..
- */
-
-#include <linux/vhost.h>
-
-/*
- * Used by QEMU userspace to ensure a consistent vhost-scsi ABI.
- *
- * ABI Rev 0: July 2012 version starting point for v3.6-rc merge candidate +
- *            RFC-v2 vhost-scsi userspace.  Add GET_ABI_VERSION ioctl usage
- * ABI Rev 1: January 2013. Ignore vhost_tpgt filed in struct vhost_scsi_target.
- *            All the targets under vhost_wwpn can be seen and used by guset.
- */
-
-#define VHOST_SCSI_ABI_VERSION	1
-
-struct vhost_scsi_target {
-	int abi_version;
-	char vhost_wwpn[TRANSPORT_IQN_LEN];
-	unsigned short vhost_tpgt;
-	unsigned short reserved;
-};
-
-/* VHOST_SCSI specific defines */
-#define VHOST_SCSI_SET_ENDPOINT _IOW(VHOST_VIRTIO, 0x40, struct vhost_scsi_target)
-#define VHOST_SCSI_CLEAR_ENDPOINT _IOW(VHOST_VIRTIO, 0x41, struct vhost_scsi_target)
-/* Changing this breaks userspace. */
-#define VHOST_SCSI_GET_ABI_VERSION _IOW(VHOST_VIRTIO, 0x42, int)
-/* Set and get the events missed flag */
-#define VHOST_SCSI_SET_EVENTS_MISSED _IOW(VHOST_VIRTIO, 0x43, __u32)
-#define VHOST_SCSI_GET_EVENTS_MISSED _IOW(VHOST_VIRTIO, 0x44, __u32)
diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index e847f1e..bb6a5b4 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -127,4 +127,32 @@ struct vhost_memory {
 /* vhost-net should add virtio_net_hdr for RX, and strip for TX packets. */
 #define VHOST_NET_F_VIRTIO_NET_HDR 27
 
+/* VHOST_SCSI specific definitions */
+
+/*
+ * Used by QEMU userspace to ensure a consistent vhost-scsi ABI.
+ *
+ * ABI Rev 0: July 2012 version starting point for v3.6-rc merge candidate +
+ *            RFC-v2 vhost-scsi userspace.  Add GET_ABI_VERSION ioctl usage
+ * ABI Rev 1: January 2013. Ignore vhost_tpgt filed in struct vhost_scsi_target.
+ *            All the targets under vhost_wwpn can be seen and used by guset.
+ */
+
+#define VHOST_SCSI_ABI_VERSION	1
+
+struct vhost_scsi_target {
+	int abi_version;
+	char vhost_wwpn[224]; /* TRANSPORT_IQN_LEN */
+	unsigned short vhost_tpgt;
+	unsigned short reserved;
+};
+
+#define VHOST_SCSI_SET_ENDPOINT _IOW(VHOST_VIRTIO, 0x40, struct vhost_scsi_target)
+#define VHOST_SCSI_CLEAR_ENDPOINT _IOW(VHOST_VIRTIO, 0x41, struct vhost_scsi_target)
+/* Changing this breaks userspace. */
+#define VHOST_SCSI_GET_ABI_VERSION _IOW(VHOST_VIRTIO, 0x42, int)
+/* Set and get the events missed flag */
+#define VHOST_SCSI_SET_EVENTS_MISSED _IOW(VHOST_VIRTIO, 0x43, __u32)
+#define VHOST_SCSI_GET_EVENTS_MISSED _IOW(VHOST_VIRTIO, 0x44, __u32)
+
 #endif
-- 
MST
