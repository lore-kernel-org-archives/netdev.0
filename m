From: Joerg Roedel <jroedel@suse.de>
Subject: [BUG] be2net breaks when dma_alloc_coherent memory is not zeroed out
Date: Tue, 2 Jun 2015 09:22:05 +0200
Message-ID: <20150602072205.GA16345@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42453 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbbFBHWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 03:22:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

yesterday I bisected an issue with one of my be2net adapters and AMD
IOMMU enabled. In 4.1-rc it suddenly broke and didn't initialize
anymore. It turned out that the be2net driver breaks when the memory
returned from dma_alloc_coherent is not zeroed out. I introduced that
change to the AMD IOMMU driver for v4.1, other DMA-API implementations
for x86 still zero out the memory.

The bug shows like this in dmesg:

 be2net 0000:02:00.0: FW config: function_mode=0x10003, function_caps=0x7
 be2net 0000:02:00.0: FW not responding
 be2net 0000:02:00.0: Unrecoverable Error detected in the adapter
 be2net 0000:02:00.0: Please reboot server to recover
 be2net 0000:02:00.0: UE: MPU bit set

or sometimes as:

 be2net 0000:02:00.1: Waiting for POST, 52s elapsed
 be2net 0000:02:00.1: Waiting for POST, 54s elapsed
 be2net 0000:02:00.1: Waiting for POST, 56s elapsed
 be2net 0000:02:00.1: Waiting for POST, 58s elapsed

But always the result is:

 be2net 0000:02:00.1: Emulex OneConnect(be3) initialization failed
 be2net: probe of 0000:02:00.1 failed with error -110

When the memory returned by dma_alloc_coherent is zeroed out everything
works fine.

But strictly speaking dma_alloc_coherent is not required to zero out the
memory, drivers need to call dma_zalloc_coherent when they need this. So
the behavior of the AMD IOMMU driver is correct.

Can you guys please have a look and remove the assumption that
dma_alloc_coherent returns initialized memory in the be2net driver? In
the future I'd like to optimize out this needless zeroing out of memory
from all IOMMU drivers.

Please let me know if you need further information or if I can help with
testing or anything.

Thanks,

	Joerg
