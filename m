From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Sun, 10 Jul 2016 10:09:24 -0700
Message-ID: <20160710170922.GC6657@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
 <20160709101403.1ed7d021@redhat.com>
 <CALx6S36dnA_vXBJVpLTZc6WyZaDh_hnw4vpp57EC2jsfA0vHcQ@mail.gmail.com>
 <20160710153731.62d6773d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36787 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbcGJRJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 13:09:29 -0400
Received: by mail-pa0-f42.google.com with SMTP id hu1so14645754pad.3
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 10:09:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160710153731.62d6773d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 03:37:31PM +0200, Jesper Dangaard Brouer wrote:
> On Sat, 9 Jul 2016 08:47:52 -0500
> Tom Herbert <tom@herbertland.com> wrote:
> 
> > On Sat, Jul 9, 2016 at 3:14 AM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:
> > > On Thu,  7 Jul 2016 19:15:13 -0700
> > > Brenden Blanco <bblanco@plumgrid.com> wrote:
> > >  
> > >> Add a new bpf prog type that is intended to run in early stages of the
> > >> packet rx path. Only minimal packet metadata will be available, hence a
> > >> new context type, struct xdp_md, is exposed to userspace. So far only
> > >> expose the packet start and end pointers, and only in read mode.
> > >>
> > >> An XDP program must return one of the well known enum values, all other
> > >> return codes are reserved for future use. Unfortunately, this
> > >> restriction is hard to enforce at verification time, so take the
> > >> approach of warning at runtime when such programs are encountered. The
> > >> driver can choose to implement unknown return codes however it wants,
> > >> but must invoke the warning helper with the action value.  
> > >
> > > I believe we should define a stronger semantics for unknown/future
> > > return codes than the once stated above:
> > >  "driver can choose to implement unknown return codes however it wants"
> > >
> > > The mlx4 driver implementation in:
> > >  [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf program
> > >
> > > On Thu,  7 Jul 2016 19:15:16 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:
> > >  
> > >> +             /* A bpf program gets first chance to drop the packet. It may
> > >> +              * read bytes but not past the end of the frag.
> > >> +              */
> > >> +             if (prog) {
> > >> +                     struct xdp_buff xdp;
> > >> +                     dma_addr_t dma;
> > >> +                     u32 act;
> > >> +
> > >> +                     dma = be64_to_cpu(rx_desc->data[0].addr);
> > >> +                     dma_sync_single_for_cpu(priv->ddev, dma,
> > >> +                                             priv->frag_info[0].frag_size,
> > >> +                                             DMA_FROM_DEVICE);
> > >> +
> > >> +                     xdp.data = page_address(frags[0].page) +
> > >> +                                                     frags[0].page_offset;
> > >> +                     xdp.data_end = xdp.data + length;
> > >> +
> > >> +                     act = bpf_prog_run_xdp(prog, &xdp);
> > >> +                     switch (act) {
> > >> +                     case XDP_PASS:
> > >> +                             break;
> > >> +                     default:
> > >> +                             bpf_warn_invalid_xdp_action(act);
> > >> +                     case XDP_DROP:
> > >> +                             goto next;
> > >> +                     }
> > >> +             }  
> > >
> > > Thus, mlx4 choice is to drop packets for unknown/future return codes.
> > >
> > > I think this is the wrong choice.  I think the choice should be
> > > XDP_PASS, to pass the packet up the stack.
> > >
> > > I find "XDP_DROP" problematic because it happen so early in the driver,
> > > that we lost all possibilities to debug what packets gets dropped.  We
> > > get a single kernel log warning, but we cannot inspect the packets any
> > > longer.  By defaulting to XDP_PASS all the normal stack tools (e.g.
> > > tcpdump) is available.
The goal of XDP is performance, and therefore the driver-specific choice
I am making here is to drop, because it preserves resources to do so. I
cannot say for all drivers whether this is the right choice or not.
Therefore, in the user-facing API I leave it undefined, so that future
drivers can have flexibility to choose the most performant
implementation for themselves.

Consider the UDP DDoS use case that we have mentioned before. Suppose an
attacker has knowledge of the particular XDP program that is being used
to filter their packets, and can somehow overflow the return code of the
program. The attacker would prefer that the overflow case consumes
time/memory/both, which if the mlx4 driver were to pass to stack it
would certainly do, and so we must choose the opposite if we have
network security in mind (we do!).
> > >  
> >
> > It's an API issue though not a problem with the packet. Allowing
> > unknown return codes to pass seems like a major security problem also.
> 
> We have the full power and flexibility of the normal Linux stack to
> drop these packets.  And from a usability perspective it gives insight
> into what is wrong and counters metrics.  Would you rather blindly drop
> e.g. 0.01% of the packets in your data-centers without knowing.
Full power, but not full speed, and in the case of DDoS mitigation this
is a strong enough argument IMHO.
> 
> We already talk about XDP as an offload mechanism.  Normally when
> loading a (XDP) "offload" program it should be rejected, e.g. by the
> validator.  BUT we cannot validate all return eBPF codes, because they
> can originate from a table lookup.  Thus, we _do_ allow programs to be
> loaded, with future unknown return code.
>  This then corresponds to only part of the program can be offloaded,
> thus the natural response is to fallback, handling this is the
> non-offloaded slower-path.
> 
> I see the XDP_PASS fallback as a natural way of supporting loading
> newer/future programs on older "versions" of XDP.
>   E.g. I can have a XDP program that have a valid filter protection
> mechanism, but also use a newer mechanism, and my server fleet contains
> different NIC vendors, some NICs only support the filter part.  Then I
> want to avoid having to compile and maintain different XDP/eBPF
> programs per NIC vendor. (Instead I prefer having a Linux stack
> fallback mechanism, and transparently XDP offload as much as the NIC
> driver supports).
I would then argue to only support offloading of XDP programs with
verifiable return codes. We're not at that stage yet, and I think we can
choose different defaults for these two cases.

We have conflicting examples here, which lead to different conclusions.
Reiterating an earlier argument that I made for others on the list to
consider:
"""
Besides, I don't see how PASS is any more correct than DROP. Consider a
future program that is intended to rewrite a packet and forward it out
another port (with some TX_OTHER return code or whatever). If the driver
PASSes the packet, it will still not be interpreted by the stack, since
it may have been destined for some other machine.
"""
So, IMHO there is not a clear right or wrong, and I still fall back to
the security argument to resolve the dilemma. The point there is not
drop/pass, but resource preservation.

> 
> 
> > > I can also imagine that, defaulting to XDP_PASS, can be an important
> > > feature in the future.
> > >
> > > In the future we will likely have features, where XDP can "offload"
> > > packet delivery from the normal stack (e.g. delivery into a VM).  On a
> > > running production system you can then load your XDP program.  If the
> > > driver was too old defaulting to XDP_DROP, then you lost your service,
> > > instead if defaulting to XDP_PASS, your service would survive, falling
> > > back to normal delivery.
> > >
> > > (For the VM delivery use-case, there will likely be a need for having a
> > > fallback delivery method in place, when the XDP program is not active,
> > > in-order to support VM migration).
> > >
> > >
> > >  
[...]
