From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Thu, 20 Apr 2017 13:12:18 -0400
Message-ID: <20170420171218.GM4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170418215856.5fda7127@redhat.com>
 <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
 <58F7D9C6.5040707@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33564 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945804AbdDTRM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:12:28 -0400
Received: by mail-oi0-f43.google.com with SMTP id y11so27347909oie.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 10:12:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58F7D9C6.5040707@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 11:42:30PM +0200, Daniel Borkmann wrote:
> On 04/19/2017 10:02 PM, Andy Gospodarek wrote:
> > On Tue, Apr 18, 2017 at 09:58:56PM +0200, Jesper Dangaard Brouer wrote:
> > > 
> > > As I argued in NetConf presentation[1] (from slide #9) we need a port
> > > mapping table (instead of using ifindex'es).  Both for supporting
> > > other "port" types than net_devices (think sockets), and for
> > > sandboxing what XDP can bypass.
> > > 
> > > I want to create a new XDP action called XDP_REDIRECT, that instruct
> > > XDP to send the xdp_buff to another "port" (get translated into a
> > > net_device, or something else depending on internal port type).
> > > 
> > > Looking at the userspace/eBPF interface, I'm wondering what is the
> > > best API for "returning" this port number from eBPF?
> > > 
> > > The options I see is:
> > > 
> > > 1) Split-up the u32 action code, and e.g let the high-16-bit be the
> > >     port number and lower-16bit the (existing) action verdict.
> > > 
> > >   Pros: Simple API
> > >   Cons: Number of ports limited to 64K
> > 
> > Practically speaking this may be seem reserving 64k for the port number
> > might be enough space, but I would also like to see a new return option
> > for flags so I start to get concerned about space.  Daniel also
> > hightlights the fact that encoding the port in the action may does not
> > leave room for flags and could get confusing.
> > 
> > One unfortunate side-effect of dropping or transmitting frames with XDP
> > is that we lose the opportunity to statistically sample in netfilter
> > since the frames were dropped so early and I'd like to bring that back
> > with a call to parse flags and possibly call psample_sample_packet()
> > after the xdp action.  Packet sampling cannot simply be an action
> > since there are times when a frame should be dropped but should also be
> > sampled, so it seems logical to add this as a flag.
> 
> Hmm, you can do that already today with bpf_xdp_event_output() helper
> and the program decides when to sample and what custom meta data to
> prepend along with the (partial or full) xdp packet, see also [1], slide
> 11 for the "XDP dump" part.
> 
> No need to change drivers for this, psample_sample_packet() would also
> be slower.
> 
>   [1] http://netdevconf.org/2.1/slides/apr6/zhou-netdev-xdp-2017.pdf

Thanks, Daniel.  Not sure how I missed this, but I appreciate the pointer.
I'll add coding up a program to demo this to my TODO list.
