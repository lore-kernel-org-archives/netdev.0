From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 10:54:11 -0700
Message-ID: <1272477251.18228.36.camel@Joe-Laptop.home>
References: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1790 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337Ab0D1RyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 13:54:13 -0400
In-Reply-To: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-04-27 at 23:36 -0700, Tom Herbert wrote:
> Add loop in NAPI poll routine to keep processing RX and TX as long as
> there is more work to do.  This is similar to what tg3 and some other
> drivers do.
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index a1c0e7b..1e4de7b 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -3736,6 +3736,23 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
>  }
>  
>  #ifdef CONFIG_FORCEDETH_NAPI
> +static inline int nv_has_work(struct fe_priv *np)
> +{
> +	if (nv_optimized(np)) {
> +		return (
> +		    ((np->get_rx.ex != np->put_rx.ex) &&
> +		     !(le32_to_cpu(np->get_rx.ex->flaglen) & NV_RX2_AVAIL)) ||
> +		    ((np->get_tx.ex != np->put_tx.ex) &&
> +		     !(le32_to_cpu(np->get_tx.ex->flaglen) & NV_TX_VALID)));
> +	} else {
> +		return (
> +		    ((np->get_rx.orig != np->put_rx.orig) &&
> +		     !(le32_to_cpu(np->get_rx.orig->flaglen) & NV_RX_AVAIL)) ||
> +		    ((np->get_tx.orig != np->put_tx.orig) &&
> +		     !(le32_to_cpu(np->get_tx.orig->flaglen) & NV_TX_VALID)));
> +	}
> +}

It might be better to test the comparisons using
a cpu_to_le32 of the constants.

static inline int nv_has_work(struct fe_priv *np)
{
	if (nv_optimized(np))
		return ((np->get_rx.ex != np->put_rx.ex) &&
			!(np->get_rx.ex->flaglen & cpu_to_le32(NV_RX2_AVAIL))) ||
		       ((np->get_tx.ex != np->put_tx.ex) &&
			!(np->get_tx.ex->flaglen & cpu_to_le32(NV_TX_VALID)));

	return ((np->get_rx.orig != np->put_rx.orig) &&
		!(np->get_rx.orig->flaglen & cpu_to_le32(NV_RX_AVAIL))) ||
	       ((np->get_tx.orig != np->put_tx.orig) &&
		!(np->get_tx.orig->flaglen & cpu_to_le32(NV_TX_VALID)));
}


