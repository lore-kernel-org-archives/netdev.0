From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf next 0/3] bridge: netfilter: fix handling of ipv4
 packets w. options
Date: Sat, 4 Oct 2014 12:04:13 +0200
Message-ID: <20141004100413.GA1241@breakpoint.cc>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	bsd@redhat.com, stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	Bandan Das <bandan.das@stratus.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141004035606.GA8228@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

[ fix netdev mail address, sorry about that ]

> On Sat, Oct 04, 2014 at 03:04:27AM +0200, Florian Westphal wrote:
> > David Newall reported that bridge causes bad checksums:
> > http://thread.gmane.org/gmane.linux.network/315705/focus=1706769
> > 
> > The proposal was to revert
> > 462fb2af9788a82a5 (bridge : Sanitize skb before it enters the IP stack).
> > 
> > However, this has some other adverse effects since bridge netfilter
> > and ip stack both use skb->cb (and we thus memset skb->cb whenever
> > we hand skb off to the ip stack).
> > 
> > So, this series attemps to resolve this a bit differently.
> > 
> > First, lets add the inet_param padding that Eric suggested previously.
> > This means that any earlier setup of IPCB will be preserved inside the
> > bridge layer.
> > 
> > This is also useful for netfilter since it will preserve
> > IPCB(skb)->frag_max_size set up by ip defrag.
> > 
> > Second, this gets rid of the option parsing/memset calls in
> > to forward and output cases.
> > 
> > Third, the pre-routing path is changed to not mangle the packets
> > but to only validate the ip options.
> > 
> > This patch series is vs. next instead of net/nf tree.
> > 
> > This has been broken for so long that I don't think we need
> > to rush this.
> 
> I'm unsure whether this is the right approach.  So if I understand
> this correctly your problem is coming from packets that are
> 
> 	IP stack => bridge => IP stack

Just to clarify, right now this doesn't work:
ping -R <addr-of-bridge>
ping -R <addr-behind-bridge>

> in which case preserving IP options may work.
> 
> But does your patch handle packets that are
> 
> 	external => bridge => IP stack

Aside from above record-route test I also played with a bogus bridge
setup where incoming packets can exceed br0 mtu, in this case we emit
frag error without echoing/acting on the options.

IP (..  flags [DF], proto ICMP (1), length 1508, options (NOP,RR 192.168.1.1, 0.0.0.0 0.0.0.0 0.0.0.0 0.0.0.0 0.0.0.0 0.0.0.0 0.0.0.0 0.0.0.0))
192.168.1.1 > 192.168.1.16: ICMP echo request, id 26676, seq 1, length 1448
IP (..  flags [none], proto ICMP (1), length 576) 192.168.1.10 > 192.168.1.1: ICMP 192.168.1.16 unreachable - need to frag (mtu 1500), length 556

1.10 is br0 IP, 1.16 and 1.1 are on different bridge ports, 1.1 has
bogus (larger) mtu than all other hosts.

The fragment error does not echo any RR information.
Is that your concern?

> The reason I asked for the IPCB to be built is to handle exactly
> that case.

Why do we need to compile ip options, exactly?  If the packet
is locally delivered, we hand it up to the ip stack which will
compile ip options normally.

If its forwarded, it only travels through netfilter hooks.
The preserved ip_options_compile() call will make sure options
look sane (we don't preserve the built opts information in
this patch).

The only case where it can reenter in fwd case, AFAICS, is when the
skb exceeds the mtu due to nf_defrag (reenter via call to ip_fragment()).

And we used to get crash here when calling icmp_send since skb->cb
was pointing to bridge cb, which then would crash in __ip_options_echo()
because the various IPCB->opts offsets were garbage.

But, why would we want to echo options?

We're just a bridge (so yes, strictly speaking the icmp response
is already wrong, but silently tossing packets doesn't seem right
either).

Are you saying we should act like router and set the options?

> In fact, even preserving IPCB in the IP stack reentry case is
> a hack since if we ever change the IP stack in future such that
> on exit the IPCB is no longer valid for reentry your approach
> will fail.

True.  I guess in that case, we'd have to resort to less
straightforward approach, i.e. explicitly add the IPCB parts
we wish to retain to br_input_skb_cb, then translate back-and-forth
where needed.

> Now as to your original problem that ip_options_compile mangles
> the packet this is something I explicitly said we should fix
> before we added br_parse_ip_options (point 2 in that email):
> 
> 	https://lkml.org/lkml/2010/9/3/16
> 
> Unfortunately it looks like nobody actually did the audit.

Right.

> So my suggestion would be to fix br_parse_ip_options so that
> it never mangles the packet.

This patch avoids the option mangling by passing in a NULL skb.
So to do what you want all that is needed is to remember
the parsed opts result.  If we add Erics suggested inet cb pad
we can just place the parsed option struct into IPCB()->opts.

If not, we could add struct ip_options to br_input_skb_cb
and stash it there (we'd still need to re-arrange skb->cb to
what ip stack expects though when calling back into it in output
path).

Alternatively, we could call the ipv4 parsing function again
to re-construct IPCB->opts.

I'm just not yet sure if this is the right idea.
Remembering the information will cause the icmp frag error
above to list br0 ip address in the icmp frag error.

Under which circumstances would we want/need to remember the
parsed options (i.e. retain struct ip_options in ->cb[]), or
act upon them?

Thanks,
Florian
