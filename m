From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 1/2] flow_dissector: Cleanup control flow
Date: Fri, 1 Sep 2017 14:26:49 +0200
Message-ID: <20170901122647.GB4938@vergenet.net>
References: <20170831222239.21509-1-tom@quantonium.net>
 <20170831222239.21509-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, alex.popov@linux.com,
        hannes@stressinduktion.org
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36825 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751715AbdIAM0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 08:26:55 -0400
Received: by mail-wm0-f52.google.com with SMTP id f127so506819wmf.1
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 05:26:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170831222239.21509-2-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Aug 31, 2017 at 03:22:38PM -0700, Tom Herbert wrote:
> __skb_flow_dissect is riddled with gotos that make discerning the flow,
> debugging, and extending the capability difficult. This patch
> reorganizes things so that we only perform goto's after the two main
> switch statements (no gotos within the cases now). It also eliminates
> several goto labels so that there are only two labels that can be target
> for goto.

I agree that the flow of __skb_flow_dissect() is difficult to follow
but its not obvious that this significant change in terms of loc
takes us to a better place.

Maybe it makes follow-up work easier. If so perhaps it should be motivated
along those lines.

In any case I won't stand in the way of this change but I did want to throw
my 2c worth in.

> 
> Reported-by: Alexander Popov <alex.popov@linux.com>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  include/net/flow_dissector.h |   9 ++
>  net/core/flow_dissector.c    | 225 ++++++++++++++++++++++++++++---------------
>  2 files changed, 156 insertions(+), 78 deletions(-)
> 
> diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
> index e2663e900b0a..c358c3ff6acc 100644
> --- a/include/net/flow_dissector.h
> +++ b/include/net/flow_dissector.h
> @@ -19,6 +19,15 @@ struct flow_dissector_key_control {
>  #define FLOW_DIS_FIRST_FRAG	BIT(1)
>  #define FLOW_DIS_ENCAPSULATION	BIT(2)
>  
> +enum flow_dissect_ret {
> +	FLOW_DISSECT_RET_OUT_GOOD,
> +	FLOW_DISSECT_RET_OUT_BAD,
> +	FLOW_DISSECT_RET_PROTO_AGAIN,
> +	FLOW_DISSECT_RET_IPPROTO_AGAIN,
> +	FLOW_DISSECT_RET_IPPROTO_AGAIN_EH,
> +	FLOW_DISSECT_RET_CONTINUE,
> +};

Minor nit:

My reading is that this patch does not seem to differentiate between the
handling of FLOW_DISSECT_RET_IPPROTO_AGAIN and
FLOW_DISSECT_RET_IPPROTO_AGAIN_EH.  Perhaps it would be better to add
FLOW_DISSECT_RET_IPPROTO_AGAIN_EH in the following patch where it is used.

> +
>  /**
>   * struct flow_dissector_key_basic:
>   * @thoff: Transport header offset

...
