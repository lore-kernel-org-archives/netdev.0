From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Fri, 14 Apr 2017 17:46:44 -0700
Message-ID: <20170415004642.GA73685@ast-mbp.thefacebook.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
 <20170413042036.GA46229@ast-mbp.thefacebook.com>
 <20170413.113722.2174945057832588335.davem@davemloft.net>
 <20170414110525.41317f5a@redhat.com>
 <20170414192814.GD41922@ast-mbp.thefacebook.com>
 <20170414153032.2b3e1a5c@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35248 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755502AbdDOAqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:46:49 -0400
Content-Disposition: inline
In-Reply-To: <20170414153032.2b3e1a5c@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 03:30:32PM -0700, Jakub Kicinski wrote:
> On Fri, 14 Apr 2017 12:28:15 -0700, Alexei Starovoitov wrote:
> > On Fri, Apr 14, 2017 at 11:05:25AM +0200, Jesper Dangaard Brouer wrote:
> > > > 
> > > > We are consistently finding that there is this real need to
> > > > communicate XDP capabilities, or somehow verify that the needs
> > > > of an XDP program can be satisfied by a given implementation.  
> > > 
> > > I fully agree that we need some way to express capabilities[1]
> > >   
> > > > Maximum headroom is just one.  
> > 
> > I don't like the idea of asking program author to explain capabilities
> > to the kernel. Right now the verifier already understands more about
> > the program than human does. If the verifier cannot deduct from the
> > insns what program will be doing, it's pretty much guarantee
> > that program author has no idea either.
> > If we add 'required_headroom' as an extra flag to BPF_PROG_LOAD,
> > the users will just pass something like 64 or 128 whereas the program
> > might only be doing IPIP encap and that will cause kernel to
> > provide extra headroom for no good reason or reject the program
> > whereas it could have run just fine.
> > 
> > So I very much agree with this part:
> > > ... or somehow verify that the needs
> > > of an XDP program can be satisfied by a given implementation.  
> > 
> > we already have cb_access, dst_needed, xdp_adjust_head flags
> > that verifier discovers in the program.
> > For headroom we need one more. The verifier can see
> > the constant passed into bpf_xdp_adjust_head().
> > It's trickier if it's a variable, but the verifier can estimate min/max
> > of the variable already and worst case it can say that it
> > will be XDP_PACKET_HEADROOM.
> > If the program is doing variable length bpf_xdp_adjust_head(),
> > the human has no idea how much they need and cannot tell kernel anyway.
> 
> If I understand correctly that the current proposal is to:
> 
> 1. Assume program needs 256 (XDP_PACKET_HEADROOM) of prepend.
> 2. Make verifier try to lower that through byte code analysis.
> 3. Make the load fail if (prog->max_prepend > driver->xdp_max_prepend).

no. the hard fail will be wrong, since verifier is conservative.
As i showed in the example with variable ip hdr length.

> We may expect most users won't care and we may want to still depend on
> the verifier to analyze the program and enable optimizations, but
> depending on the verifier for proving prepend lengths is scary.  Or are
> we just discussion the optimizations here and not the guarantees about
> headroom availability?

yes. I was thinking as an optimization. If verifier can see that
prog needs only 20 bytes of headroom or no headroom (like netronome
already does) than the ring can be configured differently for hopefully
better performance.
But that's probably bad idea, since I was assuming that such ring
reconfiguration can be made fast, which is unlikely.
If it takes seconds to setup a ring, then drivers should just
assume XDP_PACKET_HEADROOM, since at that time the program
properties are unknown and in the future other programs will be loaded.
Take a look at our current setup with slots for xdp_dump, ddos, lb
programs. Only root program is attached at the begining.
If the driver configures the ring for such empty program that would break
dynamic addition of lb prog.
The driver must not interrupt the traffic when user adds another
prog to prog array. In such case XDP side doesn't even know that
prog array is used. It's all happening purely on bpf side.

> Or worse not do that, use Qlogic, Broadcom, Mellanox or Netronome cards
> and then be in for a nasty surprise when they try to load the same
> program for Intel parts :(

are you talking hw offloaded prog or normal in-driver xdp?

> I agree that trying to express capabilities to user space is quickly
> going to become more confusing than helpful.  However, I think here we
> need the opposite - we need an opt-in way of program requesting
> guarantees about the datapath.

what is an example of what you proposing? How will it look from user pov?
