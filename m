From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Wed, 2 Nov 2016 18:20:36 +0100
Message-ID: <20161102172036.GD17689@breakpoint.cc>
References: <1478104158-9504-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53132 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932648AbcKBRWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:22:22 -0400
Content-Disposition: inline
In-Reply-To: <1478104158-9504-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lance Richardson <lrichard@redhat.com> wrote:
> Some configurations (e.g. geneve interface with default
> MTU of 1500 over an ethernet interface with 1500 MTU) result
> in the transmission of packets that exceed the configured MTU.
> While this should be considered to be a "bad" configuration,
> it is still allowed and should not result in the sending
> of packets that exceed the configured MTU.
> 
> Fix by dropping the assumption in ip_finish_output_gso() that
> locally originated gso packets will never need fragmentation.
> Basic testing using iperf (observing CPU usage and bandwidth)
> have shown no measurable performance impact for traffic not
> requiring fragmentation.
> 
> Fixes: c7ba65d7b649 ("net: ip: push gso skb forwarding handling down the stack")
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
>  net/ipv4/ip_output.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 03e7f73..4971401 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -239,11 +239,9 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
>  	struct sk_buff *segs;
>  	int ret = 0;
>  
> -	/* common case: fragmentation of segments is not allowed,
> -	 * or seglen is <= mtu
> +	/* common case: seglen is <= mtu
>  	 */
> -	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
> -	      skb_gso_validate_mtu(skb, mtu))
> +	if (skb_gso_validate_mtu(skb, mtu))

IPSKB_FRAG_SEGS is now useless and should be removed.
