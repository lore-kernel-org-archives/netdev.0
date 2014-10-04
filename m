From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH nf next 0/3] bridge: netfilter: fix handling of ipv4
 packets w. options
Date: Sat, 4 Oct 2014 11:56:06 +0800
Message-ID: <20141004035606.GA8228@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@cger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	Bandan Das <bandan.das@stratus.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412384670-17794-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2014 at 03:04:27AM +0200, Florian Westphal wrote:
> David Newall reported that bridge causes bad checksums:
> http://thread.gmane.org/gmane.linux.network/315705/focus=1706769
> 
> The proposal was to revert
> 462fb2af9788a82a5 (bridge : Sanitize skb before it enters the IP stack).
> 
> However, this has some other adverse effects since bridge netfilter
> and ip stack both use skb->cb (and we thus memset skb->cb whenever
> we hand skb off to the ip stack).
> 
> So, this series attemps to resolve this a bit differently.
> 
> First, lets add the inet_param padding that Eric suggested previously.
> This means that any earlier setup of IPCB will be preserved inside the
> bridge layer.
> 
> This is also useful for netfilter since it will preserve
> IPCB(skb)->frag_max_size set up by ip defrag.
> 
> Second, this gets rid of the option parsing/memset calls in
> to forward and output cases.
> 
> Third, the pre-routing path is changed to not mangle the packets
> but to only validate the ip options.
> 
> This patch series is vs. next instead of net/nf tree.
> 
> This has been broken for so long that I don't think we need
> to rush this.

I'm unsure whether this is the right approach.  So if I understand
this correctly your problem is coming from packets that are

	IP stack => bridge => IP stack

in which case preserving IP options may work.

But does your patch handle packets that are

	external => bridge => IP stack

The reason I asked for the IPCB to be built is to handle exactly
that case.

In fact, even preserving IPCB in the IP stack reentry case is
a hack since if we ever change the IP stack in future such that
on exit the IPCB is no longer valid for reentry your approach
will fail.

Now as to your original problem that ip_options_compile mangles
the packet this is something I explicitly said we should fix
before we added br_parse_ip_options (point 2 in that email):

	https://lkml.org/lkml/2010/9/3/16

Unfortunately it looks like nobody actually did the audit.

So my suggestion would be to fix br_parse_ip_options so that
it never mangles the packet.

Does this fix your problem or are there other issues that I
have overlooked?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
