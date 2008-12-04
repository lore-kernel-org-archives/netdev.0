From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the
 module level
Date: Thu, 4 Dec 2008 20:28:33 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812041959530.8851@axis700.grange>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
 <Pine.LNX.4.64.0812041746400.5079@axis700.grange>
 <e9c3a7c20812041051l44bd8086o97c12d77a116f62@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43359 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754218AbYLDT2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 14:28:21 -0500
In-Reply-To: <e9c3a7c20812041051l44bd8086o97c12d77a116f62@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2008, Dan Williams wrote:

> On Thu, Dec 4, 2008 at 9:56 AM, Guennadi Liakhovetski
> <g.liakhovetski@gmx.de> wrote:
> >> +
> >> +     /* try to grab channels */
> >> +     list_for_each_entry_safe(device, _d, &dma_device_list, global_node)
> >> +             list_for_each_entry(chan, &device->channels, device_node) {
> >> +                     err = dma_chan_get(chan);
> >
> > Dan, could you please explain this: dma_chan_get() takes a reference on
> > the channel _and_ calls .device_alloc_chan_resources() on first invocation
> > for a specific channel. I now see three locations in dmaengine.c, where
> > dma_chan_get() is called: in dma_request_channel() - logical, but also in
> > dmaengine_get() and dma_async_device_register(), and these latter two I
> > don't understand. I do not understand why we have to grab references and
> > allocate resources for all (public) channels on all controllers in the
> > system if someone just called dmaengine_get()?
> 
> Consider the case where a subsystem that consumes engines like
> async_tx or net_dma loads before engines are available in the system.
> They will have taken a reference against dmaengine, but calls to
> dma_find_channel will return NULL.  Once a channel driver is loaded
> dma_find_channel() can start returning results, and it is at this
> point that resources must be allocated and the backing module pinned.
> So dmaengine_get() means "I am interested in offloading stuff, if you
> see an offload resource grab it and prep it so I can discover it with
> dma_find_channel()".

Ok, but why not postpone calling .device_alloc_chan_resources() until a 
channel is _found_? Calling it for all channels just because one client 
has once called dmaengine_get() and _probably_ will poll if any channels 
become available - doesn't it look like an overkill?

> >> @@ -420,6 +443,19 @@ int dma_async_device_register(struct dma_device *device)
> >>       }
> >>
> >>       mutex_lock(&dma_list_mutex);
> >> +     list_for_each_entry(chan, &device->channels, device_node) {
> >> +             /* if clients are already waiting for channels we need to
> >> +              * take references on their behalf
> >> +              */
> >> +             if (dmaengine_ref_count && dma_chan_get(chan) == -ENODEV) {
> >> +                     /* note we can only get here for the first
> >> +                      * channel as the remaining channels are
> >> +                      * guaranteed to get a reference
> >> +                      */
> >
> > This is the second location - where and how are clients waiting for
> > channels? In the old implementation clients had notification callbacks,
> > which were called as new channels became available. Now clients are gone,
> > so, what is meant here?
> >
> 
> The assumption is that mem-to-mem offload clients poll dma_find_channel().

Hm, interesting, so that's why you want dma_find_channel() as light-weight 
as possible?

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
