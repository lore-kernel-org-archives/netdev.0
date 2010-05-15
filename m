From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] cxgb4i_v3: iscsi and libcxgbi library for handling common part
Date: Sat, 15 May 2010 22:54:09 +0530
Message-ID: <1273944249-311-4-git-send-email-rakesh@chelsio.com>
References: <1273944249-311-1-git-send-email-rakesh@chelsio.com>
 <1273944249-311-2-git-send-email-rakesh@chelsio.com>
 <1273944249-311-3-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        OISCSIML <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxDCsrvfBBoESIM7LA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1273944249-311-3-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
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

From: Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/cxgb4i/cxgb4i_iscsi.c |  617 ++++++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb4i/libcxgbi.c     |  589 ++++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb4i/libcxgbi.h     |  430 +++++++++++++++++++++++++
 3 files changed, 1636 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_iscsi.c
 create mode 100644 drivers/scsi/cxgb4i/libcxgbi.c
 create mode 100644 drivers/scsi/cxgb4i/libcxgbi.h

diff --git a/drivers/scsi/cxgb4i/cxgb4i_iscsi.c b/drivers/scsi/cxgb4i/cxgb4i_iscsi.c
new file mode 100644
index 0000000..a10ab6d
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_iscsi.c
@@ -0,0 +1,617 @@
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
+struct cxgbi_hba *cxgb4i_hba_add(struct cxgb4i_snic *snic,
+					struct net_device *dev)
+{
+	struct cxgbi_hba *chba;
+	struct Scsi_Host *shost;
+	int err;
+
+	shost = iscsi_host_alloc(&cxgb4i_host_template, sizeof(*chba), 1);
+
+	if (!shost) {
+		cxgbi_log_info("snic 0x%p, ndev 0x%p, host alloc failed\n",
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
+	cxgbi_log_debug("snic %p, cdev %p\n", snic, &snic->cdev);
+	chba->cdev = &snic->cdev;
+	chba->ndev = dev;
+	chba->shost = shost;
+
+	pci_dev_get(snic->lldi.pdev);
+	err = iscsi_host_add(shost, &snic->lldi.pdev->dev);
+	if (err) {
+		cxgbi_log_info("snic 0x%p, dev 0x%p, host add failed\n",
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
+void cxgb4i_hba_remove(struct cxgbi_hba *chba)
+{
+	iscsi_host_remove(chba->shost);
+	pci_dev_put(cxgb4i_get_snic(chba->cdev)->lldi.pdev);
+	iscsi_host_free(chba->shost);
+}
+
+static struct iscsi_endpoint *cxgb4i_ep_connect(struct Scsi_Host *shost,
+						struct sockaddr *dst_addr,
+						int non_blocking)
+{
+	struct iscsi_endpoint *iep;
+	struct cxgbi_endpoint *cep;
+	struct cxgbi_hba *hba = NULL;
+	struct cxgbi_sock *csk = NULL;
+	struct cxgb4i_snic *snic;
+	int err = 0;
+
+	if (shost)
+		hba = iscsi_host_priv(shost);
+
+	snic = cxgb4i_find_snic(hba ? hba->ndev : NULL,
+			((struct sockaddr_in *)dst_addr)->sin_addr.s_addr);
+	if (!snic) {
+		cxgbi_log_info("ep connect no snic\n");
+		err = -ENOSPC;
+		goto release_conn;
+	}
+
+	csk = cxgb4i_sock_create(snic);
+	if (!csk) {
+		cxgbi_log_info("ep connect OOM\n");
+		err = -ENOMEM;
+		goto release_conn;
+	}
+	err = cxgb4i_sock_connect(hba ? hba->ndev : NULL, csk,
+				(struct sockaddr_in *)dst_addr);
+	if (err < 0) {
+		cxgbi_log_info("ep connect failed\n");
+		goto release_conn;
+	}
+
+	hba = cxgb4i_hba_find_by_netdev(csk->dst->dev);
+	if (!hba) {
+		err = -ENOSPC;
+		cxgbi_log_info("Not going through cxgb4i device\n");
+		goto release_conn;
+	}
+
+	if (shost && hba != iscsi_host_priv(shost)) {
+		err = -ENOSPC;
+		cxgbi_log_info("Could not connect through request host %u\n",
+				shost->host_no);
+		goto release_conn;
+	}
+
+	if (cxgbi_sock_is_closing(csk)) {
+		err = -ENOSPC;
+		cxgbi_log_info("ep connect unable to connect\n");
+		goto release_conn;
+	}
+
+	iep = iscsi_create_endpoint(sizeof(*cep));
+	if (!iep) {
+		err = -ENOMEM;
+		cxgbi_log_info("iscsi alloc ep, OOM\n");
+		goto release_conn;
+	}
+
+	cep = iep->dd_data;
+	cep->csk = csk;
+	cep->chba = hba;
+
+	cxgbi_api_debug("iep 0x%p, cep 0x%p, csk 0x%p, hba 0x%p\n",
+			iep, cep, csk, hba);
+
+	return iep;
+
+release_conn:
+	cxgbi_api_debug("conn 0x%p failed, release\n", csk);
+	if (csk)
+		cxgb4i_sock_release(csk);
+
+	return ERR_PTR(err);
+}
+
+static int cxgb4i_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
+{
+	struct cxgbi_endpoint *cep = ep->dd_data;
+	struct cxgbi_sock *csk = cep->csk;
+
+	if (!cxgbi_sock_is_established(csk))
+		return 0;
+
+	return 1;
+}
+
+static void cxgb4i_ep_disconnect(struct iscsi_endpoint *ep)
+{
+	struct cxgbi_endpoint *cep = ep->dd_data;
+	struct cxgbi_conn *cconn = cep->cconn;
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
+	struct cxgbi_endpoint *cep;
+	struct cxgbi_hba *chba;
+	struct Scsi_Host *shost;
+	struct iscsi_cls_session *cls_session;
+	struct iscsi_session *session;
+
+	if (!ep) {
+		cxgbi_log_error("missing endpoint\n");
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
+					sizeof(struct cxgbi_task_data),
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
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	unsigned int max = max(512 * MAX_SKB_FRAGS, SKB_TX_HEADROOM);
+
+	max = min(cxgb4i_get_snic(cconn->chba->cdev)->tx_max_size, max);
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
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	unsigned int max = cxgb4i_get_snic(cconn->chba->cdev)->rx_max_size;
+
+	cxgb4i_align_pdu_size(max);
+
+	if (conn->max_recv_dlength) {
+		if (conn->max_recv_dlength > max) {
+			cxgbi_log_error("MaxRecvDataSegmentLength %u too big."
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
+	struct cxgbi_conn *cconn;
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
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct iscsi_endpoint *ep;
+	struct cxgbi_endpoint *cep;
+	struct cxgbi_sock *csk;
+	int err;
+
+	ep = iscsi_lookup_endpoint(transport_eph);
+	if (!ep)
+		return -EINVAL;
+
+	/*  setup ddp pagesize */
+	cep = ep->dd_data;
+	csk = cep->csk;
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
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_sock *csk = cconn->cep->csk;
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
+	struct cxgbi_hba *chba = iscsi_host_priv(shost);
+
+	if (!chba->ndev) {
+		shost_printk(KERN_ERR, shost, "Could not set host param. "
+				"Netdev for host not set\n");
+		return -ENODEV;
+	}
+
+	cxgbi_api_debug("param %d, buff %s\n", param, buff);
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
+	struct cxgbi_hba *chba = iscsi_host_priv(shost);
+	int len = 0;
+
+	if (!chba->ndev) {
+		shost_printk(KERN_ERR, shost, "Could not set host param. "
+				"Netdev for host not set\n");
+		return -ENODEV;
+	}
+
+	cxgbi_api_debug("hba %s, param %d\n", chba->ndev->name, param);
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
+			ISCSI_TGT_RESET_TMO | ISCSI_PING_TMO | \
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
+	.cleanup_task			= cxgbi_cleanup_task,
+
+	.alloc_pdu			= cxgbi_conn_alloc_pdu,
+	.init_pdu			= cxgbi_conn_init_pdu,
+	.xmit_pdu			= cxgbi_conn_xmit_pdu,
+	.parse_pdu_itt			= cxgbi_parse_pdu_itt,
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
+		cxgbi_log_error("Could not register cxgb4i transport\n");
+		return -ENODATA;
+	}
+
+	return 0;
+}
+
+void cxgb4i_iscsi_cleanup(void)
+{
+	if (cxgb4i_scsi_transport) {
+		cxgbi_api_debug("cxgb4i transport 0x%p removed\n",
+				cxgb4i_scsi_transport);
+		iscsi_unregister_transport(&cxgb4i_iscsi_transport);
+	}
+}
+
diff --git a/drivers/scsi/cxgb4i/libcxgbi.c b/drivers/scsi/cxgb4i/libcxgbi.c
new file mode 100644
index 0000000..98f904b
--- /dev/null
+++ b/drivers/scsi/cxgb4i/libcxgbi.c
@@ -0,0 +1,589 @@
+/*
+ * libcxgbi.c: Chelsio common library for T3/T4 iSCSI driver.
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
+#include <linux/scatterlist.h>
+#include <linux/pci.h>
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_host.h>
+
+#include "libcxgbi.h"
+
+/* always allocate rooms for AHS */
+#define SKB_TX_PDU_HEADER_LEN	\
+	(sizeof(struct iscsi_hdr) + ISCSI_MAX_AHS_SIZE)
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
+int cxgbi_conn_read_bhs_pdu_skb(struct iscsi_conn *conn,
+					struct sk_buff *skb)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+
+	int rc;
+
+	cxgbi_rx_debug("conn 0x%p, skb 0x%p, len %u, flag 0x%x.\n",
+			conn, skb, skb->len, cdev->get_skb_ulp_mode(skb));
+
+	if (!iscsi_tcp_recv_segment_is_hdr(tcp_conn)) {
+		iscsi_conn_failure(conn, ISCSI_ERR_PROTO);
+		return -EIO;
+	}
+
+	if (conn->hdrdgst_en && (cdev->get_skb_ulp_mode(skb)
+				& ULP2_FLAG_HCRC_ERROR)) {
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
+int cxgbi_conn_read_data_pdu_skb(struct iscsi_conn *conn,
+				    struct sk_buff *skb)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	bool offloaded = 0;
+	unsigned int offset = 0;
+	int rc;
+
+	cxgbi_rx_debug("conn 0x%p, skb 0x%p, len %u, flag 0x%x.\n",
+			conn, skb, skb->len, cdev->get_skb_ulp_mode(skb));
+
+	if (conn->datadgst_en &&
+		(cdev->get_skb_ulp_mode(skb) & ULP2_FLAG_DCRC_ERROR)) {
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
+	if (cdev->get_skb_ulp_mode(skb) & ULP2_FLAG_DATA_DDPED) {
+		cxgbi_rx_debug("skb 0x%p, opcode 0x%x, data %u, ddp'ed, "
+				"itt 0x%x.\n",
+				skb,
+				tcp_conn->in.hdr->opcode & ISCSI_OPCODE_MASK,
+				tcp_conn->in.datalen,
+				ntohl(tcp_conn->in.hdr->itt));
+		offloaded = 1;
+	} else {
+		cxgbi_rx_debug("skb 0x%p, opcode 0x%x, data %u, NOT ddp'ed, "
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
+				cxgbi_log_error("sg NULL, len %u/%u.\n",
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
+				cxgbi_log_error("too many pages %u, "
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
+int cxgbi_conn_alloc_pdu(struct iscsi_task *task, u8 opcode)
+{
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgbi_task_data *tdata = task->dd_data + sizeof(*tcp_task);
+	struct scsi_cmnd *sc = task->sc;
+	int headroom = SKB_TX_PDU_HEADER_LEN;
+
+	tcp_task->dd_data = tdata;
+	task->hdr = NULL;
+
+	/* write command, need to send data pdus */
+	if (cdev->skb_extra_headroom && (opcode == ISCSI_OP_SCSI_DATA_OUT ||
+	    (opcode == ISCSI_OP_SCSI_CMD &&
+	    (scsi_bidi_cmnd(sc) || sc->sc_data_direction == DMA_TO_DEVICE))))
+		headroom += min(cdev->skb_extra_headroom,
+					conn->max_xmit_dlength);
+
+	tdata->skb = alloc_skb(cdev->skb_tx_headroom + headroom, GFP_ATOMIC);
+	if (!tdata->skb)
+		return -ENOMEM;
+	skb_reserve(tdata->skb, cdev->skb_tx_headroom);
+
+	cxgbi_tx_debug("task 0x%p, opcode 0x%x, skb 0x%p.\n",
+			task, opcode, tdata->skb);
+
+	task->hdr = (struct iscsi_hdr *)tdata->skb->data;
+	task->hdr_max = SKB_TX_PDU_HEADER_LEN;
+
+	/* data_out uses scsi_cmd's itt */
+	if (opcode != ISCSI_OP_SCSI_DATA_OUT)
+		cxgbi_reserve_itt(task, &task->hdr->itt);
+
+	return 0;
+}
+
+int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
+			      unsigned int count)
+{
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct sk_buff *skb = tdata->skb;
+	unsigned int datalen = count;
+	int i, padlen = iscsi_padding(count);
+	struct page *pg;
+
+	cxgbi_tx_debug("task 0x%p,0x%p, offset %u, count %u, skb 0x%p.\n",
+			task, task->sc, offset, count, skb);
+
+	skb_put(skb, task->hdr_len);
+	cdev->tx_skb_setmode(skb, conn->hdrdgst_en,
+				datalen ? conn->datadgst_en : 0);
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
+			cxgbi_log_warn("tpdu, sgl %u, bad offset %u/%u.\n",
+					sdb->table.nents, tdata->offset,
+					sdb->length);
+			return err;
+		}
+		err = sgl_read_to_frags(sg, tdata->sgoffset, tdata->count,
+					tdata->frags, MAX_PDU_FRAGS);
+		if (err < 0) {
+			cxgbi_log_warn("tpdu, sgl %u, bad offset %u + %u.\n",
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
+		get_page(cdev->pad_page);
+		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+					cdev->pad_page, 0, padlen);
+
+		skb->data_len += padlen;
+		skb->truesize += padlen;
+		skb->len += padlen;
+	}
+
+	return 0;
+}
+
+int cxgbi_conn_xmit_pdu(struct iscsi_task *task)
+{
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	struct iscsi_tcp_task *tcp_task = task->dd_data;
+	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct sk_buff *skb = tdata->skb;
+	unsigned int datalen;
+	int err;
+
+	if (!skb)
+		return 0;
+
+	datalen = skb->data_len;
+	tdata->skb = NULL;
+	err = cdev->sock_send_pdus(cconn->cep->csk, skb);
+	if (err > 0) {
+		int pdulen = err;
+
+		cxgbi_tx_debug("task 0x%p, skb 0x%p, len %u/%u, rv %d.\n",
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
+	cxgbi_tx_debug("itt 0x%x, skb 0x%p, len %u/%u, xmit err %d.\n",
+			task->itt, skb, skb->len, skb->data_len, err);
+	iscsi_conn_printk(KERN_ERR, task->conn, "xmit err %d.\n", err);
+	iscsi_conn_failure(task->conn, ISCSI_ERR_XMIT_FAILED);
+	return err;
+}
+
+int cxgbi_pdu_init(struct cxgbi_device *cdev)
+{
+	if (cdev->skb_tx_headroom > (512 * MAX_SKB_FRAGS))
+		cdev->skb_extra_headroom = cdev->skb_tx_headroom;
+	cdev->pad_page = alloc_page(GFP_KERNEL);
+	if (cdev->pad_page)
+		return -ENOMEM;
+	memset(page_address(cdev->pad_page), 0, PAGE_SIZE);
+	return 0;
+
+	/*
+	if (SKB_TX_HEADROOM > (512 * MAX_SKB_FRAGS))
+		skb_extra_headroom = SKB_TX_HEADROOM;
+	pad_page = alloc_page(GFP_KERNEL);
+	if (!pad_page)
+		return -ENOMEM;
+	memset(page_address(pad_page), 0, PAGE_SIZE);
+	return 0;*/
+}
+
+void cxgbi_pdu_cleanup(struct cxgbi_device *cdev)
+{
+	if (cdev->pad_page) {
+		__free_page(cdev->pad_page);
+		cdev->pad_page = NULL;
+	}
+}
+
+void cxgbi_conn_tx_open(struct cxgbi_sock *csk)
+{
+	struct iscsi_conn *conn = csk->user_data;
+
+	if (conn) {
+		cxgbi_tx_debug("cn 0x%p, cid %d.\n", csk, conn->id);
+		iscsi_conn_queue_work(conn);
+	}
+}
+
+int cxgbi_sock_get_port(struct cxgbi_sock *csk)
+{
+	unsigned int start;
+	int idx;
+
+	if (!csk->cdev->pmap)
+		goto error_out;
+
+	if (csk->saddr.sin_port) {
+		cxgbi_log_error("connect, sin_port none ZERO %u\n",
+				ntohs(csk->saddr.sin_port));
+		return -EADDRINUSE;
+	}
+
+	spin_lock_bh(&csk->cdev->pmap->lock);
+	start = idx = csk->cdev->pmap->next;
+
+	do {
+		if (++idx >= csk->cdev->pmap->max_connect)
+			idx = 0;
+		if (!csk->cdev->pmap->port_csk[idx]) {
+			csk->saddr.sin_port =
+				htons(csk->cdev->pmap->sport_base + idx);
+			csk->cdev->pmap->next = idx;
+			csk->cdev->pmap->port_csk[idx] = csk;
+			spin_unlock_bh(&csk->cdev->pmap->lock);
+
+			cxgbi_conn_debug("reserved port %u\n",
+					csk->cdev->pmap->sport_base + idx);
+
+			return 0;
+		}
+	} while (idx != start);
+	spin_unlock_bh(&csk->cdev->pmap->lock);
+
+error_out:
+	return -EADDRNOTAVAIL;
+}
+
+void cxgbi_sock_put_port(struct cxgbi_sock *csk)
+{
+	if (csk->saddr.sin_port) {
+		int idx = ntohs(csk->saddr.sin_port) -
+			csk->cdev->pmap->sport_base;
+
+		csk->saddr.sin_port = 0;
+		if (idx < 0 || idx >= csk->cdev->pmap->max_connect)
+			return;
+
+		spin_lock_bh(&csk->cdev->pmap->lock);
+		csk->cdev->pmap->port_csk[idx] = NULL;
+		spin_unlock_bh(&csk->cdev->pmap->lock);
+
+		cxgbi_conn_debug("released port %u\n",
+				csk->cdev->pmap->sport_base + idx);
+	}
+}
+
+void cxgbi_release_itt(struct iscsi_task *task, itt_t hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	struct cxgbi_tag_format *tformat = &cdev->tag_format;
+	u32 tag = ntohl((__force u32)hdr_itt);
+
+	cxgbi_tag_debug("release tag 0x%x.\n", tag);
+
+	if (sc &&
+		(scsi_bidi_cmnd(sc) ||
+		 sc->sc_data_direction == DMA_FROM_DEVICE) &&
+			cxgbi_is_ddp_tag(tformat, tag))
+		cdev->ddp_tag_release(cdev, tag);
+}
+
+
+int cxgbi_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_session *sess = conn->session;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	struct cxgbi_tag_format *tformat = &cdev->tag_format;
+	u32 sw_tag = (sess->age << cconn->task_idx_bits) | task->itt;
+	u32 tag;
+	int err = -EINVAL;
+
+	if (sc &&
+		(scsi_bidi_cmnd(sc) ||
+		 sc->sc_data_direction == DMA_FROM_DEVICE) &&
+			cxgbi_sw_tag_usable(tformat, sw_tag)) {
+
+		struct cxgbi_sock *csk = cconn->cep->csk;
+		struct cxgbi_gather_list *gl;
+
+		gl = cdev->ddp_make_gl(scsi_in(sc)->length,
+					scsi_in(sc)->table.sgl,
+					scsi_in(sc)->table.nents,
+					cdev->pdev, GFP_ATOMIC);
+		if (gl) {
+			tag = sw_tag;
+			err = cdev->ddp_tag_reserve(cdev, csk->hwtid,
+							tformat, &tag,
+							gl, GFP_ATOMIC);
+			if (err < 0)
+				cdev->ddp_release_gl(gl, cdev->pdev);
+		}
+	}
+	if (err < 0)
+		tag = cxgbi_set_non_ddp_tag(tformat, sw_tag);
+	/*  the itt need to sent in big-endian order */
+	*hdr_itt = (__force itt_t)htonl(tag);
+
+	cxgbi_tag_debug("new sc 0x%p tag 0x%x/0x%x (itt 0x%x, age 0x%x).\n",
+			sc, tag, *hdr_itt, task->itt, sess->age);
+	return 0;
+}
+
+
+void cxgbi_parse_pdu_itt(struct iscsi_conn *conn, itt_t itt,
+				int *idx, int *age)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgbi_conn *cconn = tcp_conn->dd_data;
+	struct cxgbi_device *cdev = cconn->chba->cdev;
+	u32 tag = ntohl((__force u32) itt);
+	u32 sw_bits;
+
+	sw_bits = cxgbi_tag_nonrsvd_bits(&cdev->tag_format, tag);
+	if (idx)
+		*idx = sw_bits & ((1 << cconn->task_idx_bits) - 1);
+	if (age)
+		*age = (sw_bits >> cconn->task_idx_bits) & ISCSI_AGE_MASK;
+
+	cxgbi_tag_debug("parse tag 0x%x/0x%x, sw 0x%x, itt 0x%x, age 0x%x.\n",
+			tag, itt, sw_bits, idx ? *idx : 0xFFFFF,
+			age ? *age : 0xFF);
+}
+
+void cxgbi_cleanup_task(struct iscsi_task *task)
+{
+	struct cxgbi_task_data *tdata = task->dd_data +
+				sizeof(struct iscsi_tcp_task);
+
+	/*  never reached the xmit task callout */
+	if (tdata->skb)
+		__kfree_skb(tdata->skb);
+	memset(tdata, 0, sizeof(*tdata));
+
+	cxgbi_release_itt(task, task->hdr_itt);
+	iscsi_tcp_cleanup_task(task);
+}
+
diff --git a/drivers/scsi/cxgb4i/libcxgbi.h b/drivers/scsi/cxgb4i/libcxgbi.h
new file mode 100644
index 0000000..058a9aa
--- /dev/null
+++ b/drivers/scsi/cxgb4i/libcxgbi.h
@@ -0,0 +1,430 @@
+/*
+ * libcxgbi.h: Chelsio common library for T3/T4 iSCSI driver.
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
+#ifndef	__LIBCXGBI_H__
+#define	__LIBCXGBI_H__
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/scatterlist.h>
+#include <linux/skbuff.h>
+#include <scsi/libiscsi_tcp.h>
+
+
+#define	cxgbi_log_error(fmt...)	printk(KERN_ERR "cxgbi: ERR! " fmt)
+#define cxgbi_log_warn(fmt...)	printk(KERN_WARNING "cxgbi: WARN! " fmt)
+#define cxgbi_log_info(fmt...)	printk(KERN_INFO "cxgbi: " fmt)
+#define cxgbi_debug_log(fmt, args...) \
+	printk(KERN_INFO "cxgbi: %s - " fmt, __func__ , ## args)
+
+
+#ifdef	__DEBUG_CXGB4I__
+#define	cxgbi_log_debug	cxgbi_debug_log
+#else
+#define cxgbi_log_debug(fmt...)
+#endif
+
+#ifdef __DEBUG_CXGB4I_TAG__
+#define cxgbi_tag_debug        cxgbi_log_debug
+#else
+#define cxgbi_tag_debug(fmt...)
+#endif
+
+#ifdef __DEBUG_CXGB4I_API__
+#define cxgbi_api_debug        cxgbi_log_debug
+#else
+#define cxgbi_api_debug(fmt...)
+#endif
+
+#ifdef __DEBUG_CXGB4I_CONN__
+#define cxgbi_conn_debug         cxgbi_log_debug
+#else
+#define cxgbi_conn_debug(fmt...)
+#endif
+
+#ifdef __DEBUG_CXGB4I_TX__
+#define cxgbi_tx_debug           cxgbi_log_debug
+#else
+#define cxgbi_tx_debug(fmt...)
+#endif
+
+#ifdef __DEBUG_CXGB4I_RX__
+#define cxgbi_rx_debug           cxgbi_log_debug
+#else
+#define cxgbi_rx_debug(fmt...)
+#endif
+
+#define	ISCSI_PDU_NONPAYLOAD_LEN	312 /* bhs(48) + ahs(256) + digest(8)*/
+#define ULP2_MAX_PKT_SIZE		16224
+#define ULP2_MAX_PDU_PAYLOAD	\
+	(ULP2_MAX_PKT_SIZE - ISCSI_PDU_NONPAYLOAD_LEN)
+
+/* # of pages a pagepod can hold without needing another pagepod */
+#define PPOD_PAGES			4
+#define PPOD_PAGES_MAX			4
+#define PPOD_PAGES_SHIFT		2       /*  4 pages per pod */
+
+
+struct cxgbi_tag_format {
+	unsigned char sw_bits;
+	unsigned char rsvd_bits;
+	unsigned char rsvd_shift;
+	unsigned char filler[1];
+	unsigned int rsvd_mask;
+};
+
+struct cxgbi_gather_list {
+	unsigned int tag;
+	unsigned int length;
+	unsigned int offset;
+	unsigned int nelem;
+	struct page **pages;
+	dma_addr_t phys_addr[0];
+};
+
+struct cxgbi_sock {
+	struct net_device *egdev;
+	struct cxgbi_device *cdev;
+
+	unsigned long flags;
+	unsigned int qset;
+	unsigned int rss_qid;
+
+	unsigned int hwtid;
+	unsigned int atid;
+
+	unsigned int tx_chan;
+	unsigned int rx_chan;
+	unsigned int mss_idx;
+	unsigned int smac_idx;
+	unsigned char port_id;
+
+	void *l2t;
+
+	int wr_max_cred;
+	int wr_cred;
+	int wr_una_cred;
+
+	struct sk_buff *wr_pending_head;
+	struct sk_buff *wr_pending_tail;
+	struct sk_buff *cpl_close;
+	struct sk_buff *cpl_abort_req;
+	struct sk_buff *cpl_abort_rpl;
+	struct sk_buff *skb_ulp_lhdr;
+	spinlock_t lock;
+	atomic_t refcnt;
+	volatile unsigned int state;
+	struct sockaddr_in saddr;
+	struct sockaddr_in daddr;
+	struct dst_entry *dst;
+	struct sk_buff_head receive_queue;
+	struct sk_buff_head write_queue;
+	struct timer_list retry_timer;
+	int err;
+	rwlock_t callback_lock;
+	void *user_data;
+
+	u32 rcv_nxt;
+	u32 copied_seq;
+	u32 rcv_wup;
+	u32 snd_nxt;
+	u32 snd_una;
+	u32 write_seq;
+};
+
+enum cxgbi_sock_states{
+	CXGBI_CSK_ST_CONNECTING = 1,
+	CXGBI_CSK_ST_ESTABLISHED,
+	CXGBI_CSK_ST_ACTIVE_CLOSE,
+	CXGBI_CSK_ST_PASSIVE_CLOSE,
+	CXGBI_CSK_ST_CLOSE_WAIT_1,
+	CXGBI_CSK_ST_CLOSE_WAIT_2,
+	CXGBI_CSK_ST_ABORTING,
+	CXGBI_CSK_ST_CLOSED,
+};
+
+enum cxgbi_sock_flags {
+	CXGBI_CSK_FL_ABORT_RPL_RCVD,	/*received one ABORT_RPL_RSS message */
+	CXGBI_CSK_FL_ABORT_REQ_RCVD,	/*received one ABORT_REQ_RSS message */
+	CXGBI_CSK_FL_ABORT_RPL_PENDING,	/* expecting an abort reply */
+	CXGBI_CSK_FL_TX_DATA_SENT,	/* already sent a TX_DATA WR */
+	CXGBI_CSK_FL_ACTIVE_CLOSE_NEEDED,	/* need to be closed */
+	CXGBI_CSK_FL_OFFLOAD_DOWN,		/* offload function off */
+};
+
+static inline void cxgbi_sock_set_flag(struct cxgbi_sock *csk,
+					enum cxgbi_sock_flags flag)
+{
+	__set_bit(flag, &csk->flags);
+	cxgbi_conn_debug("csk 0x%p, set %d, state %u, flags 0x%lu\n",
+			csk, flag, csk->state, csk->flags);
+}
+
+static inline void cxgbi_sock_clear_flag(struct cxgbi_sock *csk,
+					enum cxgbi_sock_flags flag)
+{
+	__clear_bit(flag, &csk->flags);
+	cxgbi_conn_debug("csk 0x%p, clear %d, state %u, flags 0x%lu\n",
+			csk, flag, csk->state, csk->flags);
+}
+
+static inline int cxgbi_sock_flag(struct cxgbi_sock *csk,
+				enum cxgbi_sock_flags flag)
+{
+	if (csk == NULL)
+		return 0;
+
+	return test_bit(flag, &csk->flags);
+}
+
+static inline void cxgbi_sock_set_state(struct cxgbi_sock *csk, int state)
+{
+	csk->state = state;
+}
+
+static inline void cxgbi_sock_hold(struct cxgbi_sock *csk)
+{
+	atomic_inc(&csk->refcnt);
+}
+
+static inline void cxgbi_sock_put(struct cxgbi_sock *csk)
+{
+	if (atomic_dec_and_test(&csk->refcnt)) {
+		cxgbi_conn_debug("free csk 0x%p, state %u, flags 0x%lx\n",
+				csk, csk->state, csk->flags);
+		kfree(csk);
+	}
+}
+
+static inline unsigned int cxgbi_sock_is_closing(
+			const struct cxgbi_sock *csk)
+{
+	return csk->state >= CXGBI_CSK_ST_ACTIVE_CLOSE;
+}
+
+static inline unsigned int cxgbi_sock_is_established(
+				const struct cxgbi_sock *csk)
+{
+	return csk->state == CXGBI_CSK_ST_ESTABLISHED;
+}
+
+int cxgbi_sock_get_port(struct cxgbi_sock *);
+void cxgbi_sock_put_port(struct cxgbi_sock *);
+
+struct cxgbi_hba {
+	struct net_device *ndev;
+	struct Scsi_Host *shost;
+	struct cxgbi_device *cdev;
+	__be32 ipv4addr;
+};
+
+struct cxgbi_ports_map {
+	unsigned int max_connect;
+	unsigned short sport_base;
+	spinlock_t lock;
+	unsigned int next;
+	struct cxgbi_sock *port_csk[0];
+};
+
+struct cxgbi_device {
+	struct list_head list_head;
+	struct net_device *ndev;
+	struct pci_dev *pdev;
+	unsigned int skb_tx_headroom;
+	unsigned int skb_extra_headroom;
+	struct page *pad_page;
+
+	void (*tx_skb_setmode)(struct sk_buff *, int, int);
+	int (*sock_send_pdus)(struct cxgbi_sock *, struct sk_buff *);
+	int (*ddp_tag_reserve)(struct cxgbi_device *, unsigned int,
+				struct cxgbi_tag_format *, u32 *,
+				struct cxgbi_gather_list *, gfp_t);
+	void (*ddp_tag_release)(struct cxgbi_device *, u32);
+	struct cxgbi_gather_list* (*ddp_make_gl)(unsigned int,
+						struct scatterlist *,
+						unsigned int,
+						struct pci_dev *,
+						gfp_t);
+	void (*ddp_release_gl)(struct cxgbi_gather_list *, struct pci_dev *);
+	__u16 (*get_skb_ulp_mode)(struct sk_buff *);
+
+	struct cxgbi_tag_format tag_format;
+	struct cxgbi_ports_map *pmap;
+
+	void *dd_data;
+};
+
+struct cxgbi_conn {
+	struct list_head list_head;
+	struct cxgbi_endpoint *cep;
+	struct iscsi_conn *iconn;
+	struct cxgbi_hba *chba;
+	u32 task_idx_bits;
+};
+
+struct cxgbi_endpoint {
+	struct cxgbi_conn *cconn;
+	struct cxgbi_hba *chba;
+	struct cxgbi_sock *csk;
+};
+
+#define MAX_PDU_FRAGS	((ULP2_MAX_PDU_PAYLOAD + 512 - 1) / 512)
+struct cxgbi_task_data {
+	unsigned short nr_frags;
+	skb_frag_t frags[MAX_PDU_FRAGS];
+	struct sk_buff *skb;
+	unsigned int offset;
+	unsigned int count;
+	unsigned int sgoffset;
+};
+
+static inline int cxgbi_is_ddp_tag(struct cxgbi_tag_format *tformat, u32 tag)
+{
+	return !(tag & (1 << (tformat->rsvd_bits + tformat->rsvd_shift - 1)));
+}
+
+static inline int cxgbi_sw_tag_usable(struct cxgbi_tag_format *tformat,
+					u32 sw_tag)
+{
+	sw_tag >>= (32 - tformat->rsvd_bits);
+	return !sw_tag;
+}
+
+static inline u32 cxgbi_set_non_ddp_tag(struct cxgbi_tag_format *tformat,
+					u32 sw_tag)
+{
+	unsigned char shift = tformat->rsvd_bits + tformat->rsvd_shift - 1;
+
+	u32 mask = (1 << shift) - 1;
+
+	if (sw_tag && (sw_tag & ~mask)) {
+		u32 v1 = sw_tag & ((1 << shift) - 1);
+		u32 v2 = (sw_tag >> (shift - 1)) << shift;
+
+		return v2 | v1 | 1 << shift;
+	}
+
+	return sw_tag | 1 << shift;
+}
+
+static inline u32 cxgbi_ddp_tag_base(struct cxgbi_tag_format *tformat,
+					u32 sw_tag)
+{
+	u32 mask = (1 << tformat->rsvd_shift) - 1;
+
+	if (sw_tag && (sw_tag & ~mask)) {
+		u32 v1 = sw_tag & mask;
+		u32 v2 = sw_tag >> tformat->rsvd_shift;
+
+		v2 <<= tformat->rsvd_bits + tformat->rsvd_shift;
+
+		return v2 | v1;
+	}
+
+	return sw_tag;
+}
+
+static inline u32 cxgbi_tag_rsvd_bits(struct cxgbi_tag_format *tformat,
+					u32 tag)
+{
+	if (cxgbi_is_ddp_tag(tformat, tag))
+		return (tag >> tformat->rsvd_shift) & tformat->rsvd_mask;
+
+	return 0;
+}
+
+static inline u32 cxgbi_tag_nonrsvd_bits(struct cxgbi_tag_format *tformat,
+					u32 tag)
+{
+	unsigned char shift = tformat->rsvd_bits + tformat->rsvd_shift - 1;
+	u32 v1, v2;
+
+	if (cxgbi_is_ddp_tag(tformat, tag)) {
+		v1 = tag & ((1 << tformat->rsvd_shift) - 1);
+		v2 = (tag >> (shift + 1)) << tformat->rsvd_shift;
+	} else {
+		u32 mask = (1 << shift) - 1;
+		tag &= ~(1 << shift);
+		v1 = tag & mask;
+		v2 = (tag >> 1) & ~mask;
+	}
+	return v1 | v2;
+}
+
+static inline void *cxgbi_alloc_big_mem(unsigned int size,
+					gfp_t gfp)
+{
+	void *p = kmalloc(size, gfp);
+	if (!p)
+		p = vmalloc(size);
+	if (p)
+		memset(p, 0, size);
+	return p;
+}
+
+static inline void cxgbi_free_big_mem(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
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
+static inline void *cplhdr(struct sk_buff *skb)
+{
+	return skb->data;
+}
+
+int cxgbi_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt);
+void cxgbi_release_itt(struct iscsi_task *task, itt_t hdr_itt);
+void cxgbi_parse_pdu_itt(struct iscsi_conn *conn, itt_t itt,
+				int *idx, int *age);
+void cxgbi_cleanup_task(struct iscsi_task *task);
+
+int cxgbi_conn_read_bhs_pdu_skb(struct iscsi_conn *, struct sk_buff *);
+int cxgbi_conn_read_data_pdu_skb(struct iscsi_conn *, struct sk_buff *);
+void cxgbi_conn_tx_open(struct cxgbi_sock *);
+int cxgbi_conn_init_pdu(struct iscsi_task *, unsigned int , unsigned int);
+int cxgbi_conn_alloc_pdu(struct iscsi_task *, u8);
+int cxgbi_conn_xmit_pdu(struct iscsi_task *);
+
+int cxgbi_pdu_init(struct cxgbi_device *);
+void cxgbi_pdu_cleanup(struct cxgbi_device *);
+
+
+#endif	/*__LIBCXGBI_H__*/
+
-- 
1.6.6.1

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
