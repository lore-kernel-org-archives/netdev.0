From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Fri, 07 Sep 2007 17:36:47 -0500
Message-ID: <46E1D27F.2040701@cs.wisc.edu>
References: <1188599815.5176.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com
To: open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:34021 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758652AbXIGWhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 18:37:03 -0400
In-Reply-To: <1188599815.5176.12.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some quick comments that got cut out of the original mail.


> +
> +/*
> + * map single buffer
> + */
> +static int bnx2i_map_single_buf(struct bnx2i_hba *hba,
> +				       struct bnx2i_cmd *cmd)
> +{
> +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> +	int byte_count;
> +	int bd_count;
> +	u64 addr;
> +
> +	byte_count = sc->request_bufflen;
> +	sc->SCp.dma_handle =
> +		pci_map_single(hba->pci_dev, sc->request_buffer,
> +			       sc->request_bufflen, sc->sc_data_direction);
> +	addr = sc->SCp.dma_handle;
> +
> +	if (byte_count > MAX_BD_LENGTH) {
> +		bd_count = bnx2i_split_bd(cmd, addr, byte_count, 0);
> +	} else {
> +		bd_count = 1;
> +		bd[0].buffer_addr_lo = addr & 0xffffffff;
> +		bd[0].buffer_addr_hi = addr >> 32;
> +		bd[0].buffer_length = sc->request_bufflen;
> +		bd[0].flags = ISCSI_BD_FIRST_IN_BD_CHAIN |
> +			      ISCSI_BD_LAST_IN_BD_CHAIN;
> +	}
> +	bd[bd_count - 1].flags |= ISCSI_BD_LAST_IN_BD_CHAIN;
> +
> +	return bd_count;
> +}

I think you should always be getting use_sg greater than zero now, so 
the map single path is not needed.


> +
> +
> +/*
> + * map SG list
> + */
> +static int bnx2i_map_sg(struct bnx2i_hba *hba, struct bnx2i_cmd *cmd)
> +{
> +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> +	struct scatterlist *sg;
> +	int byte_count = 0;
> +	int sg_frags;
> +	int bd_count = 0;
> +	int sg_count;
> +	int sg_len;
> +	u64 addr;
> +	int i;
> +
> +	sg = sc->request_buffer;
> +	sg_count = pci_map_sg(hba->pci_dev, sg, sc->use_sg,
> +			      sc->sc_data_direction);
> +
> +	for (i = 0; i < sg_count; i++) {
> +		sg_len = sg_dma_len(sg);
> +		addr = sg_dma_address(sg);
> +		if (sg_len > MAX_BD_LENGTH)
> +			sg_frags = bnx2i_split_bd(cmd, addr, sg_len,
> +						  bd_count);


If you call blk_queue_max_segment_size() in the slave_configure callout 
you can limit the size of the segments that the block layer builds so 
they are smaller than MAX_BD_LENGTH. However, I am not sure how useful 
that is. I think DMA-API.txt states that the mapping code is ok to 
merged mutliple sglists entries into one so I think that means that we 
can still end up with an entry that is larger than MAX_BD_LENGTH. Not 
sure if there is way to tell the pci/dma map_sg code to limit this too.
