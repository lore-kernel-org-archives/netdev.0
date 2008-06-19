From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 19 Jun 2008 06:16:18 -0400
Message-ID: <20080619101618.GC17697@infradead.org>
References: <20080612104007.d68b14bd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56005 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978AbYFSKQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:16:21 -0400
Content-Disposition: inline
In-Reply-To: <20080612104007.d68b14bd@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/*
> +   This function initializes the data structures in BNI / BECLIB for network
> +   operation.  The OSM driver must call this function before making any other
> +   BNI call.
> +
> +   If this functions succeeds, the caller must call bni_cleanup() as part
> +   of driver cleanup procedure.
> +
> +   chipobj      -  Address of the space allocated by OSM for chip object
> +			(struct be_chip_object).  The space for this is
> +			allocated by OSM, but this object is maintained
> +			by BECLIB and is opaque to OSM.
> + */
> +BESTATUS bni_init(struct be_chip_object *chipobj)
> +{
> +	int r;
> +	r = be_initialize_library();
> +	if (r != BE_SUCCESS)
> +		goto error;
> +	r = be_chip_object_create(chipobj);
> +	if (r != BE_SUCCESS)
> +		goto error;
> +error:
> +	return r;
> +}

Should just me merged into the caller.

> +/*
> +   This function initializes the data structures in BNI / BECLIB for network
> +   operation.  The OSM driver must call this function before making any other
> +   BNI call.
> +
> +    chipobj        -  Pointer to the chip object passed as argument
> +			to bni_init().
> + */
> +void bni_cleanup(struct be_chip_object *chipobj)
> +{
> +	be_chip_object_destroy(chipobj);
> +}

Again, useless wrapper.

> +
> +/*
> +    This function initializes the bni_net_object for subsequent
> +    network operations. As part of the initialization, this function
> +    registers this device with beclib and creates the
> +    required set of queues (rings) that are needed to interact
> +    with BaldeEngine as a network NIC device and registers them
> +    with BladeEngine.
> +
> +    Before calling this function, the OSM driver  must have allocated
> +    space for the NetObject structure, initialized the structure,
> +    allocated DMAable memory for all the network queues that form
> +    part of the NetObject and populated the start address (virtual)
> +    and number of entries allocated for each queue in the NetObject structure.
> +
> +    The OSM driver must also have allocated memory to hold the
> +    mailbox structure (MCC_MAILBOX) and post the physical address,
> +    virtual addresses and the size of the mailbox memory in the
> +    NetObj.mb_sgl.  This structure is used by BECLIB for
> +    initial communication with the embedded MCC processor. BECLIB
> +    uses the mailbox until MCC rings are created for  more  efficient
> +    communication with the MCC processor.
> +
> +    If the OSM driver wants to create multiple network interface for more
> +    than one protection domain, it can call bni_create_netobj()
> +    multiple times  once for each protection domain.  A Maximum of
> +    32 protection domains are supported.
> +
> +    pnob - Pointer to the NetObject structure
> +    pbars         -  Pointer to the BAR address structure containing
> +			the addresses assigned OS to various BARS of the
> +			network PCI function of BladeEngine.
> +
> +    nbars         -  Number of BARs in the BAR structure.
> +
> +    sa_devp        -  Address of the space allocated for SA_DEVICE structure.
> +			This structure is initialized by the BECLIB and is
> +			opaque to the OSM drivers.
> +
> +    chipobj      -  Address of the space allocated by OSM for chip object
> +			(struct be_chip_object).  The space for this is
> +			allocated by OSM, but this object is maintained
> +			by BECLIB and is opaque to OSM.
> +*/

Also for functions please use kerneldoc comments.\

> +BESTATUS bni_change_eqd(struct bni_net_object *pnob, u32 delay)
> +{
> +	BESTATUS status = 0;
> +	struct be_eq_object *eq_objectp = NULL;
> +	struct be_function_object *pfob = &pnob->fn_obj;
> +
> +	eq_objectp = &pnob->event_q_obj;
> +	/*
> +	 * Caller must ensure Delay <= 240 and is a multiple of 8.
> +	 */
> +	status = be_eq_modify_delay(pfob, 1, &eq_objectp, &delay,
> +				    NULL, NULL, NULL);
> +	return status;
> +}

Seems like another quite useless wrapper.

> +bni_get_link_sts(struct bni_net_object *pnob, struct BE_LINK_STATUS *lsp,
> +		 MCC_WRB_CQE_CALLBACK cbf, void *cbc)
> +{
> +	BESTATUS r;
> +
> +	r = be_rxf_link_status(NET_FH(pnob), lsp, cbf, cbc, NULL);
> +
> +	return r;
> +}

another

> +{
> +	BESTATUS status;
> +
> +	if (pd) {
> +		/* this call is for setting the VM MAC address */
> +		port = 0;
> +		instance = 0;
> +	}
> +
> +	status = be_rxf_mac_address_read_write(NET_FH(pnob), port, instance,
> +			FALSE, FALSE, FALSE, mac_addr, cbf, cbc);
> +
> +	return status;
> +}

another

> +bni_set_uc_mac_adr(struct bni_net_object *pnob, u8 port, u8 instance, u8 pd,
> +		u8  *mac_addr, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
> +{
> +	BESTATUS status;
> +
> +	if (pd) {
> +		/* this call is for setting the VM MAC address */
> +		port = 0;
> +		instance = 0;
> +	}
> +
> +	status = be_rxf_mac_address_read_write(NET_FH(pnob), port, instance,
> +			FALSE, TRUE, FALSE, mac_addr, cbf, cbc);
> +
> +	return status;
> +}

another

> +BESTATUS
> +bni_set_mc_filter(struct bni_net_object *pnob, u32 nmac, bool  promiscuous,
> +		u8 *mac_addr, MCC_WRB_CQE_CALLBACK cbf, void *cbc)
> +{
> +	BESTATUS status;
> +
> +	status = be_rxf_multicast_config(NET_FH(pnob), promiscuous,
> +			nmac, mac_addr, cbf, cbc, NULL);
> +	return status;
> +}

another

> +
> +/*
> +    This function sets BE's network port into promiscuous mode.
> +
> +    pnob      - Pointer to the NetObject structure
> +
> +*/
> +void bni_set_promisc(struct bni_net_object *pnob)
> +{
> +	/* Set promiscuous mode on both ports. */
> +	be_rxf_promiscuous(NET_FH(pnob), 1, 1, NULL, NULL, NULL);
> +}

another and quite a few more..

