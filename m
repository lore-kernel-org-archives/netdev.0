From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Fri, 14 Apr 2017 12:28:15 -0700
Message-ID: <20170414192814.GD41922@ast-mbp.thefacebook.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
 <20170413042036.GA46229@ast-mbp.thefacebook.com>
 <20170413.113722.2174945057832588335.davem@davemloft.net>
 <20170414110525.41317f5a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33051 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdDNT2T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:28:19 -0400
Content-Disposition: inline
In-Reply-To: <20170414110525.41317f5a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 11:05:25AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > We are consistently finding that there is this real need to
> > communicate XDP capabilities, or somehow verify that the needs
> > of an XDP program can be satisfied by a given implementation.
> 
> I fully agree that we need some way to express capabilities[1]
> 
> > Maximum headroom is just one.

I don't like the idea of asking program author to explain capabilities
to the kernel. Right now the verifier already understands more about
the program than human does. If the verifier cannot deduct from the
insns what program will be doing, it's pretty much guarantee
that program author has no idea either.
If we add 'required_headroom' as an extra flag to BPF_PROG_LOAD,
the users will just pass something like 64 or 128 whereas the program
might only be doing IPIP encap and that will cause kernel to
provide extra headroom for no good reason or reject the program
whereas it could have run just fine.

So I very much agree with this part:
> ... or somehow verify that the needs
> of an XDP program can be satisfied by a given implementation.

we already have cb_access, dst_needed, xdp_adjust_head flags
that verifier discovers in the program.
For headroom we need one more. The verifier can see
the constant passed into bpf_xdp_adjust_head().
It's trickier if it's a variable, but the verifier can estimate min/max
of the variable already and worst case it can say that it
will be XDP_PACKET_HEADROOM.
If the program is doing variable length bpf_xdp_adjust_head(),
the human has no idea how much they need and cannot tell kernel anyway.
