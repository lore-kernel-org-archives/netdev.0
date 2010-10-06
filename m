From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Wed, 6 Oct 2010 12:37:34 -0600
Message-ID: <20101006183734.GK24268@obsidianresearch.com>
References: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj@mail.gmail.com> <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com> <20101006172518.GI24268@obsidianresearch.com> <1286389375.26136.24.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Metzler <BMT@zurich.ibm.com>,
	Bart Van Assche <bvanassche@acm.org>,
	linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([139.142.54.143]:36234 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759732Ab0JFShk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 14:37:40 -0400
Content-Disposition: inline
In-Reply-To: <1286389375.26136.24.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 02:22:55PM -0400, David Dillow wrote:
> On Wed, 2010-10-06 at 11:25 -0600, Jason Gunthorpe wrote:
> > On Wed, Oct 06, 2010 at 02:52:46PM +0200, Bernard Metzler wrote:
> > It is actually a little more complicated than just this. I assume you
> > are casting the structures over packet payloads? In this case you
> > have to guarentee alignment (or used packed everywhere). Does iwarp
> > have provisions for alignment? If so you can construct your bitfields
> > using the alignment type, ie if iWarp guarantees 4 bytes then the
> > biggest type you can use is u32 - then you can avoid using packed.
> > 
> > Mind you, I'm not sure how to guarentee alignment when you consider
> > all the possible sources of unalignment in the stack: TCP, IP, L2 stack ?
> 
> You don't have to. The TCP stack, IIRC, requires the architecture to fix
> up misaligned accesses, or at least it used to. It will try to keep
> things aligned if possible -- see the comment above NET_IP_ALIGN in
> include/linux/skbuff.h.

I was under the impression that this was just to align the IP
header. There are quite a variety of options and additional stuff that
can be inserted at each layer, VLAN for ethernet, IP option/extension
headers, TCP option headers, etc, etc. I seem to remember that because
of all this there are cases where processing unaligned payloads is
unavoidable? Hence my question if iWarp has restrictions (particularly
on TCP) that might guarentee alignment.

> The structures in Bernard's header have all fields naturally
> aligned, so no need for the packed attribute and its baggage.

No, they arent:

> +struct iwarp_rdma_write {
> +	struct iwarp_ctrl	ctrl;
> +	__u32			sink_stag;
> +	__u64			sink_to;
> +} __attribute__((__packed__));

For instance has sink_to unaligned if the maximum aligment of the
payload is only guarenteed to be 4. The proper thing to do in this
case is probably __attribute__((__packed__, __aligned__(4))) if that
works the way I think.. :)

Jason
