From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for
 returning/setting egress port?
Date: Wed, 26 Apr 2017 11:11:58 +0200
Message-ID: <20170426111158.578b925e@redhat.com>
References: <20170418215856.5fda7127@redhat.com>
        <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
        <58F7E9F3.5090604@iogearbox.net>
        <20170420025611.GA53935@ast-mbp.thefacebook.com>
        <20170420081051.77a41aa8@redhat.com>
        <20170420171006.GA97067@ast-mbp.thefacebook.com>
        <20170425113453.5c72080f@redhat.com>
        <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
        <59000EF6.1050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34128 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1437265AbdDZJMF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 05:12:05 -0400
In-Reply-To: <59000EF6.1050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Apr 2017 20:07:34 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 17-04-25 05:26 PM, Alexei Starovoitov wrote:
> > On Tue, Apr 25, 2017 at 11:34:53AM +0200, Jesper Dangaard Brouer wrote:  
> >>> Note the very first bpf patchset years ago contained the port table
> >>> abstraction. ovs has concept of vports as well. These two very
> >>> different projects needed port table to provide a layer of
> >>> indirection between ifindex==netdev and virtual port number.
> >>> This is still the case and I'd like to see this port table to be
> >>> implemented for both cls_bpf and xdp. In that sense xdp is not
> >>> special.  
> >>
> >> Glad to hear you want to see this implemented, I will start coding on
> >> this then.  Good point with cls_bpf, I was planning to make this port
> >> table strongly connected to XDP, guess I should also think of cls_bpf.  
> > 
> > perfect.
> > I think we should try to make all additions to bpf networking world
> > to be usable for both tc and xdp, since both are actively used and
> > it wouldn't be great to have cool feature for one, but not the other.
> > I think port table is an excellent candidate that applies to both.  
> 
> +1
> 
> Jesper, I was working up the code for the redirect piece for ixgbe and
> virtio, please use this as a base for your virtual port number table. I'll
> push an update onto github tomorrow. I think the table should drop in fairly
> nicely.

Cool, I will do that. Then, I'll also have a redirect method to shape
this around, and I would have to benchmark/test your ixgbe redirect.

(John please let me know, what github tree we are talking about, and
what branch)


> One piece that isn't clear to me is how do you plan to instantiate and
> program this table. Is it a new static bpf map that is created any
> time we see the redirect command? I think this would be preferred.

(This is difficult to explain without us misunderstanding each-other)

As Alexei also mentioned before, ifindex vs port makes no real
difference seen from the bpf program side.  It is userspace's
responsibility to add ifindex/port's to the bpf-maps, according to how
the bpf program "policy" want to "connect" these ports.  The
port-table system add one extra step, of also adding this port to the
port-table (which lives inside the kernel). 

When loading the XDP program, we also need to pass along a port table
"id" this XDP program is associated with (and if it doesn't exists you
create it).  And your userspace "control-plane" application also need
to know this port table "id", when adding a new port.

The concept of having multiple port tables is key.  As this implies we
can have several simultaneous "data-planes" that is *isolated* from
each-other.  Think about how network-namespaces/containers want
isolation. A subtle thing I'm afraid to mention, is that oppose to the
ifindex model, a port table with mapping to a net_device pointer, would
allow (faster) delivery into the container's inner net_device, which
sort of violates the isolation, but I would argue it is not a problem
as this net_device pointer could only be added from a process within the
namespace.  I like this feature, but it could easily be disallowed via
port insertion-time validation.

   
> >> I'm not worried about the DROP case, I agree that is fine (as you
> >> also say).  The problem is unintentionally sending a packet to a
> >> wrong ifindex.  This is clearly an eBPF program error, BUT with
> >> XDP this becomes a very hard to debug program error.  With
> >> TC-redirect/cls_bpf we can tcpdump the packets, with XDP there is
> >> no visibility into this happening (the NSA is going to love this
> >> "feature").  Maybe we could add yet-another tracepoint to allow
> >> debugging this.  My proposal that we simply remove the possibility
> >> for such program errors, by as you say move the validation from
> >> run-time into static insertion-time, via a port table.  
> > 
> > I think lack of tcpdump-like debugging in xdp is a separate issue.
> > As I was saying in the other thread we have trivial 'xdpdump'
> > kern+user app that emits pcap file, but it's too specific to how we
> > use tail_calls+prog_array in our xdp setup. I'm working on the
> > program chaining that will be generic and allow us transparently
> > add multiple xdp or tc progs to the same attachment point and will
> > allow us to do 'xdpdump' at any point of this pipeline, so
> > debugging of what happened to the packet will be easier and done in
> > the same way for both tc and xdp.
> > btw in our experience working with both tc and xdp the tc+bpf was
> > actually harder to use and more bug prone.
> >   
> 
> Nice, the tcpdump-like debugging looks interesting.

Yes, this xdpdump sound like a very useful tool.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
