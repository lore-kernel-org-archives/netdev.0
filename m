From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/4] net/sched: act_mirred: Rename tcfm_ok_push
 to tcfm_mac_header_xmit
Date: Tue, 27 Sep 2016 12:30:20 +0200
Message-ID: <57EA4A3C.8000508@iogearbox.net>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com> <1474550512-7552-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49994 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932674AbcI0KaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:30:25 -0400
In-Reply-To: <1474550512-7552-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2016 03:21 PM, Shmulik Ladkani wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>
> 'tcfm_ok_push' specifies whether a mac_len sized push is needed upon
> egress to the target device (if action is performed at ingress).
>
> Rename it to 'tcfm_mac_header_xmit' as this is actually an attribute of
> the target device.
> This allows to decouple the attribute from the action to be taken.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
>   include/net/tc_act/tc_mirred.h |  2 +-
>   net/sched/act_mirred.c         | 10 +++++-----
>   2 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
> index 62770ad..5275158 100644
> --- a/include/net/tc_act/tc_mirred.h
> +++ b/include/net/tc_act/tc_mirred.h
> @@ -8,7 +8,7 @@ struct tcf_mirred {
>   	struct tc_action	common;
>   	int			tcfm_eaction;
>   	int			tcfm_ifindex;
> -	int			tcfm_ok_push;
> +	int			tcfm_mac_header_xmit;

Since you already touch this here and in patch 2/4 anyway, maybe
make that a bool along the way?

Perhaps instead of tcfm_mac_header_xmit, tcfm_mac_header_push
might be a better name?

>   	struct net_device __rcu	*tcfm_dev;
>   	struct list_head	tcfm_list;
>   };
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 667dc38..7b03b13 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -63,7 +63,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   	struct tc_mirred *parm;
>   	struct tcf_mirred *m;
>   	struct net_device *dev;
> -	int ret, ok_push = 0;
> +	int ret, mac_header_xmit = 0;
>   	bool exists = false;
>
>   	if (nla == NULL)
> @@ -102,10 +102,10 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   		case ARPHRD_IPGRE:
>   		case ARPHRD_VOID:
>   		case ARPHRD_NONE:
> -			ok_push = 0;
> +			mac_header_xmit = 0;
>   			break;
>   		default:
> -			ok_push = 1;
> +			mac_header_xmit = 1;
>   			break;
>   		}
>   	} else {
> @@ -136,7 +136,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
>   		dev_hold(dev);
>   		rcu_assign_pointer(m->tcfm_dev, dev);
> -		m->tcfm_ok_push = ok_push;
> +		m->tcfm_mac_header_xmit = mac_header_xmit;
>   	}
>
>   	if (ret == ACT_P_CREATED) {
> @@ -181,7 +181,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
>   		goto out;
>
>   	if (!(at & AT_EGRESS)) {
> -		if (m->tcfm_ok_push)
> +		if (m->tcfm_mac_header_xmit)
>   			skb_push_rcsum(skb2, skb->mac_len);
>   	}
>
>
