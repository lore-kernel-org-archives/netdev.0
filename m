From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 41/42] vhost/scsi: partial virtio 1.0 support
Date: Tue, 25 Nov 2014 18:44:22 +0200
Message-ID: <1416933600-21398-42-git-send-email-mst@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416933600-21398-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include all endian conversions as required by virtio 1.0.
Don't set virtio 1.0 yet, since that requires ANY_LAYOUT
which we don't yet support.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/scsi.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index a17f118..01c01cb 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -168,6 +168,7 @@ enum {
 	VHOST_SCSI_VQ_IO = 2,
 };
 
+/* Note: can't set VIRTIO_F_VERSION_1 yet, since that implies ANY_LAYOUT. */
 enum {
 	VHOST_SCSI_FEATURES = VHOST_FEATURES | (1ULL << VIRTIO_SCSI_F_HOTPLUG) |
 					       (1ULL << VIRTIO_SCSI_F_T10_PI)
@@ -577,8 +578,8 @@ tcm_vhost_allocate_evt(struct vhost_scsi *vs,
 		return NULL;
 	}
 
-	evt->event.event = event;
-	evt->event.reason = reason;
+	evt->event.event = cpu_to_vhost32(vq, event);
+	evt->event.reason = cpu_to_vhost32(vq, reason);
 	vs->vs_events_nr++;
 
 	return evt;
@@ -636,7 +637,7 @@ again:
 	}
 
 	if (vs->vs_events_missed) {
-		event->event |= VIRTIO_SCSI_T_EVENTS_MISSED;
+		event->event |= cpu_to_vhost32(vq, VIRTIO_SCSI_T_EVENTS_MISSED);
 		vs->vs_events_missed = false;
 	}
 
@@ -695,12 +696,13 @@ static void vhost_scsi_complete_cmd_work(struct vhost_work *work)
 			cmd, se_cmd->residual_count, se_cmd->scsi_status);
 
 		memset(&v_rsp, 0, sizeof(v_rsp));
-		v_rsp.resid = se_cmd->residual_count;
+		v_rsp.resid = cpu_to_vhost32(cmd->tvc_vq, se_cmd->residual_count);
 		/* TODO is status_qualifier field needed? */
 		v_rsp.status = se_cmd->scsi_status;
-		v_rsp.sense_len = se_cmd->scsi_sense_length;
+		v_rsp.sense_len = cpu_to_vhost32(cmd->tvc_vq,
+						 se_cmd->scsi_sense_length);
 		memcpy(v_rsp.sense, cmd->tvc_sense_buf,
-		       v_rsp.sense_len);
+		       se_cmd->scsi_sense_length);
 		ret = copy_to_user(cmd->tvc_resp, &v_rsp, sizeof(v_rsp));
 		if (likely(ret == 0)) {
 			struct vhost_scsi_virtqueue *q;
@@ -1095,14 +1097,14 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 						", but wrong data_direction\n");
 					goto err_cmd;
 				}
-				prot_bytes = v_req_pi.pi_bytesout;
+				prot_bytes = vhost32_to_cpu(vq, v_req_pi.pi_bytesout);
 			} else if (v_req_pi.pi_bytesin) {
 				if (data_direction != DMA_FROM_DEVICE) {
 					vq_err(vq, "Received non zero di_pi_niov"
 						", but wrong data_direction\n");
 					goto err_cmd;
 				}
-				prot_bytes = v_req_pi.pi_bytesin;
+				prot_bytes = vhost32_to_cpu(vq, v_req_pi.pi_bytesin);
 			}
 			if (prot_bytes) {
 				int tmp = 0;
@@ -1117,12 +1119,12 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 				data_first += prot_niov;
 				data_niov = data_num - prot_niov;
 			}
-			tag = v_req_pi.tag;
+			tag = vhost64_to_cpu(vq, v_req_pi.tag);
 			task_attr = v_req_pi.task_attr;
 			cdb = &v_req_pi.cdb[0];
 			lun = ((v_req_pi.lun[2] << 8) | v_req_pi.lun[3]) & 0x3FFF;
 		} else {
-			tag = v_req.tag;
+			tag = vhost64_to_cpu(vq, v_req.tag);
 			task_attr = v_req.task_attr;
 			cdb = &v_req.cdb[0];
 			lun = ((v_req.lun[2] << 8) | v_req.lun[3]) & 0x3FFF;
-- 
MST
