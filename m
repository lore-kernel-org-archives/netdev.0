From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH v2 net-next] liquidio: improve UDP TX performance
Date: Tue, 21 Feb 2017 22:57:37 -0800
Message-ID: <20170222065737.GA1201@felix.cavium.com>
References: <20170221210907.GA8045@felix.cavium.com>
 <CALx6S35HE=8bwXMy7U=+kOSaP1fBmRjPUKn1neW6O=h38P0K2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com,
        VSR Burru <veerasenareddy.burru@cavium.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0076.outbound.protection.outlook.com ([104.47.36.76]:11172
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751192AbdBVG7B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 01:59:01 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35HE=8bwXMy7U=+kOSaP1fBmRjPUKn1neW6O=h38P0K2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote on Tue [2017-Feb-21 15:27:54 -0800]:
> On Tue, Feb 21, 2017 at 1:09 PM, Felix Manlunas
> <felix.manlunas@cavium.com> wrote:
> > From: VSR Burru <veerasenareddy.burru@cavium.com>
> >
> > Improve UDP TX performance by:
> > * reducing the ring size from 2K to 512
> 
> It looks like liquidio supports BQL. Is that not effective here?

Response from our colleague, VSR:
That's right, BQL is not effective here.  We reduced the ring size because
there is heavy overhead with dma_map_single every so often.  With iommu=on,
dma_map_single in PF Tx data path was taking longer time (~700usec) for
every ~250 packets.  Debugged intel_iommu code, and found that PF driver is
utilizing too many static IO virtual address mapping entries (for gather
list entries and info buffers): about 100K entries for two PF's each using
8 rings.  Also, finding an empty entry (in rbtree of device domain's iova
mapping in kernel) during Tx path becomes a bottleneck every so often; the
loop to find the empty entry goes through over 40K iterations; this is too
costly and was the major overhead.  Overhead is low when this loop quits
quickly.
