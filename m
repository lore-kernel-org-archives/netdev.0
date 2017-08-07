From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Mon, 7 Aug 2017 14:15:01 -0700
Message-ID: <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:35928 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGVPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:15:22 -0400
In-Reply-To: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing netfilter and Jamal)

On Sat, Aug 5, 2017 at 4:35 AM, Xin Long <lucien.xin@gmail.com> wrote:
> As we know in some target's checkentry it may dereference par.entryinfo
> to check entry stuff inside. But when sched action calls xt_check_target,
> par.entryinfo is set with NULL. It would cause kernel panic when calling
> some targets.
>
> It can be reproduce with:
>   # tc qd add dev eth1 ingress handle ffff:
>   # tc filter add dev eth1 parent ffff: u32 match u32 0 0 action xt \
>     -j ECN --ecn-tcp-remove
>
> It could also crash kernel when using target CLUSTERIP or TPROXY.
>
> By now there's no proper value for par.entryinfo in ipt_init_target,
> but it can not be set with NULL. This patch is to void all these
> panics by setting it with an ipt_entry obj with all members 0.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sched/act_ipt.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
> index 7c4816b..0f09f70 100644
> --- a/net/sched/act_ipt.c
> +++ b/net/sched/act_ipt.c
> @@ -41,6 +41,7 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
>  {
>         struct xt_tgchk_param par;
>         struct xt_target *target;
> +       struct ipt_entry e;
>         int ret = 0;
>
>         target = xt_request_find_target(AF_INET, t->u.user.name,
> @@ -48,10 +49,11 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
>         if (IS_ERR(target))
>                 return PTR_ERR(target);
>
> +       memset(&e, 0, sizeof(e));
>         t->u.kernel.target = target;
>         par.net       = net;
>         par.table     = table;
> -       par.entryinfo = NULL;
> +       par.entryinfo = &e;

This looks like a completely API burden?
