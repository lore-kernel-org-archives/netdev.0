From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method to read memory section of adapter dump
Date: Mon, 24 Jun 2013 09:56:06 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B72A0@saturn3.aculab.com>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com> <1371832261-18930-5-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: "Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38996 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751854Ab3FXI4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:56:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17225-07 for <netdev@vger.kernel.org>;
 Mon, 24 Jun 2013 09:56:35 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1371832261-18930-5-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch adds support to read memory section of adapter
> dump using PEX DMA method. This method significantly improves
> total adapter dump collection time.

Which DMA engine is this using?
My first thought was that it was the one in the CSB bridge
(which ought to have a shared interface), but the structures
don't seem to match the code I have for that.

...
> +struct qlcnic_pex_dma_descriptor {
> +	u32	read_data_size;
> +	u32	dma_desc_cmd;
> +	u32	src_addr_low;
> +	u32	src_addr_high;
> +	u32	dma_bus_addr_low;
> +	u32	dma_bus_addr_high;
> +	u32	rsvd[6];
> +} __packed;

Why __packed??
Why are the structures following also marked __packed.

...
> +	/* Wait for DMA to complete */
> +	temp_addr = dma_base_addr + QLC_DMA_CMD_STATUS_CTRL;
> +	for (i = 0; i < 400; i++) {
> +		dma_sts = qlcnic_ind_rd(adapter, temp_addr);
> +
> +		if (dma_sts & BIT_1)
> +			usleep_range(250, 500);
> +		else
> +			break;
> +	}

Do these DMA actually take long enough to need to sleep
for completion?
I'd have thought that they'd normally finish almost immediately.
Sleeping might be reasonable as a 'last hope' check.

I'd also consider putting the 'wait for complete' code into
a separate function - allowing overlapped operations.

...
> +
> +	if ((tmpl_hdr->version & 0xffffff) >= 0x20001)
> +		ahw->fw_dump.use_pex_dma = true;
> +	else
> +		ahw->fw_dump.use_pex_dma = false;

You know what's wrong with the above....

	David
