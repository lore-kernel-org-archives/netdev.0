From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] cxgb4i: iscsi and common pdu processing library
Date: Tue,  4 May 2010 22:13:08 +0530
Message-ID: <1272991388-8527-4-git-send-email-rakesh@chelsio.com>
References: <1272991388-8527-1-git-send-email-rakesh@chelsio.com>
 <1272991388-8527-2-git-send-email-rakesh@chelsio.com>
 <1272991388-8527-3-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCKnrzee6GxDknYHfBBoExOIn2Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1272991388-8527-3-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/cxgb4i/cxgb4i_iscsi.c |  715 ++++++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb4i/libcxgbi.c     |  464 +++++++++++++++++++++++
 drivers/scsi/cxgb4i/libcxgbi.h     |   61 +++
 3 files changed, 1240 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_iscsi.c
 create mode 100644 drivers/scsi/cxgb4i/libcxgbi.c
 create mode 100644 drivers/scsi/cxgb4i/libcxgbi.h

diff --git a/drivers/scsi/cxgb4i/cxgb4i_iscsi.c b/drivers/scsi/cxgb4i/cxgb4i_iscsi.c
new file mode 100644
index 0000000..c76fed2
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_iscsi.c
@@ -0,0 +1,715 @@
+/*
+ * cxgb4i_iscsi.c: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <linux/inet.h>
+#include <linux/crypto.h>
+#include <linux/if_vlan.h>
+#include <net/dst.h>
+#include <net/tcp.h>
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_eh.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi.h>
+#include <scsi/iscsi_proto.h>
+#include <scsi/libiscsi.h>
+#include <scsi/scsi_transport_iscsi.h>
+
+#include "cxgb4i.h"
+
+/*
+ * align pdu size to multiple of 512 for better performance
+ */
+#define cxgb4i_align_pdu_size(n) do { n = (n) & (~511); } while (0)
+
+static struct scsi_transport_template *cxgb4i_scsi_transport;
+static struct scsi_host_template cxgb4i_host_template;
+static struct iscsi_transport cxgb4i_iscsi_transport;
+
+struct cxgb4i_hba *cxgb4i_hba_add(struct cxgb4i_snic *snic,
+					struct net_device *dev)
+{
+	struct cxgb4i_hba *chba;
+	struct Scsi_Host *shost;
+	int err;
+
+	shost = iscsi_host_alloc(&cxgb4i_host_template, sizeof(*chba), 1);
+
+	if (!shost) {
+		cxgb4i_log_info("snic 0x%p, ndev 0x%p, host alloc failed\n",
+				snic, dev);
+		return NULL;
+	}
+
+	shost->transportt = cxgb4i_scsi_transport;
+	shost->max_lun = CXGB4I_MAX_LUN;
+	shost->max_id = CXGB4I_MAX_TARGET;
+	shost->max_channel = 0;
+	shost->max_cmd_len = 16;
+
+	chba = iscsi_host_priv(shost);
+	chba->snic = snic;
+	chba->ndev = dev;
+	chba->shost = shost;
+
+	pci_dev_get(snic->lldi.pdev);
+	err = iscsi_host_add(shost, &snic->lldi.pdev->dev);
+	if (err) {
+		cxgb4i_log_info("snic 0x%p, dev 0x%p, host add failed\n",
+				snic, dev);
+		goto pci_dev_put;
+	}
+
+	return chba;
+
+pci_dev_put:
+	pci_dev_put(snic->lldi.pdev);
+	scsi_host_put(shost);
+	return NULL;
+}
+
+void cxgb4i_hba_remove(struct cxgb4i_hba *chba)
+{
+	iscsi_host_remove(chba->shost);
+	pci_dev_put(chba->snic->lldi.pdev);
+	iscsi_host_free(chba->shost);
+}
+
+static struct iscsi_endpoint *cxgb4i_ep_connect(struct Scsi_Host *shost,
+						struct sockaddr *dst_addr,
+						int non_blocking)
+{
+	struct iscsi_endpoint *iep;
+	struct cxgb4i_endpoint *cep;
+	struct cxgb4i_hba *hba = NULL;
+	struct cxgb4i_sock *csk = NULL;
+	struct cxgb4i_snic *snic;
+	int err = 0;
+
+	if (shost)
+		hba = iscsi_host_priv(shost);
+
+	snic = cxgb4i_find_snic(hba ? hba->ndev : NULL,
+			((struct sockaddr_in *)dst_addr)->sin_addr.s_addr);
+	if (!snic) {
+		cxgb4i_log_info("ep connect no snic\n");
+		err = -ENOSPC;
+		goto release_conn;
+	}
+
+	csk = cxgb4i_sock_create(snic);
+	if (!csk) {
+		cxgb4i_log_info("ep connect OOM\n");
+		err = -ENOMEM;
+		goto release_conn;
+	}
+	err = cxgb4i_sock_connect(hba ? hba->ndev : NULL, csk,
+				(struct sockaddr_in *)dst_addr);
+	if (err < 0) {
+		cxgb4i_log_info("ep connect failed\n");
+		goto release_conn;
+	}
+
+	hba = cxgb4i_hba_find_by_netdev(csk->dst->dev);
+	if (!hba) {
+		err = -ENOSPC;
+		cxgb4i_log_info("Not going through cxgb4i device\n");
+		goto release_conn;
+	}
+
+	if (shost && hba != iscsi_host_priv(shost)) {
+		err = -ENOSPC;
+		cxgb4i_log_info("Could not connect through request host %u\n",
+				shost->host_no);
+		goto release_conn;
+	}
+
+	if (cxgb4i_sock_is_closing(csk)) {
+		err = -ENOSPC;
+		cxgb4i_log_info("ep connect unable to connect\n");
+		goto release_conn;
+	}
+
+	iep = iscsi_create_endpoint(sizeof(*cep));
+	if (!iep) {
+		err = -ENOMEM;
+		cxgb4i_log_info("iscsi alloc ep, OOM\n");
+		goto release_conn;
+	}
+
+	cep = iep->dd_data;
+	cep->csk = csk;
+	cep->chba = hba;
+
+	cxgb4i_api_debug("iep 0x%p, cep 0x%p, csk 0x%p, hba 0x%p\n",
+			iep, cep, csk, hba);
+
+	return iep;
+
+release_conn:
+	cxgb4i_api_debug("conn 0x%p failed, release\n", csk);
+	if (csk)
+		cxgb4i_sock_release(csk);
+
+	return ERR_PTR(err);
+}
+
+static int cxgb4i_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
+{
+	struct cxgb4i_endpoint *cep = ep->dd_data;
+	struct cxgb4i_sock *csk = cep->csk;
+
+	if (!cxgb4i_sock_is_established(csk))
+		return 0;
+
+	return 1;
+}
+
+static void cxgb4i_ep_disconnect(struct iscsi_endpoint *ep)
+{
+	struct cxgb4i_endpoint *cep = ep->dd_data;
+	struct cxgb4i_conn *cconn = cep->cconn;
+
+	if (cconn && cconn->iconn) {
+		iscsi_suspend_tx(cconn->iconn);
+
+		write_lock_bh(&cep->csk->callback_lock);
+		cep->csk->user_data = NULL;
+		cconn->cep = NULL;
+		write_unlock_bh(&cep->csk->callback_lock);
+	}
+
+	cxgb4i_sock_release(cep->csk);
+	iscsi_destroy_endpoint(ep);
+}
+
+static struct iscsi_cls_session *
+cxgb4i_create_session(struct iscsi_endpoint *ep, u16 cmds_max, u16 qdepth,
+							u32 initial_cmdsn)
+{
+	struct cxgb4i_endpoint *cep;
+	struct cxgb4i_hba *chba;
+	struct Scsi_Host *shost;
+	struct iscsi_cls_session *cls_session;
+	struct iscsi_session *session;
+
+	if (!ep) {
+		cxgb4i_log_error("missing endpoint\n");
+		return NULL;
+	}
+
+	cep = ep->dd_data;
+	chba = cep->chba;
+	shost = chba->shost;
+
+	BUG_ON(chba != iscsi_host_priv(shost));
+
+	cls_session = iscsi_session_setup(&cxgb4i_iscsi_transport, shost,
+					cmds_max, 0,
+					sizeof(struct iscsi_tcp_task) +
+					sizeof(struct cxgb4i_task_data),
+					initial_cmdsn, ISCSI_MAX_TARGET);
+	if (!cls_session)
+		return NULL;
+
+	session = cls_session->dd_data;
+	if (iscsi_tcp_r2tpool_alloc(session))
+		goto remove_session;
+
+	return cls_session;
+
+remove_session:
+	iscsi_session_teardown(cls_session);
+	return NULL;
+}
+
+static void cxgb4i_destroy_session(struct iscsi_cls_session *cls_session)
+{
+	iscsi_tcp_r2tpool_free(cls_session->dd_data);
+	iscsi_session_teardown(cls_session);
+}
+
+static inline int cxgb4i_conn_max_xmit_dlength(struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	unsigned int max = max(512 * MAX_SKB_FRAGS, SKB_TX_HEADROOM);
+
+	max = min(cconn->chba->snic->tx_max_size, max);
+	if (conn->max_xmit_dlength)
+		conn->max_xmit_dlength = min(conn->max_xmit_dlength, max);
+	else
+		conn->max_xmit_dlength = max;
+	cxgb4i_align_pdu_size(conn->max_xmit_dlength);
+	return 0;
+}
+
+static inline int cxgb4i_conn_max_recv_dlength(struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	unsigned int max = cconn->chba->snic->rx_max_size;
+
+	cxgb4i_align_pdu_size(max);
+
+	if (conn->max_recv_dlength) {
+		if (conn->max_recv_dlength > max) {
+			cxgb4i_log_error("MaxRecvDataSegmentLength %u too big."
+					" Need to be <= %u.\n",
+					conn->max_recv_dlength, max);
+			return -EINVAL;
+		}
+		conn->max_recv_dlength = min(conn->max_recv_dlength, max);
+		cxgb4i_align_pdu_size(conn->max_recv_dlength);
+	} else
+		conn->max_recv_dlength = max;
+
+	return 0;
+}
+
+static struct iscsi_cls_conn *
+cxgb4i_create_conn(struct iscsi_cls_session *cls_session, u32 cid)
+{
+	struct iscsi_cls_conn *cls_conn;
+	struct iscsi_conn *conn;
+	struct iscsi_tcp_conn *tcp_conn;
+	struct cxgb4i_conn *cconn;
+
+	cls_conn = iscsi_tcp_conn_setup(cls_session, sizeof(*cconn), cid);
+	if (!cls_conn)
+		return NULL;
+
+	conn = cls_conn->dd_data;
+	tcp_conn = conn->dd_data;
+	cconn = tcp_conn->dd_data;
+
+	cconn->iconn = conn;
+	return cls_conn;
+}
+
+static int cxgb4i_bind_conn(struct iscsi_cls_session *cls_session,
+				struct iscsi_cls_conn *cls_conn,
+				u64 transport_eph, int is_leading)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct cxgb4i_snic *snic;
+	struct iscsi_endpoint *ep;
+	struct cxgb4i_endpoint *cep;
+	struct cxgb4i_sock *csk;
+	int err;
+
+	ep = iscsi_lookup_endpoint(transport_eph);
+	if (!ep)
+		return -EINVAL;
+
+	/*  setup ddp pagesize */
+	cep = ep->dd_data;
+	csk = cep->csk;
+	snic = cep->chba->snic;
+	err = cxgb4i_ddp_setup_conn_host_pagesize(csk, csk->hwtid, 0);
+	if (err < 0)
+		return err;
+
+	err = iscsi_conn_bind(cls_session, cls_conn, is_leading);
+	if (err)
+		return -EINVAL;
+
+	/*  calculate the tag idx bits needed for this conn based on cmds_max */
+	cconn->task_idx_bits = (__ilog2_u32(conn->session->cmds_max - 1)) + 1;
+
+	read_lock(&csk->callback_lock);
+	csk->user_data = conn;
+	cconn->chba = cep->chba;
+	cconn->cep = cep;
+	cep->cconn = cconn;
+	read_unlock(&csk->callback_lock);
+
+	cxgb4i_conn_max_xmit_dlength(conn);
+	cxgb4i_conn_max_recv_dlength(conn);
+
+	spin_lock_bh(&conn->session->lock);
+	sprintf(conn->portal_address, "%pI4", &csk->daddr.sin_addr.s_addr);
+	conn->portal_port = ntohs(csk->daddr.sin_port);
+	spin_unlock_bh(&conn->session->lock);
+
+	/*  init recv engine */
+	iscsi_tcp_hdr_recv_prep(tcp_conn);
+
+	return 0;
+}
+
+static int
+cxgb4i_get_conn_param(struct iscsi_cls_conn *cls_conn,
+			enum iscsi_param param, char *buff)
+{
+	struct iscsi_conn *iconn = cls_conn->dd_data;
+	int len;
+
+	switch (param) {
+	case ISCSI_PARAM_CONN_PORT:
+		spin_lock_bh(&iconn->session->lock);
+		len = sprintf(buff, "%hu\n", iconn->portal_port);
+		spin_unlock_bh(&iconn->session->lock);
+		break;
+	case ISCSI_PARAM_CONN_ADDRESS:
+		spin_lock_bh(&iconn->session->lock);
+		len = sprintf(buff, "%s\n", iconn->portal_address);
+		spin_unlock_bh(&iconn->session->lock);
+		break;
+	default:
+		return iscsi_conn_get_param(cls_conn, param, buff);
+	}
+	return len;
+}
+
+static int
+cxgb4i_set_conn_param(struct iscsi_cls_conn *cls_conn,
+			enum iscsi_param param, char *buf, int buflen)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct cxgb4i_sock *csk = cconn->cep->csk;
+	int value, err = 0;
+
+	switch (param) {
+	case ISCSI_PARAM_HDRDGST_EN:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && conn->hdrdgst_en)
+			err = cxgb4i_ddp_setup_conn_digest(csk, csk->hwtid,
+							conn->hdrdgst_en,
+							conn->datadgst_en, 0);
+		break;
+	case ISCSI_PARAM_DATADGST_EN:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && conn->datadgst_en)
+			err = cxgb4i_ddp_setup_conn_digest(csk, csk->hwtid,
+							conn->hdrdgst_en,
+							conn->datadgst_en, 0);
+		break;
+	case ISCSI_PARAM_MAX_R2T:
+		sscanf(buf, "%d", &value);
+		if (value <= 0 || !is_power_of_2(value))
+			return -EINVAL;
+		if (session->max_r2t == value)
+			break;
+		iscsi_tcp_r2tpool_free(session);
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && iscsi_tcp_r2tpool_alloc(session))
+			return -ENOMEM;
+	case ISCSI_PARAM_MAX_RECV_DLENGTH:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err)
+			err = cxgb4i_conn_max_recv_dlength(conn);
+		break;
+	case ISCSI_PARAM_MAX_XMIT_DLENGTH:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err)
+			err = cxgb4i_conn_max_xmit_dlength(conn);
+		break;
+	default:
+		return iscsi_set_param(cls_conn, param, buf, buflen);
+	}
+	return err;
+}
+
+static int
+cxgb4i_set_host_param(struct Scsi_Host *shost,
+			enum iscsi_host_param param, char *buff, int buflen)
+{
+	struct cxgb4i_hba *chba = iscsi_host_priv(shost);
+
+	if (!chba->ndev) {
+		shost_printk(KERN_ERR, shost, "Could not set host param. "
+				"Netdev for host not set\n");
+		return -ENODEV;
+	}
+
+	cxgb4i_api_debug("param %d, buff %s\n", param, buff);
+
+	switch (param) {
+	case ISCSI_HOST_PARAM_IPADDRESS:
+	{
+		__be32 addr = in_aton(buff);
+		cxgb4i_set_iscsi_ipv4(chba, addr);
+		return 0;
+	}
+
+	case ISCSI_HOST_PARAM_HWADDRESS:
+	case ISCSI_HOST_PARAM_NETDEV_NAME:
+		return 0;
+
+	default:
+		return iscsi_host_set_param(shost, param, buff, buflen);
+	}
+}
+
+static int
+cxgb4i_get_host_param(struct Scsi_Host *shost,
+			enum iscsi_host_param param, char *buff)
+{
+	struct cxgb4i_hba *chba = iscsi_host_priv(shost);
+	int len = 0;
+
+	if (!chba->ndev) {
+		shost_printk(KERN_ERR, shost, "Could not set host param. "
+				"Netdev for host not set\n");
+		return -ENODEV;
+	}
+
+	cxgb4i_api_debug("hba %s, param %d\n", chba->ndev->name, param);
+
+	switch (param) {
+	case ISCSI_HOST_PARAM_HWADDRESS:
+		len = sysfs_format_mac(buff, chba->ndev->dev_addr, 6);
+		break;
+	case ISCSI_HOST_PARAM_NETDEV_NAME:
+		len = sprintf(buff, "%s\n", chba->ndev->name);
+		break;
+	case ISCSI_HOST_PARAM_IPADDRESS:
+	{
+		__be32 addr;
+
+		addr = cxgb4i_get_iscsi_ipv4(chba);
+		len = sprintf(buff, "%pI4", &addr);
+		break;
+	}
+	default:
+		return iscsi_host_get_param(shost, param, buff);
+	}
+
+	return len;
+}
+
+static void cxgb4i_get_conn_stats(struct iscsi_cls_conn *cls_conn,
+				struct iscsi_stats *stats)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+
+	stats->txdata_octets = conn->txdata_octets;
+	stats->rxdata_octets = conn->rxdata_octets;
+	stats->scsicmd_pdus = conn->scsicmd_pdus_cnt;
+	stats->dataout_pdus = conn->dataout_pdus_cnt;
+	stats->scsirsp_pdus = conn->scsirsp_pdus_cnt;
+	stats->datain_pdus = conn->datain_pdus_cnt;
+	stats->r2t_pdus = conn->r2t_pdus_cnt;
+	stats->tmfcmd_pdus = conn->tmfcmd_pdus_cnt;
+	stats->tmfrsp_pdus = conn->tmfrsp_pdus_cnt;
+	stats->digest_err = 0;
+	stats->timeout_err = 0;
+	stats->custom_length = 1;
+	strcpy(stats->custom[0].desc, "eh_abort_cnt");
+	stats->custom[0].value = conn->eh_abort_cnt;
+}
+
+static void cxgb4i_parse_pdu_itt(struct iscsi_conn *conn, itt_t itt,
+							int *idx, int *age)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct cxgb4i_snic *snic = cconn->chba->snic;
+	u32 tag = ntohl((__force u32) itt);
+	u32 sw_bits;
+
+	sw_bits = cxgb4i_tag_nonrsvd_bits(&snic->tag_format, tag);
+	if (idx)
+		*idx = sw_bits & ((1 << cconn->task_idx_bits) - 1);
+	if (age)
+		*age = (sw_bits >> cconn->task_idx_bits) & ISCSI_AGE_MASK;
+
+	cxgb4i_tag_debug("parse tag 0x%x/0x%x, sw 0x%x, itt 0x%x, age 0x%x.\n",
+			tag, itt, sw_bits, idx ? *idx : 0xFFFFF,
+			age ? *age : 0xFF);
+}
+
+int cxgb4i_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_session *sess = conn->session;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct cxgb4i_snic *snic = cconn->chba->snic;
+	struct cxgb4i_tag_format *tformat = &snic->tag_format;
+	u32 sw_tag = (sess->age << cconn->task_idx_bits) | task->itt;
+	u32 tag;
+	int err = -EINVAL;
+
+	if (sc &&
+		(scsi_bidi_cmnd(sc) ||
+		 sc->sc_data_direction == DMA_FROM_DEVICE) &&
+			cxgb4i_sw_tag_usable(tformat, sw_tag)) {
+
+		struct cxgb4i_sock *csk = cconn->cep->csk;
+		struct cxgb4i_gather_list *gl;
+
+		gl = cxgb4i_ddp_make_gl(scsi_in(sc)->length,
+					scsi_in(sc)->table.sgl,
+					scsi_in(sc)->table.nents,
+					snic->lldi.pdev,
+					GFP_ATOMIC);
+		if (gl) {
+			tag = sw_tag;
+			err = cxgb4i_ddp_tag_reserve(snic, csk->hwtid,
+							tformat, &tag,
+							gl, GFP_ATOMIC);
+			if (err < 0)
+				cxgb4i_ddp_release_gl(gl, snic->lldi.pdev);
+		}
+	}
+	if (err < 0)
+		tag = cxgb4i_set_non_ddp_tag(tformat, sw_tag);
+	/*  the itt need to sent in big-endian order */
+	*hdr_itt = (__force itt_t)htonl(tag);
+
+	cxgb4i_tag_debug("new sc 0x%p tag 0x%x/0x%x (itt 0x%x, age 0x%x).\n",
+			sc, tag, *hdr_itt, task->itt, sess->age);
+	return 0;
+}
+
+void cxgb4i_release_itt(struct iscsi_task *task, itt_t hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct cxgb4i_snic *snic = cconn->chba->snic;
+	struct cxgb4i_tag_format *tformat = &snic->tag_format;
+	u32 tag = ntohl((__force u32)hdr_itt);
+
+	cxgb4i_tag_debug("release tag 0x%x.\n", tag);
+
+	if (sc &&
+		(scsi_bidi_cmnd(sc) ||
+		 sc->sc_data_direction == DMA_FROM_DEVICE) &&
+			cxgb4i_is_ddp_tag(tformat, tag))
+		cxgb4i_ddp_tag_release(snic, tag);
+}
+
+void cxgb4i_cleanup_task(struct iscsi_task *task)
+{
+	struct cxgb4i_task_data *tdata = task->dd_data +
+				sizeof(struct iscsi_tcp_task);
+
+	/*  never reached the xmit task callout */
+	if (tdata->skb)
+		__kfree_skb(tdata->skb);
+	memset(tdata, 0, sizeof(*tdata));
+
+	cxgb4i_release_itt(task, task->hdr_itt);
+	iscsi_tcp_cleanup_task(task);
+}
+
+static struct scsi_host_template cxgb4i_host_template = {
+	.module				= THIS_MODULE,
+	.name				= "Chelsio T4 iSCSI initiator",
+	.proc_name			= "cxgb4i",
+	.queuecommand			= iscsi_queuecommand,
+	.change_queue_depth		= iscsi_change_queue_depth,
+	.can_queue			= CXGB4I_SCSI_HOST_QDEPTH,
+	.sg_tablesize			= SG_ALL,
+	.max_sectors			= 0xFFFF,
+	.cmd_per_lun			= ISCSI_DEF_CMD_PER_LUN,
+	.eh_abort_handler		= iscsi_eh_abort,
+	.eh_device_reset_handler	= iscsi_eh_device_reset,
+	.eh_target_reset_handler	= iscsi_eh_recover_target,
+	.target_alloc			= iscsi_target_alloc,
+	.use_clustering			= DISABLE_CLUSTERING,
+	.this_id			= -1,
+};
+
+#define	CXGB4I_CAPS	(CAP_RECOVERY_L0 | CAP_MULTI_R2T |	\
+			CAP_HDRDGST | CAP_DATADGST |		\
+			CAP_DIGEST_OFFLOAD | CAP_PADDING_OFFLOAD)
+#define	CXGB4I_PMASK	(ISCSI_MAX_RECV_DLENGTH | ISCSI_MAX_XMIT_DLENGTH | \
+			ISCSI_HDRDGST_EN | ISCSI_DATADGST_EN | \
+			ISCSI_INITIAL_R2T_EN | ISCSI_MAX_R2T | \
+			ISCSI_IMM_DATA_EN | ISCSI_FIRST_BURST | \
+			ISCSI_MAX_BURST | ISCSI_PDU_INORDER_EN | \
+			ISCSI_DATASEQ_INORDER_EN | ISCSI_ERL | \
+			ISCSI_CONN_PORT | ISCSI_CONN_ADDRESS | \
+			ISCSI_EXP_STATSN | ISCSI_PERSISTENT_PORT | \
+			ISCSI_PERSISTENT_ADDRESS | ISCSI_TARGET_NAME | \
+			ISCSI_TPGT | ISCSI_USERNAME | \
+			ISCSI_PASSWORD | ISCSI_USERNAME_IN | \
+			ISCSI_PASSWORD_IN | ISCSI_FAST_ABORT | \
+			ISCSI_ABORT_TMO | ISCSI_LU_RESET_TMO | \
+			/*ISCSI_TGT_RESET_TMO |*/ ISCSI_PING_TMO | \
+			ISCSI_RECV_TMO | ISCSI_IFACE_NAME | \
+			ISCSI_INITIATOR_NAME)
+#define	CXGB4I_HPMASK	(ISCSI_HOST_HWADDRESS | ISCSI_HOST_IPADDRESS | \
+			ISCSI_HOST_INITIATOR_NAME | ISCSI_HOST_INITIATOR_NAME)
+
+static struct iscsi_transport cxgb4i_iscsi_transport = {
+	.owner				= THIS_MODULE,
+	.name				= "cxgb4i",
+	.caps				= CXGB4I_CAPS,
+	.param_mask			= CXGB4I_PMASK,
+	.host_param_mask		= CXGB4I_HPMASK,
+	.get_host_param			= cxgb4i_get_host_param,
+	.set_host_param			= cxgb4i_set_host_param,
+
+	.create_session			= cxgb4i_create_session,
+	.destroy_session		= cxgb4i_destroy_session,
+	.get_session_param		= iscsi_session_get_param,
+
+	.create_conn			= cxgb4i_create_conn,
+	.bind_conn			= cxgb4i_bind_conn,
+	.destroy_conn			= iscsi_tcp_conn_teardown,
+	.start_conn			= iscsi_conn_start,
+	.stop_conn			= iscsi_conn_stop,
+	.get_conn_param			= cxgb4i_get_conn_param,
+	.set_param			= cxgb4i_set_conn_param,
+	.get_stats			= cxgb4i_get_conn_stats,
+
+	.send_pdu			= iscsi_conn_send_pdu,
+
+	.init_task			= iscsi_tcp_task_init,
+	.xmit_task			= iscsi_tcp_task_xmit,
+	.cleanup_task			= cxgb4i_cleanup_task,
+
+	.alloc_pdu			= cxgb4i_conn_alloc_pdu,
+	.init_pdu			= cxgb4i_conn_init_pdu,
+	.xmit_pdu			= cxgb4i_conn_xmit_pdu,
+	.parse_pdu_itt			= cxgb4i_parse_pdu_itt,
+
+	.ep_connect			= cxgb4i_ep_connect,
+	.ep_poll			= cxgb4i_ep_poll,
+	.ep_disconnect			= cxgb4i_ep_disconnect,
+
+	.session_recovery_timedout	= iscsi_session_recovery_timedout,
+};
+
+int cxgb4i_iscsi_init(void)
+{
+	cxgb4i_scsi_transport = iscsi_register_transport(
+					&cxgb4i_iscsi_transport);
+	if (!cxgb4i_scsi_transport) {
+		cxgb4i_log_error("Could not register cxgb4i transport\n");
+		return -ENODATA;
+	}
+
+	return 0;
+}
+
+void cxgb4i_iscsi_cleanup(void)
+{
+	if (cxgb4i_scsi_transport) {
+		cxgb4i_api_debug("cxgb4i transport 0x%p removed\n",
+				cxgb4i_scsi_transport);
+		iscsi_unregister_transport(&cxgb4i_iscsi_transport);
+	}
+}
+
diff --git a/drivers/scsi/cxgb4i/libcxgbi.c b/drivers/scsi/cxgb4i/libcxgbi.c
new file mode 100644
index 0000000..df1ce1d
--- /dev/null
+++ b/drivers/scsi/cxgb4i/libcxgbi.c
@@ -0,0 +1,464 @@
+/*
+ * libcxgbi.c: Chelsio common library for T3/T4 iSCSI ULD.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <linux/skbuff.h>
+#include <linux/crypto.h>
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_host.h>
+
+#include "cxgb4i.h"
+#include "libcxgbi.h"
+
+/* always allocate rooms for AHS */
+#define SKB_TX_PDU_HEADER_LEN	\
+	(sizeof(struct iscsi_hdr) + ISCSI_MAX_AHS_SIZE)
+
+static unsigned int skb_extra_headroom;
+static struct page *pad_page;
+
+/*
+ * pdu receive, interact with libiscsi_tcp
+ */
+static inline int read_pdu_skb(struct iscsi_conn *conn, struct sk_buff *skb,
+			       unsigned int offset, int offloaded)
+{
+	int status = 0;
+	int bytes_read;
+
+	bytes_read = iscsi_tcp_recv_skb(conn, skb, offset, offloaded, &status);
+	switch (status) {
+	case ISCSI_TCP_CONN_ERR:
+		return -EIO;
+	case ISCSI_TCP_SUSPENDED:
+		/* no transfer - just have caller flush queue */
+		return bytes_read;
+	case ISCSI_TCP_SKB_DONE:
+		/*
+		 * pdus should always fit in the skb and we should get
+		 * segment done notifcation.
+		 */
+		iscsi_conn_printk(KERN_ERR, conn, "Invalid pdu or skb.");
+		return -EFAULT;
+	case ISCSI_TCP_SEGMENT_DONE:
+		return bytes_read;
+	default:
+		iscsi_conn_printk(KERN_ERR, conn, "Invalid iscsi_tcp_recv_skb "
+				  "status %d\n", status);
+		return -EINVAL;
+	}
+}
+
+static int cxgb4i_conn_read_bhs_pdu_skb(struct iscsi_conn *conn,
+				    struct sk_buff *skb)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	int rc;
+
+	cxgb4i_rx_debug("conn 0x%p, skb 0x%p, len %u, flag 0x%x.\n",
+			conn, skb, skb->len, cxgb4i_skb_ulp_mode(skb));
+
+	if (!iscsi_tcp_recv_segment_is_hdr(tcp_conn)) {
+		iscsi_conn_failure(conn, ISCSI_ERR_PROTO);
+		return -EIO;
+	}
+
+	if (conn->hdrdgst_en && (cxgb4i_skb_ulp_mode(skb) &
+				ULP2_FLAG_HCRC_ERROR)) {
+		iscsi_conn_failure(conn, ISCSI_ERR_HDR_DGST);
+		return -EIO;
+	}
+
+	rc = read_pdu_skb(conn, skb, 0, 0);
+	if (rc <= 0)
+		return rc;
+
+	return 0;
+}
+
+static int cxgb4i_conn_read_data_pdu_skb(struct iscsi_conn *conn,
+				    struct sk_buff *skb)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	bool offloaded = 0;
+	unsigned int offset = 0;
+	int rc;
+
+	cxgb4i_rx_debug("conn 0x%p, skb 0x%p, len %u, flag 0x%x.\n",
+			conn, skb, skb->len, cxgb4i_skb_ulp_mode(skb));
+
+	if (conn->datadgst_en &&
+			(cxgb4i_skb_ulp_mode(skb) & ULP2_FLAG_DCRC_ERROR)) {
+		iscsi_conn_failure(conn, ISCSI_ERR_DATA_DGST);
+		return -EIO;
+	}
+
+	if (iscsi_tcp_recv_segment_is_hdr(tcp_conn))
+		return 0;
+
+	if (conn->hdrdgst_en)
+		offset = ISCSI_DIGEST_SIZE;
+
+	if (cxgb4i_skb_ulp_mode(skb) & ULP2_FLAG_DATA_DDPED) {
+		cxgb4i_rx_debug("skb 0x%p, opcode 0x%x, data %u, ddp'ed, "
+				"itt 0x%x.\n",
+				skb,
+				tcp_conn->in.hdr->opcode & ISCSI_OPCODE_MASK,
+				tcp_conn->in.datalen,
+				ntohl(tcp_conn->in.hdr->itt));
+		offloaded = 1;
+	} else {
+		cxgb4i_rx_debug("skb 0x%p, opcode 0x%x, data %u, NOT ddp'ed, "
+				"itt 0x%x.\n",
+				skb,
+				tcp_conn->in.hdr->opcode & ISCSI_OPCODE_MASK,
+				tcp_conn->in.datalen,
+				ntohl(tcp_conn->in.hdr->itt));
+	}
+
+	rc = read_pdu_skb(conn, skb, 0, offloaded);
+	if (rc < 0)
+		return rc;
+	else
+		return 0;
+}
+
+static inline void tx_skb_setmode(struct sk_buff *skb, int hcrc, int dcrc)
+{
+	u8 submode = 0;
+
+	if (hcrc)
+		submode |= 1;
+	if (dcrc)
+		submode |= 2;
+	cxgb4i_skb_ulp_mode(skb) = (ULP_MODE_ISCSI << 4) | submode;
+}
+
+static int sgl_seek_offset(struct scatterlist *sgl, unsigned int sgcnt,
+				unsigned int offset, unsigned int *off,
+				struct scatterlist **sgp)
+{
+	int i;
+	struct scatterlist *sg;
+
+	for_each_sg(sgl, sg, sgcnt, i) {
+		if (offset < sg->length) {
+			*off = offset;
+			*sgp = sg;
+			return 0;
+		}
+		offset -= sg->length;
+	}
+	return -EFAULT;
+}
+
+static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
+				unsigned int dlen, skb_frag_t *frags,
+				int frag_max)
+{
+	unsigned int datalen = dlen;
+	unsigned int sglen = sg->length - sgoffset;
+	struct page *page = sg_page(sg);
+	int i;
+
+	i = 0;
+	do {
+		unsigned int copy;
+
+		if (!sglen) {
+			sg = sg_next(sg);
+			if (!sg) {
+				cxgb4i_log_error("sg NULL, len %u/%u.\n",
+								datalen, dlen);
+				return -EINVAL;
+			}
+			sgoffset = 0;
+			sglen = sg->length;
+			page = sg_page(sg);
+
+		}
+		copy = min(datalen, sglen);
+		if (i && page == frags[i - 1].page &&
+		    sgoffset + sg->offset ==
+			frags[i - 1].page_offset + frags[i - 1].size) {
+			frags[i - 1].size += copy;
+		} else {
+			if (i >= frag_max) {
+				cxgb4i_log_error("too many pages %u, "
+						 "dlen %u.\n", frag_max, dlen);
+				return -EINVAL;
+			}
+
+			frags[i].page = page;
+			frags[i].page_offset = sg->offset + sgoffset;
+			frags[i].size = copy;
+			i++;
+		}
+		datalen -= copy;
+		sgoffset += copy;
+		sglen -= copy;
+	} while (datalen);
+
+	return i;
+}
+
+int cxgb4i_conn_alloc_pdu(struct iscsi_task *task, u8 opcode)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgb4i_task_data *tdata = task->dd_data + sizeof(*tcp_task);
+	struct scsi_cmnd *sc = task->sc;
+	int headroom = SKB_TX_PDU_HEADER_LEN;
+
+	tcp_task->dd_data = tdata;
+	task->hdr = NULL;
+
+	/* write command, need to send data pdus */
+	if (skb_extra_headroom && (opcode == ISCSI_OP_SCSI_DATA_OUT ||
+	    (opcode == ISCSI_OP_SCSI_CMD &&
+	    (scsi_bidi_cmnd(sc) || sc->sc_data_direction == DMA_TO_DEVICE))))
+		headroom += min(skb_extra_headroom, conn->max_xmit_dlength);
+
+	tdata->skb = alloc_skb(TX_HEADER_LEN + headroom, GFP_ATOMIC);
+	if (!tdata->skb)
+		return -ENOMEM;
+	skb_reserve(tdata->skb, TX_HEADER_LEN);
+
+	cxgb4i_tx_debug("task 0x%p, opcode 0x%x, skb 0x%p.\n",
+			task, opcode, tdata->skb);
+
+	task->hdr = (struct iscsi_hdr *)tdata->skb->data;
+	task->hdr_max = SKB_TX_PDU_HEADER_LEN;
+
+	/* data_out uses scsi_cmd's itt */
+	if (opcode != ISCSI_OP_SCSI_DATA_OUT)
+		cxgb4i_reserve_itt(task, &task->hdr->itt);
+
+	return 0;
+}
+
+int cxgb4i_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
+			      unsigned int count)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgb4i_task_data *tdata = tcp_task->dd_data;
+	struct sk_buff *skb = tdata->skb;
+	unsigned int datalen = count;
+	int i, padlen = iscsi_padding(count);
+	struct page *pg;
+
+	cxgb4i_tx_debug("task 0x%p,0x%p, offset %u, count %u, skb 0x%p.\n",
+			task, task->sc, offset, count, skb);
+
+	skb_put(skb, task->hdr_len);
+	tx_skb_setmode(skb, conn->hdrdgst_en, datalen ? conn->datadgst_en : 0);
+	if (!count)
+		return 0;
+
+	if (task->sc) {
+		struct scsi_data_buffer *sdb = scsi_out(task->sc);
+		struct scatterlist *sg = NULL;
+		int err;
+
+		tdata->offset = offset;
+		tdata->count = count;
+		err = sgl_seek_offset(sdb->table.sgl, sdb->table.nents,
+					tdata->offset, &tdata->sgoffset, &sg);
+		if (err < 0) {
+			cxgb4i_log_warn("tpdu, sgl %u, bad offset %u/%u.\n",
+					sdb->table.nents, tdata->offset,
+					sdb->length);
+			return err;
+		}
+		err = sgl_read_to_frags(sg, tdata->sgoffset, tdata->count,
+					tdata->frags, MAX_PDU_FRAGS);
+		if (err < 0) {
+			cxgb4i_log_warn("tpdu, sgl %u, bad offset %u + %u.\n",
+					sdb->table.nents, tdata->offset,
+					tdata->count);
+			return err;
+		}
+		tdata->nr_frags = err;
+
+		if (tdata->nr_frags > MAX_SKB_FRAGS ||
+		    (padlen && tdata->nr_frags == MAX_SKB_FRAGS)) {
+			char *dst = skb->data + task->hdr_len;
+			skb_frag_t *frag = tdata->frags;
+
+			/* data fits in the skb's headroom */
+			for (i = 0; i < tdata->nr_frags; i++, frag++) {
+				char *src = kmap_atomic(frag->page,
+							KM_SOFTIRQ0);
+
+				memcpy(dst, src+frag->page_offset, frag->size);
+				dst += frag->size;
+				kunmap_atomic(src, KM_SOFTIRQ0);
+			}
+			if (padlen) {
+				memset(dst, 0, padlen);
+				padlen = 0;
+			}
+			skb_put(skb, count + padlen);
+		} else {
+			/* data fit into frag_list */
+			for (i = 0; i < tdata->nr_frags; i++)
+				get_page(tdata->frags[i].page);
+
+			memcpy(skb_shinfo(skb)->frags, tdata->frags,
+				sizeof(skb_frag_t) * tdata->nr_frags);
+			skb_shinfo(skb)->nr_frags = tdata->nr_frags;
+			skb->len += count;
+			skb->data_len += count;
+			skb->truesize += count;
+		}
+
+	} else {
+		pg = virt_to_page(task->data);
+
+		get_page(pg);
+		skb_fill_page_desc(skb, 0, pg, offset_in_page(task->data),
+					count);
+		skb->len += count;
+		skb->data_len += count;
+		skb->truesize += count;
+	}
+
+	if (padlen) {
+		i = skb_shinfo(skb)->nr_frags;
+		get_page(pad_page);
+		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, pad_page, 0,
+				 padlen);
+
+		skb->data_len += padlen;
+		skb->truesize += padlen;
+		skb->len += padlen;
+	}
+
+	return 0;
+}
+
+int cxgb4i_conn_xmit_pdu(struct iscsi_task *task)
+{
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgb4i_conn *cconn = tcp_conn->dd_data;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgb4i_task_data *tdata = tcp_task->dd_data;
+	struct sk_buff *skb = tdata->skb;
+	unsigned int datalen;
+	int err;
+
+	if (!skb)
+		return 0;
+
+	datalen = skb->data_len;
+	tdata->skb = NULL;
+	err = cxgb4i_sock_send_pdus(cconn->cep->csk, skb);
+	if (err > 0) {
+		int pdulen = err;
+
+		cxgb4i_tx_debug("task 0x%p, skb 0x%p, len %u/%u, rv %d.\n",
+				task, skb, skb->len, skb->data_len, err);
+
+		if (task->conn->hdrdgst_en)
+			pdulen += ISCSI_DIGEST_SIZE;
+		if (datalen && task->conn->datadgst_en)
+			pdulen += ISCSI_DIGEST_SIZE;
+
+		task->conn->txdata_octets += pdulen;
+		return 0;
+	}
+
+	if (err == -EAGAIN || err == -ENOBUFS) {
+		/* reset skb to send when we are called again */
+		tdata->skb = skb;
+		return err;
+	}
+
+	kfree_skb(skb);
+	cxgb4i_tx_debug("itt 0x%x, skb 0x%p, len %u/%u, xmit err %d.\n",
+			task->itt, skb, skb->len, skb->data_len, err);
+	iscsi_conn_printk(KERN_ERR, task->conn, "xmit err %d.\n", err);
+	iscsi_conn_failure(task->conn, ISCSI_ERR_XMIT_FAILED);
+	return err;
+}
+
+int cxgb4i_pdu_init(void)
+{
+	if (SKB_TX_HEADROOM > (512 * MAX_SKB_FRAGS))
+		skb_extra_headroom = SKB_TX_HEADROOM;
+	pad_page = alloc_page(GFP_KERNEL);
+	if (!pad_page)
+		return -ENOMEM;
+	memset(page_address(pad_page), 0, PAGE_SIZE);
+	return 0;
+}
+
+void cxgb4i_pdu_cleanup(void)
+{
+	if (pad_page) {
+		__free_page(pad_page);
+		pad_page = NULL;
+	}
+}
+
+void cxgbi_conn_pdu_ready(struct cxgb4i_sock *csk)
+{
+	struct sk_buff *skb;
+	unsigned int read = 0;
+	struct iscsi_conn *conn = csk->user_data;
+	int err = 0;
+
+	cxgb4i_rx_debug("csk 0x%p.\n", csk);
+
+	read_lock(&csk->callback_lock);
+	if (unlikely(!conn || conn->suspend_rx)) {
+		cxgb4i_rx_debug("conn 0x%p, id %d, suspend_rx %lu!\n",
+				conn, conn ? conn->id : 0xFF,
+				conn ? conn->suspend_rx : 0xFF);
+		read_unlock(&csk->callback_lock);
+		return;
+	}
+	skb = skb_peek(&csk->receive_queue);
+	while (!err && skb) {
+		__skb_unlink(skb, &csk->receive_queue);
+		read += cxgb4i_skb_rx_pdulen(skb);
+		cxgb4i_rx_debug("conn 0x%p, csk 0x%p, rx skb 0x%p, pdulen %u\n",
+				conn, csk, skb, cxgb4i_skb_rx_pdulen(skb));
+		if (cxgb4i_skb_flags(skb) & CXGB4I_SKCB_FLAG_HDR_RCVD)
+			err = cxgb4i_conn_read_bhs_pdu_skb(conn, skb);
+		else if (cxgb4i_skb_flags(skb) == CXGB4I_SKCB_FLAG_DATA_RCVD)
+			err = cxgb4i_conn_read_data_pdu_skb(conn, skb);
+		__kfree_skb(skb);
+		skb = skb_peek(&csk->receive_queue);
+	}
+	read_unlock(&csk->callback_lock);
+	csk->copied_seq += read;
+	cxgb4i_sock_rx_credits(csk, read);
+	conn->rxdata_octets += read;
+
+	if (err) {
+		cxgb4i_log_info("conn 0x%p rx failed err %d.\n", conn, err);
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+	}
+}
+
+void cxgbi_conn_tx_open(struct cxgb4i_sock *csk)
+{
+	struct iscsi_conn *conn = csk->user_data;
+
+	if (conn) {
+		cxgb4i_tx_debug("cn 0x%p, cid %d.\n", csk, conn->id);
+		iscsi_conn_queue_work(conn);
+	}
+}
+
diff --git a/drivers/scsi/cxgb4i/libcxgbi.h b/drivers/scsi/cxgb4i/libcxgbi.h
new file mode 100644
index 0000000..e6c12c6
--- /dev/null
+++ b/drivers/scsi/cxgb4i/libcxgbi.h
@@ -0,0 +1,61 @@
+/*
+ * libcxgbi.h: Chelsio common library for T3/T4 iSCSI ULD.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#ifndef	__CXGB4I_PDU_H__
+#define	__CXGB4I_PDU_H__
+
+struct cpl_rx_data_ddp {
+	union opcode_tid ot;
+	__be16 urg;
+	__be16 len;
+	__be32 seq;
+	union {
+		__be32 nxt_seq;
+		__be32 ddp_report;
+	};
+	__be32 ulp_crc;
+	__be32 ddpvld;
+};
+
+#define RX_DDP_STATUS_IPP_SHIFT		27      /* invalid pagepod */
+#define RX_DDP_STATUS_TID_SHIFT		26      /* tid mismatch */
+#define RX_DDP_STATUS_COLOR_SHIFT	25      /* color mismatch */
+#define RX_DDP_STATUS_OFFSET_SHIFT	24      /* offset mismatch */
+#define RX_DDP_STATUS_ULIMIT_SHIFT	23      /* ulimit error */
+#define RX_DDP_STATUS_TAG_SHIFT		22      /* tag mismatch */
+#define RX_DDP_STATUS_DCRC_SHIFT	21      /* dcrc error */
+#define RX_DDP_STATUS_HCRC_SHIFT	20      /* hcrc error */
+#define RX_DDP_STATUS_PAD_SHIFT		19      /* pad error */
+#define RX_DDP_STATUS_PPP_SHIFT		18      /* pagepod parity error */
+#define RX_DDP_STATUS_LLIMIT_SHIFT	17      /* llimit error */
+#define RX_DDP_STATUS_DDP_SHIFT		16      /* ddp'able */
+#define RX_DDP_STATUS_PMM_SHIFT		15      /* pagepod mismatch */
+
+
+#define ULP2_FLAG_DATA_READY		0x1
+#define ULP2_FLAG_DATA_DDPED		0x2
+#define ULP2_FLAG_HCRC_ERROR		0x4
+#define ULP2_FLAG_DCRC_ERROR		0x8
+#define ULP2_FLAG_PAD_ERROR		0x10
+
+void cxgbi_conn_closing(struct cxgb4i_sock *);
+void cxgbi_conn_pdu_ready(struct cxgb4i_sock *);
+void cxgbi_conn_tx_open(struct cxgb4i_sock *);
+
+int cxgbi_init_pdu(struct iscsi_task *, unsigned int, unsigned int);
+int cxgbi_alloc_pdu(struct iscsi_task *, u8);
+int cxgbi_xmit_pdu(struct iscsi_task *);
+
+
+#endif	/*__CXGB4I_PDU_H__*/
+
-- 
1.6.6.1

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
