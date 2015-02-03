From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing actions' stats.
Date: Tue, 3 Feb 2015 09:39:39 -0800
Message-ID: <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
References: <20150203141059.GA25454@zenon.in.qult.net>
	<20150203173251.GB6246@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:44318 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbBCRjk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:39:40 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so28425358igk.1
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 09:39:39 -0800 (PST)
In-Reply-To: <20150203173251.GB6246@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2015 at 9:32 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> In tcf_exts_dump_stats(), ensure that exts->actions is not empty befo=
re
> accessing the first element of that list and calling tcf_action_copy_=
stats()
> on it.  This fixes some random segvs when adding filters of type "bas=
ic" with
> no particular action.
>
> This also fixes the dumping of those "no-action" filters, which more =
often
> than not made calls to tcf_action_copy_stats() fail and consequently =
netlink
> attributes added by the caller to be removed by a call to nla_nest_ca=
ncel().
>
> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicat=
ions.fr>
> ---
>  net/sched/cls_api.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index aad6a67..30e6967 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -602,9 +602,12 @@ EXPORT_SYMBOL(tcf_exts_dump);
>  int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
>  {
>  #ifdef CONFIG_NET_CLS_ACT
> -       struct tc_action *a =3D tcf_exts_first_act(exts);
> -       if (tcf_action_copy_stats(skb, a, 1) < 0)
> -               return -1;
> +       struct tc_action *a;
> +       if (!list_empty(&exts->actions)) {
> +               a =3D tcf_exts_first_act(exts);
> +               if (tcf_action_copy_stats(skb, a, 1) < 0)
> +                       return -1;
> +       }

Hmm, or just fix tcf_exts_first_act()? Let it call list_first_entry_or_=
null().

Also, please add Fixes: tag.

=46ixes: commit 33be627159913b094bb578e83e9a7fdc66c10208
