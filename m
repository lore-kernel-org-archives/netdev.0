From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH] datapath: Fix an error handling path in 'ovs_nla_init_match_and_action()'
Date: Wed, 13 Sep 2017 08:51:07 +0800
Message-ID: <CAMDZJNV1=1XzGKg3nNpCkzTa1Xe5Xa-q2_R5mLdyNH8qgKhvRg@mail.gmail.com>
References: <20170911192015.17553-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: pravin shelar <pshelar@nicira.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36329 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdIMAvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 20:51:09 -0400
In-Reply-To: <20170911192015.17553-1-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 3:20 AM, Christophe JAILLET
<christophe.jaillet@wanadoo.fr> wrote:
> All other error handling paths in this function go through the 'error'
> label. This one should do the same.
>
> Fixes: 9cc9a5cb176c ("datapath: Avoid using stack larger than 1024.")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> I think that the comment above the function could be improved. It looks
> like the commit log which has introduced this function.
>
> I'm also not sure that commit 9cc9a5cb176c is of any help. It is
> supposed to remove a warning, and I guess it does. But 'ovs_nla_init_match_and_action()'
> is called unconditionnaly from 'ovs_flow_cmd_set()'. So even if the stack
> used by each function is reduced, the overall stack should be the same, if
> not larger.
>
> So this commit sounds like adding a bug where the code was fine and states
> to fix an issue but, at the best, only hides it.
>
> Instead of fixing the code with the proposed patch, reverting the initial
> commit could also be considered.
> ---
>  net/openvswitch/datapath.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 76cf273a56c7..c3aec6227c91 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1112,7 +1112,8 @@ static int ovs_nla_init_match_and_action(struct net *net,
>                 if (!a[OVS_FLOW_ATTR_KEY]) {
>                         OVS_NLERR(log,
>                                   "Flow key attribute not present in set flow.");
> -                       return -EINVAL;
> +                       error = -EINVAL;
> +                       goto error;

Thank for your report. But I really don't understand.
In the 'ovs_nla_init_match_and_action', we only init 'match' when the
OVS_FLOW_ATTR_KEY is set.
If the 'OVS_FLOW_ATTR_ACTIONS' is set, but not 'OVS_FLOW_ATTR_KEY', we
can return directly because the match is not inited yet, and it is
unnecessary to set it's mask NULL. Then ovs_flow_cmd_set can run via
value returned.


>                 }
>
>                 *acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], key,
> --
> 2.11.0
>
