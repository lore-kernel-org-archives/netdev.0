From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 3/9] NetEffect 10Gb RNIC Driver: openfabrics connection manager c file
Date: Thu, 26 Oct 2006 18:58:48 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB8@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:37341 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946034AbWJZX6u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:58:50 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 3 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes_cm.c
new/drivers/infiniband/hw/nes/nes_cm.c
--- old/drivers/infiniband/hw/nes/nes_cm.c	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_cm.c	2006-10-25
10:36:29.000000000 -0500
@@ -0,0 +1,1204 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
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
+#define TCPOPT_TIMESTAMP 8
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+#include <linux/if_arp.h>
+#include <linux/notifier.h>
+#include <linux/net.h>
+#include <linux/types.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+
+#include <net/neighbour.h>
+#include <net/route.h>
+#include <net/ip_fib.h>
+
+#include <rdma/ib_smi.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_pack.h>
+#include <rdma/iw_cm.h>
+
+#include "nes.h"
+
+#define OS_LINUX
+#define OS_LINUX_26
+#include <nes.h>
+#include <nes_sockets.h>
+
+extern unsigned int send_first;
+
+struct nes_v4_quad
+{
+   UINT32   rsvd0;
+   UINT32   DstIpAdrIndex;  /* Only most significant 5 bits are valid
*/
+   UINT32   SrcIpadr;
+   UINT32   TcpPorts; /* src is low, dest is high */
+};
+
+enum ietf_mpa_flags {
+	IETF_MPA_FLAGS_MARKERS = 0x80,	 /* receive Markers */
+    IETF_MPA_FLAGS_CRC = 0x40,	 /* receive Markers */
+    IETF_MPA_FLAGS_REJECT = 0x20,	 /* Reject */
+};
+
+#define IEFT_MPA_KEY_REQ "MPA ID Req Frame"
+#define IEFT_MPA_KEY_REP "MPA ID Rep Frame"
+
+struct ietf_mpa_req_resp_frame {
+	u8 key[16];
+	u8 flags;
+	u8 rev;
+	u16 private_data_size;
+	u8 private_data[0];
+};
+
+static void connect_worker(void *);
+static void listen_worker(void *);
+
+extern int NesAdapterAdd(struct net_device *netdev);
+extern int NesInitSockets(void);
+extern void set_interface(
+				   UINT32    ip_addr,
+				   UINT32    mask,
+				   UINT32    bcastaddr,
+				   UINT32    type
+				  );
+#define ADD_ADDR     1
+#define SET_ADDR     2
+#define DELETE_ADDR  3
+
+extern void bdc_cleanup(void);
+extern int mpa_version;
+
+unsigned char   DriverNamePrefix[] = "iw_nes";
+
+int nes_if_count = 0;
+
+#define MAX_NES_IFS 4
+struct nes_dev *nes_ifs[MAX_NES_IFS]= { 0 };
+
+
+/**
+ * nes_start_cm
+ * 
+ * @param nesdev
+ * @param new_ifa
+ * 
+ * @return int
+ */
+int nes_start_cm(struct nes_dev *nesdev, struct in_ifaddr *new_ifa)
+{
+	int result = 0;
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	nes_ifs[0] = nesdev;
+
+	stack_ops_p->dhcp_control(0x00);
+
+	// set ip and subnet mask
+	stack_ops_p->set_ip_info(ntohl(new_ifa->ifa_address),
+                           ntohl(new_ifa->ifa_mask));
+	stack_ops_p->set_dev_name(nesdev->netdev->name);
+
+	if (nesdev->nes_stack_start == 0) {
+		stack_ops_p->stack_init(nesdev->netdev);
+		/* TODO: Deal with multiple IP addresses */
+		nesdev->local_ipaddr = new_ifa->ifa_address;
+
+		nesdev->nes_stack_start = 1;
+	}
+
+	return result;
+}
+
+
+/**
+ * nes_stop_cm
+ * 
+ * @param nesdev
+ * 
+ * @return int
+ */
+int nes_stop_cm(struct nes_dev *nesdev)
+{
+	if (nesdev->nes_stack_start) 
+	{
+		nesdev->nes_stack_start = 0;
+    stack_ops_p->stack_exit(nesdev->netdev);
+	}
+	return 0;
+}
+
+
+/**
+ * nes_update_arp
+ * 
+ * @param pMacAddress
+ * @param u32IpAddress
+ * @param u32ArpTimeout
+ * @param u16Entry
+ * @param type
+ */
+void nes_update_arp(unsigned char *pMacAddress, u32 u32IpAddress, 
+                    u32 u32ArpTimeout, u16 u16Entry, u16 type)
+{
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_dev *nesdev;
+	unsigned long flags;
+	u32 cqp_head;
+	u16 arp_index;
+
+	if (nes_ifs[0] == NULL) {
+		return;
+	}
+
+	nesdev = nes_ifs[0];
+
+	dprintk("%s: pMacAddress = %p, type = %u.\n", __FUNCTION__,
pMacAddress, type );
+	if (NULL == pMacAddress) {
+		dprintk("%s: Received a Delete request for IP address
0x%08X, index %u).\n", 
+				__FUNCTION__, u32IpAddress, u16Entry );
+		nes_arp_table_update(nesdev, u32IpAddress,
NES_ARP_INDEX_DELETE);
+		return;
+	} else {
+		dprintk("%s: Received an Update request for IP address
0x%08X, index %u, address %02X:%02X:%02X:%02X:%02X:%02X).\n", 
+                __FUNCTION__, u32IpAddress, u16Entry, pMacAddress[0], 
+				pMacAddress[1], pMacAddress[2],
pMacAddress[3], pMacAddress[4],
+				pMacAddress[5]);
+	}
+
+	/* Add the ARP Entry */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_head = nesdev->cqp.sq_head++;
+	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
NES_CQP_MANAGE_ARP_CACHE | NES_CQP_ARP_PERM;
+	arp_index = nes_arp_table_update(nesdev, u32IpAddress,
NES_ARP_INDEX_ADD);
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
(u32)PCI_FUNC(nesdev->pcidev->devfn) << NES_CQP_ARP_AEQ_INDEX_SHIFT;
+//	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=  ((u32)arp_index)
<< NES_CQP_ARP_AEQ_INDEX_SHIFT;
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =  (u32)arp_index;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
cqp_head;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
+	if (1 == type) {
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
NES_CQP_ARP_VALID;
+		cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_ADDR_LOW_IDX] =  
+		  (((u32)pMacAddress[2])<<24) +
(((u32)pMacAddress[3])<<16) +
+		  (((u32)pMacAddress[4])<<8) + (u32)pMacAddress[5];
+		cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_HIGH_IDX] =
(((u32)pMacAddress[0])<<16) + (u32)pMacAddress[1];
+	} else {
+		cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_ADDR_LOW_IDX] =
0;
+		cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_HIGH_IDX] = 0;
+	}
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX]);
+	cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_HIGH_IDX] =
cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_HIGH_IDX]);
+	cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_ADDR_LOW_IDX] =
cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_ARP_WQE_MAC_ADDR_LOW_IDX]);
+
+	barrier();
+	// Ring doorbell (1 WQEs)
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
nesdev->cqp.qp_id );
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+}
+
+
+/**
+ * connect_worker
+ * @param qp
+ */
+static void connect_worker(void *qp)
+{
+    unsigned long qplockflags;
+	UINTPTR socket;
+	struct socket *ksock;
+	struct nes_qp *nesqp = qp;
+	struct nes_dev *nesdev = to_nesdev(nesqp->ibqp.device);
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct iw_cm_id *cm_id = nesqp->cm_id;
+	struct nes_hw_qp_wqe *wqe;
+	struct iw_cm_event cm_event;
+	struct NES_sockaddr_in  inet_addr;
+	struct NES_sockaddr_in new_socket_name;
+	struct nes_v4_quad nes_quad;
+	struct ib_qp_attr attr;
+    struct ietf_mpa_req_resp_frame *req_frame = nesqp->ietf_frame;
+	int kaddr_length;
+    int socket_bytes;
+    int err;
+    u16 resp_private_data_length;
+
+	dprintk("Attempting to connect to  0x%08X:0x%04X on local port
0x%04X.\n", 
+	   ntohl(cm_id->remote_addr.sin_addr.s_addr), 
+	   ntohs(cm_id->remote_addr.sin_port), 
+	   ntohs(cm_id->local_addr.sin_port) );
+
+	memset( &inet_addr, 0, sizeof(inet_addr) );
+	inet_addr.sin_len = sizeof( inet_addr );
+	inet_addr.sin_family = NES_AF_INET;
+	inet_addr.sin_port = cm_id->remote_addr.sin_port;
+	inet_addr.sin_addr.NES_s_addr =
cm_id->remote_addr.sin_addr.s_addr;
+
+	err = stack_ops_p->sock_ops_p->connect(
+						nesqp->socket, 
+						(struct NES_sockaddr
*)&inet_addr,
+						sizeof(inet_addr));
+
+	dprintk("%s: Connect request returned %d.\n", __FUNCTION__,
err);
+
+	if (err < 0) {
+		dprintk("nes connect call returned %d.\n", err );
+        goto conn_err0;
+	}
+
+    /* send the req */
+    strcpy(&req_frame->key[0], IEFT_MPA_KEY_REQ);
+    req_frame->flags = IETF_MPA_FLAGS_CRC;
+    /* TODO: allow configuration of the revision */
+    /* TODO: Set context and registers properly */
+    req_frame->rev = mpa_version;
+
+    /* TODO: add retry logic checking the number of bytes sent */
+    err = stack_ops_p->sock_ops_p->send(nesqp->socket, (char
*)req_frame, 
+
sizeof(*req_frame)+nesqp->private_data_len,0);
+
+    dprintk("%s: Send for MPA request returned %d.\n", __FUNCTION__,
err);
+
+    if (err < 0) {
+        dprintk("nes send call returned %d.\n", err);
+        goto conn_err0;
+    }
+
+    /* receive the reply */
+    socket_bytes = 0;
+    do
+    {
+        err = stack_ops_p->sock_ops_p->recv(nesqp->socket, (char
*)req_frame, sizeof(*req_frame),0);
+
+        dprintk("%s: Recv for MPA reply returned %d.\n", __FUNCTION__,
err);
+
+        if (err < 0) {
+            goto conn_err0;
+        }
+        socket_bytes += err;
+    } while ( socket_bytes < sizeof(*req_frame) );
+
+    if (req_frame->flags&IETF_MPA_FLAGS_MARKERS) {
+        dprintk("%s: Peer specified markers in MPA reply.  Aborting MPA
negotiation\n", 
+                __FUNCTION__ );
+		/* TODO: Should send a reject */
+        goto conn_err0;
+    }
+    if (req_frame->flags&IETF_MPA_FLAGS_CRC) {
+        dprintk("%s: Peer specified CRC in MPA reply.  MPA version =
%u.\n", 
+                __FUNCTION__, req_frame->rev );
+    } else {
+        dprintk("%s: Peer did not specified CRC in MPA reply.  MPA
version = %u.\n", 
+                __FUNCTION__, req_frame->rev );
+	}
+
+    resp_private_data_length =
be16_to_cpu(req_frame->private_data_size);
+    if (resp_private_data_length){
+        if (resp_private_data_length>nesqp->private_data_len)
+        {
+            nesqp->ietf_frame =
kzalloc(sizeof(*nesqp->ietf_frame)+resp_private_data_length, 
+                                        GFP_KERNEL);
+            if (!nesqp->ietf_frame)
+            {
+                dprintk("%s: Error allocating response private data
area.\n", 
+                        __FUNCTION__ );
+                goto conn_err0;
+            }
+            *nesqp->ietf_frame = *req_frame;
+            kfree(req_frame);
+            req_frame = nesqp->ietf_frame;
+        }
+		err = stack_ops_p->sock_ops_p->recv(nesqp->socket, (char
*)req_frame->private_data, resp_private_data_length,0);
+
+		dprintk("%s: Recv for MPA response private data returned
%d.\n", __FUNCTION__, err);
+		if (err < 0) {
+			goto conn_err0;
+		}
+    }
+
+	stack_ops_p->accelerate_socket(nesqp->socket,
nesqp->nesqp_context);
+
+	nesqp->nesqp_context->tcpPorts =
ntohs(cm_id->remote_addr.sin_port) << 16;
+	nesqp->nesqp_context->tcpPorts +=
ntohs(cm_id->local_addr.sin_port);
+	nesqp->nesqp_context->ip0 =
ntohl(cm_id->remote_addr.sin_addr.s_addr);
+
+	nesqp->nesqp_context->misc2 |=
(u32)PCI_FUNC(nesdev->pcidev->devfn) <<
NES_QPCONTEXT_MISC2_SRC_IP_SHIFT;
+	nesqp->nesqp_context->arp_index_vlan |=
((u32)nes_arp_table_update(nesdev, nesqp->nesqp_context->ip0,
NES_ARP_INDEX_RESOLVE))<<16;
+	nesqp->nesqp_context->ts_val_delta = jiffies -
nes_read_indexed(nesdev->index_reg, NES_IDX_TCP_NOW);
+	nesqp->nesqp_context->ird_index = nesqp->hwqp.qp_id;
+	nesqp->nesqp_context->ird_ord_sizes |= (u32)1 <<
NES_QPCONTEXT_ORDIRD_IWARP_MODE_SHIFT; 
+    /* Adjust tail for not having a LSMM */
+    nesqp->hwqp.sq_tail = 1;
+
+#if defined(NES_SEND_FIRST_WRITE)
+	if (send_first) {
+		wqe = &nesqp->hwqp.sq_vbase[0];
+		*((struct nes_qp
**)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+		*((u64
*)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) |=
NES_SW_CONTEXT_ALIGN>>1;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
cpu_to_le32(NES_IWARP_SQ_OP_RDMAW); 
+		wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] = 0;
+	
+		/* use the reserved spot on the WQ for the extra first
WQE */
+		nesqp->nesqp_context->ird_ord_sizes &=
~(NES_QPCONTEXT_ORDIRD_LSMM_PRESENT | NES_QPCONTEXT_ORDIRD_WRPDU |
NES_QPCONTEXT_ORDIRD_ALSMM);
+		nesqp->skip_lsmm = 1;
+		nesqp->hwqp.sq_tail = 0;
+		nes_write32(nesdev->regs + NES_WQE_ALLOC, (1 << 24) |
0x00800000 | nesqp->hwqp.qp_id);
+	}
+#endif
+
+	memset ( &nes_quad, 0, sizeof(nes_quad));
+
+	nes_quad.DstIpAdrIndex = (u32)PCI_FUNC(nesdev->pcidev->devfn) <<
27;
+	nes_quad.SrcIpadr = cm_id->remote_addr.sin_addr.s_addr; 
+	nes_quad.TcpPorts = cm_id->remote_addr.sin_port; 
+	nes_quad.TcpPorts |= (u32)cm_id->local_addr.sin_port << 16;
+   
+	// Produce hash key  
+	nesqp->hte_index = nes_crc32(  TRUE,
+
NES_HASH_CRC_INITAL_VALUE,
+
NES_HASH_CRC_FINAL_XOR,
+						   sizeof(nes_quad),
+						   (PUINT8)&nes_quad,
+						   ORDER,
+						   REFIN,
+						   REFOUT
+						);
+
+	dprintk("%s: HTE Index = 0x%08X, CRC = 0x%08X\n", __FUNCTION__,
+					nesqp->hte_index,
nesqp->hte_index & nesadapter->hte_index_mask);
+
+	nesqp->hte_index &= nesadapter->hte_index_mask;
+	nesqp->nesqp_context->hte_index = nesqp->hte_index;
+
+	attr.qp_state = IB_QPS_RTS;
+	nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE);
+
+	kaddr_length = sizeof(new_socket_name);
+	stack_ops_p->sock_ops_p->getsockname( nesqp->socket,
+
(struct NES_sockaddr *)&new_socket_name,
+
&kaddr_length);
+
+	cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
+	cm_event.status = IW_CM_EVENT_STATUS_ACCEPTED;
+	cm_event.provider_data = cm_id->provider_data;
+	cm_event.local_addr.sin_family = new_socket_name.sin_family;
+	cm_event.local_addr.sin_port = new_socket_name.sin_port;
+	cm_event.local_addr.sin_addr.s_addr =
new_socket_name.sin_addr.NES_s_addr;
+	cm_event.remote_addr = cm_id->remote_addr;
+	cm_event.private_data = &req_frame->private_data;
+	cm_event.private_data_len = resp_private_data_length;
+
+	cm_id->event_handler(cm_id, &cm_event);   
+	// kfree(req_frame);
+
+	dprintk("%s: Exiting connect thread for QP%u\n", 
+	   __FUNCTION__,  nesqp->hwqp.qp_id );
+    return;
+
+conn_err0:
+    kfree(req_frame);
+	if (nesqp->cm_id)
+	{
+	    spin_lock_irqsave(&nesqp->lock, qplockflags);
+		if (nesqp->ksock) {
+			ksock = nesqp->ksock;
+			socket = nesqp->socket;
+		    nesqp->ksock = 0;
+		    nesqp->socket = 0;
+			spin_unlock_irqrestore(&nesqp->lock,
qplockflags);
+		    stack_ops_p->sock_ops_p->close( socket );
+			sock_release(ksock);
+		} else {
+			spin_unlock_irqrestore(&nesqp->lock,
qplockflags);
+		}
+	    cm_id->rem_ref(cm_id);
+	    nesqp->cm_id = NULL;
+	    cm_id->provider_data = NULL;
+	    cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
+	    cm_event.status = IW_CM_EVENT_STATUS_REJECTED;
+	    cm_event.provider_data = cm_id->provider_data;
+	    cm_event.local_addr = cm_id->local_addr;
+	    cm_event.remote_addr = cm_id->remote_addr;
+	    cm_event.private_data = NULL;
+	    cm_event.private_data_len = 0;
+
+	    cm_id->event_handler(cm_id, &cm_event);   
+	}
+}
+
+
+/**
+ * nes_sock_release
+ * 
+ * @param nesqp
+ * @param qplockflags
+ */
+void nes_sock_release(struct nes_qp *nesqp, unsigned long *qplockflags)
{
+	UINTPTR socket;
+	struct socket *ksock;
+
+	ksock = nesqp->ksock;
+	socket = nesqp->socket;
+    nesqp->ksock = 0;
+    nesqp->socket = 0;
+	spin_unlock_irqrestore(&nesqp->lock, *qplockflags);
+	stack_ops_p->sock_ops_p->close( socket );
+	sock_release(ksock);
+    spin_lock_irqsave(&nesqp->lock, *qplockflags);
+}
+
+
+/**
+ * nes_connect
+ * 
+ * @param cm_id
+ * @param conn_param
+ * 
+ * @return int
+ */
+int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param
*conn_param)
+{
+	int err;
+	int int_socket_opt;
+	u8 u8temp;
+	UINTPTR socket;
+	struct socket *ksock;
+	struct NES_sockaddr_in  inet_addr;
+	struct sockaddr_in  kinet_addr;
+	int kaddr_length;
+	struct nes_qp *nesqp;
+	struct nes_dev *nesdev = to_nesdev(cm_id->device);
+	struct ib_qp *ibqp;
+
+	dprintk("%s:%s:%u: data len = %u, cm_id = %p, event handler =
%p.\n", __FILE__, 
+			__FUNCTION__, __LINE__,
conn_param->private_data_len, cm_id, cm_id->event_handler);
+
+    // update the NES stack routing table
+    // Unfortunately, cannot be done in interface event handler.
Handler is called before routes are setup.
+    dprintk("call nes_update_rt\n");
+    // stack_ops_p->update_route(nesdev->netdev->name);
+    stack_ops_p->dump_rt_table();
+	
+
+	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
+	if (!ibqp)
+		return -EINVAL;
+	nesqp = to_nesqp(ibqp);
+
+    nesqp->ietf_frame =
kzalloc(sizeof(*nesqp->ietf_frame)+conn_param->private_data_len,
GFP_KERNEL);
+    if (!nesqp->ietf_frame)
+        return -ENOMEM;
+
+    nesqp->active_conn = 1;
+	dprintk("%s: QP%u, Destination IP = 0x%08X, local = 0x%08X.\n", 
+		__FUNCTION__, nesqp->hwqp.qp_id, 
+		ntohl(cm_id->remote_addr.sin_addr.s_addr), 
+		ntohl(cm_id->local_addr.sin_addr.s_addr));
+
+	socket = stack_ops_p->sock_ops_p->socket(NES_AF_INET,
NES_SOCK_STREAM, 0);
+	dprintk("returned socket = %p.\n", (void *)socket);
+	nesqp->socket = socket;
+   
+	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP,
&ksock);
+	if (err < 0) {
+		dprintk("kernel socket call returned %d.\n", err );
+		stack_ops_p->sock_ops_p->close( socket );
+		return err;
+	}
+
+	dprintk("kernel socket =  %p.\n", ksock );
+	nesqp->ksock = ksock;
+
+	memset( &kinet_addr, 0, sizeof(kinet_addr) );
+	kinet_addr.sin_family = AF_INET;
+	kinet_addr.sin_port = cm_id->local_addr.sin_port;
+	kinet_addr.sin_addr.s_addr = cm_id->local_addr.sin_addr.s_addr;
+	err = ksock->ops->bind(ksock, (struct sockaddr *)&kinet_addr,
sizeof(kinet_addr));
+	if (err < 0) {
+		dprintk("kernel bind call returned %d.\n", err );
+		sock_release(ksock);
+		stack_ops_p->sock_ops_p->close( socket );
+		return err;
+	}
+
+	memset( &kinet_addr, 0, sizeof(kinet_addr) );
+	err = ksock->ops->getname(ksock, (struct sockaddr *)&kinet_addr,
&kaddr_length,0);
+	if (err < 0) {
+		dprintk("kernel getname call returned %d.\n", err );
+		sock_release(ksock);
+		stack_ops_p->sock_ops_p->close( socket );
+		return err;
+	}
+
+	dprintk("kernel getname call returned port =  0x%04X.\n",
ntohs(kinet_addr.sin_port) );
+	cm_id->local_addr.sin_port = kinet_addr.sin_port;
+	inet_addr.sin_len = sizeof( inet_addr );
+	inet_addr.sin_family = NES_AF_INET;
+	inet_addr.sin_port = cm_id->local_addr.sin_port;
+	inet_addr.sin_addr.NES_s_addr =
cm_id->local_addr.sin_addr.s_addr;
+	err = stack_ops_p->sock_ops_p->bind( 
+			socket,
+			(struct NES_sockaddr *)&inet_addr,
+			sizeof(inet_addr));
+
+	if (err < 0) {
+		dprintk("nes bind call returned %d.\n", err );
+		sock_release(ksock);
+		stack_ops_p->sock_ops_p->close( socket );
+		return err;
+	}
+	
+	int_socket_opt = 1;
+	err = stack_ops_p->sock_ops_p->setsockopt( 
+			socket, NES_SOL_SOCKET, NES_TCP_NODELAY, 
+			(char *)&int_socket_opt,
sizeof(int_socket_opt));
+
+	if (err < 0) {
+		dprintk("nes setsockopt (TCP_NODELAY) call returned
%d.\n", err );
+	}
+
+	int_socket_opt = 0;
+	u8temp = 1 << (ntohs(cm_id->local_addr.sin_port)&7);
+	nesdev->apbv_table[ntohs(cm_id->local_addr.sin_port)>>3] |=
u8temp;
+
+	/* Cache the cm_id in the qp */
+	nesqp->cm_id = cm_id;
+	cm_id->provider_data = nesqp;
+	/* Associate QP <--> CM_ID */
+	cm_id->add_ref(cm_id);
+
+    /* Copy the private data */
+    if (conn_param->private_data_len) {
+        memcpy(nesqp->ietf_frame->private_data,
conn_param->private_data, 
+               conn_param->private_data_len);
+    }
+    nesqp->ietf_frame->private_data_size =
cpu_to_be16(conn_param->private_data_len);
+    nesqp->private_data_len = conn_param->private_data_len;
+    nesqp->nesqp_context->ird_ord_sizes |= (u32)conn_param->ord;
+	dprintk("%s:requested ord = 0x%08X.\n", __FUNCTION__,
(u32)conn_param->ord );
+
+    // start a worker thread
+	nesqp->wq = create_singlethread_workqueue("NesConnectWQ");
+	INIT_WORK(&nesqp->work, connect_worker, nesqp);
+	queue_work(nesqp->wq, &nesqp->work);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	return err;
+}
+
+
+/**
+ * nes_disconnect_worker
+ * 
+ * @param qp
+ */
+void nes_disconnect_worker(void *qp)
+{
+	struct nes_qp *nesqp = qp;
+	// struct nes_dev *nesdev = to_nesdev(nesqp->ibqp.device);
+	// struct iw_cm_id *cm_id = nesqp->cm_id;
+	// struct iw_cm_event cm_event;
+	struct ib_qp_attr attr;
+	// u8 u8temp;
+
+	dprintk("%s: Disconnecting qp%u after AE\n", __FUNCTION__,
nesqp->hwqp.qp_id );
+
+	switch (nesqp->ibqp_state) {
+		case IB_QPS_RTS:
+			/* this should be a FIN received */
+			attr.qp_state = IB_QPS_SQD;
+			nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE
);
+			break;
+		case IB_QPS_SQD:
+			/* this should be a Close complete */
+			attr.qp_state = IB_QPS_SQD;
+			nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE
);
+			break;
+		case IB_QPS_SQE:
+			/* TODO: Add Terminate received processing */
+			break;
+		default:
+			dprintk("%s: Should not be here. QP%u state =
%u.\n", __FUNCTION__, nesqp->hwqp.qp_id, nesqp->ibqp_state );
+
+	}
+
+    return;
+}
+
+
+/**
+ * nes_disconnect
+ * 
+ * @param cm_id
+ * @param abrupt
+ * 
+ * @return int
+ */
+int nes_disconnect(struct iw_cm_id *cm_id, int abrupt)
+{
+	struct ib_qp_attr attr;
+	struct ib_qp *ibqp;
+	struct nes_qp *nesqp;
+	struct nes_dev *nesdev = to_nesdev(cm_id->device);
+	int err = 0;
+	u8 u8temp;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
atomic_read(&nesdev->netdev->refcnt));
+
+	/* If the qp was already destroyed, then there's no QP */
+	if (cm_id->provider_data == 0)
+		return 0;
+
+	nesqp = (struct nes_qp *)cm_id->provider_data;
+	ibqp = &nesqp->ibqp;
+
+	/* Disassociate the QP from this cm_id */
+	cm_id->provider_data = 0;
+	cm_id->rem_ref(cm_id);
+	nesqp->cm_id = 0;
+
+	stack_ops_p->decelerate_socket(nesqp->socket, 
+                                (struct nes_uploaded_qp_context *)
+                                nesqp->nesqp_context);
+  
+	if (nesqp->active_conn) {
+	  u8temp = 1 << (ntohs(cm_id->local_addr.sin_port)&7);
+	  nesdev->apbv_table[ntohs(cm_id->local_addr.sin_port)>>3] &=
~(u8temp);
+	} else {
+		dev_put(nesdev->netdev);
+        /* Need to free the Last Streaming Mode Message */
+        pci_free_consistent(nesdev->pcidev, 
+
nesqp->private_data_len+sizeof(*nesqp->ietf_frame), 
+                            nesqp->ietf_frame,
+                            nesqp->ietf_frame_pbase);
+    }
+
+	if (nesqp->ksock) sock_release(nesqp->ksock);
+	stack_ops_p->sock_ops_p->close( nesqp->socket );
+	nesqp->ksock = 0;
+	nesqp->socket = 0;
+	if (nesqp->wq) {
+		destroy_workqueue(nesqp->wq);
+		nesqp->wq = NULL;
+	}
+
+	memset(&attr, 0, sizeof(struct ib_qp_attr));
+	if (abrupt)
+		attr.qp_state = IB_QPS_ERR;
+	else
+		attr.qp_state = IB_QPS_SQD;
+
+	return err;
+}
+
+
+/**
+ * nes_accept
+ * 
+ * @param cm_id
+ * @param conn_param
+ * 
+ * @return int
+ */
+int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param
*conn_param)
+{
+	struct nes_qp *nesqp;
+	struct nes_dev *nesdev;
+	struct nes_adapter *nesadapter;
+	struct ib_qp *ibqp;
+    struct nes_hw_qp_wqe *wqe;
+	struct nes_v4_quad nes_quad;
+	struct ib_qp_attr attr;
+    struct iw_cm_event cm_event;
+
+	dprintk("%s:%s:%u: data len = %u\n", 
+			__FILE__, __FUNCTION__, __LINE__,
conn_param->private_data_len);
+
+	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
+	if (!ibqp)
+		return -EINVAL;
+	nesqp = to_nesqp(ibqp);
+	nesdev = to_nesdev(nesqp->ibqp.device);
+	nesadapter = nesdev->nesadapter;
+	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
atomic_read(&nesdev->netdev->refcnt));
+
+    nesqp->ietf_frame = pci_alloc_consistent(nesdev->pcidev, 
+
sizeof(*nesqp->ietf_frame)+conn_param->private_data_len,
+                                             &nesqp->ietf_frame_pbase);
+    if (!nesqp->ietf_frame) {
+        dprintk(KERN_ERR PFX "%s: Unable to allocate memory for private
data\n", __FUNCTION__);
+        return -ENOMEM;
+    }
+    dprintk(PFX "%s: PCI consistent memory for "
+            "private data located @ %p (pa = 0x%08lX.) size = %u.\n", 
+            __FUNCTION__, nesqp->ietf_frame, (unsigned
long)nesqp->ietf_frame_pbase,
+            conn_param->private_data_len+sizeof(*nesqp->ietf_frame));
+    nesqp->private_data_len = conn_param->private_data_len;
+
+    strcpy(&nesqp->ietf_frame->key[0], IEFT_MPA_KEY_REP);
+    memcpy(&nesqp->ietf_frame->private_data, conn_param->private_data,
conn_param->private_data_len);
+    nesqp->ietf_frame->private_data_size =
cpu_to_be16(conn_param->private_data_len);
+    nesqp->ietf_frame->rev = mpa_version;
+    nesqp->ietf_frame->flags = IETF_MPA_FLAGS_CRC;
+
+    wqe = &nesqp->hwqp.sq_vbase[0];
+    *((struct nes_qp
**)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+	*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) |=
NES_SW_CONTEXT_ALIGN>>1;
+    wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
cpu_to_le32(NES_IWARP_SQ_WQE_STREAMING); 
+    wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
cpu_to_le32(conn_param->private_data_len+sizeof(*nesqp->ietf_frame));
+    wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] =
cpu_to_le32((u32)nesqp->ietf_frame_pbase);
+    wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] =
cpu_to_le32((u32)((u64)nesqp->ietf_frame_pbase>>32));
+    wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX] =
cpu_to_le32(conn_param->private_data_len+sizeof(*nesqp->ietf_frame));
+    wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] = 0;
+
+	nesqp->nesqp_context->ird_ord_sizes |=
NES_QPCONTEXT_ORDIRD_LSMM_PRESENT | NES_QPCONTEXT_ORDIRD_WRPDU;
+    nesqp->skip_lsmm = 1;
+
+	/* Cache the cm_id in the qp */
+	nesqp->cm_id = cm_id;
+	nesqp->socket = (u32)cm_id->provider_data;
+	nesqp->ksock = 0;
+	cm_id->provider_data = nesqp;
+	nesqp->active_conn = 0;
+    /* Just save the private data here and set context bits */
+	stack_ops_p->accelerate_socket(nesqp->socket,
nesqp->nesqp_context);
+	nesqp->nesqp_context->tcpPorts =
ntohs(cm_id->remote_addr.sin_port) << 16;
+	nesqp->nesqp_context->tcpPorts +=
ntohs(cm_id->local_addr.sin_port);
+	nesqp->nesqp_context->ip0 =
ntohl(cm_id->remote_addr.sin_addr.s_addr);
+	nesqp->nesqp_context->misc2 |=
(u32)PCI_FUNC(nesdev->pcidev->devfn) <<
NES_QPCONTEXT_MISC2_SRC_IP_SHIFT;
+	nesqp->nesqp_context->arp_index_vlan |=
((u32)nes_arp_table_update(nesdev, nesqp->nesqp_context->ip0,
NES_ARP_INDEX_RESOLVE))<<16;
+	nesqp->nesqp_context->ts_val_delta = jiffies -
nes_read_indexed(nesdev->index_reg, NES_IDX_TCP_NOW);
+	nesqp->nesqp_context->ird_index = nesqp->hwqp.qp_id;
+	nesqp->nesqp_context->ird_ord_sizes |= (u32)1 <<
NES_QPCONTEXT_ORDIRD_IWARP_MODE_SHIFT; 
+	nesqp->nesqp_context->ird_ord_sizes |= (u32)conn_param->ord; 
+
+	memset ( &nes_quad, 0, sizeof(nes_quad));
+
+	nes_quad.DstIpAdrIndex = (u32)PCI_FUNC(nesdev->pcidev->devfn) <<
27;
+	nes_quad.SrcIpadr = cm_id->remote_addr.sin_addr.s_addr; 
+	nes_quad.TcpPorts = cm_id->remote_addr.sin_port; 
+	nes_quad.TcpPorts |= (u32)cm_id->local_addr.sin_port << 16;
+   
+	// Produce hash key  
+	nesqp->hte_index = nes_crc32(  TRUE,
+
NES_HASH_CRC_INITAL_VALUE,
+
NES_HASH_CRC_FINAL_XOR,
+						   sizeof(nes_quad),
+						   (PUINT8)&nes_quad,
+						   ORDER,
+						   REFIN,
+						   REFOUT
+						);
+
+	dprintk("%s: HTE Index = 0x%08X, CRC = 0x%08X\n", 
+					__FUNCTION__, nesqp->hte_index,
+					nesqp->hte_index &
nesadapter->hte_index_mask);
+
+	nesqp->hte_index &= nesadapter->hte_index_mask;
+	nesqp->nesqp_context->hte_index = nesqp->hte_index;
+
+	attr.qp_state = IB_QPS_RTS;
+	nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE );
+	cm_id->add_ref(cm_id);
+
+    cm_event.event = IW_CM_EVENT_ESTABLISHED;
+    cm_event.status = IW_CM_EVENT_STATUS_ACCEPTED;
+    cm_event.provider_data = (void *)nesqp;
+    cm_event.local_addr = cm_id->local_addr;
+    cm_event.remote_addr = cm_id->remote_addr;
+    cm_event.private_data = NULL;
+    cm_event.private_data_len = 0;
+
+    cm_id->event_handler(cm_id, &cm_event);   
+
+	return 0;
+}
+
+
+/**
+ * nes_reject
+ * 
+ * @param cm_id
+ * @param pdata
+ * @param pdata_len
+ * 
+ * @return int
+ */
+int nes_reject(struct iw_cm_id *cm_id, const void *pdata, u8 pdata_len)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	
+    stack_ops_p->sock_ops_p->close( (UINTPTR)cm_id->provider_data );
+	return 0;
+}
+
+
+/**
+ * listen_worker
+ * 
+ * @param listener
+ */
+static void listen_worker( void *listener )
+{
+	struct nes_listener *nes_listener = listener;
+	struct nes_dev *nesdev = nes_listener->nesdev;
+	struct iw_cm_id *cm_id = nes_listener->cm_id;
+	struct iw_cm_event cm_event;
+	struct NES_sockaddr_in  inet_addr;
+	struct NES_sockaddr_in new_socket_name;
+    struct ietf_mpa_req_resp_frame req_frame;
+    char *private_data = NULL;
+	UINTPTR new_socket;
+	int kaddr_length;
+    int err;
+    int socket_bytes;
+    u16 req_private_data_length;
+
+    cm_id->add_ref(cm_id);
+	do {
+		dprintk("Issuing Accept on 0x%08X:0x%04X (socket
0x%0lX), netdev->refcnt = %u.\n", 
+
ntohl(cm_id->local_addr.sin_addr.s_addr), 
+				ntohs(cm_id->local_addr.sin_port),
nes_listener->socket, atomic_read(&nesdev->netdev->refcnt));
+
+		kaddr_length = sizeof(inet_addr);
+		new_socket =
stack_ops_p->sock_ops_p->accept(nes_listener->socket,
+								(struct
NES_sockaddr *)&inet_addr, &kaddr_length);
+
+		dprintk("%s: Accept request returned %d.\n",
__FUNCTION__, 
+				(int)new_socket );
+		if ((int)new_socket < 0) {
+			if (-NES_ECONNABORTED != (int)new_socket)
+			{
+				cm_event.event =
IW_CM_EVENT_CONNECT_REQUEST;
+				cm_event.status =
IW_CM_EVENT_STATUS_EINVAL;
+				cm_event.provider_data = (void
*)new_socket;
+				cm_event.local_addr =
nes_listener->cm_id->local_addr;
+				cm_event.remote_addr.sin_family =
AF_INET;
+				cm_event.remote_addr.sin_port =
inet_addr.sin_port;
+				cm_event.remote_addr.sin_addr.s_addr =
inet_addr.sin_addr.NES_s_addr;
+				cm_event.private_data = NULL;
+				cm_event.private_data_len = 0;
+                continue;
+			}
+			break; 
+		}
+
+		dprintk("Accept address info:
0x%08X:0x%04X.netdev->refcnt = %u\n", 
+		ntohl(inet_addr.sin_addr.NES_s_addr), 
+		ntohs(inet_addr.sin_port),
atomic_read(&nesdev->netdev->refcnt));
+		
+        /* Issue receive for IETF mode request */
+        socket_bytes = 0;
+        do
+        {
+            err = stack_ops_p->sock_ops_p->recv(new_socket, (char
*)&req_frame, sizeof(req_frame),0);
+
+            dprintk("%s: Recv for MPA request returned %d.\n",
__FUNCTION__, err );
+
+            if (err < 0) {
+                goto accept_err0;
+            }
+            socket_bytes += err;
+        } while (socket_bytes < sizeof(req_frame));
+
+        if (req_frame.flags&IETF_MPA_FLAGS_MARKERS)
+        {
+    	    dprintk("%s: Peer specified Markers in MPA request.
Aborting MPA negotiation \n", 
+        	        __FUNCTION__ );
+            goto accept_err0;
+        }
+	    if (req_frame.flags&IETF_MPA_FLAGS_CRC) {
+    	    dprintk("%s: Peer specified CRC in MPA reply.  MPA version =
%u.\n", 
+        	        __FUNCTION__, req_frame.rev );
+	    } else {
+    	    dprintk("%s: Peer did not specified CRC in MPA reply.  MPA
version = %u.\n", 
+        	        __FUNCTION__, req_frame.rev );
+		}
+
+        req_private_data_length =
be16_to_cpu(req_frame.private_data_size);
+        if (req_private_data_length) {
+            private_data = kzalloc(req_private_data_length,
GFP_KERNEL);
+            if (!private_data)
+            {
+                dprintk("%s: Error allocating req private data
area.\n", __FUNCTION__ );
+                goto accept_err0;
+            }
+            err = stack_ops_p->sock_ops_p->recv(new_socket,
private_data, req_private_data_length,0);
+
+            dprintk("%s: Recv for MPA request private data returned
%d.\n", __FUNCTION__, err );
+            if (err < 0) {
+                goto accept_err0;
+            }
+        }
+
+		kaddr_length = sizeof(new_socket_name);
+		stack_ops_p->sock_ops_p->getsockname( new_socket,
+
(struct NES_sockaddr *)&new_socket_name,
+
&kaddr_length);
+
+		cm_event.event = IW_CM_EVENT_CONNECT_REQUEST;
+		cm_event.status = IW_CM_EVENT_STATUS_OK;
+		cm_event.provider_data = (void *)new_socket;
+		cm_event.local_addr.sin_family =
new_socket_name.sin_family;
+		cm_event.local_addr.sin_port = new_socket_name.sin_port;
+		cm_event.local_addr.sin_addr.s_addr =
new_socket_name.sin_addr.NES_s_addr;
+		cm_event.remote_addr.sin_family = AF_INET;
+		cm_event.remote_addr.sin_port = inet_addr.sin_port;
+		cm_event.remote_addr.sin_addr.s_addr =
inet_addr.sin_addr.NES_s_addr;
+		cm_event.private_data = private_data;
+		cm_event.private_data_len = req_private_data_length;
+
+		cm_id->event_handler(cm_id, &cm_event);
+
+		if (private_data)
+        {
+        }
+
+        private_data = NULL;
+        continue;
+
+accept_err0:
+        if (private_data)
+            kfree(private_data);
+        private_data = NULL;
+        stack_ops_p->sock_ops_p->close( new_socket );
+
+	} while (1);
+
+	dprintk("Exiting Listener worker thread \n" );
+	nes_listener->accept_failed = 1;
+    return;
+}
+
+
+/**
+ * nes_create_listen
+ * 
+ * @param cm_id
+ * @param backlog
+ * 
+ * @return int
+ */
+int nes_create_listen(struct iw_cm_id *cm_id, int backlog)
+{
+	int err;
+	int int_socket_opt;
+	u8 u8temp;
+	UINTPTR socket;
+	struct socket *ksock;
+	struct nes_listener *nes_listener;
+	struct sockaddr_in  kinet_addr;
+	struct NES_sockaddr_in  inet_addr;
+	int kaddr_length;
+	struct nes_dev *nesdev = to_nesdev(cm_id->device);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	// Allocate a listener
+	nes_listener = kzalloc(sizeof *nes_listener, GFP_KERNEL);
+	if (NULL == nes_listener) {
+		dprintk("%s:%s: Error allocating listener.\n", __FILE__,
__FUNCTION__ );
+		return -ENOMEM;
+	}
+
+	dprintk("%s: socket function pointer = %p, listener = %p, cm_id
= %p, event_handler = %p, netdev->refcnt = %u.\n", 
+			__FUNCTION__, stack_ops_p->sock_ops_p->socket,
nes_listener, cm_id, cm_id->event_handler, 
+			atomic_read(&nesdev->netdev->refcnt) );
+	nes_listener->nesdev = nesdev;
+	socket =  stack_ops_p->sock_ops_p->socket( NES_AF_INET,
NES_SOCK_STREAM, 0 );
+	dprintk("returned socket = %p.\n", (void *)socket );
+	if ((long)socket < 0) {
+		dprintk("NES socket call returned %d.\n", (int)socket );
+		return (int)socket;
+	}
+	nes_listener->socket = socket;
+
+	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP,
&ksock);
+	if (err < 0) {
+		dprintk("kernel socket call returned %d.\n", err );
+		stack_ops_p->sock_ops_p->close( socket );
+		return err;
+	}
+
+	dprintk("kernel socket =  %p.\n", ksock );
+	nes_listener->ksock = ksock;
+
+	memset( &kinet_addr, 0, sizeof(kinet_addr) );
+	kinet_addr.sin_family = AF_INET;
+	kinet_addr.sin_port = cm_id->local_addr.sin_port;
+	kinet_addr.sin_addr.s_addr = cm_id->local_addr.sin_addr.s_addr;
+	err = ksock->ops->bind(ksock, (struct sockaddr *)&kinet_addr,
sizeof(kinet_addr));
+	if (err < 0) {
+		dprintk("kernel bind call returned %d.\n", err );
+		goto release_sockets0;
+	}
+
+	memset( &kinet_addr, 0, sizeof(kinet_addr) );
+	err = ksock->ops->getname(ksock, (struct sockaddr *)&kinet_addr,
&kaddr_length,0);
+	if (err < 0) {
+		dprintk("kernel getname call returned %d.\n", err );
+		goto release_sockets0;
+	}
+
+	dprintk("kernel getname call returned port =  0x%04X.\n",
kinet_addr.sin_port );
+	cm_id->local_addr.sin_port = kinet_addr.sin_port;
+	inet_addr.sin_len = sizeof( inet_addr );
+	inet_addr.sin_family = NES_AF_INET;
+	inet_addr.sin_port = cm_id->local_addr.sin_port;
+	inet_addr.sin_addr.NES_s_addr =
cm_id->local_addr.sin_addr.s_addr;
+	err = stack_ops_p->sock_ops_p->bind(socket, (struct NES_sockaddr
*)&inet_addr,
+
sizeof(inet_addr));
+	if (err < 0) {
+		dprintk("NES Socket bind call returned %d.\n", err );
+		goto release_sockets0;
+	}
+
+	int_socket_opt = 1;
+	err = stack_ops_p->sock_ops_p->setsockopt(socket,
NES_SOL_SOCKET, NES_TCP_NODELAY, 
+
(char *)&int_socket_opt, sizeof(int_socket_opt));
+
+	if (err < 0) {
+		dprintk("%s: nes setsockopt (TCP_NODELAY) call returned
%d.\n", __FUNCTION__, err );
+	}
+
+	int_socket_opt = 0;
+	err = stack_ops_p->sock_ops_p->setsockopt(socket,
NES_SOL_SOCKET, TCPOPT_TIMESTAMP, 
+
(char *)&int_socket_opt, sizeof(int_socket_opt));
+
+	if (err < 0) {
+		dprintk("%s: nes setsockopt (TCPOPT_TIMESTAMP) call
returned %d.\n", __FUNCTION__, err );
+	}
+
+	int_socket_opt = (496*1024)-8;
+	err = stack_ops_p->sock_ops_p->setsockopt(socket,
NES_SOL_SOCKET, NES_SO_RCVBUF, 
+
(char *)&int_socket_opt, sizeof(int_socket_opt));
+
+	if (err < 0) {
+		dprintk("%s: nes setsockopt (NES_SO_RECVBUF) call
returned %d.\n", __FUNCTION__, err);
+	}
+
+	u8temp = 1 << (ntohs(cm_id->local_addr.sin_port)&7);
+	nesdev->apbv_table[ntohs(cm_id->local_addr.sin_port)>>3] |=
u8temp;
+
+	dprintk("Attempting to listen on 0x%08X:0x%04X.\n", 
+	   ntohl(cm_id->local_addr.sin_addr.s_addr), 
+	   ntohs(cm_id->local_addr.sin_port) );
+
+	err = stack_ops_p->sock_ops_p->listen(socket, backlog );
+
+	dprintk("Listen request returned %X.\n", err );
+
+	if (err < 0) {
+		dprintk("NES Socket listen call returned %d.\n", err );
+		goto release_sockets0;
+	}
+
+	dprintk("Setting cm_id->provider_data for listen to %p.\n",
nes_listener );
+	nes_listener->cm_id = cm_id;
+	cm_id->provider_data = nes_listener;
+
+	// start a worker thread
+	nes_listener->wq =
create_singlethread_workqueue("NesListenerWQ");
+
+	INIT_WORK(&nes_listener->work, listen_worker, nes_listener);
+	queue_work(nes_listener->wq, &nes_listener->work);
+	dprintk("%s: Exiting create listen, netdev->refcnt = %u.\n",
__FUNCTION__, 
+			atomic_read(&nesdev->netdev->refcnt) );
+	return 0;
+
+release_sockets0:
+	sock_release(ksock);
+	stack_ops_p->sock_ops_p->close( socket );
+	return err;
+}
+
+
+/**
+ * nes_destroy_listen
+ * 
+ * @param cm_id
+ * 
+ * @return int
+ */
+int nes_destroy_listen(struct iw_cm_id *cm_id)
+{
+	struct nes_listener *nes_listener = (struct nes_listener
*)(unsigned long)cm_id->provider_data;
+	struct nes_dev *nesdev = to_nesdev(cm_id->device);
+	int err;
+	u8 u8temp;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	err = 0;
+
+	u8temp = 1 << (ntohs(cm_id->local_addr.sin_port)&7);
+	nesdev->apbv_table[ntohs(cm_id->local_addr.sin_port)>>3] &=
~(u8temp);
+
+	sock_release(nes_listener->ksock);
+	stack_ops_p->sock_ops_p->close( nes_listener->socket );
+
+	do {
+		msleep(1);
+	} while( 0 == nes_listener->accept_failed );
+
+	//	dprintk("%s: Accept failed.\n", __FUNCTION__ );
+	destroy_workqueue(nes_listener->wq);
+
+    cm_id->rem_ref(cm_id);
+	kfree(nes_listener);
+
+	return err;
+}
+


