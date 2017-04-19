From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Wed, 19 Apr 2017 14:00:19 +0200
Message-ID: <20170419140019.366fb1fb@redhat.com>
References: <20170418215856.5fda7127@redhat.com>
        <58F67D15.3050308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762727AbdDSMBD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 08:01:03 -0400
In-Reply-To: <58F67D15.3050308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Apr 2017 13:54:45 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 17-04-18 12:58 PM, Jesper Dangaard Brouer wrote:
> > 
> > As I argued in NetConf presentation[1] (from slide #9) we need a port
> > mapping table (instead of using ifindex'es).  Both for supporting
> > other "port" types than net_devices (think sockets), and for
> > sandboxing what XDP can bypass.
> > 
> > I want to create a new XDP action called XDP_REDIRECT, that instruct
> > XDP to send the xdp_buff to another "port" (get translated into a
> > net_device, or something else depending on internal port type).
> > 
> > Looking at the userspace/eBPF interface, I'm wondering what is the
> > best API for "returning" this port number from eBPF?
> > 
> > The options I see is:
> > 
> > 1) Split-up the u32 action code, and e.g let the high-16-bit be the
> >    port number and lower-16bit the (existing) action verdict.
> > 
> >  Pros: Simple API
> >  Cons: Number of ports limited to 64K
> > 
> > 2) Extend both xdp_buff + xdp_md to contain a (u32) port number, allow
> >    eBPF to update xdp_md->port.
> > 
> >  Pros: Larger number of ports.
> >  Cons: This require some ebpf translation steps between xdp_buff <-> xdp_md.
> >        (see xdp_convert_ctx_access)
> > 
> > 3) Extend only xdp_buff and create bpf_helper that set port in xdp_buff.
> > 
> >  Pros: Hides impl details, and allows helper to give eBPF code feedback
> >        (on e.g. if port doesn't exist any longer)
> >  Cons: Helper function call likely slower?
> > 
> >   
> 
> How about doing this the same way redirect is done in the tc case? I have this
> patch under test,
> 
>  https://github.com/jrfastab/linux/commit/e78f5425d5e3c305b4170ddd85c61c2e15359fee

I have been looking at this approach, which is close to option #3 above.

The problem with your implementation that you use a per-cpu store.
This creates the problem of storing state between packets. First packet
can call helper bpf_xdp_redirect() setting an ifindex, but program can
still return XDP_PASS.  Next packet can call XDP_REDIRECT and use the
ifindex set from the first packet.  IMHO this is a problematic API to
expose.

I do see that the TC interface that uses the same approach, via helper
bpf_redirect().  Maybe it have the same API problem?  Looking at
sch_handle_ingress() I don't see this is handled (e.g. by always
clearing this_cpu_ptr(redirect_info)->ifindex = 0).


> that should give you some idea. It just needs a port mapping table in the
> bpf_tx_xdp() call.

I'll take a closer look. I don't think we need the per-cpu-store
approach for XDP, as we might as well store the port info in xdp_buff,
or return it directly option #1.

(TC redirect need the per-cpu-store to avoid extending the SKB).


> > (Cc'ed xdp-newbies as end-users might have an opinion on UAPI?)

I would still like people to comment on the above options?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
