From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on 64KB
 page granularity
Date: Wed, 20 May 2015 09:26:50 +0100
Message-ID: <20150520082650.GU26335@zion.uk.xensource.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
 <1431622863-28575-22-git-send-email-julien.grall@citrix.com>
 <20150515023534.GE19352@zion.uk.xensource.com> <5555E81E.8070803@citrix.com>
 <20150515153143.GA8521@zion.uk.xensource.com> <5559D6EE.3030400@citrix.com>
 <20150518125406.GA9503@zion.uk.xensource.com> <555BBFA7.8030502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <555BBFA7.8030502@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 11:56:39PM +0100, Julien Grall wrote:

> 
> >>diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> >>index 0eda6e9..c2a5402 100644
> >>--- a/drivers/net/xen-netback/common.h
> >>+++ b/drivers/net/xen-netback/common.h
> >>@@ -204,7 +204,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
> >>  /* Maximum number of Rx slots a to-guest packet may use, including the
> >>   * slot needed for GSO meta-data.
> >>   */
> >>-#define XEN_NETBK_RX_SLOTS_MAX (MAX_SKB_FRAGS + 1)
> >>+#define XEN_NETBK_RX_SLOTS_MAX ((MAX_SKB_FRAGS + 1) * XEN_PFN_PER_PAGE)
> >>
> >>  enum state_bit_shift {
> >>         /* This bit marks that the vif is connected */
> >>
> >>The function xenvif_wait_for_rx_work never returns. I guess it's because there
> >>is not enough slot available.
> >>
> >>For 64KB page granularity we ask for 16 times more slots than 4KB page
> >>granularity. Although, it's very unlikely that all the slot will be used.
> >>
> >>FWIW I pointed out the same problem on blkfront.
> >>
> >
> >This is not going to work. The ring in netfront / netback has only 256
> >slots. Now you ask for netback to reserve more than 256 slots -- (17 +
> >1) * (64 / 4) = 288, which can never be fulfilled. See the call to
> >xenvif_rx_ring_slots_available.
> >
> >I think XEN_NETBK_RX_SLOTS_MAX derived from the fact the each packet to
> >the guest cannot be larger than 64K. So you might be able to
> >
> >#define XEN_NETBK_RX_SLOTS_MAX ((65536 / XEN_PAGE_SIZE) + 1)
> 
> I didn't know that packet cannot be larger than 64KB. That's simply a lot
> the problem.
> 

I think about this more, you will need one more slot for GSO
information, so make it ((65536 / XEN_PAGE_SIZE) + 1 + 1).

> >
> >Blk driver may have a different story. But the default ring size (1
> >page) yields even less slots than net (given that sizeof(union(req/rsp))
> >is larger IIRC).
> 
> I will see with Roger for Blkback.
> 
> 
> -- 
> Julien Grall
