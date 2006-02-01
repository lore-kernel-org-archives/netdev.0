From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [lock validator] inet6_destroy_sock(): soft-safe -> soft-unsafe lock dependency
Date: Wed, 1 Feb 2006 12:13:19 +0100
Message-ID: <20060201111318.GA6259@elte.hu>
References: <20060127001807.GA17179@elte.hu> <E1F2IcV-0007Iq-00@gondolin.me.apana.org.au> <20060128152204.GA13940@elte.hu> <20060131102758.GA31460@gondor.apana.org.au> <20060131212432.GA18812@elte.hu> <20060201104214.GA9085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932447AbWBALOs@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060201104214.GA9085@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Jan 31, 2006 at 10:24:32PM +0100, Ingo Molnar wrote:
> >
> >  [<c04de9e8>] _write_lock+0x8/0x10
> >  [<c0499015>] inet6_destroy_sock+0x25/0x100
> >  [<c04b8672>] tcp_v6_destroy_sock+0x12/0x20
> >  [<c046bbda>] inet_csk_destroy_sock+0x4a/0x150
> >  [<c047625c>] tcp_rcv_state_process+0xd4c/0xdd0
> >  [<c047d8e9>] tcp_v4_do_rcv+0xa9/0x340
> >  [<c047eabb>] tcp_v4_rcv+0x8eb/0x9d0
> 
> OK this is definitely broken.  We should never touch the dst lock in 
> softirq context.  Since inet6_destroy_sock may be called from that 
> context due to the asynchronous nature of sockets, we can't take the 
> lock there.
> 
> In fact this sk_dst_reset is totally redundant since all IPv6 sockets 
> use inet_sock_destruct as their socket destructor which always cleans 
> up the dst anyway.  So the solution is to simply remove the call.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

cool - i've booted your patch and will have results later today [it's 
looking good so far, after 10 minutes of uptime ;)]

btw., this codepath took some time to trigger, and i'm not sure why: 
maybe because i dont have any true ipv6 traffic? (In fact i dont have 
CONFIG_IPV6 enabled at all in this kernel config - so this codepath must 
be an effect of ipv4/ipv6 unification?) I guess i should run the ipv6 
testsuite to expose all the important codepaths to the validator? [Would 
you have any suggestions for me how to do that quickly & easily?]

another thing: could you add the string 'lock validator' somewhere into 
the changelog, so that we can grep for such things later on? One reason 
for that is to strenghten my future arguments for mainline inclusion 
;-), but there's another argument as well:

the lock validator finds _all_ hidden deadlocks [no matter how obscure, 
interdependent or unlikely they are, as long as the affected codepath is 
triggered at least once], and thus the resulting bug statistics and 
characteristics will be an excellent (and one-time) opportunity to 
objectively judge the absolute code quality (and defect rate) of the 
Linux kernel, for an important category of hard-to-find bugs. (Maybe the 
results can even be extrapolated to other, similarly hard-to-find bug 
categories.)

in other words, the lock validator is building a runtime set of formal 
"locking requirements", and is automatically proving (and maintaining 
the proof) that all locking activity within the kernel meets those 
requirements, mathematically. It thus enables us to achieve a hard 
ceiling of 100% correctness that we can rarely achieve in complex code 
as the kernel. We should minimize the changeset entropy introduced and 
preserve this historic information.

	Ingo
