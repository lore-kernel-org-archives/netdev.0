From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net] net/flow: fix fc->percpu NULL pointer dereference
Date: Sat, 10 Jun 2017 16:29:23 +0800
Message-ID: <CADvbK_dBuJKymP6tT358EEN2Qg6s+f8Sj8z-UN6ypdoDNcp-dA@mail.gmail.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com> <1497013755-24481-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33369 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751844AbdFJI3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 04:29:24 -0400
Received: by mail-qk0-f195.google.com with SMTP id 76so2349945qkz.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 01:29:24 -0700 (PDT)
In-Reply-To: <1497013755-24481-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 9:09 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> Now we will force to do garbage collection if any policy removed in
> xfrm_policy_flush(). But during xfrm_net_exit(). We call flow_cache_fini()
> first and set set fc->percpu to NULL. Then after we call xfrm_policy_fini()
> -> frxm_policy_flush() -> flow_cache_flush(), we will get NULL pointer
> dereference when check percpu_empty. The code path looks like:
>
> flow_cache_fini()
>   - fc->percpu = NULL
> xfrm_policy_fini()
>   - xfrm_policy_flush()
>     - xfrm_garbage_collect()
>       - flow_cache_flush()
>         - flow_cache_percpu_empty()
>           - fcp = per_cpu_ptr(fc->percpu, cpu)
>
> To reproduce, just add ipsec in netns and then remove the netns.
>
> v2:
> As Xin Long suggested, since only two other places need to call it. move
> xfrm_garbage_collect() outside xfrm_policy_flush().
>
> Fixes: 35db06912189 ("xfrm: do the garbage collection after flushing policy")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/key/af_key.c       | 2 ++
>  net/xfrm/xfrm_policy.c | 4 ----
>  net/xfrm/xfrm_user.c   | 1 +
>  3 files changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 512dc43..5103f92 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -2755,6 +2755,8 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
>         int err, err2;
>
>         err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, true);
> +       if (!err)
> +               xfrm_garbage_collect(net);
>         err2 = unicast_flush_resp(sk, hdr);
>         if (err || err2) {
>                 if (err == -ESRCH) /* empty table - old silent behavior */
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index ed4e52d..643a18f 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1006,10 +1006,6 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
>                 err = -ESRCH;
>  out:
>         spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
> -
> -       if (cnt)
> -               xfrm_garbage_collect(net);
> -
>         return err;
>  }
>  EXPORT_SYMBOL(xfrm_policy_flush);
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 38614df..86116e9 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -2027,6 +2027,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
>                         return 0;
>                 return err;
>         }
> +       xfrm_garbage_collect(net);
>
>         c.data.type = type;
>         c.event = nlh->nlmsg_type;
> --
> 2.5.5
>
 It's a xfrm fix, pls also fix the title, like:
   xfrm: move xfrm_garbage_collect out of xfrm_policy_flush
or
   xfrm: fix ...
