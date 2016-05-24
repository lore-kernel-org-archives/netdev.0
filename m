From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: ixgbe: ksoftirqd consumes 100% CPU w/ ~50 TCP conns
Date: Tue, 24 May 2016 22:35:11 +0200
Message-ID: <20160524223511.1823433d@redhat.com>
References: <CAEm7KtxXapo-9OevQtFAnuZo5h4FH8RQ-Nm3in4A0uJh0KqYKQ@mail.gmail.com>
	<CAEm7KtxaUC0uBM9sAQSqBeT7AhyEBK=950AxT7N4imgcQ1TnwQ@mail.gmail.com>
	<CAKgT0UdCH=4MzwAjPTpPt2BXcxMxQbzkRPpB9_TJd10_6x9kTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Brandon Philips <brandon@ifup.co>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Matthew Garrett <mjg59@srcf.ucam.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754970AbcEXUfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 16:35:18 -0400
In-Reply-To: <CAKgT0UdCH=4MzwAjPTpPt2BXcxMxQbzkRPpB9_TJd10_6x9kTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2016 12:46:56 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> I'm guessing the issue is lock contention on the IOMMU resource table.
> I resolved most of that for the Rx side back when we implemented the
> Rx page reuse but the Tx side still has to perform a DMA mapping for
> each individual buffer.  Depending on the needs of the user if they
> still need the IOMMU enabled for use with something like KVM one thing
> they may try doing is use the kernel parameter "iommu=pt" to allow
> host devices to access memory without the penalty for having to
> allocate/free resources and still provide guests with IOMMU isolation.

Listen to Alex, he knows what his is talking about.

My longer term plan for getting rid of the dma_map/unmap overhead is to
_keep_ the pages DMA mapped and recycle them back via page-pool.
Details in my slides, see slide 5:
 http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf

Alex'es RX recycle trick for the Intel drivers are described on
slide14.  It seems like, in your use-case the pages might be held "too"
long for the RX recycling trick to work.

If you want to understand the IOMMU problem in details, I recommend to
read the article "True IOMMU Protection from DMA Attacks"
 http://www.cs.technion.ac.il/~mad/publications/asplos2016-iommu.pdf
(My solution is different, but they desc the problem very well)

--Jesper

 
> On Tue, May 24, 2016 at 9:40 AM, Brandon Philips <brandon@ifup.co> wrote:
> > Hello Everyone-
> >
> > So we tracked it down to IOMMU causing CPU affinity getting broken[1].
> > Can we provide any further details or is this a known issue?
> >
> > Thank You,
> >
> > Brandon
> >
> > [1] https://github.com/coreos/bugs/issues/1275#issuecomment-219866601
> >
> > On Tue, May 17, 2016 at 12:44 PM, Brandon Philips <brandon@ifup.co> wrote:  
> >> Hello ixgbe team-
> >>
> >> With Linux v4.6 and the ixgbe driver (details below) a user is reporting
> >> ksoftirqd consuming 100% of the CPU on all cores after a moderate  ~20-50
> >> number of TCP connections. They are unable to reproduce this issue with
> >> Cisco hardware.
> >>
> >> With Kernel v3.19 they cannot reproduce[1] the issue. Disabling IOMMU
> >> (intel_iommu=off) does "fix" the issue[2].
> >>
> >> Thank You,
> >>
> >> Brandon
> >>
> >> [1] https://github.com/coreos/bugs/issues/1275#issuecomment-219157803
> >> [2] https://github.com/coreos/bugs/issues/1275#issuecomment-219819986
> >>
> >> Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> >> ethtool -i eno1
> >> driver: ixgbe
> >> version: 4.0.1-k
> >> firmware-version: 0x800004e0
> >> bus-info: 0000:06:00.0
> >> supports-statistics: yes
> >> supports-test: yes
> >> supports-eeprom-access: yes
> >> supports-register-dump: yes
> >> supports-priv-flags: no
> >>
> >> CPU
> >> Intel(R) Xeon(R) CPU E5-2690 v3 @ 2.60GHz  



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
