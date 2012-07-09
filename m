From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Sun, 08 Jul 2012 23:47:47 -0700 (PDT)
Message-ID: <20120708.234747.2210170159486826750.davem@davemloft.net>
References: <20120629013017.GA4649@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab2GIGru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 02:47:50 -0400
In-Reply-To: <20120629013017.GA4649@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Thu, 28 Jun 2012 18:30:17 -0700

> +#define HASH_SIZE  16
> +#define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)

Define HASH such that it masks with (HASH_SIZE - 1) instead of
0xf, so that if HASH_SIZE is changed everything automatically
still works without having to remember to update the value in
HASH()'s definition too.

> +	if (skb->protocol != htons(ETH_P_IP))
> +		goto tx_error;

We are really past the point where we can add major inet protocol
features without supporting ipv6 as well.

> +	if (IS_ERR(rt)) {
> +		dev->stats.tx_carrier_errors++;
> +		goto tx_error_icmp;
> +	}
> +#ifdef CONFIG_XFRM
> +		/* if there is no transform then this tunnel is not functional.
> +		 * Or if the xfrm is not mode tunnel.
> +		 */
> +		if (!rt->dst.xfrm ||
> +		    rt->dst.xfrm->props.mode != XFRM_MODE_TUNNEL) {
> +			stats->tx_carrier_errors++;
> +			goto tx_error_icmp;
> +		}
> +#endif

This code in the CONFIG_XFRM block is not indented properly.

And this is a pointless CONFIG_* check, you can't even register
this tunnel outside of the XFRM code.  In fact the code already
depends upon INET_XFRM_MODE_TUNNEL which therefore automatically
means that CONFIG_XFRM must be set for this code.

> +	}
> +
> +
> +	if (tunnel->err_count > 0) {

Get rid of these extra blank lines.

> +	}
> +
> +
> +	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |

Again.

The reason there are long periods of time between my attempts to
review your code (and probably the reason I'm the only person still
reviewing your work at all) is that I know there are going to be so
many problems to let you know about.  It's really painful to review
your work and I've spent so much time on the coding style and the
simpler issues that I really haven't considered the high level issues
of what your code is trying to do.
