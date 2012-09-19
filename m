From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window
 is valid
Date: Wed, 19 Sep 2012 23:38:29 +0100
Message-ID: <1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
	 <1348090423-32665-6-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Martin Willi <martin@revosec.ch>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-6-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 23:33 +0200, Mathias Krause wrote:
> The current code fails to ensure that the netlink message actually
> contains as many bytes as the header indicates. If a user creates a new
> state or updates an existing one but does not supply the bytes for the
> whole ESN replay window, the kernel copies random heap bytes into the
> replay bitmap, the ones happen to follow the XFRMA_REPLAY_ESN_VAL
> netlink attribute. This leads to following issues:
> 
> 1. The replay window has random bits set confusing the replay handling
>    code later on.
> 
> 2. A malicious user could use this flaw to leak up to ~3.5kB of heap
>    memory when she has access to the XFRM netlink interface (requires
>    CAP_NET_ADMIN).

Where does this limit come from?  Is that just the standard size netlink
skb?

I'm a little worried that the user-provided
xfrm_replay_state_esn::bmp_len is not being directly validated anywhere.
Currently xfrm_replay_state_esn_len() may overflow, and as its return
type is int it may unexpectedly return a negative value.

[...]
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
[...]
> @@ -370,14 +378,15 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
>  					 struct nlattr *rp)
>  {
>  	struct xfrm_replay_state_esn *up;
> +	size_t ulen;

I would normally expect to see sizes declared as size_t but mixing
size_t and int in comparisons tends to result in bugs.  So I think this
should to be int, matching the return types of nla_len() and
xfrm_replay_state_esn_len() (and apparently all lengths in netlink...)

>  	if (!replay_esn || !rp)
>  		return 0;
>  
>  	up = nla_data(rp);
> +	ulen = xfrm_replay_state_esn_len(up);
>
> -	if (xfrm_replay_state_esn_len(replay_esn) !=
> -			xfrm_replay_state_esn_len(up))
> +	if (nla_len(rp) < ulen || xfrm_replay_state_esn_len(replay_esn) != ulen)
>  		return -EINVAL;
>  
>  	return 0;
> @@ -388,22 +397,28 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
>  				       struct nlattr *rta)
>  {
>  	struct xfrm_replay_state_esn *p, *pp, *up;
> +	size_t klen, ulen;

Also int, for the same reason.

>  	if (!rta)
>  		return 0;
>  
>  	up = nla_data(rta);
> +	klen = xfrm_replay_state_esn_len(up);
> +	ulen = nla_len(rta) > sizeof(*up) ? klen : sizeof(*up);
[...]

I understand that this is correct since verify_replay() previously
checked that nla_len(rta) is either == sizeof(*up) or >= klen.  But
would it not be more obviously correct to test nla_len(rta) >= klen?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
