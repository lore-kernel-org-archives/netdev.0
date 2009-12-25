From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] increase skb size to prevent dma over skb boundary
Date: Thu, 24 Dec 2009 20:31:37 -0500
Message-ID: <20091225013137.GA12068@localhost.localdomain>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA93CD0DD@rrsmsx501.amr.corp.intel.com> <20091209152312.GA11983@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com> <20091223064725.GB12439@jenkins.home.ifup.org> <alpine.WNT.2.00.0912231040560.4616@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brandon Philips <brandon@ifup.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36549 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZLYBbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 20:31:44 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.0912231040560.4616@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2009 at 11:43:40AM -0800, Brandeburg, Jesse wrote:
> On Tue, 22 Dec 2009, Brandon Philips wrote:
> > On 11:20 Thu 10 Dec 2009, Tantilov, Emil S wrote:
> > > >> I am trying to test the patches you submitted (thanks btw) and so
> > > >> far am not able to reproduce the panic you described. When MTU is at
> > > >> 1500 RCTL.LPE (bit 5) is set to 0 and the HW will not allow the
> > > >> reception of large packets (>1522 bytes, which is what rx_buffer_len
> > > >> is set to). This is basically what I am seeing in my tests - packets
> > > >> are discarded by the HW.     
> > 
> > I have a memory dump from an SLE10 SP3 machine that seems to reproduce
> > this issue. The testing environment was netperf with the MTU being
> > switched every minute from 9000 -> 1500 and it took 40 hours to hit
> > the bug. So, an overnight test, as you tried, may not be enough.
> 
> Thanks for testing Brandon, I think your test (with e1000e 1.0.2.5) is 
> significantly different than the test that Neil started with.  That said I 
> think it is a valuable test and we are going to start a test today that 
> uses pktgen on two machines to send 64 byte and 9014 byte packets to a 
> host that is changing its MTU every 5-10 seconds.
>  
> > In the memory dump there are 6 skb's in the ring that have memory
> > overwritten from skb->data to skb->data + 2048. The machine ended up
> > oopsing in skb_release_data() from e1000_clean_all_rx_rings() from
> > e1000_change_mtu().
> 
> I think we should put a patch like the below into the kernel and actually 
> *catch* any overrun DMAs even on a production machine.  At that point we 
> could even leak that skb memory to prevent the corrupted memory from 
> making its way into the general environment.
>  
> > 35:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)
> 
> what kind of system is this that had such a high bus number? PPC64?
> 
> >         Subsystem: Intel Corporation PRO/1000 PT Quad Port LP Server Adapter
> >         Kernel driver in use: e1000
> >         Kernel modules: e1000
> 
> e1000_change_mtu could possibly have a race that would allow corruption if 
> all receives were not completed in the time we waited (10 millseconds) for 
> some reason, but only if LPE was cleared already.  I still think your test 
> is significantly different and maybe showing a different (but similar) 
> edge case bug than Neil.
> 
> shouldn't IOMMU systems be catching this too when it was occuring?  we 
> only call pci_map_* with buffer_info->length which is assigned 
> rx_buffer_len.
> 
> e1000/e1000e: check rx length for overruns
> 
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> it has been reported that some tests can cause DMA overruns resulting in
> corrupted memory.  If the hardware writes more data to memory than we had
> allocated this is something we can check for.
> 
> For now, WARN_ON, with the future capability of doing something like leaking
> the memory rather than returning a known corrupt buffer to userspace.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: brandon@ifup.org
> CC: nhorman@tuxdriver.com

I think this seems like a reasonable idea.  Additionally (or perhaps
alternatively), it might be a good idea to (when allocating buffers in the
default setup path), expand the allocation size by a word, that we write a
cannary value into.  Then we can check that cannary on the napi poll should the
hardware dma past the end of the skb.
Neil

> 
