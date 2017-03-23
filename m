From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH 4.11] genetlink: fix counting regression on
 ctrl_dumpfamily()
Date: Thu, 23 Mar 2017 11:45:17 +0100
Message-ID: <c591cfc3-76a0-adb7-13ef-f1feb9290782@gmail.com>
References: <1490195313-13272-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
        Xose Vazquez Perez <xose.vazquez@gmail.com>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Johannes Berg <johannes@sipsolutions.net>
To: Stanislaw Gruszka <sgruszka@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35429 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbdCWKpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:45:21 -0400
In-Reply-To: <1490195313-13272-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.03.2017 16:08, Stanislaw Gruszka wrote:
> Commit 2ae0f17df1cd ("genetlink: use idr to track families") replaced
> 
> 	if (++n < fams_to_skip)
> 		continue;
> into:
> 
> 	if (n++ < fams_to_skip)
> 		continue;
> 
> This subtle change cause that on retry ctrl_dumpfamily() call we omit
> one family that failed to do ctrl_fill_info() on previous call, because
> cb->args[0] = n number counts also family that failed to do
> ctrl_fill_info().
> 
> Patch fixes the problem and avoid confusion in the future just decrease
> n counter when ctrl_fill_info() fail.
> 
> User visible problem caused by this bug is failure to get access to
> some genetlink family i.e. nl80211. However problem is reproducible
> only if number of registered genetlink families is big enough to
> cause second call of ctrl_dumpfamily().
> 
> Cc: Xose Vazquez Perez <xose.vazquez@gmail.com>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> Dave, please also target this for 4.10+ -stable.
> 
>  net/netlink/genetlink.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index fb6e10f..92e0981 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -783,8 +783,10 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>  
>  		if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).portid,
>  				   cb->nlh->nlmsg_seq, NLM_F_MULTI,
> -				   skb, CTRL_CMD_NEWFAMILY) < 0)
> +				   skb, CTRL_CMD_NEWFAMILY) < 0) {
> +			n--;
>  			break;
> +		}
>  	}
>  
>  	cb->args[0] = n;
> 


Thanks Stanislaw, Larry!

Tested-by: poma <poma@gmail.com>

Ref.
https://bugzilla.redhat.com/show_bug.cgi?id=1422247
