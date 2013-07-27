From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sat, 27 Jul 2013 01:24:30 +0100
Message-ID: <1374884670.1666.72.camel@bwh-desktop.uk.level5networks.com>
References: <1374857234-1442-1-git-send-email-nhorman@tuxdriver.com>
	 <1374883371.1666.56.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jay Cliburn <jcliburn@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <stable@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1374883371.1666.56.camel@bwh-desktop.uk.level5networks.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-07-27 at 01:02 +0100, Ben Hutchings wrote:
> On Fri, 2013-07-26 at 12:47 -0400, Neil Horman wrote:
> > atl1c uses netdev_alloc_skb to refill its rx dma ring, but that call makes no
> > guarantees about the suitability of the memory for use in DMA.  As a result
> > we've gotten reports of atl1c drivers occasionally hanging and needing to be
> > reset:
> > https://bugzilla.kernel.org/show_bug.cgi?id=54021
> > 
> > Fix this by modifying the call to use the internal version __netdev_alloc_skb,
> > where you can set the gfp_mask explicitly to include GFP_DMA.
> 
> This is a really bad idea.  GFP_DMA means allocation from the ISA DMA
> region (< 16 MB).  pci_map_single() takes care of allocating a bounce
> buffer if necessary.
> 
> Ben.
> 
> > Tested by two reporters in the above bug, who have the hardware to validate it.
> > Both report immediate cessation of the problem with this patch
[...]

So perhaps the chip somehow fails to support a full 32-bit address
(which is the current DMA mask), though given that there are 64 address
bits in RX descriptors this seems unlikely.  And the most likely result
of that would be memory corruption, not a stall.

Alternately, perhaps more likely, there's something wrong with the
driver's error handling.  If atl1_alloc_rx_buffer() fails then the RX
queue could run dry.  Depending on how the hardware is designed, that
could result in a complete RX stall (no RX buffers available => no RX
completions => no attempt to allocate more RX buffers).

Maybe your change makes it less likely for atl1_alloc_rx_buffer() to
fail.  On a modern PC the (ISA) DMA zone is basically unused whereas
bounce buffers might be more contended.  Did you try adding some logging
for failure of pci_map_single()?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
