From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method to
 read memory section of adapter dump
Date: Wed, 26 Jun 2013 23:43:14 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4DAE09@avmb2.qlogic.org>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <1371832261-18930-5-git-send-email-jitendra.kalsaria@qlogic.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72A0@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:9216 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313Ab3FZXnU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 19:43:20 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B72A0@saturn3.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Monday, June 24, 2013 1:56 AM
> To: Jitendra Kalsaria; David Miller
> Cc: netdev; Sony Chacko; Shahed Shaikh; Dept-NX Linux NIC Driver
> Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method
> to read memory section of adapter dump
> 
> > From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> >
> > This patch adds support to read memory section of adapter dump using
> > PEX DMA method. This method significantly improves total adapter dump
> > collection time.
> 
> Which DMA engine is this using?
> My first thought was that it was the one in the CSB bridge (which ought to
> have a shared interface), but the structures don't seem to match the code I
> have for that.
> 

It's not the one in the CSB bridge.

> ...
> > +struct qlcnic_pex_dma_descriptor {
> > +	u32	read_data_size;
> > +	u32	dma_desc_cmd;
> > +	u32	src_addr_low;
> > +	u32	src_addr_high;
> > +	u32	dma_bus_addr_low;
> > +	u32	dma_bus_addr_high;
> > +	u32	rsvd[6];
> > +} __packed;
> 
> Why __packed??
> Why are the structures following also marked __packed.
> 

 No need of __packed. Will remove in follow up patch.

> ...
> > +	/* Wait for DMA to complete */
> > +	temp_addr = dma_base_addr + QLC_DMA_CMD_STATUS_CTRL;
> > +	for (i = 0; i < 400; i++) {
> > +		dma_sts = qlcnic_ind_rd(adapter, temp_addr);
> > +
> > +		if (dma_sts & BIT_1)
> > +			usleep_range(250, 500);
> > +		else
> > +			break;
> > +	}
> 
> Do these DMA actually take long enough to need to sleep for completion?
> I'd have thought that they'd normally finish almost immediately.
> Sleeping might be reasonable as a 'last hope' check.
> 

We need to call sleep to cover worst case scenarios and we have encountered issues without sleep.
In the follow up patch we will be using usleep_range(50, 100).

> I'd also consider putting the 'wait for complete' code into a separate function
> - allowing overlapped operations.
> 

Sure. I will create a separate function.

> ...
> > +
> > +	if ((tmpl_hdr->version & 0xffffff) >= 0x20001)
> > +		ahw->fw_dump.use_pex_dma = true;
> > +	else
> > +		ahw->fw_dump.use_pex_dma = false;
> 
> You know what's wrong with the above....

Yes. Got it.  Masking is not done properly. It should be
if ((tmpl_hdr->version & 0xfffff) >= 0x20001)

Thanks for review comments.

-Shahed
> 
> 	David
