From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] genetlink: convert family dump code to use RCU
Date: Wed, 21 Aug 2013 21:32:40 -0700
Message-ID: <CALnjE+oqN0NC1xmzTRFXOuMb+4L83JJyo5SGqBTvW-KfefE39g@mail.gmail.com>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	<1377094083-8122-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:36800 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752387Ab3HVEcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:32:41 -0400
Received: by mail-qe0-f48.google.com with SMTP id 1so823121qec.7
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 21:32:40 -0700 (PDT)
In-Reply-To: <1377094083-8122-3-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 21, 2013 at 7:08 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> In my previous commit 58ad436fcf49810aa006016107f494c9ac9013db
> ("genetlink: fix family dump race") I attempted to solve an
> issue in generic netlink that could lead to crashes, but it
> turns out that this introduced a possibility for deadlock. As
> I haven't found a way to actually add locking without causing
> that, convert the family, family ops/mcast group lists all to
> use RCU, so the family dump code can simply use RCU protection
> instead of locking.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

I send out a fix which fixes genl locking for dump operation and it
might fix this issue, Can you try this?

http://marc.info/?l=linux-netdev&m=137714389705485&w=2

> ---
>  net/netlink/genetlink.c | 25 ++++++++++++++++---------
>  1 file changed, 16 insertions(+), 9 deletions(-)
>
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 512718a..2027964 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -222,7 +222,7 @@ int genl_register_mc_group(struct genl_family *family,
>
>         grp->id = id;
>         set_bit(id, mc_groups);
> -       list_add_tail(&grp->list, &family->mcast_groups);
> +       list_add_tail_rcu(&grp->list, &family->mcast_groups);
>         grp->family = family;
>
>         genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
> @@ -246,7 +246,7 @@ static void __genl_unregister_mc_group(struct genl_family *family,
>         netlink_table_ungrab();
>
>         clear_bit(grp->id, mc_groups);
> -       list_del(&grp->list);
> +       list_del_rcu(&grp->list);
>         genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
>         grp->id = 0;
>         grp->family = NULL;
> @@ -272,6 +272,7 @@ void genl_unregister_mc_group(struct genl_family *family,
>         genl_lock_all();
>         __genl_unregister_mc_group(family, grp);
>         genl_unlock_all();
> +       synchronize_rcu();
>  }
>  EXPORT_SYMBOL(genl_unregister_mc_group);
>
> @@ -281,6 +282,7 @@ static void genl_unregister_mc_groups(struct genl_family *family)
>
>         list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
>                 __genl_unregister_mc_group(family, grp);
> +       synchronize_rcu();
>  }
>
>  /**
> @@ -318,7 +320,7 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
>                 ops->flags |= GENL_CMD_CAP_HASPOL;
>
>         genl_lock_all();
> -       list_add_tail(&ops->ops_list, &family->ops_list);
> +       list_add_tail_rcu(&ops->ops_list, &family->ops_list);
>         genl_unlock_all();
>
>         genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
> @@ -351,9 +353,10 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
>         genl_lock_all();
>         list_for_each_entry(rc, &family->ops_list, ops_list) {
>                 if (rc == ops) {
> -                       list_del(&ops->ops_list);
> +                       list_del_rcu(&ops->ops_list);
>                         genl_unlock_all();
>                         genl_ctrl_event(CTRL_CMD_DELOPS, ops);
> +                       synchronize_rcu();
>                         return 0;
>                 }
>         }
> @@ -418,7 +421,7 @@ int genl_register_family(struct genl_family *family)
>         } else
>                 family->attrbuf = NULL;
>
> -       list_add_tail(&family->family_list, genl_family_chain(family->id));
> +       list_add_tail_rcu(&family->family_list, genl_family_chain(family->id));
>         genl_unlock_all();
>
>         genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
> @@ -498,7 +501,8 @@ int genl_unregister_family(struct genl_family *family)
>                 if (family->id != rc->id || strcmp(rc->name, family->name))
>                         continue;
>
> -               list_del(&rc->family_list);
> +               list_del_rcu(&rc->family_list);
> +               synchronize_rcu();
>                 INIT_LIST_HEAD(&family->ops_list);
>                 genl_unlock_all();
>
> @@ -692,7 +696,7 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
>                 if (nla_ops == NULL)
>                         goto nla_put_failure;
>
> -               list_for_each_entry(ops, &family->ops_list, ops_list) {
> +               list_for_each_entry_rcu(ops, &family->ops_list, ops_list) {
>                         struct nlattr *nest;
>
>                         nest = nla_nest_start(skb, idx++);
> @@ -718,7 +722,7 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
>                 if (nla_grps == NULL)
>                         goto nla_put_failure;
>
> -               list_for_each_entry(grp, &family->mcast_groups, list) {
> +               list_for_each_entry_rcu(grp, &family->mcast_groups, list) {
>                         struct nlattr *nest;
>
>                         nest = nla_nest_start(skb, idx++);
> @@ -790,9 +794,10 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>         int chains_to_skip = cb->args[0];
>         int fams_to_skip = cb->args[1];
>
> +       rcu_read_lock();
>         for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
>                 n = 0;
> -               list_for_each_entry(rt, genl_family_chain(i), family_list) {
> +               list_for_each_entry_rcu(rt, genl_family_chain(i), family_list) {
>                         if (!rt->netnsok && !net_eq(net, &init_net))
>                                 continue;
>                         if (++n < fams_to_skip)
> @@ -807,6 +812,8 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>         }
>
>  errout:
> +       rcu_read_unlock();
> +
>         cb->args[0] = i;
>         cb->args[1] = n;
>
> --
> 1.8.4.rc2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
