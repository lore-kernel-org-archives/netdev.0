From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: Add limits for
 encapsulation and EH
Date: Fri, 1 Sep 2017 14:22:43 +0200
Message-ID: <20170901122241.GA4938@vergenet.net>
References: <20170831222239.21509-1-tom@quantonium.net>
 <20170831222239.21509-3-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, alex.popov@linux.com,
        hannes@stressinduktion.org
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35327 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdIAMWt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 08:22:49 -0400
Received: by mail-wr0-f173.google.com with SMTP id y15so174122wrc.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 05:22:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170831222239.21509-3-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 03:22:39PM -0700, Tom Herbert wrote:
> In flow dissector there are no limits to the number of nested
> encapsulations that might be dissected which makes for a nice DOS
> attack. This patch limits for dissecting nested encapsulations
> as well as for dissecting over extension headers.
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  net/core/flow_dissector.c | 48 ++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 45 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5110180a3e96..1bca748de27d 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -396,6 +396,35 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
>  	key_ip->ttl = iph->hop_limit;
>  }
>  
> +/* Maximum number of nested encapsulations that can be processed in
> + * __skb_flow_dissect
> + */
> +#define MAX_FLOW_DISSECT_ENCAPS	5
> +
> +static bool skb_flow_dissect_encap_allowed(int *num_encaps, unsigned int *flags)
> +{
> +	++*num_encaps;
> +
> +	if (*num_encaps >= MAX_FLOW_DISSECT_ENCAPS) {
> +		if (*num_encaps == MAX_FLOW_DISSECT_ENCAPS) {
> +			/* Allow one more pass but ignore disregard

It seems that 'ignore' or 'disregard' should be dropped from the text above.

> +			 * further encapsulations
> +			 */
> +			*flags |= FLOW_DISSECTOR_F_STOP_AT_ENCAP;
> +		} else {
> +			/* Max encaps reached */
> +			return  false;

There are two spaces between 'return' and 'false'.

...
