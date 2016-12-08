From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v5 3/6] virtio_net: Add XDP support
Date: Thu, 8 Dec 2016 07:54:31 +0200
Message-ID: <20161208075418-mutt-send-email-mst@kernel.org>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201157.28121.39934.stgit@john-Precision-Tower-5810>
 <20161208064037-mutt-send-email-mst@kernel.org>
 <5848EC48.7080904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750838AbcLHFyi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 00:54:38 -0500
Content-Disposition: inline
In-Reply-To: <5848EC48.7080904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 09:14:48PM -0800, John Fastabend wrote:
> On 16-12-07 08:48 PM, Michael S. Tsirkin wrote:
> > On Wed, Dec 07, 2016 at 12:11:57PM -0800, John Fastabend wrote:
> >> From: John Fastabend <john.fastabend@gmail.com>
> >>
> >> This adds XDP support to virtio_net. Some requirements must be
> >> met for XDP to be enabled depending on the mode. First it will
> >> only be supported with LRO disabled so that data is not pushed
> >> across multiple buffers. Second the MTU must be less than a page
> >> size to avoid having to handle XDP across multiple pages.
> >>
> >> If mergeable receive is enabled this patch only supports the case
> >> where header and data are in the same buf which we can check when
> >> a packet is received by looking at num_buf. If the num_buf is
> >> greater than 1 and a XDP program is loaded the packet is dropped
> >> and a warning is thrown. When any_header_sg is set this does not
> >> happen and both header and data is put in a single buffer as expected
> >> so we check this when XDP programs are loaded.  Subsequent patches
> >> will process the packet in a degraded mode to ensure connectivity
> >> and correctness is not lost even if backend pushes packets into
> >> multiple buffers.
> >>
> >> If big packets mode is enabled and MTU/LRO conditions above are
> >> met then XDP is allowed.
> >>
> >> This patch was tested with qemu with vhost=on and vhost=off where
> >> mergeable and big_packet modes were forced via hard coding feature
> >> negotiation. Multiple buffers per packet was forced via a small
> >> test patch to vhost.c in the vhost=on qemu mode.
> >>
> >> Suggested-by: Shrijeet Mukherjee <shrijeet@gmail.com>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > 
> > I'd like to note that I don't think disabling LRO is a good
> > plan long-term. It's really important for virtio performance,
> > so IMHO we need a fix for that.
> > I'm guessing that a subset of XDP programs would be quite
> > happy with just looking at headers, and that is there in the 1st buffer.
> > So how about teaching XDP that there could be a truncated packet?
> > 
> > Then we won't have to disable LRO.
> > 
> 
> Agreed long-term we can drop this requirement this type of improvement
> would also allow working with jumbo frames on nics.
> 
> I don't think it should block this patch series though.
> 
> .John

Right.
