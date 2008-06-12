From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 12 Jun 2008 03:40:07 -0700
Message-ID: <20080612104007.d68b14bd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:8902 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169AbYFLKkL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:40:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/net/benet/Makefile |   22 +
 drivers/net/benet/bni.c    | 1177 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 1199 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/Makefile
 create mode 100644 drivers/net/benet/bni.c

diff --git a/drivers/net/benet/Makefile b/drivers/net/benet/Makefile
new file mode 100644
index 0000000..0fe3297
--- /dev/null
+++ b/drivers/net/benet/Makefile
@@ -0,0 +1,22 @@
+#
+# Makefile to build the network driver for ServerEngine's BladeEngine.
+#
+BECLIBPATH = $(src)/../../message/beclib
+
+EXTRA_CFLAGS = -Wno-unknown-pragmas -DFUNCTION_NIC -I$(BECLIBPATH) \
+	-I$(BECLIBPATH)/fw -I$(BECLIBPATH)/fw/amap -I$(BECLIBPATH)/fw/bmap 
+
+obj-$(CONFIG_BENET) 	:= benet.o
+
+benet-objs	:=  be_init.o be_int.o be_netif.o be_ethtool.o bni.o \
+	../../message/beclib/funcobj_ll.o  \
+	../../message/beclib/chipobj_ll.o \
+	../../message/beclib/cq_ll.o \
+	../../message/beclib/eq_ll.o \
+	../../message/beclib/main_ll.o \
+	../../message/beclib/mpu_ll.o \
+	../../message/beclib/ethrx_ll.o \
+	../../message/beclib/ethtx_ll.o \
+	../../message/beclib/rxf_ll.o
+
+clean-files := ../../message/beclib/*.o
diff --git a/drivers/net/benet/bni.c b/drivers/net/benet/bni.c
new file mode 100644
index 0000000..ce72845
--- /dev/null
+++ b/drivers/net/benet/bni.c
@@ -0,0 +1,1177 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#include "bni.h"
+
+/*
+   This function initializes the data structures in BNI / BECLIB for network
+   operation.  The OSM driver must call this function before making any other
+   BNI call.
+
+   If this functions succeeds, the caller must call bni_cleanup() as part
+   of driver cleanup procedure.
+
+   chipobj      -  Address of the space allocated by OSM for chip object
+			(struct be_chip_object).  The space for this is
+			allocated by OSM, but this object is maintained
+			by BECLIB and is opaque to OSM.
+ */
+BESTATUS bni_init(struct be_chip_object *chipobj)
+{
+	int r;
+	r = be_initialize_library();
+	if (r != BE_SUCCESS)
+		goto error;
+	r = be_chip_object_create(chipobj);
+	if (r != BE_SUCCESS)
+		goto error;
+error:
+	return r;
+}
+
+/*
+   This function initializes the data structures in BNI / BECLIB for network
+   operation.  The OSM driver must call this function before making any other
+   BNI call.
+
+    chipobj        -  Pointer to the chip object passed as argument
+			to bni_init().
+ */
+void bni_cleanup(struct be_chip_object *chipobj)
+{
+	be_chip_object_destroy(chipobj);
+}
+
+/*
+    This function initializes the bni_net_object for subsequent
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
+    chipobj      -  Address of the space allocated by OSM for chip object
+			(struct be_chip_object).  The space for this is
+			allocated by OSM, but this object is maintained
+			by BECLIB and is opaque to OSM.
+*/
+BESTATUS
+bni_create_netobj(struct bni_net_object *pnob,
+		struct sa_dev_bar_locations *pbars, u32 nbars,
+		struct sa_dev *sa_devp, struct be_chip_object *chipobj)
+{
+	BESTATUS status = 0;
+	bool  eventable = FALSE, tx_no_delay = FALSE, rx_no_delay = FALSE;
+	struct be_eq_object *eq_objectp = NULL;
+	struct be_function_object *pfob = &pnob->fn_obj;
+	struct sa_sgl sgl;
+	SA_STATUS r;
+	u32 tempSz;
+	u32 tx_cmpl_wm = CEV_WMARK_96;	/* 0xffffffff to disable */
+	u32 rx_cmpl_wm = CEV_WMARK_160;	/* 0xffffffff to disable */
+	u32 eq_delay = 0; /* delay in 8usec units. 0xffffffff to disable */
+
+	memset(&sgl, 0, sizeof(struct sa_sgl));
+	r = sa_dev_create(pbars, nbars, (void *)0, sa_devp);
+	if (r != SA_SUCCESS)
+		return r;
+
+	status = be_function_object_create(sa_devp, BE_FUNCTION_TYPE_NETWORK,
+					&pnob->mb_sgl, pfob, chipobj);
+	if (status != BE_SUCCESS)
+		return status;
+	pnob->fn_obj_created = TRUE;
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
+		sa_sgl_create_contiguous(pnob->event_q, pnob->event_q_bus,
+			pnob->event_q_size, &sgl);
+
+		status = be_eq_create(pfob, &sgl, 4, pnob->event_q_len,
+				(u32) -1,	/* CEV_WMARK_* or -1 */
+				eq_delay,	/* in 8us units, or -1 */
+				&pnob->event_q_obj);
+		if (status != BE_SUCCESS)
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
+		sa_sgl_create_contiguous(pnob->tx_cq, pnob->tx_cq_bus,
+			pnob->tx_cq_size, &sgl);
+		status = be_cq_create(pfob, &sgl,
+			pnob->txcq_len * sizeof(struct ETH_TX_COMPL_AMAP),
+			FALSE,	/* solicted events,  */
+			tx_no_delay,	/* nodelay  */
+			tx_cmpl_wm,	/* Watermark encodings */
+			eq_objectp, &pnob->tx_cq_obj);
+		if (status != BE_SUCCESS)
+			goto error_ret;
+
+		pnob->tx_cq_id = be_cq_get_id(&pnob->tx_cq_obj);
+		pnob->tx_cq_created = 1;
+	}
+	/*
+	 * Eth Tx queue
+	 */
+	if (pnob->tx_q_len) {
+		struct be_eth_sq_parameters ex_params = { 0 };
+		u32 type;
+
+		if (pnob->tx_q_port) {
+			/* TXQ to be bound to a specific port */
+			type = BE_ETH_TX_RING_TYPE_BOUND;
+			ex_params.port = pnob->tx_q_port - 1;
+		} else
+			type = BE_ETH_TX_RING_TYPE_STANDARD;
+
+		sa_sgl_create_contiguous(pnob->tx_q, pnob->tx_q_bus,
+				pnob->tx_q_size, &sgl);
+		status = be_eth_sq_create_ex(pfob, &sgl,
+				pnob->tx_q_len * sizeof(struct ETH_WRB_AMAP),
+				type, 2, &pnob->tx_cq_obj,
+				&ex_params, &pnob->tx_q_obj);
+
+		if (status != BE_SUCCESS)
+			goto error_ret;
+
+		pnob->tx_q_id = be_eth_sq_get_id(&pnob->tx_q_obj);
+		pnob->tx_q_created = 1;
+	}
+	/*
+	 * Now Eth Rx compl. queue.  Always needed.
+	 */
+	sa_sgl_create_contiguous(pnob->rx_cq, pnob->rx_cq_bus,
+			pnob->rx_cq_size, &sgl);
+	status = be_cq_create(pfob, &sgl,
+			pnob->rx_cq_len * sizeof(struct ETH_RX_COMPL_AMAP),
+			FALSE,	/* solicted events,  */
+			rx_no_delay,	/* nodelay  */
+			rx_cmpl_wm,	/* Watermark encodings */
+			eq_objectp, &pnob->rx_cq_obj);
+	if (status != BE_SUCCESS)
+		goto error_ret;
+
+	pnob->rx_cq_id = be_cq_get_id(&pnob->rx_cq_obj);
+	pnob->rx_cq_created = 1;
+
+	status = be_eth_rq_set_frag_size(pfob,
+			pnob->rx_buf_size,	/* desired frag size in bytes */
+			(u32 *) &tempSz);	/* actual frag size set */
+	if (status != BE_SUCCESS) {
+		be_eth_rq_get_frag_size(pfob, (u32 *) &pnob->rx_buf_size);
+		if ((pnob->rx_buf_size != 2048)
+		    && (pnob->rx_buf_size != 4096)
+		    && (pnob->rx_buf_size != 8192))
+			goto error_ret;
+	} else {
+		/*be_eth_rq_get_frag_size (pfob, (u32*)&pnob->rx_buf_size); */
+		if (pnob->rx_buf_size != tempSz)
+			pnob->rx_buf_size = tempSz;
+	}
+	/*
+	 * Eth RX queue. be_eth_rq_create() always assumes 2 pages size
+	 */
+	sa_sgl_create_contiguous(pnob->rx_q, pnob->rx_q_bus, pnob->rx_q_size,
+				&sgl);
+	status = be_eth_rq_create(pfob, &sgl, &pnob->rx_cq_obj,
+			     &pnob->rx_cq_obj, &pnob->rx_q_obj);
+
+	if (status != BE_SUCCESS)
+		goto error_ret;
+
+	pnob->rx_q_id = be_eth_rq_get_id(&pnob->rx_q_obj);
+	pnob->rx_q_created = 1;
+
+	return BE_SUCCESS;	/* All required queues created. */
+
+error_ret:
+	/*
+	 *  Some queue creation failed.  Clean up any we successfully created.
+	 */
+	bni_destroy_netobj(pnob, sa_devp);
+	return status;
+}
+
+/*
+   This function changes the EQ delay - the interval that BladeEngine
+   should wait after an event entry is made in an EQ before the host
+   is interrupted.
+
+    pnob - Pointer to the NetObject structure
+    delay   - The delay in microseconds.  Must be between 0 and 240 and
+		must be a multiple of 8.
+*/
+BESTATUS bni_change_eqd(struct bni_net_object *pnob, u32 delay)
+{
+	BESTATUS status = 0;
+	struct be_eq_object *eq_objectp = NULL;
+	struct be_function_object *pfob = &pnob->fn_obj;
+
+	eq_objectp = &pnob->event_q_obj;
+	/*
+	 * Caller must ensure Delay <= 240 and is a multiple of 8.
+	 */
+	status = be_eq_modify_delay(pfob, 1, &eq_objectp, &delay,
+				    NULL, NULL, NULL);
+	return status;
+}
+/*
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
+    pnob	- Pointer to the NetObject structure. This NetObject should
+		  have been created using a previous call to bni_create_netobj()
+*/
+BESTATUS bni_create_mcc_rings(struct bni_net_object *pnob)
+{
+	BESTATUS status = 0;
+	struct sa_sgl sgl;
+	struct be_function_object *pfob = &pnob->fn_obj;
+
+	memset(&sgl, 0, sizeof(struct sa_sgl));
+	/*
+	 * Create the MCC completion ring.
+	 */
+	if (pnob->mcc_cq_len) {
+		(void)sa_sgl_create_contiguous(pnob->mcc_cq, pnob->mcc_cq_bus,
+			pnob->mcc_cq_size, &sgl);
+
+		status = be_cq_create(pfob, &sgl,
+			pnob->mcc_cq_len * sizeof(struct MCC_CQ_ENTRY_AMAP),
+			FALSE,	/* solicted events,  */
+			TRUE,	/* nodelay  */
+			0,	/* 0 Watermark since Nodelay is true */
+			&pnob->event_q_obj,
+			&pnob->mcc_cq_obj);
+
+		if (status != BE_SUCCESS)
+			return status;
+
+		pnob->mcc_cq_id = be_cq_get_id(&pnob->mcc_cq_obj);
+		pnob->mcc_cq_created = 1;
+	}
+	if (pnob->mcc_q_len) {
+		sa_sgl_create_contiguous(pnob->mcc_q, pnob->mcc_q_bus,
+			pnob->mcc_q_size, &sgl);
+
+		status = be_mcc_ring_create(pfob, &sgl,
+				pnob->mcc_q_len * sizeof(struct MCC_WRB_AMAP),
+				pnob->mcc_wrb_ctxt, pnob->mcc_wrb_ctxtLen,
+				&pnob->mcc_cq_obj, &pnob->mcc_q_obj);
+
+		if (status != BE_SUCCESS)
+			return status;
+
+		/* be_mcc_get_id() is not exposed to drivers since we
+		 * do not need post any commands directly.  BECLib
+		 * does it for us.
+		 */
+		pnob->mcc_q_created = 1;
+	}
+	return BE_SUCCESS;
+}
+
+/*
+    This function destroys a NetObject created using a previous call to
+    BeCreateNetObject().  All the queues associated with the NetObject are
+    de-registered from BladeEngine.  The actual memory allocated for the
+    queues as well as the space allocated for the NetObject must be freed
+    by the OSM driver after this call returns.
+
+    pnob - Pointer to the NetObject structure
+
+*/
+void bni_destroy_netobj(struct bni_net_object *pnob, struct sa_dev *sa_devp)
+{
+
+	BESTATUS status;
+
+	/* free the queues */
+
+	if (pnob->tx_q_created) {
+		status = be_eth_sq_destroy(&pnob->tx_q_obj);
+		pnob->tx_q_created = 0;
+	}
+
+	if (pnob->rx_q_created) {
+		status = be_eth_rq_destroy(&pnob->rx_q_obj);
+		if (status != 0) {
+			status = be_eth_rq_destroy_options(&pnob->rx_q_obj, 0,
+						      NULL, NULL);
+			BUG_ON(status);
+		}
+		pnob->rx_q_created = 0;
+	}
+
+	bni_process_rx_flush_cmpl(pnob);
+
+	if (pnob->tx_cq_created) {
+		status = be_cq_destroy(&pnob->tx_cq_obj);
+		pnob->tx_cq_created = 0;
+	}
+
+	if (pnob->rx_cq_created) {
+		status = be_cq_destroy(&pnob->rx_cq_obj);
+		pnob->rx_cq_created = 0;
+	}
+
+	if (pnob->mcc_q_created) {
+		status = be_mcc_ring_destroy(&pnob->mcc_q_obj);
+		pnob->mcc_q_created = 0;
+	}
+	if (pnob->mcc_cq_created) {
+		status = be_cq_destroy(&pnob->mcc_cq_obj);
+		pnob->mcc_cq_created = 0;
+	}
+
+	if (pnob->event_q_created) {
+		status = be_eq_destroy(&pnob->event_q_obj);
+		pnob->event_q_created = 0;
+	}
+	be_function_cleanup(&pnob->fn_obj);
+
+	/* Cleanup the SA device object. */
+	sa_dev_destroy(sa_devp);
+}
+
+/*
+    This function processes the Flush Completions that are issued by the
+    ARM F/W, when a Recv Ring is destroyed.  A flush completion is
+    identified when a Rx COmpl descriptor has the tcpcksum and udpcksum
+    set and the pktsize is 32.  These completions are received on the
+    Rx Completion Queue.
+
+    pnob - Pointer to the NetObject structure
+
+    Returns number of flush completions processed.
+
+*/
+u32 bni_process_rx_flush_cmpl(struct bni_net_object *pnob)
+{
+	struct ETH_RX_COMPL_AMAP *rxcp;
+	unsigned int i = 0;
+	while ((rxcp = bni_get_rx_cmpl(pnob)) != NULL) {
+		bni_notify_cmpl(pnob, 1, pnob->rx_cq_id, 1);
+		i++;
+	}
+	return i;
+}
+
+/*
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
+    pnob       - Pointer to the NetObject structure
+
+    txb_list   - Pointer to the fragment list describing the ether
+		frame fragments to be transmitted
+
+    flags         - A 32 bit flag indicating a required transmit option.
+
+    vlant       - VLAN tag to be inserted (if ETHVLAN set in flags)
+
+    mss           - Mss to be used if LSO is enabled.
+
+    ctxtp      - An OSM context handle that the OSM can use to
+		identify a completion with a send request.
+
+    nfrags      - Number of fragments in the txb_list (1 to 15)
+*/
+BESTATUS
+bni_tx_pkt(struct bni_net_object *pnob,
+	   struct bni_tx_frag_list *txb_list,
+	   u32 flags, u32 vlant, u32 mss, void *ctxtp, u32 nfrags)
+{
+	struct ETH_WRB_AMAP *first_wrb, *curr_wrb;
+	int txq_hd;
+	u32 fi, total_frags;
+
+	if (((pnob->tx_q_len - 2) - atomic_read(&pnob->tx_q_used)) > nfrags) {
+		if (nfrags & 1)
+			total_frags = nfrags + 1;
+		else
+			total_frags = nfrags;
+	} else
+		return BE_NOT_OK;
+
+	atomic_add(total_frags, &pnob->tx_q_used);
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
+
+	AMAP_SET_BITS_PTR(ETH_WRB, crc, curr_wrb, 1);
+
+	if (flags & LSO) {
+		AMAP_SET_BITS_PTR(ETH_WRB, lso, curr_wrb, 1);
+		AMAP_SET_BITS_PTR(ETH_WRB, lso_mss, curr_wrb, mss);
+	} else {
+		if (flags & TCPCS)
+			AMAP_SET_BITS_PTR(ETH_WRB, tcpcs, curr_wrb, 1);
+
+		if (flags & IPCS)
+			AMAP_SET_BITS_PTR(ETH_WRB, ipcs, curr_wrb, 1);
+
+		if (flags & UDPCS)
+			AMAP_SET_BITS_PTR(ETH_WRB, udpcs, curr_wrb, 1);
+	}
+
+	/* Transmit the packet in forwarding path for loopback packet */
+	if (flags & FORWARD)
+		AMAP_SET_BITS_PTR(ETH_WRB, forward, curr_wrb, 1);
+
+	AMAP_SET_BITS_PTR(ETH_WRB, vlan_tag, curr_wrb, vlant);
+	if (flags & ETHVLAN)
+		AMAP_SET_BITS_PTR(ETH_WRB, vlan, curr_wrb, 1);
+
+	if (flags & ETHEVENT)
+		AMAP_SET_BITS_PTR(ETH_WRB, event, curr_wrb, 1);
+
+	AMAP_SET_BITS_PTR(ETH_WRB, last, curr_wrb, 0);
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_hi, curr_wrb, txb_list[0].txb_pa_hi);
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_lo, curr_wrb, txb_list[0].txb_pa_lo);
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_len, curr_wrb, txb_list[0].txb_len);
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
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_hi, curr_wrb,
+				txb_list[fi].txb_pa_hi);
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_lo, curr_wrb,
+				txb_list[fi].txb_pa_lo);
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_len, curr_wrb,
+				txb_list[fi].txb_len);
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
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_hi, curr_wrb, 0);
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_lo, curr_wrb, 0);
+		AMAP_SET_BITS_PTR(ETH_WRB, frag_len, curr_wrb, 0);
+	}
+	/*
+	 * Fix up the last fragment
+	 */
+	if (flags & ETHCOMPLETE)
+		AMAP_SET_BITS_PTR(ETH_WRB, complete, curr_wrb, 1);
+
+	AMAP_SET_BITS_PTR(ETH_WRB, last, curr_wrb, 1);
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
+/*
+   This function writes the number of posted WRBs into the doorbell
+   to kick off the actual transmit of the ether frames whose
+   addresses are filled in the ether send ring by the function
+   bni_tx_pkt().
+
+    pnob   - Pointer to the NetObject structure
+
+    nposted - Number of WRBs filled in.
+
+*/
+void bni_start_tx(struct bni_net_object *pnob, u32 nposted)
+{
+#define CSR_ETH_MAX_SQPOSTS 255
+	struct SQ_DB_AMAP sqdb;
+
+	sqdb.dw[0] = 0;
+
+	AMAP_SET_BITS_PTR(SQ_DB, cid, &sqdb, pnob->tx_q_id);
+	while (nposted) {
+		if (nposted > CSR_ETH_MAX_SQPOSTS) {
+			AMAP_SET_BITS_PTR(SQ_DB, numPosted, &sqdb,
+							CSR_ETH_MAX_SQPOSTS);
+			nposted -= CSR_ETH_MAX_SQPOSTS;
+		} else {
+			AMAP_SET_BITS_PTR(SQ_DB, numPosted, &sqdb, nposted);
+			nposted = 0;
+		}
+		PD_WRITE(NET_FH(pnob), etx_sq_db, sqdb);
+	}
+
+	return;
+}
+
+/*
+    This function posts  receive buffers to the ether receive queue.
+    The caller must allocate  the buffers, populate the addresses in
+    list of bni_recv_buffer structures and pass the address of this
+    list. The number of the receive buffers in the list should not be
+    more than 255.  If the list has more than 255 receive buffers or
+    the RX ring has less free slots than the number of buffers in
+    the list, the function will post whatever buffers it can in the
+    available free slots in the RX ring and remove these entries from
+    the list.  The caller is responsible for freeing the remaining
+    buffers in the list.
+
+    The OSM driver must have filled in the context handle for each
+    bni_recv_buffer entry in the member context1. This function stores
+    the handle in the array NetObj.rx_ctxt at the index
+    corresponding to the entry in the recieve buffer queue where the
+    buffer was posted. OSM driver can retrieve this context information
+    using the fragndx field in the RX completion descriptor and use it
+    for the receive completion processing.
+
+    pnob      - Pointer to the NetObject structure
+
+    rxbl      - A List of bni_recv_buffer structures that hold the
+		free recv buffer address.
+
+    Returns number of buffers that were posted to this queue
+
+*/
+u32 bni_post_rx_buffs(struct bni_net_object *pnob, struct list_head *rxbl)
+{
+	u32 nposted = 0;
+	struct ETH_RX_D_AMAP *rxd = NULL;
+	struct bni_recv_buffer *rxbp;
+	void **rx_ctxp;
+	struct RQ_DB_AMAP rqdb;
+
+	rx_ctxp = pnob->rx_ctxt;
+
+	while (!list_empty(rxbl) &&
+	       (rx_ctxp[pnob->rx_q_hd] == NULL) && nposted < 255) {
+
+		rxbp = list_first_entry(rxbl, struct bni_recv_buffer, rxb_list);
+		list_del(&rxbp->rxb_list);
+		rxd = pnob->rx_q + pnob->rx_q_hd;
+		AMAP_SET_BITS_PTR(ETH_RX_D, fragpa_lo, rxd, rxbp->rxb_pa_lo);
+		AMAP_SET_BITS_PTR(ETH_RX_D, fragpa_hi, rxd, rxbp->rxb_pa_hi);
+
+		rx_ctxp[pnob->rx_q_hd] = rxbp->rxb_ctxt;
+		bni_adv_rxq_hd(pnob);
+		nposted++;
+	}
+
+	if (nposted) {
+		/* Now press the door bell to notify BladeEngine. */
+		rqdb.dw[0] = 0;
+		AMAP_SET_BITS_PTR(RQ_DB, numPosted, &rqdb, nposted);
+		AMAP_SET_BITS_PTR(RQ_DB, rq, &rqdb, pnob->rx_q_id);
+		PD_WRITE(NET_FH(pnob), erx_rq_db, rqdb);
+	}
+	atomic_add(nposted, &pnob->rx_q_posted);
+	return nposted;
+}
+
+/*
+    This function checks the Eth send completion queue and returns
+    the address of the TX completion entry at the tail of the completion
+    queue.  If no valid completion is present, this function returns NULL.
+
+    pnob      - Pointer to the NetObject structure
+
+    If a valid entry is found, it returns the pointer to ETH_TX_COMPL_AMAP
+    If no valid entry is found, NULL is returned
+
+*/
+struct ETH_TX_COMPL_AMAP *bni_get_tx_cmpl(struct bni_net_object *pnob)
+{
+	struct ETH_TX_COMPL_AMAP *txcp = &pnob->tx_cq[pnob->tx_cq_tl];
+	u32 valid;
+
+	valid  = AMAP_GET_BITS_PTR(ETH_TX_COMPL, valid, txcp);
+	if (valid == 0)
+		return NULL;
+
+	AMAP_SET_BITS_PTR(ETH_TX_COMPL, valid, txcp, 0);
+	bni_adv_txcq_tl(pnob);
+	return txcp;
+
+}
+
+/*
+    This function checks the Eth receive completion queue and returns
+    the address of the RX completion entry at the tail of the completion
+    queue.  If no valid completion is present, this function returns NULL.
+
+    pnob      - Pointer to the NetObject structure
+
+    If a valid entry is found, it returns the pointer to ETH_RX_COMPL
+    If no valid entry is found, NULL is returned
+
+*/
+struct ETH_RX_COMPL_AMAP *bni_get_rx_cmpl(struct bni_net_object *pnob)
+{
+	struct ETH_RX_COMPL_AMAP *rxcp = &pnob->rx_cq[pnob->rx_cq_tl];
+	u32 valid, ct;
+
+	valid  = AMAP_GET_BITS_PTR(ETH_RX_COMPL, valid, rxcp);
+	if (valid == 0)
+		return NULL;
+
+	ct  = AMAP_GET_BITS_PTR(ETH_RX_COMPL, ct, rxcp);
+	if (ct != 0) {
+		/* Invalid chute #. treat as error */
+		AMAP_SET_BITS_PTR(ETH_RX_COMPL, err, rxcp, 1);
+	}
+
+	bni_adv_rxcq_tl(pnob);
+	AMAP_SET_BITS_PTR(ETH_RX_COMPL, valid, rxcp, 0);
+	return rxcp;
+}
+
+/*
+    This function notifies BladeEngine of the number of completion
+    entries processed from the specified completion queue by writing
+    the number of popped entries to the door bell.
+
+    pnob	- Pointer to the NetObject structure
+
+    n		- Number of completion entries processed
+
+    cq_id	- Queue ID of the completion queue for which notification
+			is being done.
+
+    re_arm	- 1  - rearm the completion ring to generate an event.
+		- 0  - dont rearm the completion ring to generate an event
+
+*/
+void bni_notify_cmpl(struct bni_net_object *pnob, int n, int cq_id, int re_arm)
+{
+
+	struct CQ_DB_AMAP cqdb;
+
+	cqdb.dw[0] = 0;
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &cqdb, cq_id);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &cqdb, re_arm);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &cqdb, n);
+
+	PD_WRITE(NET_FH(pnob), cq_db, cqdb);
+}
+
+/*
+   This function enables the interrupt corresponding to the Event
+   queue ID for the given NetObject
+
+    pnob      - Pointer to the NetObject structure
+*/
+void bni_enable_eq_intr(struct bni_net_object *pnob)
+{
+	struct CQ_DB_AMAP cqdb;
+
+	cqdb.dw[0] = 0;		/* clear entire doorbell */
+
+	AMAP_SET_BITS_PTR(CQ_DB, event, &cqdb, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &cqdb, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &cqdb, 0);
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &cqdb, pnob->event_q_id);
+
+	PD_WRITE(NET_FH(pnob), cq_db, cqdb);
+}
+
+/*
+   This function disables the interrupt corresponding to the Event
+   queue ID for the given NetObject
+
+    pnob      - Pointer to the NetObject structure
+*/
+void bni_disable_eq_intr(struct bni_net_object *pnob)
+{
+	struct CQ_DB_AMAP cqdb;
+
+	cqdb.dw[0] = 0;		/* clear entire doorbell */
+
+	AMAP_SET_BITS_PTR(CQ_DB, event, &cqdb, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &cqdb, 0);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &cqdb, 0);
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &cqdb, pnob->event_q_id);
+
+	PD_WRITE(NET_FH(pnob), cq_db, cqdb);
+}
+
+/*
+    This function enables the interrupt from the  network function
+    of the BladeEngine. Use the function bni_disable_eq_intr()
+    to enable the interrupt from the event queue of only one specific
+    NetObject
+
+    pnob      - Pointer to the NetObject structure
+*/
+void bni_enable_intr(struct bni_net_object *pnob)
+{
+
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+	u32 host_intr;
+
+	ctrl.dw[0] = PCICFG1_READ(NET_FH(pnob), host_timer_int_ctrl);
+
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+							hostintr, ctrl.dw);
+	if (!host_intr) {
+		AMAP_SET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+						hostintr, ctrl.dw, 1);
+		PCICFG1_WRITE_CONST(NET_FH(pnob), host_timer_int_ctrl,
+								ctrl.dw[0]);
+	}
+}
+
+/*
+   This function disables the interrupt from the network function of
+   the BladeEngine.  Use the function bni_disable_eq_intr() to
+   disable the interrupt from the event queue of only one specific NetObject
+
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_disable_intr(struct bni_net_object *pnob)
+{
+
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+	u32 host_intr;
+
+	ctrl.dw[0] = PCICFG1_READ(NET_FH(pnob), host_timer_int_ctrl);
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+							hostintr, ctrl.dw);
+	if (host_intr) {
+		AMAP_SET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR, hostintr,
+						ctrl.dw, 0);
+		PCICFG1_WRITE_CONST(NET_FH(pnob), host_timer_int_ctrl,
+						ctrl.dw[0]);
+	}
+}
+
+/*
+   This function reads the ISR and returns the value read.  ISR is
+   a clear-on-read register
+
+    pnob      - Pointer to the NetObject structure
+
+    Returns the 32 bit value in the ISR
+*/
+u32 bni_get_isr(struct bni_net_object *pnob)
+{
+	return CSR_READ(NET_FH(pnob), cev.isr1);
+}
+
+/*
+    This function checks the event queue for a valid event. If a valid
+    entry is found, it returns pointer to the entry.  The client is
+    responsible for tracking the number of event queue items popped
+    out of this queue for subsequently ringing the event queue doorbell.
+
+    pnob      - Pointer to the NetObject structure
+
+    Pointer to next valid event queue entry if one is found.
+    NULL if no valid entry is found.
+*/
+struct EQ_ENTRY_AMAP *bni_get_event(struct bni_net_object *pnob)
+{
+	struct EQ_ENTRY_AMAP *eqp = &(pnob->event_q[pnob->event_q_tl]);
+	u32 valid;
+
+	valid  = AMAP_GET_BITS_PTR(EQ_ENTRY, Valid, eqp);
+	if (!valid)
+		return NULL;
+	/*
+	 * We got a valid event. Now increment the EQ index to next event.
+	 */
+	bni_adv_eq_tl(pnob);
+	return eqp;
+}
+
+/*
+    This function notifies BladeEngine of how many events were processed
+    from the event queue by ringing the corresponding door bell and
+    optionally re-arms the event queue.
+
+    pnob	- Pointer to the NetObject structure
+    n		- number of events processed
+    re_arm	- 1 - re-arm the EQ, 0 - do not re-arm the EQ
+
+*/
+void bni_notify_event(struct bni_net_object *pnob, int n, int re_arm)
+{
+	struct CQ_DB_AMAP eqdb;
+
+	eqdb.dw[0] = 0;
+
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &eqdb, pnob->event_q_id);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &eqdb, re_arm);
+	AMAP_SET_BITS_PTR(CQ_DB, event, &eqdb, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &eqdb, n);
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
+/*
+   This function gets the current link status.
+
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
+*/
+BESTATUS
+bni_get_link_sts(struct bni_net_object *pnob, struct BE_LINK_STATUS *lsp,
+		 MCC_WRB_CQE_CALLBACK cbf, void *cbc)
+{
+	BESTATUS r;
+
+	r = be_rxf_link_status(NET_FH(pnob), lsp, cbf, cbc, NULL);
+
+	return r;
+}
+
+/*
+   This function gets the specified MAC address from BladeEngine's MAC address
+   table.
+
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
+   mac_addr           - Address the array where to return the MAC address.
+
+   cbf        - Pointer to a function that will be called on completion.
+			If NULL, the call will block waiting for completion.
+
+   cbc         - Opaque context argument that will be passed to the
+			completion call back function.
+*/
+
+BESTATUS
+bni_get_uc_mac_adrr(struct bni_net_object *pnob, u8 port, u8 instance, u8 pd,
+		u8 *mac_addr, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
+{
+	BESTATUS status;
+
+	if (pd) {
+		/* this call is for setting the VM MAC address */
+		port = 0;
+		instance = 0;
+	}
+
+	status = be_rxf_mac_address_read_write(NET_FH(pnob), port, instance,
+			FALSE, FALSE, FALSE, mac_addr, cbf, cbc);
+
+	return status;
+}
+
+/*
+   This function sets the specified MAC address from BladeEngine's MAC address
+   table.
+
+   pnob           - Pointer to the NetObject structure
+
+   port           - 0 for first port, 1 for second port.
+
+   instance       - 0 for the first MAC address of the port, 1 for
+			the second instance of the AMC address for the port.
+
+   pd             - The protection domain number (used only for
+			virtual machie)
+
+   mac_addr       - Address the array where the
+			MAC address to be set is stored.
+
+   cbf        - Pointer to a function that will be called on completion.
+			If NULL, the call will block waiting for completion.
+
+   cbc         - Opaque context argument that will be passed to the
+			completion call back function.
+*/
+BESTATUS
+bni_set_uc_mac_adr(struct bni_net_object *pnob, u8 port, u8 instance, u8 pd,
+		u8  *mac_addr, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
+{
+	BESTATUS status;
+
+	if (pd) {
+		/* this call is for setting the VM MAC address */
+		port = 0;
+		instance = 0;
+	}
+
+	status = be_rxf_mac_address_read_write(NET_FH(pnob), port, instance,
+			FALSE, TRUE, FALSE, mac_addr, cbf, cbc);
+
+	return status;
+}
+
+/*
+    This function adds the given multicast MAC addresses into BE's
+    multicast filter table.   The maximum number of multicast addresses
+    that can be added  using this call is 32.  More than 32 addresses
+    can be added through multiple calls.
+
+    pnob     - Pointer to the NetObject structure
+
+    nmac      - number of MAC sddresses to be added - maximum is 32
+
+    promiscuous - Whether to enable multicast promiscuous mode or not.
+		  If 1,  multicast promiscuous mode is enabled and the
+		  parameters NumMac  and mac_addr are ignored.
+		  If this is not enabled, the multicast addresses in
+		  the array mac_addr will programmed
+
+    mac_addr     - Pointer to an address an array of mac address
+
+    cbf  - Pointer to a function that will be called on completion.
+		If NULL, the call will block waiting for completion.
+
+    cbc   - Opaque context argument that will be passed to the
+		completion call back function.
+*/
+BESTATUS
+bni_set_mc_filter(struct bni_net_object *pnob, u32 nmac, bool  promiscuous,
+		u8 *mac_addr, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
+{
+	BESTATUS status;
+
+	status = be_rxf_multicast_config(NET_FH(pnob), promiscuous,
+			nmac, mac_addr, cbf, cbc, NULL);
+	return status;
+}
+
+/*
+    This function sets BE's network port into promiscuous mode.
+
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_set_promisc(struct bni_net_object *pnob)
+{
+	/* Set promiscuous mode on both ports. */
+	be_rxf_promiscuous(NET_FH(pnob), 1, 1, NULL, NULL, NULL);
+}
+
+/*
+    This function takes BE's network port out of promiscuous mode.
+
+    pnob      - Pointer to the NetObject structure
+
+*/
+void bni_reset_promisc(struct bni_net_object *pnob)
+{
+	/* Reset promiscuous mode on both ports. */
+	be_rxf_promiscuous(NET_FH(pnob), 0, 0, NULL, NULL, NULL);
+}
+
+/*
+    This function configures the VLAN Id table of BladeEngine.  If the table
+    has any VLAN, Vlan filtering is turned on.  If there no VLANN Ids  in the
+    table, VLAN filtering is turned off. BladeEngine supports a maximum of
+    32 VLans.
+
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
+*/
+BESTATUS
+bni_config_vlan(struct bni_net_object *pnob, u16 *vlanp, u32 nv,
+		MCC_WRB_CQE_CALLBACK cbf, void *cbc, bool  promiscuous)
+{
+	BESTATUS status;
+
+	status = be_rxf_vlan_config(NET_FH(pnob), promiscuous, nv, vlanp,
+				    cbf, cbc, NULL);
+
+	return status;
+}
+
+/*
+    This function gets the ethernet port statistics from the ASIC
+
+    pnob       - Pointer to the NetObject structure
+
+    va       - Virtual address of structure FWCMD_ETH_GET_STATISTICS
+
+    pa       - Physical address of structure FWCMD_ETH_GET_STATISTICS
+
+    cbf    - Pointer to a function that will be
+		called on completion. If NULL, the call will block
+		    waiting for completion.
+
+    cbc     - Opaque context argument that will be passed to
+		the completion call back function
+
+*/
+BESTATUS
+bni_get_stats(struct bni_net_object *pnob,
+	      struct FWCMD_ETH_GET_STATISTICS *va,
+	      u64 pa, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
+{
+	BESTATUS s;
+
+	s = be_rxf_query_eth_statistics(NET_FH(pnob), va, pa, cbf, cbc, NULL);
+
+	return s;
+
+}
+
+/*
+    Wrapper function to Set Pause frame control
+
+    pfob     - Pointer to the function object to read from.
+    txfc_enable	- Boolean variable - 0 if TX flow control is to be
+		disabled, 1 if  TX flow control is to be disabled.
+
+    rxfc_enable	- Boolean variable - 0 if RX flow control is to be
+		disabled, 1 if  XX flow control is to be disabled
+*/
+BESTATUS
+bni_set_flow_ctll(struct be_function_object *pfob, bool txfc_enable,
+		  bool rxfc_enable)
+{
+	return be_eth_set_flow_control(pfob, txfc_enable, rxfc_enable);
+}
+
+/*
+    Wrapper function to Get Pause frame control
+
+    pfob     - Pointer to the function object to read from.
+
+    txfc_enable	- Pointer to a Boolean variable where the TX flow
+			control setting will be returned.  0 if the flow
+			control is disabled, 1 if  flow control is disabled.
+    rxfc_enable	- Pointer to a Boolean variable where the RX flow
+			control setting will be returned.  0 if the flow
+			control is disabled, 1 if  flow control is disabled
+
+*/
+BESTATUS
+bni_get_flow_ctl(struct be_function_object *pfob, bool *txfc_enable,
+					bool *rxfc_enable)
+{
+	return be_eth_get_flow_control(pfob, txfc_enable, rxfc_enable);
+}
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

