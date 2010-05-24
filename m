From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer
	updates
Date: Mon, 24 May 2010 19:42:05 +0300
Message-ID: <20100524164205.GA6664@redhat.com>
References: <20100524161351.GA6580@redhat.com> <OF1C9B2FC2.B6CFE18F-ON8825772D.0059C934-8825772D.005A61BA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757279Ab0EXRha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 13:37:30 -0400
Content-Disposition: inline
In-Reply-To: <OF1C9B2FC2.B6CFE18F-ON8825772D.0059C934-8825772D.005A61BA@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 24, 2010 at 09:27:15AM -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 05/24/2010 09:13:51 AM:
> 
> > On Mon, May 24, 2010 at 08:52:40AM -0700, David Stevens wrote:
> > > "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/24/2010 03:17:10 AM:
> > > 
> > > > On Thu, May 20, 2010 at 09:58:06AM -0700, David L Stevens wrote:
> > > > > [for Michael Tsirkin's vhost development git tree]
> > > > > 
> > > > > This patch fixes a race between guest and host when
> > > > > adding used buffers wraps the ring. Without it, guests
> > > > > can see partial packets before num_buffers is set in
> > > > > the vnet header.
> > > > > 
> > > > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > > > 
> > > > Could you please explain what the race is?
> > > 
> > >         Sure. The pre-patch code in the ring-wrap case
> > > does this:
> > > 
> > >         add part1 bufs
> > >         update used index
> > >         add part2 bufs
> > >         update used index
> > > 
> > >         After we update the used index for part1, the part1
> > > buffers are available to the guest. If the guest is
> > > consuming at that point, it can process the partial
> > > packet before the rest of the packet is there. In that
> > > case, num_buffers will be greater than the number of
> > > buffers available to the guest and it'll drop the
> > > packet with a framing error. I was seeing 2 or 3 framing
> > > errors every 100 million packets or so pre-patch, none
> > > post-patch.
> > >         Actually, the second sentence is incorrect in the
> > > original description-- num_buffers is up to date when
> > > the guest sees it, but the used index is not.
> > > 
> > >                                                 +-DLS
> > 
> > so this happens always - what does wrap-around refer to?
> 
>         The 2-part update only happens when a packet spans
> the end/beginning of the vring (the wrap). The framing error only
> happens if the guest sees the vring-wrapping packets
> before the second used-index write (the race).
>         So, the framing error doesn't happen always--it's
> pretty rare. But with the patch, it never happens.
> 
>                                                         +-DLS

I see. The logging is still bugg though I think.
