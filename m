From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 15:20:51 +0400
Message-ID: <20061002112050.GA772@2ka.mipt.ru>
References: <20060925103836.GA13966@2ka.mipt.ru> <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru> <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:5840 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750918AbWJBLVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 07:21:40 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610010203440.8658@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 01, 2006 at 02:27:13AM -0400, James Morris (jmorris@namei.org) wrote:
> Please review this patch carefully.  It addresses a couple of issues.
> 
> When a security module is loaded (in this case, SELinux), the 
> security_xfrm_policy_lookup() hook can return an access denied permission 
> (or other error).  We were not handling that correctly, and in fact 
> inverting the return logic and propagating a false "ok" back up to 
> xfrm_lookup(), which then allowed packets to pass as if they were not 
> associated with an xfrm policy.
> 
> The way I was seeing the problem was when connecting via IPsec to a 
> confined service on an SELinux box (vsftpd), which did not have the 
> appropriate SELinux policy permissions to send packets via IPsec.
> 
> The first SYNACK would be blocked, because of an uncached lookup via 
> flow_cache_lookup(), which would fail to resolve an xfrm policy because 
> the SELinux policy is checked at that point via the resolver.
> 
> However, retransmitted SYNACKs would then find a cached flow entry when 
> calling into flow_cache_lookup() with a null xfrm policy, which is 
> interpreted by xfrm_lookup() as the packet not having any associated 
> policy and similarly to the first case, allowing it to pass without 
> transformation.
> 
> The solution presented here is to first ensure that errno values are 
> correctly propagated all the way back up through the various call chains 
> from security_xfrm_policy_lookup(), and handled correctly.
> 
> Then, flow_cache_lookup() is modified, so that if the policy resolver 
> fails (typically a permission denied via the security module), the flow 
> cache entry is killed rather than having a null policy assigned (which 
> indicates that the packet can pass freely).  This also forces any future 
> lookups for the same flow to consult the security module (e.g. SELinux) 
> for current security policy (rather than, say, caching the error on the 
> flow cache entry).
> 
> I've done quite a bit of testing and not seen any problems, although the 
> patch could certainly do with further review.
> 
> Evgeniy, please let me know if this fixes your problem.

With that patch applied I got kernel panic after some time.
Unfortunately I have not installed serial console, so the most
interesting bits of the stack dump are not visible.
Here is the last ones which are on the screen:
ip_rcv
ip_rcv_finish
packet_rcv_spkt
ip_rcv
netif_receive_skb
sys_accept
skge_poll

and some other uninteresting stuff like hrtimer, softirq and the like...

EIP is at xfrm_lookup+0x43d/0x470

Notice packet socket handler in the trace, may be it can help - I ran
system with tcpdump started.

-- 
	Evgeniy Polyakov
