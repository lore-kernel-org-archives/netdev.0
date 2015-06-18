From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 2/2] bridge: multicast: start querier timer when
 running user-space stp
Date: Thu, 18 Jun 2015 11:37:40 +0800
Message-ID: <20150618033740.GB27370@gondor.apana.org.au>
References: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
 <1434540511-648-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, sashok@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35951 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbbFRDhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 23:37:42 -0400
Content-Disposition: inline
In-Reply-To: <1434540511-648-3-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 04:28:31AM -0700, Nikolay Aleksandrov wrote:
> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> When STP is running in user-space and querier is configured, the
> querier timer is not started when a port goes to forwarding state.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: eb1d16414339 ("bridge: Add core IGMP snooping support")
> ---
>  net/bridge/br_stp.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index fb3ebe615513..1e2f2f1ff6b0 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -456,6 +456,9 @@ void br_port_state_selection(struct net_bridge *br)
>  				p->topology_change_ack = 0;
>  				br_make_blocking(p);
>  			}
> +		} else if (br->stp_enabled == BR_USER_STP &&
> +			   p->state == BR_STATE_FORWARDING) {
> +			br_multicast_enable_port(p);
>  		}

Minor nit, the stp_enabled check appears to be redundant since
you're in the else clause.

More importantly, I'm not sure about the logic.  For kernel STP,
we enable the port as soon as we get out of blocking.  IIRC enabling
the port just means that we start tracking subscriptions/queries
so it should be OK to do even while we're listening/learning.

In any case the logic should be identical whether we use kernel
STP or user-space STP.

So how about removing br_multicast_enable_port from br_make_forward
and just add it here for both kernel and user-space STP?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
