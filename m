From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Set the filter Hardware
 device for all use-cases
Date: Mon, 5 Dec 2016 14:00:10 +0100
Message-ID: <20161205130009.GA19728@penelope.horms.nl>
References: <1480857919-25194-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f178.google.com ([209.85.210.178]:36619 "EHLO
        mail-wj0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751476AbcLENAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 08:00:13 -0500
Received: by mail-wj0-f178.google.com with SMTP id qp4so289646637wjc.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 05:00:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480857919-25194-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hadar,

On Sun, Dec 04, 2016 at 03:25:19PM +0200, Hadar Hen Zion wrote:
> Check if the returned device from tcf_exts_get_dev function supports tc
> offload and in case the rule can't be offloaded, set the filter hw_dev
> parameter to the original device given by the user.
> 
> The filter hw_device parameter should always be set by fl_hw_replace_filter
> function, since this pointer is used by dump stats and destroy
> filter for each flower rule (offloaded or not).
> 
> Fixes: 7091d8c7055d ('net/sched: cls_flower: Add offload support using egress Hardware device')
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reported-by: Simon Horman <horms@verge.net.au>

Thanks for fixing this, it looks good to me now.

I apologise for not reporting this from my netronome.com address,
which was my intention.

Tested-by: Simon Horman <simon.horman@netronome.com>

> ---
>  net/sched/cls_flower.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> index c5cea78..29a9e6d 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c
> @@ -236,8 +236,11 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
>  	int err;
>  
>  	if (!tc_can_offload(dev, tp)) {
> -		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev))
> +		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
> +		    (f->hw_dev && !tc_can_offload(f->hw_dev, tp))) {
> +			f->hw_dev = dev;
>  			return tc_skip_sw(f->flags) ? -EINVAL : 0;
> +		}
>  		dev = f->hw_dev;
>  		tc->egress_dev = true;
>  	} else {
> -- 
> 1.8.3.1
> 
