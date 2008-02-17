From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 3/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:31:15 -0800
Message-ID: <20080217023115.88b5a64e@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:36552 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbYBQCbU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:31:20 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:31:16 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool, proc files, Kconfig, Makefile etc.

----------------------------------
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/bni.c benet/linux-2.6.24.2/drivers/net/benet/bni.c
--- orig/linux-2.6.24.2/drivers/net/benet/bni.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/bni.c	2008-02-14 15:23:07.794207864 +0530
@@ -0,0 +1,1506 @@
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
+/*
+
+@file
+    bni.c
+
+@brief
+    This file contains finctions that will be used by the BladeEngine
+    Network drivers to access BladeEngine Hardware. All code in
+    this file must be completely OS neutral.
+
+*/
+
+#include "bni.h"
+
+/*
+ * Initial Interrupt coalascing related parameters.
+ * Never enable Watermark on Compl ring without eq_delay enabled
+ */
+u32 tx_cmpl_wm = CEV_WMARK_96;	/* 0xffffffff to disable */
+u32 rx_cmpl_wm = CEV_WMARK_160;	/* 0xffffffff to disable */
+u32 eq_delay;		/* delay in 8usec units. 0xffffffff to disable */
+
+/*!
+   This function initializes the data structures in BNI / BECLIB for network
+   operation.  The OSM driver must call this function before making any other
+   BNI call.
+
+   If this functions succeeds, the caller must call bni_cleanup() as part
+   of driver cleanup procedure.
+
+@param
+    chipobj      -  Address of the space allocated by OSM for FunctionObject
+			(BE_CHIP_OBJECT).  The space for this is allocated by
+			OSM, but this object is maintained by BECLIB and is
+			opaque to OSM.
+@return
+    BESTATUS - (0 if successful, non-zero status code if not successful)
+
+ */
+BESTATUS bni_init(PBE_CHIP_OBJECT chipobj)
+{
+	int r;
+	r = be_initialize_library();
+	if (r != BE_SUCCESS) {
+		TRACE(DL_ERR, "be_initialize_library() failed - %x\n", r);
+		goto error;
+	}
+	r = be_chip_object_create(chipobj);
+	if (r != BE_SUCCESS) {
+		TRACE(DL_ERR, "be_chip_object_create() failed - %x\n", r);
+		goto error;
+	}
+
+      error:
+	if (r != BE_SUCCESS) {
+		TRACE(DL_ERR, "bni_init failed. Cleaning up everything.");
+	}
+
+	return (r);
+}
+
+/*!
+   This function initializes the data structures in BNI / BECLIB for network
+   operation.  The OSM driver must call this function before making any other
+   BNI call.
+
+@param
+    chipobj        -  Pointer to the chip object passed as argument
+			to bni_init().
+ */
+void bni_cleanup(PBE_CHIP_OBJECT chipobj)
+{
+	SA_ASSERT(chipobj);
+
+	be_chip_object_destroy(chipobj);
+}
+
+/*!
+@brief
+    This function initializes the BNI_NET_OBJECT for subsequent
+    network operations. As part of the initialization, this function
+    registers this device with beclib and creates the
+    required set of queues (rings) that are needed to interact
+    with BaldeEngine as a network NIC device and registers them
+    with BladeEngine.
+
+    Before calling this function, the OSM driver  must have allocated
+    space for the NetObject structure, initialized the structure,
+    allocated DMAable memory for all the network queues that form
+    part of the NetObject and populated the start address (virtual)
+    and number of entries allocated for each queue in the NetObject structure.
+
+    The OSM driver must also have allocated memory to hold the
+    mailbox structure (MCC_MAILBOX) and post the physical address,
+    virtual addresses and the size of the mailbox memory in the
+    NetObj.mb_sgl.  This structure is used by BECLIB for
+    initial communication with the embedded MCC processor. BECLIB
+    uses the mailbox until MCC rings are created for  more  efficient
+    communication with the MCC processor.
+
+    If the OSM driver wants to create multiple network interface for more
+    than one protection domain, it can call bni_create_netobj()
+    multiple times  once for each protection domain.  A Maximum of
+    32 protection domains are supported.
+
+@param
+    pnob - Pointer to the NetObject structure
+    pbars         -  Pointer to the BAR address structure containing
+			the addresses assigned OS to various BARS of the
+			network PCI function of BladeEngine.
+
+    nbars         -  Number of BARs in the BAR structure.
+
+    sa_devp        -  Address of the space allocated for SA_DEVICE structure.
+			This structure is initialized by the BECLIB and is
+			opaque to the OSM drivers.
+
+    chipobj      -  Address of the space allocated by OSM for FunctionObject
+		     (BE_CHIP_OBJECT).  The space for this is allocated by OSM,
+		     but this object is maintained by BECLIB and is
+		     opaque to OSM.
+@return
+    BESTATUS - (0 if successful, non-zero status code if not successful)
+*/
+BESTATUS
+bni_create_netobj(PBNI_NET_OBJECT pnob,
+		  SA_DEV_BAR_LOCATIONS *pbars,
+		  u32 nbars, SA_DEV *sa_devp, PBE_CHIP_OBJECT chipobj)
+{
+	BESTATUS Status = 0;
+	BOOLEAN eventable = FALSE, tx_no_delay = FALSE, rx_no_delay =
+	    FALSE;
+	PBE_EQ_OBJECT eq_objectp = NULL;
+	PBE_FUNCTION_OBJECT pfob = &pnob->fn_obj;
+	SA_SGL sgl;
+	SA_STATUS r;
+	u32 tempSz;
+
+	memset(&sgl, 0, sizeof(SA_SGL));
+	r = sa_dev_create(pbars, nbars, 0, sa_devp);
+	if (r != SA_SUCCESS) {
+		TRACE(DL_ERR, "sa_dev_create() failed - %x\n", r);
+		return r;
+	}
+
+	Status = be_function_object_create(sa_devp,
+						BE_FUNCTION_TYPE_NETWORK,
+						&pnob->mb_sgl,
+						pfob,
+						chipobj);
+	if (Status != BE_SUCCESS) {
+		TRACE(DL_ERR, "be_function_object_create() failed - %x\n", r);
+		return Status;
+		/*
+		 * the function object is ZERO'd so nothing to do after
+		 * this .
+		 */
+	}
+
+	if (tx_cmpl_wm == 0xffffffff)
+		tx_no_delay = TRUE;
+	if (rx_cmpl_wm == 0xffffffff)
+		rx_no_delay = TRUE;
+	/*
+	 * now create the necessary rings
+	 * Event Queue first.
+	 */
+	if (pnob->event_q_len) {
+		(void)sa_sgl_create_contiguous(pnob->event_q,
+					       pnob->event_q_pa,
+					       pnob->event_q_len *
+					       sizeof(EQ_ENTRY), &sgl);
+
+		Status = be_eq_create(pfob, &sgl, 4, pnob->event_q_len,
+				(u32) -1,	/* CEV_WMARK_* or -1 */
+				eq_delay,	/* in 8us units, or -1 */
+				&pnob->event_q_obj);
+		if (Status != BE_SUCCESS)
+			goto error_ret;
+		pnob->event_q_id = be_eq_get_id(&pnob->event_q_obj);
+		pnob->event_q_created = 1;
+		eventable = TRUE;
+		eq_objectp = &pnob->event_q_obj;
+	}
+	/*
+	 * Now Eth Tx Compl. queue.
+	 */
+	if (pnob->txcq_len) {
+
+		(void)sa_sgl_create_contiguous(pnob->tx_cq, pnob->tx_cq_pa,
+					       pnob->txcq_len *
+					       sizeof(ETH_TX_COMPL), &sgl);
+		Status = be_cq_create(pfob, &sgl,
+				pnob->txcq_len * sizeof(ETH_TX_COMPL),
+				FALSE,	/* solicted events,  */
+				tx_no_delay,	/* nodelay  */
+				tx_cmpl_wm,	/* Watermark encodings */
+				eq_objectp, &pnob->tx_cq_obj);
+		if (Status != BE_SUCCESS)
+			goto error_ret;
+
+		pnob->tx_cq_id = be_cq_get_id(&pnob->tx_cq_obj);
+		pnob->tx_cq_created = 1;
+	}
+	/*
+	 * Eth Tx queue
+	 */
+	if (pnob->tx_q_len) {
+		BE_ETH_SQ_PARAMETERS ex_params = { 0 };
+		u32 type;
+
+		if (pnob->tx_q_port) {
+			/* TXQ to be bound to a specific port */
+			type = BE_ETH_TX_RING_TYPE_BOUND;
+			ex_params.port = pnob->tx_q_port - 1;
+		} else
+			type = BE_ETH_TX_RING_TYPE_STANDARD;
+
+		(void)sa_sgl_create_contiguous(pnob->tx_q, pnob->tx_q_pa,
+					       pnob->tx_q_len *
+					       sizeof(ETH_WRB), &sgl);
+		Status = be_eth_sq_create_ex(pfob, &sgl,
+				pnob->tx_q_len * sizeof(ETH_WRB),
+				type, 2,
+				&pnob->tx_cq_obj,
+				&ex_params, &pnob->tx_q_obj);
+
+		if (Status != BE_SUCCESS)
+			goto error_ret;
+
+		pnob->tx_q_id = be_eth_sq_get_id(&pnob->tx_q_obj);
+		pnob->tx_q_created = 1;
+	}
+	/*
+	 * Now Eth Broadcast Rx compl. Queue.  VM NetObjects will not need this
+	 */
+	if (pnob->bcrx_cq_len) {
+
+		(void)sa_sgl_create_contiguous(pnob->bcrx_cq,
+					       pnob->bcrx_cq_pa,
+					       pnob->bcrx_cq_len *
+					       sizeof(ETH_RX_COMPL), &sgl);
+		Status = be_cq_create(pfob, &sgl,
+			pnob->bcrx_cq_len * sizeof(ETH_RX_COMPL),
+			FALSE,	/* solicted events,  */
+			rx_no_delay,	/* nodelay  */
+			rx_cmpl_wm,	/* Watermark encodings */
+			eq_objectp, &pnob->bcrx_cq_obj);
+
+		if (Status != BE_SUCCESS)
+			goto error_ret;
+
+		pnob->bcrx_cq_id = be_cq_get_id(&pnob->bcrx_cq_obj);
+		pnob->bcrx_cq_created = 1;
+	}
+	/*
+	 * Now Eth Unicast Rx compl. queue.  Always needed.
+	 */
+	(void)sa_sgl_create_contiguous(pnob->ucrx_cq, pnob->ucrx_cq_pa,
+				       pnob->ucrx_cq_len *
+				       sizeof(ETH_RX_COMPL), &sgl);
+	Status = be_cq_create(pfob, &sgl,
+			pnob->ucrx_cq_len * sizeof(ETH_RX_COMPL),
+			FALSE,	/* solicted events,  */
+			rx_no_delay,	/* nodelay  */
+			rx_cmpl_wm,	/* Watermark encodings */
+			eq_objectp, &pnob->ucrx_cq_obj);
+	if (Status != BE_SUCCESS)
+		goto error_ret;
+
+	pnob->ucrx_cq_id = be_cq_get_id(&pnob->ucrx_cq_obj);
+	pnob->ucrx_cq_created = 1;
+
+	Status = be_eth_rq_set_frag_size(pfob,
+			pnob->rx_buf_size,	/* desired frag size in bytes */
+			(u32 *) &tempSz);	/* actual frag size set */
+	if (Status != BE_SUCCESS) {
+		be_eth_rq_get_frag_size(pfob, (u32 *) &pnob->rx_buf_size);
+		if ((pnob->rx_buf_size != 2048)
+		    && (pnob->rx_buf_size != 4096)
+		    && (pnob->rx_buf_size != 8192))
+			goto error_ret;
+	} else {
+		/*be_eth_rq_get_frag_size (pfob, (u32*)&pnob->rx_buf_size); */
+		if (pnob->rx_buf_size != tempSz) {
+			pnob->rx_buf_size = tempSz;
+			TRACE(DL_ERR,
+			      "%s: Could not set desired frag size. using %d\n",
+			      __FUNCTION__, pnob->rx_buf_size);
+		}
+	}
+	/*
+	 * Eth RX queue. be_eth_rq_create() always assumes 2 pages size
+	 */
+	(void)sa_sgl_create_contiguous(pnob->rx_q, pnob->rx_q_pa,
+				       pnob->rx_q_len * sizeof(ETH_RX_D),
+				       &sgl);
+	Status =
+	    be_eth_rq_create(pfob, &sgl, &pnob->ucrx_cq_obj,
+			     pnob->bcrx_cq_len ? &pnob->bcrx_cq_obj : NULL,
+			     &pnob->rx_q_obj);
+
+	if (Status != BE_SUCCESS)
+		goto error_ret;
+
+	pnob->rx_q_id = be_eth_rq_get_id(&pnob->rx_q_obj);
+	pnob->rx_q_created = 1;
+
+	return BE_SUCCESS;	/* All required queues created. */
+
+      error_ret:
+	/*
+	 *  Some queue creation failed.  Clean up any we successfully created.
+	 */
+	bni_destroy_netobj(pnob, sa_devp);
+	return Status;
+}
+
+/*!
+@brief
+   This function changes the EQ delay - the interval that BladeEngine
+   should wait after an event entry is made in an EQ before the host
+   is interrupted.
+
+@param
+    pnob - Pointer to the NetObject structure
+    Delay   - The delay in microseconds.  Must be between 0 and 240 and
+		must be a multiple of 8.
+
+@return
+    None
+*/
+BESTATUS bni_change_eqd(PBNI_NET_OBJECT pnob, u32 Delay)
+{
+	BESTATUS Status = 0;
+	PBE_EQ_OBJECT eq_objectp = NULL;
+	PBE_FUNCTION_OBJECT pfob = &pnob->fn_obj;
+
+	eq_objectp = &pnob->event_q_obj;
+
+	/*
+	 * Caller must ensure Delay <= 240 and is a multiple of 8.
+	 */
+	Status = be_eq_modify_delay(pfob, 1, &eq_objectp, &Delay,
+				    NULL, NULL, NULL);
+	if (Status < 0)
+		TRACE(DL_ERR, "bni_change_eqd failed \n");
+
+	return Status;
+}
+
+/*!
+@brief
+    This function creates the MCC request and completion ring required
+    for communicating with the ARM processor.  The caller must have
+    allocated required amount of memory for the MCC ring and MCC
+    completion ring and posted the virtual address and number of
+    entries in the corresponding members (mcc_q and mcc_cq) in the
+    NetObject struture.
+
+    When this call is completed, all further communication with
+    ARM will switch from mailbox to this ring.
+
+@param
+    pnob - Pointer to the NetObject structure.  This NetObject
+		should have been created using a previous call to
+		bni_create_netobj()
+
+@return
+    BESTATUS - (0 if successful, non-zero status code if not successful)
+*/
+BESTATUS bni_create_mcc_rings(PBNI_NET_OBJECT pnob)
+{
+	BESTATUS Status = 0;
+	SA_SGL sgl;
+	PBE_FUNCTION_OBJECT pfob = &pnob->fn_obj;
+
+	memset(&sgl, 0, sizeof(SA_SGL));
+
+	/*
+	 * Create the MCC completion ring.
+	 */
+	if (pnob->mcc_cq_len) {
+
+		(void)sa_sgl_create_contiguous(pnob->mcc_cq,
+					       pnob->mcc_cq_pa,
+					       pnob->mcc_cq_len *
+					       sizeof(MCC_CQ_ENTRY), &sgl);
+
+		Status = be_cq_create(pfob, &sgl,
+				pnob->mcc_cq_len * sizeof(MCC_CQ_ENTRY),
+				FALSE,	/* solicted events,  */
+				TRUE,	/* nodelay  */
+				0,	/* 0 Watermark since Nodelay is true */
+				&pnob->event_q_obj,
+				&pnob->mcc_cq_obj);
+
+		if (Status != BE_SUCCESS)
+			return (Status);
+
+		pnob->mcc_cq_id = be_cq_get_id(&pnob->mcc_cq_obj);
+		pnob->mcc_cq_created = 1;
+	}
+	/*
+	 * Now Eth Tx queue.  Needed in DMA mode TX.
+	 */
+	if (pnob->mcc_q_len) {
+
+		(void)sa_sgl_create_contiguous(pnob->mcc_q,
+					       pnob->mcc_q_pa,
+					       pnob->mcc_q_len *
+					       sizeof(MCC_WRB), &sgl);
+
+		Status = be_mcc_ring_create(pfob,
+					    &sgl,
+					    pnob->mcc_q_len *
+					    sizeof(MCC_WRB),
+					    pnob->mcc_wrb_ctxt,
+					    pnob->mcc_wrb_ctxtLen,
+					    &pnob->mcc_cq_obj,
+					    &pnob->mcc_q_obj);
+
+		if (Status != BE_SUCCESS)
+			return (Status);
+
+		/* be_mcc_get_id() is not exposed to drivers since we
+		 * do not need post any commands directly.  BECLib
+		 * does it for us.
+		 */
+		pnob->mcc_q_created = 1;
+	}
+	return (BE_SUCCESS);
+}
+
+/*!
+@brief
+    This function destroys a NetObject created using a previous call to
+    BeCreateNetObject().  All the queues associated with the NetObject are
+    de-registered from BladeEngine.  The actual memory allocated for the
+    queues as well as the space allocated for the NetObject must be freed
+    by the OSM driver after this call returns.
+
+@param
+    pnob - Pointer to the NetObject structure
+
+@return
+    None
+
+*/
+void bni_destroy_netobj(PBNI_NET_OBJECT pnob, SA_DEV *sa_devp)
+{
+
+	BESTATUS beStatus;
+
+	/* free the queues */
+
+	if (pnob->tx_q_created) {
+		beStatus = be_eth_sq_destroy(&pnob->tx_q_obj);
+		pnob->tx_q_created = 0;
+	}
+
+	if (pnob->rx_q_created) {
+		beStatus = be_eth_rq_destroy(&pnob->rx_q_obj);
+		if (beStatus != 0) {
+			beStatus =
+			    be_eth_rq_destroy_options(&pnob->rx_q_obj, 0,
+						      NULL, NULL);
+			SA_ASSERT(0 == beStatus);
+		}
+		pnob->rx_q_created = 0;
+	}
+
+	bni_process_rx_flush_cmpl(pnob);
+
+	if (pnob->tx_cq_created) {
+		beStatus = be_cq_destroy(&pnob->tx_cq_obj);
+		pnob->tx_cq_created = 0;
+	}
+
+	if (pnob->bcrx_cq_created) {
+		beStatus = be_cq_destroy(&pnob->bcrx_cq_obj);
+		pnob->bcrx_cq_created = 0;
+	}
+
+	if (pnob->ucrx_cq_created) {
+		beStatus = be_cq_destroy(&pnob->ucrx_cq_obj);
+		pnob->ucrx_cq_created = 0;
+	}
+
+	if (pnob->mcc_q_created) {
+		beStatus = be_mcc_ring_destroy(&pnob->mcc_q_obj);
+		pnob->mcc_q_created = 0;
+	}
+	if (pnob->mcc_cq_created) {
+		beStatus = be_cq_destroy(&pnob->mcc_cq_obj);
+		pnob->mcc_cq_created = 0;
+	}
+
+	if (pnob->event_q_created) {
+		beStatus = be_eq_destroy(&pnob->event_q_obj);
+		pnob->event_q_created = 0;
+	}
+	/*
+	 * This will cleanup all the other functions, including page tables,
+	 * jell, templates, etc.
+	 */
+	be_function_cleanup(&pnob->fn_obj);
+
+	/* Cleanup the SA device object. */
+	sa_dev_destroy(sa_devp);
+
+}
+
+/*!
+
+@brief
+    This function processes the Flush Completions that are issued by the
+    ARM F/W, when a Recv Ring is destroyed.
+    A flush completion is identified when a Rx COmpl descriptor has
+    the tcpcksum and udpcksum set and the pktsize is 32.
+    These completions are received on the Unicast Rx Completion Queue.
+
+@param
+    pnob - Pointer to the NetObject structure
+
+@return
+    Number of Flush Completions processed.
+
+*/
+u32 bni_process_rx_flush_cmpl(PBNI_NET_OBJECT pnob)
+{
+	PETH_RX_COMPL rxcp;
+	unsigned int i = 0;
+	while ((rxcp = bni_get_ucrx_cmpl(pnob)) != NULL) {
+		bni_notify_cmpl(pnob, 1, pnob->ucrx_cq_id, 1);
+		i++;
+	}
+	return i;
+}
+
+/*!
+@brief
+    This Function fills in required number of WRBs in the ether send ring
+    for transmitting the given ether frame.  The entire ether frame can be
+    in one or more scattered locations. The physical address of the
+    fragments and the count of the bytes in each fragment are indicated
+    by a fragment list pointer.  Pointer to an opaque context is also
+    passed to this function. This context is stored in the array
+    NetObj.tx_ctxt[] at the same index as that of the
+    last WRB entry used for this request.  OSM driver can retrieve
+    this context from this array at the wrb_index indicated by the
+    completion status entry for this transmit and use it to identify
+    the request and do appropriate processing when the transmit is completed.
+
+@param
+    pnob       - Pointer to the NetObject structure
+
+    txb_list   - Pointer to the fragment list describing the ether
+		frame fragments to be transmitted
+
+    flags         - A 32 bit flag indicating a required transmit option.  The
+		Valid options are :
+
+		IPCS         - Enable IP checksum offload
+		UDPCS        - Enable UDP checksum offload
+		TCPCS        - Enable TCP checksum offload
+		LSO          - Enable Large Segmnet offload
+		ETHVLAN      - Insert VLAN
+		ETHEVENT     - Enable event generation on completion
+		ETHCOMPLETE  - Enable completion generation on completion
+		IPSEC        - Enable IPSEC
+		FORWARD      - Send in the Forwarding Path
+
+    vlant       - VLAN tag to be inserted (if ETHVLAN set in flags)
+
+    mss           - Mss to be used if LSO is enabled.
+
+    ctxtp      - An OSM context handle that the OSM can use to
+		identify a completion with a send request.
+
+    nfrags      - Number of fragments in the txb_list (1 to 15)
+
+@return
+    BESTATUS - (0 if successful, non-zero status code if not successful)
+
+*/
+BESTATUS
+bni_tx_pkt(PBNI_NET_OBJECT pnob,
+	   PBNI_TX_FRAG_LIST txb_list,
+	   u32 flags, u32 vlant, u32 mss, void *ctxtp, u32 nfrags)
+{
+	PETH_WRB first_wrb, curr_wrb;
+	int txq_hd;
+	u32 fi, total_frags;
+
+	if (((pnob->tx_q_len - 2) - pnob->tx_q_used) > nfrags) {
+		if (nfrags & 1)
+			total_frags = nfrags + 1;
+		else
+			total_frags = nfrags;
+	} else {
+		return BE_NOT_OK;
+	}
+
+	sa_atomic_add((u32) total_frags, (u32 *) &pnob->tx_q_used);
+
+	/* Store number of WRBS for this pkt in 1st WRb of this pkt */
+	*(u32 *) (&(pnob->tx_ctxt[pnob->tx_q_hd])) = total_frags;
+
+	/*
+	 * fill in the first WRB depending on the options passed to us,
+	 */
+	txq_hd = pnob->tx_q_hd;
+	curr_wrb = &pnob->tx_q[txq_hd];
+	first_wrb = curr_wrb;
+
+	*((u32 *) curr_wrb + 2) = 0x00000000;
+	*((u32 *) curr_wrb + 3) = 0x00000000;
+	curr_wrb->crc = 1;
+
+	if (flags & LSO) {
+		curr_wrb->lso = 1;
+		curr_wrb->lso_mss = mss;
+	} else {
+		if (flags & TCPCS) {
+			curr_wrb->tcpcs = 1;
+		}
+		if (flags & IPCS) {
+			curr_wrb->ipcs = 1;
+		}
+		if (flags & UDPCS) {
+			curr_wrb->udpcs = 1;
+		}
+	}
+
+	/* Transmit the packet in forwarding path for loopback packet */
+	if (flags & FORWARD) {
+		curr_wrb->forward = 1;
+	}
+
+	curr_wrb->vlan_tag = vlant;
+	if (flags & ETHVLAN) {
+		curr_wrb->vlan = 1;
+	}
+
+	if (flags & ETHEVENT) {
+		curr_wrb->event = 1;
+	}
+	curr_wrb->last = 0;
+	curr_wrb->frag_pa_hi = txb_list[0].txb_pa_hi;
+	curr_wrb->frag_pa_lo = txb_list[0].txb_pa_lo;
+	curr_wrb->frag_len = txb_list[0].txb_len;
+	/*
+	 * Fill in rest of the WRBs.  Only the fragment address and count
+	 * are different from the first WRB. So just copy other words from
+	 * the first WRB.
+	 *
+	 */
+	for (fi = 1; fi < nfrags; fi++) {
+		bni_adv_txq_hd(pnob);
+		txq_hd = pnob->tx_q_hd;
+		curr_wrb = &pnob->tx_q[txq_hd];
+
+		*((u32 *) curr_wrb + 2) = *((u32 *) first_wrb + 2);
+		*((u32 *) curr_wrb + 3) = *((u32 *) first_wrb + 3);
+		curr_wrb->frag_pa_hi = txb_list[fi].txb_pa_hi;
+		curr_wrb->frag_pa_lo = txb_list[fi].txb_pa_lo;
+		curr_wrb->frag_len = txb_list[fi].txb_len;
+	}
+	/*
+	 * BladeEngine does not like odd number of WRBs. make it even
+	 * with a dummy entry
+	 */
+	if (nfrags & 1) {
+		bni_adv_txq_hd(pnob);
+		txq_hd = pnob->tx_q_hd;
+		curr_wrb = &pnob->tx_q[txq_hd];
+
+		*((u32 *) curr_wrb + 2) = *((u32 *) first_wrb + 2);
+		*((u32 *) curr_wrb + 3) = *((u32 *) first_wrb + 3);
+		curr_wrb->frag_pa_lo = 0;
+		curr_wrb->frag_pa_hi = 0;
+		curr_wrb->frag_len = 0;
+	}
+	/*
+	 * Fix up the last fragment
+	 */
+	if (flags & ETHCOMPLETE) {
+		curr_wrb->complete = 1;
+	}
+	curr_wrb->last = 1;
+
+	/*
+	 * pnob->tx_q_hd-1 represents the last wrb index of
+	 * this packet. That will be the wrb index that we will get
+	 * in Tx completion
+	 */
+	pnob->tx_ctxt[pnob->tx_q_hd] = ctxtp;
+	bni_adv_txq_hd(pnob);
+
+	return BE_SUCCESS;
+}
+
+/*!
+
+@brief
+   This function writes the number of posted WRBs into the doorbell
+   to kick off the actual transmit of the ether frames whose
+   addresses are filled in the ether send ring by the function
+   bni_tx_pkt().
+
+@param
+    pnob   - Pointer to the NetObject structure
+
+    NumPosted - Number of WRBs filled in.
+
+*/
+void bni_start_tx(PBNI_NET_OBJECT pnob, u32 NumPosted)
+{
+#define CSR_ETH_MAX_SQPOSTS 255
+	SQ_DB sqdb;
+
+	TOU32(sqdb) = 0;
+
+	sqdb.cid = pnob->tx_q_id;
+	while (NumPosted) {
+		if (NumPosted > CSR_ETH_MAX_SQPOSTS) {
+			sqdb.numPosted = CSR_ETH_MAX_SQPOSTS;
+			NumPosted -= CSR_ETH_MAX_SQPOSTS;
+		} else {
+			sqdb.numPosted = NumPosted;
+			NumPosted = 0;
+		}
+		PD_WRITE(NET_FH(pnob), etx_sq_db, sqdb);
+	}
+
+	return;
+}
+
+/*!
+
+@brief
+    This function posts  receive buffers to the ether receive queue.
+    The caller must allocate  the buffers, populate the addresses in
+    list of BNI_RECV_BUFFER structures and pass the address of this
+    list. The number of the receive buffers in the list should not be
+    more than 255.  If the list has more than 255 receive buffers or
+    the RX ring has less free slots than the number of buffers in
+    the list, the function will post whatever buffers it can in the
+    available free slots in the RX ring and remove these entries from
+    the list.  The caller is responsible for freeing the remaining
+    buffers in the list.
+
+    The OSM driver must have filled in the context handle for each
+    BNI_RECV_BUFFER entry in the member context1. This function stores
+    the handle in the array NetObj.rx_ctxt at the index
+    corresponding to the entry in the recieve buffer queue where the
+    buffer was posted. OSM driver can retrieve this context information
+    using the fragndx field in the RX completion descriptor and use it
+    for the receive completion processing.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+    rxb_list  - A List of PBNI_RECV_BUFFER structures that hold the
+		free recv buffer address.
+
+@return
+    Number of buffers that were posted to this queue
+
+*/
+u32 bni_post_rx_buffs(PBNI_NET_OBJECT pnob, PSA_LIST_ENTRY rxb_list)
+{
+	PSA_LIST_ENTRY list_element;
+	u32 nposted = 0;
+	PETH_RX_D pRxDescr = NULL;
+	PBNI_RECV_BUFFER rxbp;
+	PVOID *rx_ctxp;
+	RQ_DB rqdb;
+
+	pRxDescr = pnob->rx_q;
+	rx_ctxp = pnob->rx_ctxt;
+
+	SA_ASSERT(pRxDescr);
+	SA_ASSERT(rx_ctxp);
+
+	while (!IsListEmpty(rxb_list) &&
+	       (rx_ctxp[pnob->rx_q_hd] == NULL) && nposted < 255) {
+
+		list_element = RemoveHeadList(rxb_list);
+
+		rxbp =
+		    SA_CONTAINING_RECORD(list_element, BNI_RECV_BUFFER,
+					 rxb_list);
+
+		pRxDescr[pnob->rx_q_hd].fragpa_lo = rxbp->rxb_pa_lo;
+		pRxDescr[pnob->rx_q_hd].fragpa_hi = rxbp->rxb_pa_hi;
+
+		rx_ctxp[pnob->rx_q_hd] = rxbp->rxb_ctxt;
+		bni_adv_rxq_hd(pnob);
+
+		nposted++;
+
+	}
+
+	if (nposted) {
+		/* Now press the door bell to notify BladeEngine. */
+		TOU32(rqdb) = 0;
+		rqdb.numPosted = nposted;
+		rqdb.rq = pnob->rx_q_id;
+		PD_WRITE(NET_FH(pnob), erx_rq_db, rqdb);
+	}
+
+	pnob->rx_q_posted += nposted;
+	return nposted;
+}
+
+/*!
+
+@brief
+    This function checks the Eth send completion queue and returns
+    the address of the TX completion entry at the tail of the completion
+    queue.  If no valid completion is present, this function returns NULL.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+@return
+    If a valid entry is found, it returns the pointer to ETH_TX_COMPL
+    If no valid entry is found, NULL is returned
+
+*/
+PETH_TX_COMPL bni_get_tx_cmpl(PBNI_NET_OBJECT pnob)
+{
+	PETH_TX_COMPL txcp = &pnob->tx_cq[pnob->tx_cq_tl];
+
+	if (txcp->valid == 0)
+		return (NULL);
+
+	SA_ASSERT(txcp->ct == 0);
+	SA_ASSERT(txcp->wrb_index < (u32) pnob->tx_q_len);
+	SA_ASSERT(txcp->ringid == pnob->tx_q_id);
+
+	txcp->valid = 0;
+	bni_adv_txcq_tl(pnob);
+	return (txcp);
+
+}
+
+/*!
+
+@brief
+    This function checks the Eth unicast receive completion queue and returns
+    the address of the RX completion entry at the tail of the completion
+    queue.  If no valid completion is present, this function returns NULL.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+@return
+    If a valid entry is found, it returns the pointer to ETH_RX_COMPL
+    If no valid entry is found, NULL is returned
+
+*/
+PETH_RX_COMPL bni_get_ucrx_cmpl(PBNI_NET_OBJECT pnob)
+{
+	PETH_RX_COMPL rxcp = &pnob->ucrx_cq[pnob->ucrx_cq_tl];
+
+	if (rxcp->valid == 0)
+		return (NULL);
+
+	if (rxcp->ct != 0) {
+		rxcp->err = 1;
+
+		TRACE(DL_ERR, "Invalid chute %d in ucrx cmpl\n", rxcp->ct);
+	}
+
+	SA_ASSERT(rxcp->fragndx >= 0);
+	SA_ASSERT(rxcp->fragndx < pnob->rx_q_len);
+	SA_ASSERT(rxcp->pktsize <= ((pnob->rx_buf_size) * (rxcp->numfrags)));
+
+	bni_adv_ucrxcq_tl(pnob);
+	rxcp->valid = 0;
+	return (rxcp);
+}
+
+/*!
+
+@brief
+    This function checks the Eth broadcast receive completion queue and returns
+    the address of the RX completion entry at the tail of the completion
+    queue.  If no valid completion is present, this function returns NULL.
+
+@param
+    pnob    - Pointer to NetObject
+
+@return
+    If a valid entry is found, it returns the pointer to ETH_RX_COMPL
+    If no valid entry is found, NULL is returned
+
+*/
+PETH_RX_COMPL bni_get_bcrx_cmpl(PBNI_NET_OBJECT pnob)
+{
+	PETH_RX_COMPL rxcp = &pnob->bcrx_cq[pnob->bcrx_cq_tl];
+
+	if (rxcp->valid == 0)
+		return (NULL);
+
+	SA_ASSERT(rxcp->ct == 0);
+	SA_ASSERT(rxcp->fragndx >= 0);
+	SA_ASSERT(rxcp->fragndx < pnob->rx_q_len);
+	SA_ASSERT(rxcp->pktsize <= pnob->rx_buf_size);
+
+	bni_adv_bcrxcq_tl(pnob);
+	rxcp->valid = 0;
+	return (rxcp);
+}
+
+/*!
+
+@brief
+    This function notifies BladeEngine of the number of completion
+    entries processed from the specified completion queue by writing
+    the number of popped entries to the door bell.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+    n    - Number of completion entries processed
+
+    cq_id         - Queue ID of the completion queue for which notification
+			is being done.
+
+    re_arm 	 - 1  - rearm the completion ring to generate an event.
+		 - 0  - dont rearm the completion ring to generate an event
+
+*/
+void bni_notify_cmpl(PBNI_NET_OBJECT pnob, int n, int cq_id, int re_arm)
+{
+
+	CQ_DB sqdb;
+
+	TOU32(sqdb) = 0;
+	sqdb.qid = cq_id;
+	sqdb.rearm = re_arm;
+	sqdb.num_popped = n;
+
+	PD_WRITE(NET_FH(pnob), cq_db, sqdb);
+}
+
+/*!
+@brief
+   This function enables the interrupt corresponding to the Event
+   queue ID for the given NetObject
+
+@param
+    pnob      - Pointer to the NetObject structure
+*/
+
+/*
+ * Doorbell, enable/disable of EQ interrupts.  This will not mask
+ * the UE interrupt.
+ */
+void bni_enable_eq_intr(PBNI_NET_OBJECT pnob)
+{
+	CQ_DB cq_db;
+
+	SA_ASSERT(pnob);
+
+	cq_db.dw = 0;		/* clear entire doorbell */
+
+	cq_db.event = 1;
+	cq_db.rearm = 1;
+	cq_db.num_popped = 0;
+	cq_db.qid = pnob->event_q_id;
+
+	PD_WRITE(NET_FH(pnob), cq_db, cq_db);
+}
+
+/*!
+@brief
+   This function disables the interrupt corresponding to the Event
+   queue ID for the given NetObject
+
+@param
+    pnob      - Pointer to the NetObject structure
+*/
+void bni_disable_eq_intr(PBNI_NET_OBJECT pnob)
+{
+	CQ_DB cq_db;
+
+	SA_ASSERT(pnob);
+
+	cq_db.dw = 0;		/* clear entire doorbell */
+
+	cq_db.event = 1;
+	cq_db.rearm = 0;
+	cq_db.num_popped = 0;
+	cq_db.qid = pnob->event_q_id;
+
+	PD_WRITE(NET_FH(pnob), cq_db, cq_db);
+}
+
+/*!
+
+@brief
+    This function enables the interrupt from the  network function
+    of the BladeEngine. Use the function bni_disable_eq_intr()
+    to enable the interrupt from the event queue of only one specific
+    NetObject
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_enable_intr(PBNI_NET_OBJECT pnob)
+{
+
+	PCICFG_HOST_TIMER_INT_CTRL_CSR ctrl;
+
+	SA_ASSERT(pnob);
+
+	ctrl.dw = PCICFG1_READ(NET_FH(pnob), host_timer_int_ctrl);
+	if (!ctrl.hostintr) {
+		ctrl.hostintr = 1;
+		TRACE(DL_INFO, "Enabling Interrupt.\n");
+		PCICFG1_WRITE_CONST(NET_FH(pnob), host_timer_int_ctrl, ctrl.dw);
+	}
+}
+
+/*!
+
+@brief
+   This function disables the interrupt from the network function of
+   the BladeEngine.  Use the function bni_disable_eq_intr() to
+   disable the interrupt from the event queue of only one specific NetObject
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_disable_intr(PBNI_NET_OBJECT pnob)
+{
+
+	PCICFG_HOST_TIMER_INT_CTRL_CSR ctrl;
+
+	SA_ASSERT(pnob);
+
+	ctrl.dw = PCICFG1_READ(NET_FH(pnob), host_timer_int_ctrl);
+	if (ctrl.hostintr) {
+		ctrl.hostintr = 0;
+		TRACE(DL_INFO, "Disable Interrupt.\n");
+		PCICFG1_WRITE_CONST(NET_FH(pnob), host_timer_int_ctrl, ctrl.dw);
+	}
+}
+
+/*
+
+@brief
+   This function reads the ISR and returns the value read.  ISR is
+   a clear-on-read register
+
+@param
+    pnob      - Pointer to the NetObject structure
+@return
+    Returns the 32 bit value in the ISR
+
+*/
+u32 bni_get_isr(PBNI_NET_OBJECT pnob)
+{
+	return (CSR_READ(NET_FH(pnob), cev.isr1));
+}
+
+/*!
+
+@brief
+    This function checks the event queue for a valid event. If a valid
+    entry is found, it returns pointer to the entry.  The client is
+    responsible for tracking the number of event queue items popped
+    out of this queue for subsequently ringing the event queue doorbell.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+@return
+    Pointer to next valid event queue entry if one is found.
+    NULL if no valid entry is found.
+*/
+PEQ_ENTRY bni_get_event(PBNI_NET_OBJECT pnob)
+{
+	PEQ_ENTRY eqp = &(pnob->event_q[pnob->event_q_tl]);
+
+	if (!eqp->Valid)
+		return (NULL);
+	/*
+	 * We got a Valid Event. Now increment the Event queue
+	 * index to next event.
+	 */
+	bni_adv_eq_tl(pnob);
+	return eqp;
+}
+
+/*!
+
+@brief
+    This function notifies BladeEngine of how many events were processed
+    from the event queue by ringing the corresponding door bell and
+    optionally re-arms the event queue.
+
+
+@param
+    pnob      - Pointer to the NetObject structure
+    n    - number of events processed
+    re_arm        - 1 - re-arm the EQ, 0 - do not re-arm the EQ
+
+*/
+void bni_notify_event(PBNI_NET_OBJECT pnob, int n, int re_arm)
+{
+	CQ_DB eqdb;
+
+	TOU32(eqdb) = 0;
+	eqdb.qid = pnob->event_q_id;
+	eqdb.rearm = re_arm;
+	eqdb.event = 1;
+
+	eqdb.num_popped = n;
+
+	/*
+	 * Under some situations we see an interrupt and no valid
+	 * EQ entry.  To keep going, we need to ring the DB even if
+	 * numPOsted is 0.
+	 */
+	PD_WRITE(NET_FH(pnob), cq_db, eqdb);
+
+	return;
+}
+
+/*!
+
+@brief
+   This function gets the current link status.
+
+@param
+   pnob           - Pointer to the NetObject structure
+
+   lsp       - Pointer to the stucture LINK_STATUS where the Link
+			status is to be returned.
+
+   cbf        - Pointer to a function that will be called on completion.
+			If NULL, the call will block waiting for completion.
+
+   cbc         - Opaque context argument that will be passed to the
+			completion call back function
+
+
+@return
+    none
+*/
+
+BESTATUS
+bni_get_link_sts(PBNI_NET_OBJECT pnob, PBE_LINK_STATUS lsp,
+		 MCC_WRB_CQE_CALLBACK cbf, PVOID cbc)
+{
+	BESTATUS r;
+
+	r = be_rxf_link_status(NET_FH(pnob), lsp, cbf, cbc, NULL);
+
+	return (r);
+}
+
+/*!
+
+@brief
+   This function gets the specified MAC address from BladeEngine's MAC address
+   table.
+
+@param
+   pnob           - Pointer to the NetObject structure
+
+   port              - 0 for first port, 1 for second port.
+
+   instance          - 0 for the first MAC address of the port, 1 for
+			the second instance of the AMC address for the port.
+
+   pd                - The protection domain number (used only for
+			virtual machine)
+
+   mac_addr           - Address the strcuture SA_MAC_ADDRESS where to return
+			the MAC address.
+
+   cbf        - Pointer to a function that will be called on completion.
+			If NULL, the call will block waiting for completion.
+
+   cbc         - Opaque context argument that will be passed to the
+			completion call back function.
+@return
+    BESTATUS         - (0 if successful, non-zero status code if not successful)
+*/
+
+BESTATUS
+bni_get_uc_mac_adrr(PBNI_NET_OBJECT pnob, u8 port,
+		    u8 instance, u8 pd,
+		    PSA_MAC_ADDRESS mac_addr,
+		    MCC_WRB_CQE_CALLBACK cbf, PVOID cbc)
+{
+	BESTATUS status;
+
+	if (pd) {
+		/* this call is for setting the VM MAC address */
+		port = 0;
+		instance = 0;
+	}
+
+	status = be_rxf_mac_address_read_write(NET_FH(pnob),
+			port,
+			instance,
+			FALSE,	/* Not  Management Mac */
+			FALSE,	/* False for Read */
+			FALSE, mac_addr, cbf, cbc);
+
+	TRACE(DL_INFO, "be_rxf_mac_address_read_write Status is %d\n", status);
+	return status;
+}
+
+/*!
+
+@brief
+   This function sets the specified MAC address from BladeEngine's MAC address
+   table.
+
+@param
+   pnob           - Pointer to the NetObject structure
+
+   port              - 0 for first port, 1 for second port.
+
+   instance          - 0 for the first MAC address of the port, 1 for
+			the second instance of the AMC address for the port.
+
+   pd                - The protection domain number (used only for
+			virtual machie)
+
+   mac_addr           - Address the strcuture SA_MAC_ADDRESS where the
+			MAC address to be set is stored.
+
+   cbf        - Pointer to a function that will be called on completion.
+			If NULL, the call will block waiting for completion.
+
+   cbc         - Opaque context argument that will be passed to the
+			completion call back function.
+@return
+    BESTATUS         - (0 if successful, non-zero status code if not successful)
+*/
+BESTATUS
+bni_set_uc_mac_adr(PBNI_NET_OBJECT pnob, u8 port,
+		   u8 instance, u8 pd,
+		   PSA_MAC_ADDRESS mac_addr,
+		   MCC_WRB_CQE_CALLBACK cbf, PVOID cbc)
+{
+	BESTATUS status;
+
+	if (pd) {
+		/* this call is for setting the VM MAC address */
+		port = 0;
+		instance = 0;
+	}
+
+	status = be_rxf_mac_address_read_write(NET_FH(pnob), port,
+			       instance,
+			       FALSE,	/* Not  Management Mac */
+			       TRUE,	/* TRUE for set */
+			       FALSE, mac_addr, cbf, cbc);
+
+	TRACE(DL_INFO, "be_rxf_mac_address_read_write Status is %d\n", status);
+	return status;
+}
+
+/*!
+
+@brief
+    This function adds the given multicast MAC addresses into BE's
+    multicast filter table.   The maximum number of multicast addresses
+    that can be added  using this call is 32.  More than 32 addresses
+    can be added through multiple calls.
+
+@param
+    pnob     - Pointer to the NetObject structure
+
+    NumMac      - number of MAC sddresses to be added - maximum is 32
+
+    Promiscuous - Whether to enable multicast promiscuous mode or not.
+		If 1,  multicast promiscuous mode is enabled and the
+		  parameters NumMac  and mac_addr are ignored.
+		  If this is not enabled, the multicast addresses in
+		  the array mac_addr will programmed
+
+    mac_addr     - Pointer to an address an array of type SA_MAC_ADDRESS
+
+    cbf  - Pointer to a function that will be called on completion.
+		If NULL, the call will block waiting for completion.
+
+    cbc   - Opaque context argument that will be passed to the
+		completion call back function.
+@return
+    none
+
+*/
+BESTATUS
+bni_set_mc_filter(PBNI_NET_OBJECT pnob,
+		  u32 NumMac,
+		  BOOLEAN promiscuous,
+		  PSA_MAC_ADDRESS mac_addr,
+		  MCC_WRB_CQE_CALLBACK cbf, PVOID cbc)
+{
+	BESTATUS status;
+
+	status = be_rxf_multicast_config(NET_FH(pnob), promiscuous,
+			NumMac,
+			mac_addr,
+			cbf, cbc, NULL);
+
+	return status;
+}
+
+/*!
+
+@brief
+    This function sets BE's network port into promiscuous mode.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_set_promisc(PBNI_NET_OBJECT pnob)
+{
+	/* Set promiscuous mode on both ports. */
+	be_rxf_promiscuous(NET_FH(pnob), 1, 1, NULL, NULL, NULL);
+}
+
+/*!
+
+@brief
+    This function takes BE's network port out of promiscuous mode.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_reset_promisc(PBNI_NET_OBJECT pnob)
+{
+	/* Reset promiscuous mode on both ports. */
+	be_rxf_promiscuous(NET_FH(pnob), 0, 0, NULL, NULL, NULL);
+}
+
+/*!
+
+@brief
+    This function configures the VLAN Id table of BladeEngine.  If the table
+    has any VLAN, Vlan filtering is turned on.  If there no VLANN Ids  in the
+    table, VLAN filtering is turned off. BladeEngine supports a maximum of
+    32 VLans.
+
+@param
+    pnob      - Pointer to the NetObject structure
+
+    vlanp       - pointer to an array containing the VLAN IDs to be
+		configured.
+
+    nv     - Number of Vlan IDs in the array.
+
+   cbf    - Pointer to a function that will be called on completion.
+		If NULL, the call will block waiting for completion.
+
+   cbc     - Opaque context argument that will be passed to the
+		completion call back function
+
+   promiscuous   - Enable vlan Promiscuous mode or not. TRUE=Enable.
+
+@return
+    BESTATUS - (0 if successful, non-zero status code if not successful)
+
+*/
+BESTATUS
+bni_config_vlan(PBNI_NET_OBJECT pnob, u16 *vlanp, u32 nv,
+		MCC_WRB_CQE_CALLBACK cbf, PVOID cbc, BOOLEAN promiscuous)
+{
+	BESTATUS status;
+
+	status = be_rxf_vlan_config(NET_FH(pnob), promiscuous, nv, vlanp,
+				    cbf, cbc, NULL);
+
+	return status;
+}
+
+/*!
+
+@brief
+    This function gets the ethernet port statistics from the ASIC
+
+@param
+    pnob       - Pointer to the NetObject structure
+
+    ioctl_va       - Virtual address of structure IOCTL_ETH_GET_STATISTICS
+
+    ioctl_pa       - Physical address of structure IOCTL_ETH_GET_STATISTICS
+
+    cbf    - Pointer to a function that will be
+		called on completion. If NULL, the call will block
+		    waiting for completion.
+
+    cbc     - Opaque context argument that will be passed to
+		the completion call back function
+
+
+*/
+BESTATUS
+bni_get_stats(PBNI_NET_OBJECT pnob,
+	      IOCTL_ETH_GET_STATISTICS *ioctl_va,
+	      u64 ioctl_pa, MCC_WRB_CQE_CALLBACK cbf, PVOID cbc)
+{
+	BESTATUS s;
+
+	SA_ASSERT(pnob);
+	SA_ASSERT(ioctl_va);
+	SA_ASSERT(ioctl_pa);
+
+	s = be_rxf_query_eth_statistics(NET_FH(pnob), ioctl_va, ioctl_pa,
+					cbf, cbc, NULL);
+
+	return (s);
+
+}
+
+/*!
+@brief
+    Wrapper function to Set Pause frame control
+@param
+    pfob     - Pointer to the function object to read from.
+@param
+    txfc_enable	- Boolean variable - 0 if TX flow control is to be
+		disabled, 1 if  TX flow control is to be disabled.
+
+    rxfc_enable	- Boolean variable - 0 if RX flow control is to be
+		disabled, 1 if  XX flow control is to be disabled
+@return
+*/
+BESTATUS
+bni_set_flow_ctll(PBE_FUNCTION_OBJECT pfob, boolean txfc_enable,
+		  boolean rxfc_enable)
+{
+	return be_eth_set_flow_control(pfob, txfc_enable, rxfc_enable);
+}
+
+/*!
+@brief
+    Wrapper function to Get Pause frame control
+@param
+    pfob     - Pointer to the function object to read from.
+@param
+
+    txfc_enable	- Pointer to a Boolean variable where the TX flow
+			control setting will be returned.  0 if the flow
+			control is disabled, 1 if  flow control is disabled.
+
+    rxfc_enable	- Pointer to a Boolean variable where the RX flow
+			control setting will be returned.  0 if the flow
+			control is disabled, 1 if  flow control is disabled
+
+@return
+*/
+BESTATUS
+bni_get_flow_ctl(PBE_FUNCTION_OBJECT pfob, boolean *txfc_enable,
+		 boolean *rxfc_enable)
+{
+	return be_eth_get_flow_control(pfob, txfc_enable, rxfc_enable);
+}
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/be_ethtool.c benet/linux-2.6.24.2/drivers/net/benet/be_ethtool.c
--- orig/linux-2.6.24.2/drivers/net/benet/be_ethtool.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/be_ethtool.c	2008-02-14 15:23:07.795207712 +0530
@@ -0,0 +1,410 @@
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
+/*
+ * be_ethtool.c
+ *
+ * 	This file contains various functions that ethtool can use
+ * 	to talk to the driver and the BE H/W.
+ */
+
+#include <linux/pci.h>
+#include "be.h"
+
+#include <linux/ethtool.h>
+
+static const char benet_gstrings_stats[][ETH_GSTRING_LEN] = {
+/*net_device_stats */
+	"irq",
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors",
+	"tx_errors",
+	"rx_dropped",
+	"tx_dropped",
+	"multicast",
+	"collisions",
+	"rx_length_errors",
+	"rx_over_errors",
+	"rx_crc_errors",
+	"rx_frame_errors",
+	"rx_fifo_errors",
+	"rx_missed_errors",
+	"tx_aborted_errors",
+	"tx_carrier_errors",
+	"tx_fifo_errors",
+	"tx_heartbeat_errors",
+	"tx_window_errors",
+	"rx_compressed",
+	"tc_compressed",
+/*BE driver Stats */
+	"bes_tx_reqs",
+	"bes_tx_fails",
+	"bes_fwd_reqs",
+	"bes_tx_wrbs",
+	"bes_interrupts",
+	"bes_events",
+	"bes_tx_events",
+	"bes_ucrx_events",
+	"bes_bcrx_events",
+	"bes_tx_compl",
+	"bes_ucrx_compl",
+	"bes_bcrx_compl",
+	"bes_ethrx_post_fail",
+	"bes_802_3_dropped_frames",
+	"bes_802_3_malformed_frames",
+	"bes_eth_tx_rate",
+	"bes_eth_rx_rate",
+#ifdef RX_PKT_COALESCE
+	"Num Packets collected",
+	"Num Times Flushed",
+#endif
+};
+
+#define NET_DEV_STATS_LEN \
+	(sizeof(struct net_device_stats)/sizeof(unsigned long))
+#define BENET_STATS_LEN  sizeof(benet_gstrings_stats) / ETH_GSTRING_LEN
+
+static void
+be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	PBNI_NET_OBJECT pnob = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+
+	strncpy(drvinfo->driver, be_driver_name, 32);
+	strncpy(drvinfo->version, be_drvr_ver, 32);
+	strncpy(drvinfo->fw_version, be_fw_ver, 32);
+	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+}
+
+static int
+be_get_coalesce(struct net_device *netdev,
+		struct ethtool_coalesce *coalesce)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(NetObject)->adapter;
+
+#ifdef RX_PKT_COALESCE
+	coalesce->rx_max_coalesced_frames = adapter->max_rx_coal;
+#endif
+
+	coalesce->rx_coalesce_usecs = adapter->cur_eqd;
+	coalesce->rx_coalesce_usecs_high = adapter->max_eqd;
+	coalesce->rx_coalesce_usecs_low = adapter->min_eqd;
+
+	coalesce->tx_coalesce_usecs = adapter->cur_eqd;
+	coalesce->tx_coalesce_usecs_high = adapter->max_eqd;
+	coalesce->tx_coalesce_usecs_low = adapter->min_eqd;
+
+	coalesce->use_adaptive_rx_coalesce = adapter->enable_aic;
+	coalesce->use_adaptive_tx_coalesce = adapter->enable_aic;
+
+	return 0;
+}
+
+static int
+be_set_coalesce(struct net_device *netdev,
+		struct ethtool_coalesce *coalesce)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(NetObject)->adapter;
+	u32 max, min, cur;
+
+#ifdef RX_PKT_COALESCE
+	adapter->max_rx_coal = coalesce->rx_max_coalesced_frames;
+	if (adapter->max_rx_coal < 0)
+		adapter->max_rx_coal = 0;
+	if (adapter->max_rx_coal >= MAX_COALESCE_FRAGS)
+		adapter->max_rx_coal = MAX_COALESCE_FRAGS;
+#endif
+
+	if (adapter->enable_aic == 0 &&
+	    coalesce->use_adaptive_rx_coalesce == 1) {
+		/* if AIC is being turned on now, start with an EQD of 0 */
+		adapter->cur_eqd = 0;
+	}
+	adapter->enable_aic = coalesce->use_adaptive_rx_coalesce;
+
+	/* round off to nearest multiple of 8 */
+	max = (((coalesce->rx_coalesce_usecs_high + 4) >> 3) << 3);
+	min = (((coalesce->rx_coalesce_usecs_low + 4) >> 3) << 3);
+	cur = (((coalesce->rx_coalesce_usecs + 4) >> 3) << 3);
+
+	if (adapter->enable_aic) {
+		/* accept low and high if AIC is enabled */
+		if (max > MAX_EQD)
+			min = MAX_EQD;
+		if (min > max)
+			min = max;
+		adapter->max_eqd = max;
+		adapter->min_eqd = min;
+		if (adapter->cur_eqd > max)
+			adapter->cur_eqd = max;
+		if (adapter->cur_eqd < min)
+			adapter->cur_eqd = min;
+	} else {
+		/* accept specified coalesce_usecs only if AIC is disabled */
+		if (cur > MAX_EQD)
+			cur = MAX_EQD;
+		if (bni_change_eqd(NetObject, cur) == BE_SUCCESS)
+			adapter->cur_eqd = cur;
+	}
+
+	return 0;
+}
+
+static u32 be_get_rx_csum(struct net_device *netdev)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(NetObject)->adapter;
+	return adapter->rx_csum;
+}
+
+static int be_set_rx_csum(struct net_device *netdev, uint32_t data)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(NetObject)->adapter;
+	if (data)
+		adapter->rx_csum = 1;
+	else
+		adapter->rx_csum = 0;
+
+	return 0;
+}
+
+static void
+be_get_strings(struct net_device *netdev, uint32_t stringset,
+	       uint8_t *data)
+{
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *benet_gstrings_stats,
+		       sizeof(benet_gstrings_stats));
+		break;
+	}
+}
+
+static int be_get_stats_count(struct net_device *netdev)
+{
+	return BENET_STATS_LEN;
+}
+
+static void
+be_get_ethtool_stats(struct net_device *netdev,
+		     struct ethtool_stats *stats, uint64_t *data)
+{
+	PBNI_NET_OBJECT pnob = netdev->priv;
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	int i;
+
+	data[0] = adapter->pdev->irq;
+
+	benet_get_stats(netdev);
+
+	for (i = 1; i <= NET_DEV_STATS_LEN; i++)
+		data[i] = ((unsigned long *)&adapter->benet_stats)[i - 1];
+
+	data[i++] = adapter->be_stat.bes_tx_reqs;
+	data[i++] = adapter->be_stat.bes_tx_fails;
+	data[i++] = adapter->be_stat.bes_fwd_reqs;
+	data[i++] = adapter->be_stat.bes_tx_wrbs;
+
+	data[i++] = adapter->be_stat.bes_ints;
+	data[i++] = adapter->be_stat.bes_events;
+	data[i++] = adapter->be_stat.bes_tx_events;
+	data[i++] = adapter->be_stat.bes_ucrx_events;
+	data[i++] = adapter->be_stat.bes_bcrx_events;
+	data[i++] = adapter->be_stat.bes_tx_compl;
+	data[i++] = adapter->be_stat.bes_ucrx_compl;
+	data[i++] = adapter->be_stat.bes_bcrx_compl;
+	data[i++] = adapter->be_stat.bes_ethrx_post_fail;
+	data[i++] = adapter->be_stat.bes_802_3_dropped_frames;
+	data[i++] = adapter->be_stat.bes_802_3_malformed_frames;
+
+	data[i++] = adapter->be_stat.bes_eth_tx_rate;
+	data[i++] = adapter->be_stat.bes_eth_rx_rate;
+
+#ifdef RX_PKT_COALESCE
+	data[i++] = adapter->be_stat.bes_rx_coal;
+	data[i++] = adapter->be_stat.bes_rx_flush;
+#endif
+
+}
+
+static int
+be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+
+	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+	ecmd->port = PORT_FIBRE;
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(OSM_NOB(NetObject)->os_handle)) {
+		ecmd->speed = SPEED_10000;
+		ecmd->duplex = DUPLEX_FULL;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = AUTONEG_DISABLE;
+	return 0;
+}
+
+/*Get the Ring parameters from the NetObject */
+static void
+be_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+
+	/*Pre Set Maxims */
+	ring->rx_max_pending = NetObject->rx_q_len;
+	ring->rx_mini_max_pending = ring->rx_mini_max_pending;
+	ring->rx_jumbo_max_pending = ring->rx_jumbo_max_pending;
+	ring->tx_max_pending = NetObject->tx_q_len;
+
+	/*Current hardware Settings                */
+	ring->rx_pending = NetObject->rx_q_posted;
+	ring->rx_mini_pending = ring->rx_mini_pending;
+	ring->rx_jumbo_pending = ring->rx_jumbo_pending;
+	ring->tx_pending = NetObject->tx_q_used;
+
+}
+
+static void
+be_get_pauseparam(struct net_device *netdev,
+		  struct ethtool_pauseparam *ecmd)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	boolean rxfc = FALSE;
+	boolean txfc = FALSE;
+	if (ecmd->cmd != ETHTOOL_GPAUSEPARAM) {
+		return;
+	}
+
+	if (bni_get_flow_ctl(&NetObject->fn_obj, &txfc, &rxfc) !=
+	    BE_SUCCESS) {
+		printk(KERN_WARNING
+		       "Unable to get pause frame settings\n");
+	}
+
+	if (txfc == TRUE)
+		ecmd->tx_pause = 1;
+	else
+		ecmd->tx_pause = 0;
+
+	if (rxfc == TRUE)
+		ecmd->rx_pause = 1;
+	else
+		ecmd->rx_pause = 0;
+
+	/* Always setting autoneg to TRUE */
+	ecmd->autoneg = 1;
+
+	return;
+}
+
+static int
+be_set_pauseparam(struct net_device *netdev,
+		  struct ethtool_pauseparam *ecmd)
+{
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+	boolean txfc = FALSE;
+	boolean rxfc = FALSE;
+
+	if (ecmd->cmd != ETHTOOL_SPAUSEPARAM)
+		return -EINVAL;
+
+	if (ecmd->tx_pause)
+		txfc = TRUE;
+	else
+		txfc = FALSE;
+
+	if (ecmd->rx_pause)
+		rxfc = TRUE;
+	else
+		rxfc = FALSE;
+
+	if (bni_set_flow_ctll(&NetObject->fn_obj, txfc, rxfc) != BE_SUCCESS) {
+		printk(KERN_ERR "Unable to set pause frame settings\n");
+	}
+	return 0;
+}
+
+struct ethtool_ops be_ethtool_ops = {
+	.get_settings = be_get_settings,
+	.get_drvinfo = be_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+#ifdef RX_PKT_COALESCE
+	.get_coalesce = be_get_coalesce,
+	.set_coalesce = be_set_coalesce,
+#endif
+	.get_ringparam = be_get_ringparam,
+	.get_pauseparam = be_get_pauseparam,
+	.set_pauseparam = be_set_pauseparam,
+	.get_rx_csum = be_get_rx_csum,	/*Yes */
+	.set_rx_csum = be_set_rx_csum,
+	.get_tx_csum = ethtool_op_get_tx_csum,	/*Yes */
+	.set_tx_csum = ethtool_op_set_tx_csum,	/*Yes */
+	.get_sg = ethtool_op_get_sg,	/*Yes */
+	.set_sg = ethtool_op_set_sg,	/*Yes */
+#ifdef NETIF_F_TSO
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = ethtool_op_set_tso,
+#endif
+	.get_strings = be_get_strings,
+	.get_stats_count = be_get_stats_count,
+	.get_ethtool_stats = be_get_ethtool_stats,
+};
+
+void be_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
+}
+
+int be_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr)
+{
+	void *addr = ifr->ifr_data;
+	uint32_t cmd;
+
+	if (get_user(cmd, (uint32_t *) addr))
+		return -EFAULT;
+
+	return -EOPNOTSUPP;
+}
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/be_proc.c benet/linux-2.6.24.2/drivers/net/benet/be_proc.c
--- orig/linux-2.6.24.2/drivers/net/benet/be_proc.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/be_proc.c	2008-02-14 15:23:07.796207560 +0530
@@ -0,0 +1,679 @@
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
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include "be.h"
+
+extern PBE_ADAPTER be_adapter[];
+
+char *be_adpt_name[] = {
+	"driver/benet0",
+	"driver/benet1"
+};
+
+struct proc_dir_entry *be_proc_dir[MAX_BE_DEVICES];
+
+/* path under /proc */
+#define BE_PORT_STAT_FILE    "port_stat"
+#define BE_MISC_STAT_FILE    "misc_stat"
+#define BE_DRVR_STAT_FILE    "drvr_stat"
+
+/*File to read Eth Ring Information */
+#define BE_ETH_RING_FILE "eth_ring"
+
+/*File to read/set dbg_mask */
+#define BE_DBG_MASK "dbg_mask"
+
+#define BE_PROC_MODE          0600
+
+#define BE_PORT0_STAT_INDEX  0x00	/* index to read first port0 stat */
+#define BE_PORT1_STAT_INDEX  0x3B	/* index to read first port1 stat */
+#define BE_MISC_STAT_INDEX   0x76	/* index to read first misc stat */
+#define BE_LAST_STAT_INDEX   0x95	/* last index */
+/*
+ * descriptor strings for port statistics
+ */
+char *stat_desc_port[] = {
+	/* 0x00 */ "total bytes received OK (LSD)",
+	/* 0x01 */ "total bytes received OK (MSD)",
+	/* 0x02 */ "total frames received OK",
+	/* 0x03 */ "unicast frames received OK",
+	/* 0x04 */ "multicast frames received OK",
+	/* 0x05 */ "broadcast frames received OK",
+	/* 0x06 */ "CRC errors",
+	/* 0x07 */ "alignment/bad symbol errors",
+	/* 0x08 */ "PAUSE frames received",
+	/* 0x09 */ "control frames received",
+	/* 0x0a */ "in range length errors 1",
+	/* 0x0b */ "out of range length errors 2",
+	/* 0x0c */ "frame too long errors 3",
+	/* 0x0d */ "dropped due to address mismatch",
+	/* 0x0e */ "dropped due to vlan mismatch",
+	/* 0x0f */ "dropped ip too small (ip length < ip header len)",
+	/* 0x10 */ "dropped ip too short (ip length > pkt len)",
+	/* 0x11 */ "dropped ip header too small (ip header len < 5)",
+	/* 0x12 */ "dropped bad tcp header length",
+	/* 0x13 */ "received runt pkts",
+	/* 0x14 */ "received 64 byte pkts",
+	/* 0x15 */ "received pkts 65 to 127 bytes",
+	/* 0x16 */ "received pkts 128 to 255 bytes",
+	/* 0x17 */ "received pkts 256 to 511 bytes",
+	/* 0x18 */ "received pkts 512 to 1023 bytes",
+	/* 0x19 */ "received pkts 1024 to 1518 bytes",
+	/* 0x1a */ "received pkts 1519 to 2047 bytes",
+	/* 0x1b */ "received pkts 2048 to 4095 bytes",
+	/* 0x1c */ "received pkts 4096 to 8191 bytes",
+	/* 0x1d */ "received pkts 8192 to 9216 bytes",
+	/* 0x1e */ "received IP checksum errors",
+	/* 0x1f */ "received TCP checksum errors",
+	/* 0x20 */ "received UDP checksum errors",
+	/* 0x21 */ "non-RSS pkts received",
+	/* 0x22 */ "IP pkts received (good and bad)",
+	/* 0x23 */ "chute 1 offloaded pkts received",
+	/* 0x24 */ "chute 2 offloaded pkts received",
+	/* 0x25 */ "chute 3 offloaded pkts received",
+	/* 0x26 */ "IPSEC pkts received",
+	/* 0x27 */ "mgmt pkts received",
+	/* 0x28 */ "bytes transmitted OK (LSD)",
+	/* 0x29 */ "total bytes transmitted OK (MSD)",
+	/* 0x2a */ "unicast frames transmitted OK",
+	/* 0x2b */ "multicast frames transmitted OK",
+	/* 0x2c */ "broadcast frames transmitted OK",
+	/* 0x2d */ "PAUSE frames sent",
+	/* 0x2e */ "control frames sent",
+	/* 0x2f */ "transmitted 64 byte pkts",
+	/* 0x30 */ "transmitted pkts 65 to 127 bytes",
+	/* 0x31 */ "transmitted pkts 128 to 255 bytes",
+	/* 0x32 */ "transmitted pkts 256 to 511 bytes",
+	/* 0x33 */ "transmitted pkts 512 to 1023 bytes",
+	/* 0x34 */ "transmitted pkts 1024 to 1518 bytes",
+	/* 0x35 */ "transmitted pkts 1519 to 2047 bytes",
+	/* 0x36 */ "transmitted pkts 2048 to 4095 bytes",
+	/* 0x37 */ "transmitted pkts 4096 to 8191 bytes",
+	/* 0x38 */ "transmitted pkts 8192 to 9216 bytes",
+	/* 0x39 */ "dropped pkts due to rx fifo overflow",
+	/* 0x3a */ "reserved"
+};
+
+char *stat_desc_misc[] = {
+	/* 0x76 */ "dropped pkts due to no pbuf space",
+	/* 0x77 */ "dropped pkts due to no txp buf space",
+	/* 0x78 */ "dropped pkts due to no ipsec buf space",
+	/* 0x79 */ "dropped pkts due to no erx desc space",
+	/* 0x7a */ "dropped pkts due to no tpre desc space",
+	/* 0x7b */ "pkts received on mgmt port",
+	/* 0x7c */ "bytes received on mgmt port",
+	/* 0x7d */ "pause frames received on mgmt port",
+	/* 0x7e */ "error frames received on mgmt port",
+	/* 0x7f */ "pkts transmitted on mgmt port",
+	/* 0x80 */ "bytes transmitted on mgmt port",
+	/* 0x81 */ "pause frames transmitted on mgmt port",
+	/* 0x82 */ "dropped pkts due to mgmt rx fifo overflow",
+	/* 0x83 */ "ipsec received IP checksum errors",
+	/* 0x84 */ "ipsec received TCP checksum errors",
+	/* 0x85 */ "ipsec received UDP checksum errors",
+	/* 0x86 */ "ipsec runt pkts",
+	/* 0x87 */ "ipsec number dropped due to address mismatch",
+	/* 0x88 */ "ipsec dropped pkts due to rx fifo overflow",
+	/* 0x89 */ "ipsec frame too long errors 3",
+	/* 0x8a */ "ipsec total ip frames (good and bad)",
+	/* 0x8b */ "ipsec dropped ip too small (ip length < ip hdr len)",
+	/* 0x8c */ "ipsec dropped ip too short (ip length > pkt len)",
+	/* 0x8d */ "ipsec dropped ip header too small (ip header len < 5)",
+	/* 0x8e */ "ipsec dropped bad tcp header length",
+	/* 0x8f */ "ipsec chute 1 offloaded pkts received",
+	/* 0x90 */ "ipsec chute 2 offloaded pkts received",
+	/* 0x91 */ "ipsec chute 3 offloaded pkts received",
+	/* 0x92 */ "pkts dropped due to needing more than 7 fragments",
+	/* 0x93 */ "pkts dropped due to insufficient fragments available",
+	/* 0x94 */ "pkts dropped due to invalid fragment ring",
+	/* 0x95 */ "forwarded pkts"
+};
+
+/*
+ * we use a buffer to read all stats in one shot to get
+ * a consistent set (best effort) of counters rather than read them in
+ * multiple calls from filesystems
+ */
+static char port_stats_buf[8192];
+static int port_stat_count;
+
+/*
+ * read the counters for  port0 and port1, format them with description
+ * and return to the buffer given to us.  These counters are
+ * clear on read.
+ */
+static int proc_read_port_stat(char *page, char **start,
+			       off_t off, int count, int *eof, void *data)
+{
+	int i, n;
+	u32 v1, v2;
+	char *p;
+	PBE_ADAPTER adapter = (PBE_ADAPTER) data;
+
+	u32 *Stats = (u32 *) &adapter->eth_statsp->params.response;
+	u64 pa;
+	be_timer_ctxt_t *ctxt = adapter->ctxt;
+
+	if (!BE_DEV_STATE_OPEN(adapter)) {
+		/* Not ready to report Stats */
+		*eof = 1;
+		return 0;
+	}
+	/* Get Physical Addr */
+	pa = pci_map_single(adapter->pdev,
+			    adapter->eth_statsp,
+			    sizeof(IOCTL_ETH_GET_STATISTICS),
+			    PCI_DMA_FROMDEVICE);
+	pa = cpu_to_le64(pa);
+	ctxt->get_stat_sem = (unsigned long)&adapter->get_eth_stat_sem;
+	bni_get_stats(adapter->net_obj, adapter->eth_statsp,
+		      pa, get_stat_cb, (PVOID) ctxt);
+	atomic_inc(&ctxt->get_stat_flag);
+	ctxt->get_stats_timer.data = (unsigned long)ctxt;
+	mod_timer(&ctxt->get_stats_timer, (jiffies + (HZ * 60)));
+	down((PVOID) ctxt->get_stat_sem); /* block till callback is called */
+
+	if (off == 0) {
+		/* first call to us.  Read all port stats from BE */
+		for (p = port_stats_buf, i = 0, port_stat_count = 0;
+				     i < BE_PORT1_STAT_INDEX; i++) {
+
+			v1 = Stats[i]; /* port 0 */
+			v2 = Stats[i + BE_PORT1_STAT_INDEX]; /* port 1 */
+
+			n = sprintf(p, "%50s: %11u:%11u\n",
+				    stat_desc_port[i], v1, v2);
+			p += n;
+			port_stat_count += n;
+		}
+
+	}
+	*start = page;
+	if (count < (port_stat_count - off)) {
+		i = count;
+		*eof = 0;	/* More bytes left */
+	} else {
+		i = port_stat_count - off;
+		*eof = 1;	/* Nothing left. indicate EOF */
+	}
+	memcpy(page, port_stats_buf + off, i);
+	pci_unmap_single(adapter->pdev, (ulong) adapter->eth_statsp,
+			 sizeof(IOCTL_ETH_GET_STATISTICS),
+			 PCI_DMA_FROMDEVICE);
+	return (i);
+}
+
+static int proc_write_port_stat(struct file *file,
+				const char *buffer, unsigned long count,
+				void *data)
+{
+	return (count);		/* we do not support write */
+}
+
+/*
+ * we use a buffer to read all stats in one shot to get
+ * a consistent set (best effort) of counters rather than read them in
+ * multiple calls from filesystems
+ */
+static char misc_stats_buf[8192];
+static int misc_stat_count;
+
+/*
+ * read the miscellaneous counters, format them with description
+ * and return to the buffer given to us.  These counters are
+ * clear on read.
+ */
+static int proc_read_misc_stat(char *page, char **start,
+			       off_t off, int count, int *eof, void *data)
+{
+	int i, n;
+	u32 v;
+	char *p;
+	PBE_ADAPTER adapter = (PBE_ADAPTER) data;
+
+	u32 *Stats = (u32 *) &adapter->eth_statsp->params.response;
+	u64 pa;
+	be_timer_ctxt_t *ctxt = adapter->ctxt;
+
+	if (!BE_DEV_STATE_OPEN(adapter)) {
+		/* Not ready to report Stats */
+		*eof = 1;
+		return 0;
+	}
+	/* Get Physical Addr */
+	pa = pci_map_single(adapter->pdev,
+			    adapter->eth_statsp,
+			    sizeof(IOCTL_ETH_GET_STATISTICS),
+			    PCI_DMA_FROMDEVICE);
+	pa = cpu_to_le64(pa);
+	ctxt->get_stat_sem = (unsigned long)&adapter->get_eth_stat_sem;
+	bni_get_stats(adapter->net_obj, adapter->eth_statsp,
+		      pa, get_stat_cb, (PVOID) ctxt);
+	atomic_inc(&ctxt->get_stat_flag);
+	ctxt->get_stats_timer.data = (unsigned long)ctxt;
+	mod_timer(&ctxt->get_stats_timer, (jiffies + (HZ * 60)));
+	down((PVOID) ctxt->get_stat_sem); /* block till callback is called */
+
+	if (off == 0) {
+		/* first call to us.  Read all stats from BE */
+		for (p = misc_stats_buf, i = BE_MISC_STAT_INDEX,
+		     misc_stat_count = 0; i <= BE_LAST_STAT_INDEX; i++) {
+			/* port 0 */
+
+			v = Stats[i];
+
+			n = sprintf(p, "%55s: %11u\n",
+				    stat_desc_misc[i - BE_MISC_STAT_INDEX],
+				    v);
+			p += n;
+			misc_stat_count += n;
+		}
+	}
+	*start = page;
+	/* copy whatever we can */
+	if (count < (misc_stat_count - off)) {
+		i = count;
+		*eof = 0;	/* More bytes left */
+	} else {
+		i = misc_stat_count - off;
+		*eof = 1;	/* Nothing left. indicate EOF */
+	}
+	memcpy(page, misc_stats_buf + off, i);
+	pci_unmap_single(adapter->pdev, (ulong) adapter->eth_statsp,
+			 sizeof(IOCTL_ETH_GET_STATISTICS),
+			 PCI_DMA_FROMDEVICE);
+	return (i);
+}
+
+static int proc_write_misc_stat(struct file *file,
+				const char *buffer, unsigned long count,
+				void *data)
+{
+	return (count);		/* we do not support write */
+}
+
+/*
+ * read the driver stats.
+ */
+static int proc_read_drvr_stat(char *page, char **start,
+			       off_t off, int count, int *eof, void *data)
+{
+	int n;
+	char *p = page;
+	PBE_ADAPTER adapter = (PBE_ADAPTER) data;
+
+	if (off == 0) {
+		n = sprintf(p, "tx_reqs = %d\n",
+			    adapter->be_stat.bes_tx_reqs);
+		p += n;
+		n = sprintf(p, "tx_fails = %d\n",
+			    adapter->be_stat.bes_tx_fails);
+		p += n;
+		n = sprintf(p, "fwd_reqs = %d\n",
+			    adapter->be_stat.bes_fwd_reqs);
+		p += n;
+		n = sprintf(p, "tx_wrbs = %d\n",
+			    adapter->be_stat.bes_tx_wrbs);
+		p += n;
+		n = sprintf(p, "ints = %d\n", adapter->be_stat.bes_ints);
+		p += n;
+		n = sprintf(p, "poll = %d\n", adapter->be_stat.bes_polls);
+		p += n;
+		n = sprintf(p, "events = %d\n",
+			    adapter->be_stat.bes_events);
+		p += n;
+		n = sprintf(p, "tx_events = %d\n",
+			    adapter->be_stat.bes_tx_events);
+		p += n;
+		n = sprintf(p, "ucrx_events = %d\n",
+			    adapter->be_stat.bes_ucrx_events);
+		p += n;
+		n = sprintf(p, "bcrx_events = %d\n",
+			    adapter->be_stat.bes_bcrx_events);
+		p += n;
+		n = sprintf(p, "tx_compl = %d\n",
+			    adapter->be_stat.bes_tx_compl);
+		p += n;
+		n = sprintf(p, "ucrx_compl = %d\n",
+			    adapter->be_stat.bes_ucrx_compl);
+		p += n;
+		n = sprintf(p, "bcrx_compl = %d\n",
+			    adapter->be_stat.bes_bcrx_compl);
+		p += n;
+		n = sprintf(p, "ethrx_post_fail = %d\n",
+			    adapter->be_stat.bes_ethrx_post_fail);
+		p += n;
+		n = sprintf(p, "802.3_dropped_frames = %d\n",
+			    adapter->be_stat.bes_802_3_dropped_frames);
+		p += n;
+		n = sprintf(p, "802.3_malformed_frames = %d\n",
+			    adapter->be_stat.bes_802_3_malformed_frames);
+		p += n;
+		n = sprintf(p, "eth_tx_rate = %d\n",
+			    adapter->be_stat.bes_eth_tx_rate);
+		p += n;
+		n = sprintf(p, "eth_rx_rate = %d\n",
+			    adapter->be_stat.bes_eth_rx_rate);
+		p += n;
+
+#ifdef RX_PKT_COALESCE
+		n = sprintf(p, "Num pkts collected = %d\n",
+			    adapter->be_stat.bes_rx_coal);
+		p += n;
+		n = sprintf(p, "Num times flushed = %d\n",
+			    adapter->be_stat.bes_rx_flush);
+		p += n;
+#endif
+		n = sprintf(p, "ints_per_sec = %d\n",
+			    adapter->be_stat.bes_ips);
+		p += n;
+		n = sprintf(p, "eq_delay = %d / %d / %d\n",
+			    adapter->min_eqd, adapter->cur_eqd,
+			    adapter->max_eqd);
+		p += n;
+
+	}
+	*eof = 1;
+	return (p - page);
+}
+
+static int proc_write_drvr_stat(struct file *file,
+				const char *buffer, unsigned long count,
+				void *data)
+{
+	PBE_ADAPTER adapter = (PBE_ADAPTER) data;
+	memset(&(adapter->be_stat), 0, sizeof(adapter->be_stat));
+
+	return (count);		/* we do not support write */
+}
+
+static char read_eth_ring_buf[4096];
+static int read_eth_ring_count;
+
+/*
+ * Get Various Eth Ring Properties
+ */
+static int proc_eth_read_ring(char *page, char **start,
+			      off_t off, int count, int *eof, void *data)
+{
+	int i, n;
+	char *p = read_eth_ring_buf;
+	PBE_ADAPTER adapter = (PBE_ADAPTER) data;
+	struct net_device *netdev = adapter->netdevp;
+	PBNI_NET_OBJECT NetObject = netdev->priv;
+
+	if (off == 0) {
+		/* Reset read_eth_ring_count */
+		read_eth_ring_count = 0;
+
+		n = sprintf(p, "                    PhyAddr  VirtAddr  Size  TotalEntries  ProducerIndex  ConsumerIndex  NumUsed\n");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "                    -------  --------  ----  ------------  -------------  -------------  -------\n");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "%s", "EthSendRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "         %7lx  %8p  %4u  %12u  %13u  %13u  %7u  \n",
+			    virt_to_phys(NetObject->tx_q),
+			    (void *)NetObject->tx_q,
+			    (u32) (NetObject->tx_q_len * sizeof(ETH_WRB)),
+			    NetObject->tx_q_len, NetObject->tx_q_hd,
+			    NetObject->tx_q_tl, NetObject->tx_q_used);
+
+		p += n;
+		read_eth_ring_count += n;
+
+		/* Get Eth Send Compl Queue Details */
+		n = sprintf(p, "%s", "EthSendCmplRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "     %7lx  %8p  %4u  %12u  %13s  %13u  %7s\n",
+			    virt_to_phys(NetObject->tx_cq),
+			    (void *)NetObject->tx_cq,
+			    (u32) (NetObject->txcq_len *
+				   sizeof(ETH_TX_COMPL)),
+			    NetObject->txcq_len, "NA", NetObject->tx_cq_tl,
+			    "NA");
+
+		p += n;
+		read_eth_ring_count += n;
+		/* Get Eth Rx Queue Details */
+		n = sprintf(p, "%s", "EthRxRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "           %7lx  %8p  %4u  %12u  %13u  %13s  %7u  \n",
+			    virt_to_phys(NetObject->rx_q),
+			    (void *)NetObject->rx_q,
+			    (u32) (NetObject->rx_q_len * sizeof(ETH_RX_D)),
+			    NetObject->rx_q_len, NetObject->rx_q_hd, "NA",
+			    NetObject->rx_q_posted);
+		p += n;
+		read_eth_ring_count += n;
+
+		/* Get Eth Unicast Rx Compl Queue Details */
+		n = sprintf(p, "%s", "EthUnicastRxCmplRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, "%7lx  %8p  %4u  %12u  %13s  %13u  %7s\n",
+			    virt_to_phys(NetObject->ucrx_cq),
+			    (void *)NetObject->ucrx_cq,
+			    (u32) (NetObject->ucrx_cq_len *
+				   sizeof(ETH_RX_COMPL)),
+			    NetObject->ucrx_cq_len, "NA",
+			    NetObject->ucrx_cq_tl, "NA");
+		p += n;
+		read_eth_ring_count += n;
+
+		/* Get Eth Broadcast Rx Compl Queue Details */
+		n = sprintf(p, "%s", "EthBdcastRxCmplRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p, " %7lx  %8p  %4u  %12u  %13s  %13u  %7s \n",
+			    virt_to_phys(NetObject->bcrx_cq),
+			    (void *)NetObject->bcrx_cq,
+			    (u32) (NetObject->bcrx_cq_len *
+				   sizeof(ETH_RX_COMPL)),
+			    NetObject->bcrx_cq_len, "NA",
+			    NetObject->bcrx_cq_tl, "NA");
+
+		p += n;
+		read_eth_ring_count += n;
+
+		/* Get Eth Event Queue Details */
+		n = sprintf(p, "%s", "EthEventRing");
+		p += n;
+		read_eth_ring_count += n;
+
+		n = sprintf(p,
+			    "        %7lx  %8p  %4u  %12u  %13s  %13u  %7s\n",
+			    virt_to_phys(NetObject->event_q),
+			    (void *)NetObject->event_q,
+			    (u32) (NetObject->event_q_len *
+				   sizeof(EQ_ENTRY)),
+			    NetObject->event_q_len, "NA",
+			    NetObject->event_q_tl, "NA");
+
+		p += n;
+		read_eth_ring_count += n;
+	}
+
+	*start = page;
+	/* copy whatever we can */
+	if (count < (read_eth_ring_count - off)) {
+		i = count;
+		*eof = 0;	/* More bytes left */
+	} else {
+		i = read_eth_ring_count - off;
+		*eof = 1;	/* Nothing left. indicate EOF */
+	}
+
+	memcpy(page, read_eth_ring_buf + off, i);
+	return (i);
+}
+
+static int proc_eth_write_ring(struct file *file,
+			       const char *buffer, unsigned long count,
+			       void *data)
+{
+	return (count);		/* we do not support write */
+}
+
+/*
+ * read the dbg_mask file.
+ */
+static int proc_read_dbg_mask(char *page, char **start,
+			      off_t off, int count, int *eof, void *data)
+{
+	*eof = 1;
+	return sprintf(page, "0x%x\n", dbg_mask);
+}
+
+/*
+ * write the dbg_mask value
+ */
+static int proc_write_dbg_mask(struct file *file,
+			       const char *buffer, unsigned long count,
+			       void *data)
+{
+
+	u8 buf[32];
+
+	if (count > sizeof(buf))
+		return -EINVAL;
+	if (copy_from_user(buf, buffer, count))
+		return -EFAULT;
+	buf[count] = '\0';
+
+	dbg_mask = simple_strtoul(buf, NULL, 16);
+	sa_trace_set_level(dbg_mask);
+	return (count);
+}
+
+void be_init_procfs(PBE_ADAPTER adapter)
+{
+	static struct proc_dir_entry *pde;
+	int adapt_num = 0;
+
+	while (adapt_num < MAX_BE_DEVICES) {
+		if (be_adapter[adapt_num] == adapter)
+			break;
+		adapt_num++;
+	}
+
+	if (adapt_num == MAX_BE_DEVICES) {
+		printk("Invalid Adapter Pointer received");
+		return;
+	}
+
+	/* create directory */
+	be_proc_dir[adapt_num] =
+	     proc_mkdir(be_adpt_name[adapt_num], NULL);
+	if (be_proc_dir[adapt_num]) {
+		(be_proc_dir[adapt_num])->owner = THIS_MODULE;
+	}
+
+	pde = create_proc_entry(BE_PORT_STAT_FILE, BE_PROC_MODE,
+			       be_proc_dir[adapt_num]);
+	if (pde) {
+		pde->read_proc = proc_read_port_stat;
+		pde->write_proc = proc_write_port_stat;
+		pde->data = adapter;
+		pde->owner = THIS_MODULE;
+	}
+
+	pde = create_proc_entry(BE_MISC_STAT_FILE, BE_PROC_MODE,
+			       be_proc_dir[adapt_num]);
+	if (pde) {
+		pde->read_proc = proc_read_misc_stat;
+		pde->write_proc = proc_write_misc_stat;
+		pde->data = adapter;
+		pde->owner = THIS_MODULE;
+	}
+	pde = create_proc_entry(BE_DRVR_STAT_FILE, BE_PROC_MODE,
+			       be_proc_dir[adapt_num]);
+	if (pde) {
+		pde->read_proc = proc_read_drvr_stat;
+		pde->write_proc = proc_write_drvr_stat;
+		pde->data = adapter;
+		pde->owner = THIS_MODULE;
+	}
+
+	pde = create_proc_entry(BE_ETH_RING_FILE, BE_PROC_MODE,
+			       be_proc_dir[adapt_num]);
+	if (pde) {
+		pde->read_proc = proc_eth_read_ring;
+		pde->write_proc = proc_eth_write_ring;
+		pde->data = adapter;
+		pde->owner = THIS_MODULE;
+	}
+
+	pde = create_proc_entry(BE_DBG_MASK, BE_PROC_MODE,
+			       be_proc_dir[adapt_num]);
+	if (pde) {
+		pde->read_proc = proc_read_dbg_mask;
+		pde->write_proc = proc_write_dbg_mask;
+		pde->data = adapter;
+		pde->owner = THIS_MODULE;
+	}
+}
+
+void be_cleanup_procfs(PBE_ADAPTER adapter)
+{
+	int adapt_num = 0;
+
+	while (adapt_num < MAX_BE_DEVICES) {
+		if (be_adapter[adapt_num] == adapter)
+			break;
+		adapt_num++;
+	}
+
+	if (adapt_num == MAX_BE_DEVICES) {
+		printk(KERN_ERR "BldEng:Invalid Adapter Pointer received");
+		return;
+	}
+	remove_proc_entry(BE_PORT_STAT_FILE, be_proc_dir[adapt_num]);
+	remove_proc_entry(BE_MISC_STAT_FILE, be_proc_dir[adapt_num]);
+	remove_proc_entry(BE_DRVR_STAT_FILE, be_proc_dir[adapt_num]);
+	remove_proc_entry(BE_ETH_RING_FILE, be_proc_dir[adapt_num]);
+	remove_proc_entry(BE_DBG_MASK, be_proc_dir[adapt_num]);
+	remove_proc_entry(be_adpt_name[adapt_num], NULL);
+}
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/Makefile benet/linux-2.6.24.2/drivers/net/benet/Makefile
--- orig/linux-2.6.24.2/drivers/net/benet/Makefile	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/Makefile	2008-02-14 15:23:07.796207560 +0530
@@ -0,0 +1,25 @@
+#
+# Makefile to build the network driver for ServerEngine's BladeEngine.
+#
+BECLIBPATH = $(src)/../../message/beclib
+
+EXTRA_CFLAGS = -Wno-unknown-pragmas -DRX_PKT_COALESCE \
+	-DFUNCTION_NIC -I$(BECLIBPATH) -I$(BECLIBPATH)/sa \
+	-I$(BECLIBPATH)/fw -I$(BECLIBPATH)/fw/amap -I$(BECLIBPATH)/fw/bmap 
+
+obj-$(CONFIG_BENET) 	:= benet.o
+
+benet-objs	:=  be_init.o be_int.o be_netif.o be_tx.o \
+	be_proc.o be_ethtool.o bni.o \
+	../../message/beclib/funcobj_ll.o  \
+	../../message/beclib/chipobj_ll.o \
+	../../message/beclib/cq_ll.o \
+	../../message/beclib/eq_ll.o \
+	../../message/beclib/main_ll.o \
+	../../message/beclib/mpu_ll.o \
+	../../message/beclib/ethrx_ll.o \
+	../../message/beclib/ethtx_ll.o \
+	../../message/beclib/rxf_ll.o \
+	../../message/beclib/sa/sa.o 
+
+clean-files := ../../message/beclib/*.o  ../../message/beclib/sa/*.o 
diff -uprN orig/linux-2.6.24.2/drivers/net/Kconfig benet/linux-2.6.24.2/drivers/net/Kconfig
--- orig/linux-2.6.24.2/drivers/net/Kconfig	2008-02-11 11:21:11.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/Kconfig	2008-02-14 15:16:13.000000000 +0530
@@ -2585,6 +2585,22 @@ config TEHUTI
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
+config BENET
+	tristate "ServerEngines 10Gb NIC - BladeEngine"
+	depends on PCI
+	help
+	  This driver implements the NIC functionality for ServerEngines
+	  10Gb network adapter BladeEngine (EC 3210).
+
+config BENET_NAPI
+	bool "Use Rx Polling (NAPI) for benet"
+	depends on BENET
+	default y
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card. Selecting
+	  this feature will give better performance in high traffic conditions.
+
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff -uprN orig/linux-2.6.24.2/drivers/net/Makefile benet/linux-2.6.24.2/drivers/net/Makefile
--- orig/linux-2.6.24.2/drivers/net/Makefile	2008-02-11 11:21:11.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/Makefile	2008-02-14 15:16:13.000000000 +0530
@@ -16,6 +16,7 @@ obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atl1/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_BENET) += benet/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff -uprN orig/linux-2.6.24.2/MAINTAINERS benet/linux-2.6.24.2/MAINTAINERS
--- orig/linux-2.6.24.2/MAINTAINERS	2008-02-11 11:21:11.000000000 +0530
+++ benet/linux-2.6.24.2/MAINTAINERS	2008-02-14 15:16:27.000000000 +0530
@@ -3376,6 +3376,13 @@ L:	linux-ide@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/jgarzik/libata-dev.git
 S:	Supported
 
+SERVER ENGINES 10Gbe NIC - BLADE-ENGINE
+P:	Subbu Seetharaman
+M:	subbus@serverengines.com
+L:	netdev@vger.kernel.org
+W:	http://www.serverengines.com
+S:	Supported
+
 SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
 P:	Pat Gefre
 M:	pfg@sgi.com

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

