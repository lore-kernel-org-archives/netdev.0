From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 5 Nov 2004 16:23:19 -0800
Message-ID: <20041105162319.6e2917c5.davem@davemloft.net>
References: <4178AB0D.6060107@pobox.com>
	<20041022.155159.98771450.yoshfuji@linux-ipv6.org>
	<20041022075947.GA15795@xi.wantstofly.org>
	<1099577717.1039.155.camel@jzny.localdomain>
	<20041104221801.584c8f11.davem@davemloft.net>
	<20041105091427.GB28112@xi.wantstofly.org>
	<418B4B1A.8@conectiva.com.br>
	<20041105101513.GA28779@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, hadi@cyberus.ca, yoshfuji@linux-ipv6.org,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041105101513.GA28779@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Nov 2004 11:15:13 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> On Fri, Nov 05, 2004 at 07:42:50AM -0200, Arnaldo Carvalho de Melo wrote:
> 
> > >IPSEC.. not that I know of.  So unless my distro does stuff behind
> > >my back, no.  How do I make sure?
> > 
> > setkey -DP
> 
> Thanks.  Both machines I'm seeing this problem on have:
> 
> # setkey -DP
> No SPD entries.
> # 

Well, xfrm_lookup() is returning an error somehow, that's the only
way to execute dst_release() in udpv6_sendmsg().  And xfrm_lookup()
only returns errors if IPSEC policies have been configured either
globally or locally for the socket.

Full proof from xfrm_lookup():

	policy = NULL;
	if (sk && sk->sk_policy[1])
		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);


Unless socket IPSEC policy has been set via setsockopt(), policy will
be NULL here.

	if (!policy) {
		/* To accelerate a bit...  */
		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
			return 0;

		policy = flow_cache_lookup(fl, family,
					   policy_to_flow_dir(XFRM_POLICY_OUT),
					   xfrm_policy_lookup);
	}

Unless some IPSEC policies have been installed, flow_cache_lookup() will
return NULL, thus policy will be NULL here.

	if (!policy)
		return 0;

And thus we always return zero.

Back in udpv6_sendmsg() we have exactly one dst_release() call which is:

	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
		dst_release(dst);
		goto out;
	}

So, Lennert's traces make no sense, since without IPSEC policies installed
xfrm_lookup() can never return non-zero.

This could mean memory corruption or some kind, or perhaps something installed
some IPSEC policies behind his back, but his setkey -DP command shows that this
is not currently the case at least.

I hope Jeff or Lennert get newer traces soon.
