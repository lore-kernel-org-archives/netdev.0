From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 7/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:43:12 -0800
Message-ID: <20080217024312.8976972f@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:32030 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbYBQCnR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:43:17 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:43:12 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ether ring creation function in beclib.

---------------------------------------
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/ethtx_ll.c benet/linux-2.6.24.2/drivers/message/beclib/ethtx_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/ethtx_ll.c 1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/ethtx_ll.c 2008-02-14 15:23:07.806206040 +0530
@@ -0,0 +1,561 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_sq_create_ex
+ * Creates an ethernet send ring - extended version with
+ * additional parameters.
+ * function_object -
+ * sgl - no virtual address required
+ * length_in_bytes -
+ * type - The type of ring to create.
+ * ulp - The requested ULP number for the ring.
+ * This should be zero based, i.e. 0,1,2. This must
+ * be valid NIC ULP based on the firmware config.
+ * All doorbells for this ring must be sent to
+ * this ULP. The first network ring allocated for
+ * each ULP are higher performance than subsequent rings.
+ * cq_object - cq object for completions
+ * ex_parameters - Additional parameters (that may increase in
+ * future revisions). These parameters are only used
+ * for certain ring types -- see
+ * BE_ETH_SQ_PARAMETERS for details.
+ * eth_sq -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create_ex(IN PBE_FUNCTION_OBJECT function_object,
+ IN PSA_SGL sgl,
+ IN u32 length,
+ IN u32 type,
+ IN u32 ulp,
+ IN PBE_CQ_OBJECT cq_object,
+ IN BE_ETH_SQ_PARAMETERS *ex_parameters,
+ OUT PBE_ETHSQ_OBJECT eth_sq)
+{
+ IOCTL_COMMON_ETH_TX_CREATE *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ ASSERT(sgl);
+ ASSERT(eth_sq);
+ ASSERT(ex_parameters);
+
+ FUNCTION_ASSERT(function_object);
+ be_lock_wrb_post(function_object);
+
+ sa_zero_mem(eth_sq, sizeof(*eth_sq));
+
+ eth_sq->magic = BE_ETHSQ_MAGIC;
+ eth_sq->parent_function = function_object;
+ eth_sq->bid = 0xFFFFFFFF;
+ eth_sq->cq_object = cq_object;
+
+ /* Translate beclib interface to arm interface. */
+ switch (type) {
+ case BE_ETH_TX_RING_TYPE_FORWARDING:
+ type = ETH_TX_RING_TYPE_FORWARDING;
+ break;
+ case BE_ETH_TX_RING_TYPE_STANDARD:
+ type = ETH_TX_RING_TYPE_STANDARD;
+ break;
+ case BE_ETH_TX_RING_TYPE_BOUND:
+ ASSERT(ex_parameters->port < 2);
+ type = ETH_TX_RING_TYPE_BOUND;
+ break;
+ default:
+ TRACE(DL_ERR, "Invalid eth tx ring type:%d", type);
+ return BE_NOT_OK;
+ break;
+ }
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ ASSERT(wrb);
+ TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ /* NIC must be supported by the current config. */
+ ASSERT(function_object->fw_config.nic_ulp_mask);
+
+ /*
+ * The ulp parameter must select a valid NIC ULP
+ * for the current config.
+ */
+ ASSERT((1 << ulp) & function_object->fw_config.nic_ulp_mask);
+
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_ETH_TX_CREATE);
+
+ /* Only used for ETH_TX_RING_TYPE_BOUND */
+ ioctl->header.request.port_number = ex_parameters->port;
+ ioctl->params.request.context.pd_id =
+ be_function_get_pd_number(function_object);
+ ioctl->params.request.context.tx_ring_size =
+ be_ring_length_to_encoding(length, sizeof(ETH_WRB));
+ ioctl->params.request.context.cq_id_send = cq_object->cq_id;
+ ioctl->params.request.context.func =
+ be_function_get_function_number(function_object);
+ ioctl->params.request.type = type;
+ ioctl->params.request.ulp_num = (1 << ulp);
+
+ ioctl->params.request.num_pages = sa_ceiling(length, SA_PAGE_SIZE);
+ ASSERT(sa_sgl_get_page_count(sgl) >=
+ ioctl->params.request.num_pages);
+
+ /* Create a page list for the IOCTL. */
+ be_sgl_to_pa_list(sgl,
+ ioctl->params.request.pages,
+ SA_NUMBER_OF(ioctl->params.request.pages));
+
+ status =
+ be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+ ioctl);
+ if (status != BE_SUCCESS) {
+ TRACE(DL_ERR, "MCC to create etx queue failed.");
+ goto Error;
+ }
+ /* save the butler ID */
+ eth_sq->bid = ioctl->params.response.cid;
+
+ /* add a reference to the corresponding CQ */
+ be_cq_object_reference(cq_object);
+
+ /* add this object to the function object */
+ _be_function_add_eth_sq(function_object, eth_sq);
+
+ TRACE(DL_INFO,
+ "eth sq created. function:%d pd:%d bid:%d bytes:%d cq_id:%d",
+ be_function_get_function_number(function_object),
+ be_function_get_pd_number(function_object), eth_sq->bid,
+ length, be_cq_get_id(cq_object));
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+
+}
+
+/*!
+
+@brief
+ this routine creates an ethernet send queue
+
+@param
+ function_object - handle to a function object
+@param
+ send_queue_va - base VA for a the ethernet send ring
+@param
+ ring_size_power_of_two - number of entries in the
+ ring (power of two). 32K = 0, 1 = rsvd,
+ 2 = 1, 3 = 4 ....
+@param
+ cq_object - internal CQ handle returned.
+@param
+ pp_eth_sq - internal eth sq handle returned.
+
+@return
+ BE_SUCCESS if successfull, , otherwise a useful error code is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+ this function allocates an eth_sq object
+
+*/
+BESTATUS be_eth_sq_create(IN PBE_FUNCTION_OBJECT function_object,
+ IN PSA_SGL sgl, IN u32 length, IN u32 type,
+ IN u32 ulp, /* 0,1,2 ulp id for the request ring */
+ IN PBE_CQ_OBJECT cq_object,
+ OUT PBE_ETHSQ_OBJECT eth_sq)
+{
+ BE_ETH_SQ_PARAMETERS ex_parameters = { 0 };
+
+ return be_eth_sq_create_ex(function_object,
+ sgl,
+ length,
+ type,
+ ulp, cq_object, &ex_parameters, eth_sq);
+}
+
+/*!
+
+@brief
+ This routine returns the RID for an Etx SQ
+
+@param
+ EthSq - EthSq Handle returned from EthSqCreate
+
+@return
+ The RID for an Etx SQ
+
+@note
+
+*/
+u32 be_eth_sq_get_id(IN PBE_ETHSQ_OBJECT eth_sq)
+{
+ ETHSQ_ASSERT(eth_sq);
+ return eth_sq->bid;
+}
+
+/*!
+
+@brief
+ This routine destroys an ethernet send queue
+
+@param
+ EthSq - EthSq Handle returned from EthSqCreate
+
+@return
+ This function always return BE_SUCCESS.
+
+@note
+ This function frees memory allocated by EthSqCreate for the EthSq Object.
+
+*/
+BESTATUS be_eth_sq_destroy(IN PBE_ETHSQ_OBJECT eth_sq)
+{
+ BESTATUS status = 0;
+
+ ETHSQ_ASSERT(eth_sq);
+
+ /* Send ioctl to destroy the queue. */
+ status =
+ be_function_ring_destroy(eth_sq->parent_function, eth_sq->bid,
+ IOCTL_RING_TYPE_ETH_TX);
+ ASSERT(status == 0);
+
+ /* Derefence any associated CQs. */
+ be_cq_object_dereference(eth_sq->cq_object);
+
+ /* Remove from function */
+ _be_function_remove_eth_sq(eth_sq->parent_function, eth_sq);
+
+ /* Clear tracking object */
+ sa_zero_mem(eth_sq, sizeof(*eth_sq));
+
+ return status;
+}
+
+/*!
+
+@brief
+ This routine attempts to set the transmit flow control parameters.
+
+@param
+ FunctionObject - Handle to a function object
+
+@param
+ txfc_enable - transmit flow control enable - true for
+ enable, false for disable
+
+@param
+ rxfc_enable - receive flow control enable - true for
+ enable, false for disable
+
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+ code is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+
+ This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_set_flow_control(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean txfc_enable, IN boolean rxfc_enable)
+{
+ IOCTL_COMMON_SET_FLOW_CONTROL *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_SET_FLOW_CONTROL);
+
+ ioctl->params.request.rx_flow_control = rxfc_enable;
+ ioctl->params.request.tx_flow_control = txfc_enable;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "set flow control ioctl failed.");
+ goto error;
+ }
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
+
+/*!
+
+@brief
+ This routine attempts to get the transmit flow control parameters.
+
+@param
+ FunctionObject - Handle to a function object
+
+@param
+ txfc_enable - transmit flow control enable - true for
+ enable, false for disable
+
+@param
+ rxfc_enable - receive flow control enable - true for enable,
+ false for disable
+
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS error code
+ is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+
+ This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_get_flow_control(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean *txfc_enable, IN boolean *rxfc_enable)
+{
+ IOCTL_COMMON_GET_FLOW_CONTROL *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_GET_FLOW_CONTROL);
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "get flow control ioctl failed.");
+ goto error;
+ }
+
+ *txfc_enable = ioctl->params.response.tx_flow_control;
+ *rxfc_enable = ioctl->params.response.rx_flow_control;
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_set_qos
+ * This function sets the ethernet transmit Quality of Service (QoS)
+ * characteristics of BladeEngine for the domain. All ethernet
+ * transmit rings of the domain will evenly share the bandwidth.
+ * The exeception to sharing is the host primary (super) ethernet
+ * transmit ring as well as the host ethernet forwarding ring
+ * for missed offload data.
+ * function_object -
+ * max_bps - the maximum bits per second in units of
+ * 10 Mbps (valid 0-100)
+ * max_pps - the maximum packets per second in units
+ * of 1 Kpps (0 indicates no limit)
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_qos(IN PBE_FUNCTION_OBJECT function_object,
+ IN u32 max_bps, IN u32 max_pps)
+{
+ IOCTL_COMMON_SET_QOS *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_SET_QOS);
+
+ /* Set fields in ioctl */
+ ioctl->params.request.max_bits_per_second_NIC = max_bps;
+ ioctl->params.request.max_packets_per_second_NIC = max_pps;
+ ioctl->params.request.valid_flags = QOS_BITS_NIC | QOS_PKTS_NIC;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "network set qos ioctl failed.");
+ }
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_get_qos
+ * This function retrieves the ethernet transmit Quality of Service (QoS)
+ * characteristics for the domain.
+ * function_object -
+ * max_bps - the maximum bits per second in units of
+ * 10 Mbps (valid 0-100)
+ * max_pps - the maximum packets per second in units of
+ * 1 Kpps (0 indicates no limit)
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_qos(IN PBE_FUNCTION_OBJECT function_object,
+ IN u32 *max_bps, IN u32 *max_pps)
+{
+ IOCTL_COMMON_GET_QOS *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_GET_QOS);
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "network get qos ioctl failed.");
+ goto error;
+ }
+
+ *max_bps = ioctl->params.response.max_bits_per_second_NIC;
+ *max_pps = ioctl->params.response.max_packets_per_second_NIC;
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_set_frame_size
+ * This function sets the ethernet maximum frame size. The previous
+ * values are returned.
+ * function_object -
+ * tx_frame_size - maximum transmit frame size in bytes
+ * rx_frame_size - maximum receive frame size in bytes
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_frame_size(IN PBE_FUNCTION_OBJECT function_object,
+ IN OUT u32 *tx_frame_size,
+ IN OUT u32 *rx_frame_size)
+{
+ IOCTL_COMMON_SET_FRAME_SIZE *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_SET_FRAME_SIZE);
+ ioctl->params.request.max_tx_frame_size = *tx_frame_size;
+ ioctl->params.request.max_rx_frame_size = *rx_frame_size;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "network set frame size ioctl failed.");
+ goto error;
+ }
+
+ *tx_frame_size = ioctl->params.response.chip_max_tx_frame_size;
+ *rx_frame_size = ioctl->params.response.chip_max_rx_frame_size;
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/ethrx_ll.c benet/linux-2.6.24.2/drivers/message/beclib/ethrx_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/ethrx_ll.c 1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/ethrx_ll.c 2008-02-14 15:23:07.807205888 +0530
@@ -0,0 +1,430 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*!
+
+@brief
+ This routine creates a Ethernet receive ring.
+
+@param
+ function_object - handle to a function object
+@param
+ rq_base_va - base VA for the default receive ring. this must be
+ exactly 8K in length and continguous physical memory.
+@param
+ cq_object - handle to a previously created CQ to be associated
+ with the RQ.
+@param
+ pp_eth_rq - pointer to an opqaue handle where an eth
+ receive object is returned.
+@return
+ BE_SUCCESS if successfull, , otherwise a useful
+ BESTATUS error code is returned.
+@note
+ IRQL: < DISPATCH_LEVEL
+ this function allocates a PBE_ETHRQ_OBJECT object.
+ there must be no more than 1 of these per function object, unless the
+ function object supports RSS (is networking and on the host).
+ the rq_base_va must point to a buffer of exactly 8K.
+ the erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+ will be updated as appropriate on return
+*/
+BESTATUS
+be_eth_rq_create(PBE_FUNCTION_OBJECT function_object,
+ PSA_SGL sgl,
+ PBE_CQ_OBJECT cq_object,
+ PBE_CQ_OBJECT bcmc_cq_object, PBE_ETHRQ_OBJECT eth_rq)
+{
+ BESTATUS status = 0;
+ MCC_WRB *wrb = NULL;
+ IOCTL_COMMON_ETH_RX_CREATE *ioctl = NULL;
+
+ /* MPU will set the */
+ ASSERT(sgl);
+ ASSERT(eth_rq);
+
+ FUNCTION_ASSERT(function_object);
+ CQ_ASSERT(cq_object);
+
+ be_lock_wrb_post(function_object);
+
+ eth_rq->magic = BE_ETHRQ_MAGIC;
+ eth_rq->parent_function = function_object;
+ eth_rq->cq_object = cq_object;
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_ETH_RX_CREATE);
+
+ ioctl->params.request.num_pages = 2; /* required length */
+ ioctl->params.request.cq_id = be_cq_get_id(cq_object);
+
+ if (bcmc_cq_object) {
+ /* Only pd 0 host & storage can receive broadcast/multicast. */
+ if (be_function_get_pd_number(function_object) != 0) {
+ TRACE(DL_WARN,
+ "bcmc_cq_object ignored for pd_number:%d",
+ be_function_get_pd_number(function_object));
+ }
+ ioctl->params.request.bcmc_cq_id =
+ be_cq_get_id(bcmc_cq_object);
+ } else {
+ ioctl->params.request.bcmc_cq_id = 0xFFFF;
+ }
+
+ /* Create a page list for the IOCTL. */
+ be_sgl_to_pa_list(sgl,
+ ioctl->params.request.pages,
+ SA_NUMBER_OF(ioctl->params.request.pages));
+
+ /* Post the Ioctl */
+ status =
+ be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+ ioctl);
+ if (status != BE_SUCCESS) {
+ TRACE(DL_ERR, "ioctl to map eth rxq frags failed.");
+ goto Error;
+ }
+ /* Save the ring ID for cleanup. */
+ eth_rq->rid = ioctl->params.response.id;
+
+ be_cq_object_reference(cq_object);
+
+ _be_function_add_eth_rq(function_object, eth_rq);
+
+ TRACE(DL_INFO,
+ "eth rq created. function:%d pd:%d bytes:%d bcmc_id:%d cq_id:%d",
+ be_function_get_function_number(function_object),
+ be_function_get_pd_number(function_object),
+ sa_sgl_get_page_count(sgl) * SA_PAGE_SIZE,
+ (bcmc_cq_object ? be_cq_get_id(bcmc_cq_object) : -1),
+ be_cq_get_id(cq_object));
+
+Error:
+
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+
+@brief
+ This routine returns the RID for an Ethernet receive queue
+
+@param
+ EthRq - Ethernet receive queue handle returned from EthRqCreate
+
+@return
+ Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+@note
+ IRQL: <= DISPATCH_LEVEL
+*/
+u32 be_eth_rq_get_id(IN PBE_ETHRQ_OBJECT rq)
+{
+ ETHRQ_ASSERT(rq);
+ return rq->rid;
+}
+
+/*!
+
+@brief
+ This routine destroys an Ethernet receive queue
+
+@param
+ eth_rq - ethernet receive queue handle returned from eth_rq_create
+
+@return
+ Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+@note
+ This function frees resourcs allocated by EthRqCreate.
+ The erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+ will be updated as appropriate on return
+ IRQL: < DISPATCH_LEVEL
+*/
+
+void be_eth_rq_destroy_internal_callback(PVOID context, BESTATUS status,
+ MCC_WRB *wrb)
+{
+ PBE_ETHRQ_OBJECT eth_rq = (PBE_ETHRQ_OBJECT) context;
+ ETHRQ_ASSERT(eth_rq);
+
+ if (status != BE_SUCCESS) {
+ TRACE(DL_ERR,
+ "Destroy eth rq failed in internal callback.\n");
+ } else {
+ /* Dereference any CQs associated with this queue. */
+ be_cq_object_dereference(eth_rq->cq_object);
+
+ /* Remove from the function object. */
+ _be_function_remove_eth_rq(eth_rq->parent_function,
+ eth_rq);
+ }
+
+ return;
+}
+
+BESTATUS
+be_eth_rq_destroy_async(IN PBE_ETHRQ_OBJECT eth_rq,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context)
+{
+ BESTATUS status = BE_SUCCESS;
+ ETHRQ_ASSERT(eth_rq);
+
+ /* Send ioctl to destroy the RQ. */
+ status = be_function_ring_destroy_async(eth_rq->parent_function,
+ eth_rq->rid,
+ IOCTL_RING_TYPE_ETH_RX,
+ callback,
+ callback_context,
+ be_eth_rq_destroy_internal_callback,
+ eth_rq);
+
+ return status;
+}
+
+BESTATUS be_eth_rq_destroy(IN PBE_ETHRQ_OBJECT eth_rq)
+{
+ return be_eth_rq_destroy_async(eth_rq, NULL, NULL);
+}
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_eth_rq_destroy_options
+ * Destroys an ethernet receive ring with finer granularity options
+ * than the standard be_eth_rq_destroy() API function.
+ * eth_rq -
+ * flush - Set to 1 to flush the ring, set to 0 to bypass the flush
+ * callback - Callback function on completion
+ * callback_context - Callback context
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *----------------------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_options(IN PBE_ETHRQ_OBJECT eth_rq,
+ IN boolean flush,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context)
+{
+ IOCTL_COMMON_RING_DESTROY *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = BE_SUCCESS;
+ PBE_FUNCTION_OBJECT function_object = NULL;
+
+ ETHRQ_ASSERT(eth_rq);
+
+ function_object = eth_rq->parent_function;
+ FUNCTION_ASSERT(function_object);
+
+ be_lock_wrb_post(function_object);
+
+ TRACE(DL_INFO, "Destroy eth_rq ring id:%d, flush:%d", eth_rq->rid,
+ flush);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ ASSERT(wrb);
+ TRACE(DL_ERR, "No free MCC WRBs in destroy eth_rq ring.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_RING_DESTROY);
+
+ ioctl->params.request.id = eth_rq->rid;
+ ioctl->params.request.ring_type = IOCTL_RING_TYPE_ETH_RX;
+ ioctl->params.request.bypass_flush = ((0 == flush) ? 1 : 0);
+
+ /* Post the Ioctl */
+ status =
+ be_function_post_mcc_wrb_with_internal_callback
+ (function_object, wrb, NULL, callback, callback_context,
+ be_eth_rq_destroy_internal_callback, eth_rq, ioctl);
+
+ if (status != BE_SUCCESS && status != BE_PENDING) {
+ TRACE(DL_ERR,
+ "eth_rq ring destroy ioctl failed. id:%d, flush:%d",
+ eth_rq->rid, flush);
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+
+@brief
+ This routine queries the frag size for erx.
+
+@param
+ function_object - handle to a function object
+
+@param
+ frag_size_bytes - erx frag size in bytes that is/was set.
+
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+ code is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+
+*/
+BESTATUS
+be_eth_rq_get_frag_size(IN PBE_FUNCTION_OBJECT function_object,
+ OUT u32 *frag_size_bytes)
+{
+ IOCTL_ETH_GET_RX_FRAG_SIZE *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ ASSERT(frag_size_bytes);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ return BE_STATUS_NO_MCC_WRB;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ ETH_GET_RX_FRAG_SIZE);
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, /* context */
+ ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "get frag size ioctl failed.");
+ goto error;
+ }
+
+ *frag_size_bytes =
+ 1 << ioctl->params.response.actual_fragsize_log2;
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
+
+/*!
+
+@brief
+ This routine attempts to set the frag size for erx. If the frag size is
+ already set, the attempt fails and the current frag size is returned.
+
+@param
+ FunctionObject - Handle to a function object
+
+@param
+ FragSizeEncoded - Encoded erx frag size to attempt to set to.
+
+@param
+ FragSizeBytes - Erx frag size in bytes that is/was set.
+
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+ code is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+
+ This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_rq_set_frag_size(IN PBE_FUNCTION_OBJECT function_object,
+ IN u32 new_frag_size_bytes,
+ OUT u32 *current_frag_size_bytes)
+{
+ IOCTL_ETH_SET_RX_FRAG_SIZE *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+
+ ASSERT(current_frag_size_bytes);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto error;
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ ETH_SET_RX_FRAG_SIZE);
+
+ ASSERT(new_frag_size_bytes >= 128 &&
+ new_frag_size_bytes <= 16 * 1024);
+
+ /* This is the log2 of the fragsize. This is not the exact
+ * ERX encoding. */
+ ioctl->params.request.new_fragsize_log2 =
+ sa_log2(new_frag_size_bytes);
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+ NULL, /* context */
+ ioctl);
+
+ if (status != 0) {
+ TRACE(DL_ERR, "set frag size ioctl failed.");
+ goto error;
+ }
+
+ *current_frag_size_bytes =
+ 1 << ioctl->params.response.actual_fragsize_log2;
+
+error:
+ be_unlock_wrb_post(function_object);
+
+ return status;
+}
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/rxf_ll.c benet/linux-2.6.24.2/drivers/message/beclib/rxf_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/rxf_ll.c 1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/rxf_ll.c 2008-02-14 15:32:13.489249608 +0530
@@ -0,0 +1,1008 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*!
+
+@brief
+ This routine adds, removes, or reads a WoL magic packet.
+
+@param
+ FunctionObject - Function object handle.
+
+@param
+ Mac1 - Set to TRUE if this function will operate on
+ the MAC 1 Magic Packet.
+
+@param
+ Operation - Operation to perform.
+
+@param
+ Pattern - Pattern to set, or the pattern returned.
+
+@param
+ PatternMask - Pattern mask to set, or the pattern mask returned.
+
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+
+*/
+BESTATUS be_rxf_wake_on_lan_config(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean enable_port0, IN boolean enable_port1,
+ IN boolean magic_packet_enable, IN u32 index,
+ IN PVOID pattern, IN PVOID pattern_mask,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_WAKE_ON_LAN_QUEUE_CONTEXT queue_context
+ )
+{
+ IOCTL_ETH_ACPI_CONFIG *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = BE_SUCCESS;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ FUNCTION_ASSERT(function_object);
+
+ /* Valid range for index is 0-3. */
+ ASSERT(index < 4);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ ETH_ACPI_CONFIG);
+
+ ioctl->params.request.index = index;
+ ioctl->params.request.port0 = enable_port0;
+ ioctl->params.request.port1 = enable_port1;
+ ioctl->params.request.magic_packet = magic_packet_enable;
+
+ if (enable_port0 || enable_port1) {
+
+ if (pattern) {
+ sa_memcpy(ioctl->params.request.byte_pattern,
+ pattern,
+ sizeof(ioctl->params.request.
+ byte_pattern));
+ }
+ if (pattern_mask) {
+ sa_memcpy(ioctl->params.request.bit_mask,
+ pattern_mask,
+ sizeof(ioctl->params.request.bit_mask));
+ }
+ /* Track which indicies are enabled/disabled */
+ function_object->config.wol_bitmask |= (1 << index);
+ } else {
+
+ /* Track which indicies are enabled/disabled */
+ function_object->config.wol_bitmask &= ~(1 << index);
+ }
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb,
+ generic_context,
+ callback,
+ callback_context,
+ ioctl);
+
+ if (status < 0) {
+ TRACE(DL_ERR, "wake-on-lan ioctl failed.");
+ goto Error;
+ }
+
+ Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+@brief
+ This routine gets or sets a mac address for a domain
+ given the port and mac.
+@param
+ FunctionObject - Function object handle.
+@param
+ Port1 - Set to TRUE if this function will set/get the Port 1
+ address. Only the host may set this to TRUE.
+@param
+ Mac1 - Set to TRUE if this function will set/get the
+ MAC 1 address. Only the host may set this to TRUE.
+@param
+ Write - Set to TRUE if this function should write the mac address.
+@param
+ MacAddress - Buffer of the mac address to read or write.
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+ IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_mac_address_read_write(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean port1, /* VM must always set to false */
+ IN boolean mac1, /* VM must always set to false */
+ IN boolean mgmt, IN boolean write,
+ IN boolean permanent, IN OUT PSA_MAC_ADDRESS mac_address,
+ IN MCC_WRB_CQE_CALLBACK callback, /* optional */
+ IN PVOID callback_context) /* optional */
+{
+ BESTATUS status = BE_SUCCESS;
+ union {
+ IOCTL_COMMON_NTWK_MAC_QUERY *query;
+ IOCTL_COMMON_NTWK_MAC_SET *set;
+ } ioctl = {
+ 0};
+ MCC_WRB *wrb = NULL;
+ u32 type = 0;
+
+ FUNCTION_ASSERT(function_object);
+
+ be_lock_wrb_post(function_object);
+
+ ASSERT(mac_address);
+
+ ASSERT(port1 == FALSE
+ || be_function_is_vm(function_object) == FALSE);
+ ASSERT(mac1 == FALSE
+ || be_function_is_vm(function_object) == FALSE);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ TRACE(DL_ERR, "MCC wrb peek failed.");
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+
+ if (mgmt) {
+ type = MAC_ADDRESS_TYPE_MANAGEMENT;
+ } else if (be_function_is_vm(function_object) &&
+ be_function_is_networking(function_object)) {
+ type = MAC_ADDRESS_TYPE_PD;
+ } else {
+ if (be_function_is_networking(function_object)) {
+ type = MAC_ADDRESS_TYPE_NETWORK;
+ } else {
+ type = MAC_ADDRESS_TYPE_STORAGE;
+ }
+ }
+
+ if (write) {
+ /* Prepares an embedded ioctl, including
+ * request/response sizes.
+ */
+ ioctl.set = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object,
+ wrb, COMMON_NTWK_MAC_SET);
+
+ ioctl.set->params.request.invalidate = 0;
+ ioctl.set->params.request.mac1 = (mac1 ? 1 : 0);
+ ioctl.set->params.request.port = (port1 ? 1 : 0);
+ ioctl.set->params.request.type = type;
+
+ /* Copy the mac address to set. */
+ ioctl.set->params.request.mac.SizeOfStructure =
+ sizeof(ioctl.set->params.request.mac);
+ sa_memcpy(ioctl.set->params.request.mac.MACAddress,
+ mac_address, sizeof(*mac_address));
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb(function_object,
+ wrb,
+ callback,
+ callback_context,
+ ioctl.set);
+
+ } else {
+
+ /*
+ * Prepares an embedded ioctl, including
+ * request/response sizes.
+ */
+ ioctl.query =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object,
+ wrb, COMMON_NTWK_MAC_QUERY);
+
+ ioctl.query->params.request.mac1 = (mac1 ? 1 : 0);
+ ioctl.query->params.request.port = (port1 ? 1 : 0);
+ ioctl.query->params.request.type = type;
+ ioctl.query->params.request.permanent = permanent;
+
+ /* Post the Ioctl (with a copy for the response) */
+ status = be_function_post_mcc_wrb_with_copy(function_object,
+ wrb, NULL, /* queue context */
+ callback,
+ callback_context,
+ ioctl.query,
+ BE_CREATE_MCC_RESPONSE_COPY
+ (IOCTL_COMMON_NTWK_MAC_QUERY,
+ params.
+ response.mac.
+ MACAddress,
+ mac_address));
+ }
+
+ if (status < 0) {
+ TRACE(DL_ERR, "mac set/query failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+@brief
+ This routine writes data to context memory.
+@param
+ FunctionObject - Function object handle.
+@param
+ McHashTable - Set to the 128-bit multicast address hash table.
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+ IRQL: < DISPATCH_LEVEL
+*/
+
+BESTATUS be_rxf_multicast_config(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean promiscuous, IN u32 num,
+ IN SA_MAC_ADDRESS *mac_table,
+ IN MCC_WRB_CQE_CALLBACK callback, /* optional */
+ IN PVOID callback_context,
+ IN PBE_MULTICAST_QUEUE_CONTEXT queue_context)
+{
+ BESTATUS status = BE_SUCCESS;
+ IOCTL_COMMON_NTWK_MULTICAST_SET *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ FUNCTION_ASSERT(function_object);
+ ASSERT(num <=
+ SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_MULTICAST_SET,
+ params.request.mac));
+
+ if (num > SA_NUMBER_OF_FIELD(
+ IOCTL_COMMON_NTWK_MULTICAST_SET, params.request.mac)) {
+ TRACE(DL_ERR, "Too many multicast addresses. BE supports %d.",
+ SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_MULTICAST_SET,
+ params.request.mac));
+ return BE_NOT_OK;
+ }
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context =
+ (PBE_GENERIC_QUEUE_CONTEXT) queue_context;
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_NTWK_MULTICAST_SET);
+
+ TRACE(DL_INFO,
+ "multicast config. function:%d promiscuous:%d num:%d",
+ be_function_get_function_number(function_object),
+ promiscuous, num);
+
+ ioctl->params.request.promiscuous = promiscuous;
+ if (!promiscuous) {
+
+ ioctl->params.request.num_mac = num;
+
+ if (num > 0) {
+ u32 i = 0;
+
+ ASSERT(mac_table);
+ sa_memcpy(ioctl->params.request.mac, mac_table,
+ 6 * num);
+ for (i = 0; i < num; i++) {
+ TRACE(DL_VERBOSE,
+ " multicast address[%d]: "
+ SA_MAC_FORMAT, i,
+ SA_MAC_ARGS(mac_table[i]));
+ }
+ }
+ /* track number of addresses */
+ function_object->config.num_multicast = num;
+ } else {
+ /* track number of addresses */
+ function_object->config.num_multicast = 0xFF; /* infinite */
+ }
+
+ /* Post the Ioctl */
+ status =
+ be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb,
+ generic_context,
+ callback,
+ callback_context,
+ ioctl);
+ if (status < 0) {
+ TRACE(DL_ERR, "multicast ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+@brief
+ This routine adds or removes a vlan tag from the rxf table.
+@param
+ FunctionObject - Function object handle.
+@param
+ VLanTag - VLan tag to add or remove.
+@param
+ Add - Set to TRUE if this will add a vlan tag
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+ IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_vlan_config(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean promiscuous, IN u32 num,
+ IN u16 *vlan_tag_array,
+ IN MCC_WRB_CQE_CALLBACK callback, /* optional */
+ IN PVOID callback_context,
+ IN PBE_VLAN_QUEUE_CONTEXT queue_context) /* optional */
+{
+ BESTATUS status = BE_SUCCESS;
+ IOCTL_COMMON_NTWK_VLAN_CONFIG *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ FUNCTION_ASSERT(function_object);
+
+ ASSERT(num <=
+ SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_VLAN_CONFIG,
+ params.request.vlan_tag));
+ if (num >
+ SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_VLAN_CONFIG,
+ params.request.vlan_tag)) {
+ TRACE(DL_ERR, "Too many VLAN tags.");
+ return BE_NOT_OK;
+ }
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_NTWK_VLAN_CONFIG);
+
+ TRACE(DL_INFO, "vlan config. function:%d promiscuous:%d num:%d",
+ be_function_get_function_number(function_object),
+ promiscuous, num);
+
+ ioctl->params.request.promiscuous = promiscuous;
+ if (!promiscuous) {
+
+ ioctl->params.request.num_vlan = num;
+
+ if (num > 0) {
+ ASSERT(vlan_tag_array);
+ sa_memcpy(ioctl->params.request.vlan_tag,
+ vlan_tag_array,
+ num * sizeof(vlan_tag_array[0]));
+ }
+ /* Track number of tags */
+ function_object->config.num_vlan = num;
+
+ } else {
+ /* promiscuous mode, tracking number is set inifinite */
+ function_object->config.num_vlan = 0xFF;
+ }
+
+ /* Post the Ioctl */
+ status =
+ be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb,
+ generic_context,
+ callback,
+ callback_context,
+ ioctl);
+ if (status < 0) {
+ TRACE(DL_ERR, "vlan ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*!
+@brief
+ This routine assigns a CPU number to an RSS table.
+@param
+ FunctionObject - Function object handle.
+@param
+ RssEntry - The RSS entry (bucket) to assign this CPU to.
+@param
+ Cpu - The CPU number that incomming packets that hash to
+ the RssEntry bucket index will be directed to.
+@return
+ BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+@note
+ IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_rss_config(IN PBE_FUNCTION_OBJECT function_object,
+ IN u32 rss_type, /* use enumeration ENABLE_RSS_ENUM */
+ IN u32 num_cq, /* 2, 3, or 4 */
+ IN u32 *cq_id_array, /* Array of num_cq id values */
+ IN u32 default_cq_id, /* non-RSS default CQ ID */
+ IN u32 flush_mask, /* mask of CQs to flush */
+ IN PVOID hash, /* 16 bytes */
+ IN u32 cpu_table_length, /* bytes (power of 2 from 2 to 128) */
+ IN u8 *cpu_table, /* 2 to 128 bytes */
+ IN MCC_WRB_CQE_CALLBACK callback, /* optional */
+ IN PVOID callback_context,
+ IN PBE_RSS_QUEUE_CONTEXT queue_context) /* optional */
+{
+ BESTATUS status = BE_SUCCESS;
+ IOCTL_ETH_RSS_CONFIG *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ FUNCTION_ASSERT(function_object);
+
+ be_lock_wrb_post(function_object);
+
+ ASSERT(!be_function_is_vm(function_object));
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl =
+ BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ ETH_RSS_CONFIG);
+
+ ioctl->params.request.enable_rss = rss_type;
+ ioctl->params.request.cq_flush_mask = flush_mask;
+
+ if (cq_id_array) {
+ ioctl->params.request.cqid0 = cq_id_array[0];
+ ioctl->params.request.cqid1 = cq_id_array[1];
+ ioctl->params.request.cqid2 = cq_id_array[2];
+ ioctl->params.request.cqid3 = cq_id_array[3];
+ }
+
+ if (rss_type != RSS_ENABLE_NONE) {
+ ASSERT(num_cq >= 1 && num_cq <= 4);
+ ASSERT(cq_id_array);
+ ASSERT(hash);
+ }
+
+ if (hash) {
+ sa_memcpy(ioctl->params.request.hash, hash,
+ sizeof(ioctl->params.request.hash));
+ }
+ /*
+ * Double check the table. Each entry should be 0 to
+ * num_cq-1 corresponding to the index in the cq_id_array to use.
+ */
+ if (cpu_table_length > 0) {
+
+ ASSERT(cpu_table);
+ ASSERT(cpu_table_length <=
+ sizeof(ioctl->params.request.cpu_table));
+
+ ioctl->params.request.cpu_table_size_log2 =
+ sa_log2(cpu_table_length);
+ ASSERT(ioctl->params.request.cpu_table_size_log2 > 0
+ && ioctl->params.request.cpu_table_size_log2 <= 7);
+
+ sa_memcpy(ioctl->params.request.cpu_table, cpu_table,
+ cpu_table_length);
+ }
+
+ TRACE(DL_INFO, "RSS hash. 0x%08x 0x%08x 0x%08x 0x%08x",
+ ioctl->params.request.hash[0],
+ ioctl->params.request.hash[1],
+ ioctl->params.request.hash[2],
+ ioctl->params.request.hash[3]);
+
+ TRACE(DL_INFO,
+ "RSS table. log2(len):%d 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x"
+ " 0x%02x 0x%02x 0x%02x",
+ ioctl->params.request.cpu_table_size_log2,
+ ioctl->params.request.cpu_table[0],
+ ioctl->params.request.cpu_table[1],
+ ioctl->params.request.cpu_table[2],
+ ioctl->params.request.cpu_table[3],
+ ioctl->params.request.cpu_table[4],
+ ioctl->params.request.cpu_table[5],
+ ioctl->params.request.cpu_table[6],
+ ioctl->params.request.cpu_table[7]);
+
+ /* software tracking */
+ function_object->config.rss_type = rss_type;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb, generic_context, callback,
+ callback_context, ioctl);
+ if (status < 0) {
+ TRACE(DL_ERR, "rss ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+BESTATUS be_rxf_link_status(IN PBE_FUNCTION_OBJECT function_object,
+ OUT BE_LINK_STATUS *link_status,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_LINK_STATUS_QUEUE_CONTEXT queue_context) /* optional */
+{
+ IOCTL_COMMON_NTWK_LINK_STATUS_QUERY *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ ASSERT(link_status);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_NTWK_LINK_STATUS_QUERY);
+
+ /* Post or queue the Ioctl */
+ status = be_function_post_mcc_wrb_with_copy(function_object, wrb,
+ generic_context, /* Queue context */
+ callback,
+ callback_context,
+ ioctl,
+ BE_CREATE_MCC_RESPONSE_COPY
+ (IOCTL_COMMON_NTWK_LINK_STATUS_QUERY,
+ params.response,
+ link_status));
+
+ if (status < 0) {
+ TRACE(DL_ERR, "link status ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+BESTATUS
+be_rxf_query_eth_statistics(IN PBE_FUNCTION_OBJECT function_object,
+ IN IOCTL_ETH_GET_STATISTICS *va_for_ioctl,
+ IN u64 pa_for_ioctl,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_ETH_STATS_QUEUE_CONTEXT queue_context)
+{
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ ASSERT(va_for_ioctl);
+ ASSERT(pa_for_ioctl);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+
+ TRACE(DL_INFO,
+ "Query eth stats. ioctl va:%p pa:0x%08x_%08x",
+ va_for_ioctl, sa_hi(pa_for_ioctl), sa_lo(pa_for_ioctl));
+
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ va_for_ioctl =
+ BE_FUNCTION_PREPARE_NONEMBEDDED_IOCTL(function_object, wrb,
+ va_for_ioctl, pa_for_ioctl, ETH_GET_STATISTICS);
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb, generic_context, callback, callback_context,
+ va_for_ioctl);
+
+ if (status < 0) {
+ TRACE(DL_ERR, "eth stats ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+BESTATUS
+be_rxf_promiscuous(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean enable_port0,
+ IN boolean enable_port1,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_PROMISCUOUS_QUEUE_CONTEXT queue_context)
+{
+ IOCTL_ETH_PROMISCUOUS *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ ETH_PROMISCUOUS);
+
+ ioctl->params.request.port0_promiscuous = enable_port0;
+ ioctl->params.request.port1_promiscuous = enable_port1;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb, generic_context, callback, callback_context,
+ ioctl);
+
+ if (status < 0) {
+ TRACE(DL_ERR, "promiscuous ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*
+ *------------------------------------------------------------------
+ * Function: be_rxf_force_failover
+ * Forces failure of all traffic to the specified MAC port.
+ * Use the be_rxf_link_status to query to active port. Automatic
+ * failover feature of BladeEngine is implicitly disabled with this call.
+ * function_object -
+ * port - Port to use, 0 or 1.
+ * callback - optional
+ * callback_context - optional
+ * queue_context - Optional. Pointer to a previously allocated
+ * BE_QUEUE_CONTEXT struct. If the MCC WRB ring is
+ * full, this structure is used to queue the operation.
+ * It will be posted to the MCC ring when space
+ * becomes available. All queued commands will be
+ * posted to the ring in the order they are received.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * BE_PENDING (postive value) if the IOCTL
+ * completion is pending. Negative error code on failure.
+ *--------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_force_failover(IN PBE_FUNCTION_OBJECT function_object,
+ IN u32 port,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_FORCE_FAILOVER_QUEUE_CONTEXT queue_context)
+{
+ IOCTL_COMMON_FORCE_FAILOVER *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_FORCE_FAILOVER);
+
+ ASSERT(port == 0 || port == 1);
+ ioctl->params.request.move_to_port = port;
+ ioctl->params.request.failover_config = FAILOVER_CONFIG_OFF;
+
+ /* Post the Ioctl */
+ status = be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb,
+ generic_context,
+ callback,
+ callback_context,
+ ioctl);
+
+ if (status < 0) {
+ TRACE(DL_ERR, "force failover ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*
+ *--------------------------------------------------------------------------
+ * Function: be_rxf_manage_autofailover
+ * Enables or disables BladeEngine automatic port failover.
+ * function_object -
+ * enable - Set to 1 to enable the feature. Set to 0 to disable
+ * the feature.
+ * callback - Optional callback function. When the command
+ * completes the callback function will be called
+ * with the callback context.
+ * callback_context - Optional callback context.
+ * queue_context - Optional. Pointer to a previously allocated
+ * BE_QUEUE_CONTEXT struct. If the MCC WRB ring is full,
+ * this structure is used to queue the operation. It
+ * will be posted to the MCC ring when space
+ * becomes available. All queued commands will
+ * be posted to the ring in the order they are received.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * BE_PENDING (postive value) if the IOCTL
+ * completion is pending. Negative error code on failure.
+ *-----------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_manage_autofailover(IN PBE_FUNCTION_OBJECT function_object,
+ IN boolean enable,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_FORCE_FAILOVER_QUEUE_CONTEXT
+ queue_context)
+{
+ IOCTL_COMMON_FORCE_FAILOVER *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_FORCE_FAILOVER);
+
+ if (enable) {
+ ioctl->params.request.failover_config = FAILOVER_CONFIG_ON;
+ } else {
+ ioctl->params.request.failover_config =
+ FAILOVER_CONFIG_OFF;
+ }
+ ioctl->params.request.move_to_port = FAILOVER_PORT_NONE;
+
+ /* Post the Ioctl */
+ status =
+ be_function_post_mcc_wrb_with_queue_context(function_object,
+ wrb,
+ generic_context,
+ callback,
+ callback_context,
+ ioctl);
+
+ if (status < 0) {
+ TRACE(DL_ERR, "manage autofailover ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}
+
+/*
+ *-------------------------------------------------------------------------
+ * Function: be_rxf_filter_config
+ * Configures BladeEngine ethernet receive filter settings.
+ * function_object -
+ * settings - Pointer to the requested filter settings.
+ * The response from BladeEngine will be placed back
+ * in this structure.
+ * callback - optional
+ * callback_context - optional
+ * queue_context - Optional. Pointer to a previously allocated struct.
+ * If the MCC WRB ring is full, this structure is
+ * used to queue the operation. It will be posted
+ * to the MCC ring when space becomes available. All
+ * queued commands will be posted to the ring in
+ * the order they are received. It is always valid
+ * to pass a pointer to a generic
+ * BE_GENERIC_QUEUE_CONTEXT. However, the specific
+ * context structs are generally smaller than
+ * the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * BE_PENDING (postive value) if the IOCTL
+ * completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_filter_config(IN PBE_FUNCTION_OBJECT function_object,
+ IN OUT NTWK_RX_FILTER_SETTINGS *settings,
+ IN MCC_WRB_CQE_CALLBACK callback,
+ IN PVOID callback_context,
+ IN PBE_RXF_FILTER_QUEUE_CONTEXT queue_context)
+{
+ IOCTL_COMMON_NTWK_RX_FILTER *ioctl = NULL;
+ MCC_WRB *wrb = NULL;
+ BESTATUS status = 0;
+ PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+ ASSERT(settings);
+
+ be_lock_wrb_post(function_object);
+
+ wrb = be_function_peek_mcc_wrb(function_object);
+
+ if (!wrb) {
+ if (queue_context && callback) {
+ wrb = (MCC_WRB *) &queue_context->wrb_header;
+ generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+ queue_context; /* Indicate to queue */
+ generic_context->context.bytes =
+ sizeof(*queue_context);
+ } else {
+ status = BE_STATUS_NO_MCC_WRB;
+ goto Error;
+ }
+ }
+ /* Prepares an embedded ioctl, including request/response sizes. */
+ ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+ COMMON_NTWK_RX_FILTER);
+ sa_memcpy(&ioctl->params.request, settings, sizeof(*settings));
+
+ /* Post or queue the Ioctl */
+ status = be_function_post_mcc_wrb_with_copy(function_object,
+ wrb, generic_context, /* Queue context */
+ callback,
+ callback_context,
+ ioctl,
+ BE_CREATE_MCC_RESPONSE_COPY
+ (IOCTL_COMMON_NTWK_RX_FILTER,
+ params.response,
+ settings));
+
+ if (status < 0) {
+ TRACE(DL_ERR, "RXF/ERX filter config ioctl failed.");
+ goto Error;
+ }
+
+Error:
+ be_unlock_wrb_post(function_object);
+ return status;
+}

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

