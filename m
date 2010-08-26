From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 17:43:42 -0600
Message-ID: <20100826234342.GA24333@obsidianresearch.com>
References: <adapqx5rtez.fsf@cisco.com> <alpine.DEB.2.00.1008261613160.24174@router.home> <alpine.DEB.2.00.1008261629440.24174@router.home> <20100826.151553.242147157.davem@davemloft.net> <20100826222146.GA23025@obsidianresearch.com> <alpine.DEB.2.00.1008261825490.26351@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org, yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008261825490.26351-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 26, 2010 at 06:26:58PM -0500, Christoph Lameter wrote:
> On Thu, 26 Aug 2010, Jason Gunthorpe wrote:
>
> > The 40 bytes at this location are defined by the HW specification to
> > be an IB GRH which has an identical layout to an IPv6 header. Roland
> > is right, it would be clearer to use ib_grh ->dgid
>
> Ok but then we have no nice function that checks for multicast anymore.

Were you going to try it this way?

     /* First byte of dgid signals multicast/broadcast when 0xff */
     if ((wc->wc_flags & IB_WC_GRH) &&
         ((struct ib_grh *)skb->data)->dgid.raw[0] == 0xff) {
	     if (memcmp(((struct ib_grh *)skb->data)->dgid.raw,
                        dev->broadcast + 4, sizeof(union ib_gid)) == 0)
                     skb->pkt_type = PACKET_BROADCAST;
             else
                     skb->pkt_type = PACKET_MULTICAST;
     }
     else
             skb->pkt_type = PACKET_HOST;

I think doing the memcmp only in the multicast path should be
reasonable overhead wise.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
