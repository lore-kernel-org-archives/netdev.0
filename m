From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Wed, 19 Apr 2017 16:02:59 -0400
Message-ID: <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170418215856.5fda7127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:36488 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936106AbdDSUDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 16:03:17 -0400
Received: by mail-yb0-f176.google.com with SMTP id s22so15185144ybe.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 13:03:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170418215856.5fda7127@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 09:58:56PM +0200, Jesper Dangaard Brouer wrote:
> 
> As I argued in NetConf presentation[1] (from slide #9) we need a port
> mapping table (instead of using ifindex'es).  Both for supporting
> other "port" types than net_devices (think sockets), and for
> sandboxing what XDP can bypass.
> 
> I want to create a new XDP action called XDP_REDIRECT, that instruct
> XDP to send the xdp_buff to another "port" (get translated into a
> net_device, or something else depending on internal port type).
> 
> Looking at the userspace/eBPF interface, I'm wondering what is the
> best API for "returning" this port number from eBPF?
> 
> The options I see is:
> 
> 1) Split-up the u32 action code, and e.g let the high-16-bit be the
>    port number and lower-16bit the (existing) action verdict.
> 
>  Pros: Simple API
>  Cons: Number of ports limited to 64K

Practically speaking this may be seem reserving 64k for the port number
might be enough space, but I would also like to see a new return option
for flags so I start to get concerned about space.  Daniel also
hightlights the fact that encoding the port in the action may does not
leave room for flags and could get confusing.

One unfortunate side-effect of dropping or transmitting frames with XDP
is that we lose the opportunity to statistically sample in netfilter
since the frames were dropped so early and I'd like to bring that back
with a call to parse flags and possibly call psample_sample_packet()
after the xdp action.  Packet sampling cannot simply be an action
since there are times when a frame should be dropped but should also be
sampled, so it seems logical to add this as a flag.

> 
> 2) Extend both xdp_buff + xdp_md to contain a (u32) port number, allow
>    eBPF to update xdp_md->port.
> 
>  Pros: Larger number of ports.
>  Cons: This require some ebpf translation steps between xdp_buff <-> xdp_md.
>        (see xdp_convert_ctx_access)

I think I would lean towards this based on the fact that I'd like to see
a flags field added to the u32 return (maybe the top 8 bits) as
mentioned above.

So if we follow down this path and add a 'dest' field to xdp_buff and
xdp_md like this:

struct xdp_buff {
        void *data;
        void *data_end;
        void *data_hard_start;
	__u32 dest; 
};

struct xdp_md {
        __u32 data;
        __u32 data_end;
	__u32 dest;
};

and then lookup this dest in a table we have the option to make that
dest an ifindex/socket/other.

I did also look at JohnF's patch and I do like the simplicity of the redirect
action and new ndo_xdp_xmit and how it moves towards a way to transmit the
frame.  The downside is that it presumes an ifindex, so it might not be ideal
we want the lookup to return something other than an ifindex.

Before aligning on a direction for the return values from exiting xdp
call, it seems like we should also think about the tx side and how that
would be handled.  If we are ultimately going to need a new netdev op to
handle the redirect then what may be the issue with not providing the
destination port the return code and the option proposed by JohnF looks
good to me with maybe a small tweak to not presume ifindex in some manner.

JohnF, any test results with this you can share?  Presumably you tested with
virtio-net, right?

> 
> 3) Extend only xdp_buff and create bpf_helper that set port in xdp_buff.
> 
>  Pros: Hides impl details, and allows helper to give eBPF code feedback
>        (on e.g. if port doesn't exist any longer)
>  Cons: Helper function call likely slower?
> 
> 
> (Cc'ed xdp-newbies as end-users might have an opinion on UAPI?)
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> [1] http://people.netfilter.org/hawk/presentations/NetConf2017/xdp_work_ahead_NetConf_April_2017.pdf
