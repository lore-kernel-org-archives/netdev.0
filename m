From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net/sched: cls_flower: Don't err on HW flow add
 failure unless we're on skip_sw
Date: Wed, 25 Oct 2017 17:01:52 +0200
Message-ID: <20171025150152.GD1976@nanopsycho.orion>
References: <1508942313-544-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, mlxsw@mellanox.com,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:56494 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdJYPBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 11:01:54 -0400
Received: by mail-wr0-f195.google.com with SMTP id r79so276849wrb.13
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 08:01:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508942313-544-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 25, 2017 at 04:38:33PM CEST, ogerlitz@mellanox.com wrote:
>If we failed to offload a flow to HW, we should be err-ing only if skip_sw
>is set, otherwise this should go unnoted.

First of all, this patch should got to net-next, not net as you
indicate.


>
>Fixes: 717503b9cf57 ('net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev infra')
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
> net/sched/cls_flower.c | 6 ++----
> 1 file changed, 2 insertions(+), 4 deletions(-)
>
>diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>index 16f58ab..ae2b5c6 100644
>--- a/net/sched/cls_flower.c
>+++ b/net/sched/cls_flower.c
>@@ -230,12 +230,10 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
> 
> 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
> 			       &cls_flower, skip_sw);
>-	if (err < 0) {
>+	if (err < 0)
> 		fl_hw_destroy_filter(tp, f);
>-		return err;

I believe it is better to do just:
		if (skip_sw)
			return err;
The reason is that you would propagate the actual error, not just
"-EINVAL" in all cases.


The same issue is present for matchall, u32 and bpf classifiers. Do you
want to fix it in one go? If not, I can take care of it. Up to you.


Thanks



>-	} else if (err > 0) {
>+	else if (err > 0)
> 		f->flags |= TCA_CLS_FLAGS_IN_HW;
>-	}
> 
> 	if (skip_sw && !(f->flags & TCA_CLS_FLAGS_IN_HW))
> 		return -EINVAL;
>-- 
>2.5.5
>
