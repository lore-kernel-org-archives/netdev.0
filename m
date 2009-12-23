From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 0/3] increase skb size to prevent dma over skb boundary
Date: Wed, 23 Dec 2009 11:43:40 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0912231040560.4616@jbrandeb-desk1.amr.corp.intel.com>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA93CD0DD@rrsmsx501.amr.corp.intel.com> <20091209152312.GA11983@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com>
 <20091223064725.GB12439@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13854 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbZLWTnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 14:43:41 -0500
In-Reply-To: <20091223064725.GB12439@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2009, Brandon Philips wrote:
> On 11:20 Thu 10 Dec 2009, Tantilov, Emil S wrote:
> > >> I am trying to test the patches you submitted (thanks btw) and so
> > >> far am not able to reproduce the panic you described. When MTU is at
> > >> 1500 RCTL.LPE (bit 5) is set to 0 and the HW will not allow the
> > >> reception of large packets (>1522 bytes, which is what rx_buffer_len
> > >> is set to). This is basically what I am seeing in my tests - packets
> > >> are discarded by the HW.     
> 
> I have a memory dump from an SLE10 SP3 machine that seems to reproduce
> this issue. The testing environment was netperf with the MTU being
> switched every minute from 9000 -> 1500 and it took 40 hours to hit
> the bug. So, an overnight test, as you tried, may not be enough.

Thanks for testing Brandon, I think your test (with e1000e 1.0.2.5) is 
significantly different than the test that Neil started with.  That said I 
think it is a valuable test and we are going to start a test today that 
uses pktgen on two machines to send 64 byte and 9014 byte packets to a 
host that is changing its MTU every 5-10 seconds.
 
> In the memory dump there are 6 skb's in the ring that have memory
> overwritten from skb->data to skb->data + 2048. The machine ended up
> oopsing in skb_release_data() from e1000_clean_all_rx_rings() from
> e1000_change_mtu().

I think we should put a patch like the below into the kernel and actually 
*catch* any overrun DMAs even on a production machine.  At that point we 
could even leak that skb memory to prevent the corrupted memory from 
making its way into the general environment.
 
> 35:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)

what kind of system is this that had such a high bus number? PPC64?

>         Subsystem: Intel Corporation PRO/1000 PT Quad Port LP Server Adapter
>         Kernel driver in use: e1000
>         Kernel modules: e1000

e1000_change_mtu could possibly have a race that would allow corruption if 
all receives were not completed in the time we waited (10 millseconds) for 
some reason, but only if LPE was cleared already.  I still think your test 
is significantly different and maybe showing a different (but similar) 
edge case bug than Neil.

shouldn't IOMMU systems be catching this too when it was occuring?  we 
only call pci_map_* with buffer_info->length which is assigned 
rx_buffer_len.

e1000/e1000e: check rx length for overruns

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

it has been reported that some tests can cause DMA overruns resulting in
corrupted memory.  If the hardware writes more data to memory than we had
allocated this is something we can check for.

For now, WARN_ON, with the future capability of doing something like leaking
the memory rather than returning a known corrupt buffer to userspace.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: brandon@ifup.org
CC: nhorman@tuxdriver.com
---

 drivers/net/e1000/e1000_main.c |    3 +++
 drivers/net/e1000e/netdev.c    |    4 ++++
 2 files changed, 7 insertions(+), 0 deletions(-)


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7e855f9..911258b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3666,6 +3666,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
+		WARN_ON(length > buffer_info->length);
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
@@ -3849,6 +3850,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
+		WARN_ON(length > buffer_info->length);
+
 		/* !EOP means multiple descriptors were used to store a single
 		 * packet, also make sure the frame isn't just CRC only */
 		if (unlikely(!(status & E1000_RXD_STAT_EOP) || (length <= 4))) {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 762b697..394c2dc 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -449,6 +449,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
+		WARN_ON(length > adapter->rx_buffer_len);
 
 		/* !EOP means multiple descriptors were used to store a single
 		 * packet, also make sure the frame isn't just CRC only */
@@ -758,6 +759,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		}
 
 		length = le16_to_cpu(rx_desc->wb.middle.length0);
+		WARN_ON(length > adapter->rx_ps_bsize0);
 
 		if (!length) {
 			e_dbg("Last part of the packet spanning multiple "
@@ -814,6 +816,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			if (!length)
 				break;
 
+			WARN_ON(length > PAGE_SIZE);
 			ps_page = &buffer_info->ps_pages[j];
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
@@ -939,6 +942,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
+		WARN_ON(length > PAGE_SIZE);
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
