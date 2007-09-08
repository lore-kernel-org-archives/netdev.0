From: FUJITA Tomonori <tomof@acm.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 8 Sep 2007 16:41:09 +0900
Message-ID: <20070908084127G.tomof@acm.org>
References: <1188599815.5176.12.camel@dell>
	<46E1D27F.2040701@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com
To: open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo11.iij4u.or.jp ([210.138.174.81]:33802 "EHLO
	mfo11.iij4u.or.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbXIHH4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 03:56:20 -0400
Cc: fujita.tomonori@lab.ntt.co.jp
In-Reply-To: <46E1D27F.2040701@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Sep 2007 17:36:47 -0500
Mike Christie <michaelc@cs.wisc.edu> wrote:

> > +/*
> > + * map SG list
> > + */
> > +static int bnx2i_map_sg(struct bnx2i_hba *hba, struct bnx2i_cmd *cmd)
> > +{
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> > +	struct scatterlist *sg;
> > +	int byte_count = 0;
> > +	int sg_frags;
> > +	int bd_count = 0;
> > +	int sg_count;
> > +	int sg_len;
> > +	u64 addr;
> > +	int i;
> > +
> > +	sg = sc->request_buffer;
> > +	sg_count = pci_map_sg(hba->pci_dev, sg, sc->use_sg,
> > +			      sc->sc_data_direction);

Can you use scsi_dma_map() here?


> > +	for (i = 0; i < sg_count; i++) {
> > +		sg_len = sg_dma_len(sg);
> > +		addr = sg_dma_address(sg);
> > +		if (sg_len > MAX_BD_LENGTH)
> > +			sg_frags = bnx2i_split_bd(cmd, addr, sg_len,
> > +						  bd_count);

Please use scsi_for_each_sg().

You can't directly access to use_sg, request_buffer, request_bufflen,
and resid in scsi_cmnd structure. Please use the scsi data accessors
in scsi_cmnd.h: scsi_sg_count, scsi_sglist, scsi_bufflen,
scsi_set_resid, and scsi_get_resid.


> If you call blk_queue_max_segment_size() in the slave_configure callout 
> you can limit the size of the segments that the block layer builds so 
> they are smaller than MAX_BD_LENGTH. However, I am not sure how useful 
> that is. I think DMA-API.txt states that the mapping code is ok to 
> merged mutliple sglists entries into one so I think that means that we 
> can still end up with an entry that is larger than MAX_BD_LENGTH. Not 
> sure if there is way to tell the pci/dma map_sg code to limit this too.

Yeah, iommu code ignores the lld limitations (the problem is that the
lld limitations are in request_queue and iommu code can't access to
request_queue). There is no way to tell iommu code about the lld
limitations.
