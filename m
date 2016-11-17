From: Andrei Vagin <avagin@gmail.com>
Subject: Re: [Patch net] net: check dead netns for peernet2id_alloc()
Date: Wed, 16 Nov 2016 23:17:05 -0800
Message-ID: <CANaxB-yVpvudJaG_NY4LpuCu-Jy1ya8r=sW_Rjb2pEn176snYQ@mail.gmail.com>
References: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38375 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcKQHRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 02:17:06 -0500
Received: by mail-it0-f43.google.com with SMTP id j191so27171630ita.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 23:17:06 -0800 (PST)
In-Reply-To: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 10:27 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Andrei reports we still allocate netns ID from idr after we destroy
> it in cleanup_net().
>
> cleanup_net():
>   ...
>   idr_destroy(&net->netns_ids);
>   ...
>   list_for_each_entry_reverse(ops, &pernet_list, list)
>     ops_exit_list(ops, &net_exit_list);
>       -> rollback_registered_many()
>         -> rtmsg_ifinfo_build_skb()
>          -> rtnl_fill_ifinfo()
>            -> peernet2id_alloc()
>
> After that point we should not even access net->netns_ids, we
> should check the death of the current netns as early as we can in
> peernet2id_alloc().
>
> For net-next we can consider to avoid sending rtmsg totally,
> it is a good optimization for netns teardown path.

It works for me and looks good. Thanks.

Acked-by: Andrei Vagin <avagin@openvz.org>

>
> Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/core/net_namespace.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index f61c0e0..7001da9 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -219,6 +219,8 @@ int peernet2id_alloc(struct net *net, struct net *peer)
>         bool alloc;
>         int id;
>
> +       if (atomic_read(&net->count) == 0)
> +               return NETNSA_NSID_NOT_ASSIGNED;
>         spin_lock_irqsave(&net->nsid_lock, flags);
>         alloc = atomic_read(&peer->count) == 0 ? false : true;
>         id = __peernet2id_alloc(net, peer, &alloc);
> --
> 2.1.0
>
