From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net: sched: fix refcount imbalance in actions
Date: Thu, 30 Jul 2015 02:55:39 +0200
Message-ID: <55B9760B.10004@iogearbox.net>
References: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net> <CAHA+R7MVFhv1_J=0QE6zjCiVtCCKsaU=WgX6eH-u3op7GLZW5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42561 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbbG3Azs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:55:48 -0400
In-Reply-To: <CAHA+R7MVFhv1_J=0QE6zjCiVtCCKsaU=WgX6eH-u3op7GLZW5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2015 02:33 AM, Cong Wang wrote:
...
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index af427a3..bd63a39 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -53,8 +53,11 @@ int tcf_hash_release(struct tc_action *a, int bind)
>          if (p) {
>                  if (bind)
>                          p->tcfc_bindcnt--;
> -               else if (p->tcfc_bindcnt > 0)
> -                       return -EPERM;
> +               else {
> +                       if (p->tcfc_bindcnt > 0)
> +                               return -EPERM;
> +                       return ret;
> +               }

Hm, so this seems not correct: if we only ever increase tcfc_refcnt
when there's bind=1, and only ever decrease when bind=1, then we
will never free the action as we do start out from ref=1 in case
it has been added without initial binding, if I see this correctly.

>                  p->tcfc_refcnt--;
>                  if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
> @@ -214,9 +217,10 @@ int tcf_hash_check(u32 index, struct tc_action
> *a, int bind)
>          struct tcf_hashinfo *hinfo = a->ops->hinfo;
>          struct tcf_common *p = NULL;
>          if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
> -               if (bind)
> +               if (bind) {
>                          p->tcfc_bindcnt++;
> -               p->tcfc_refcnt++;
> +                       p->tcfc_refcnt++;
> +               }
>                  a->priv = p;
>                  return 1;
>          }
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index a42a3b2..2685450 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -98,6 +98,8 @@ static int tcf_mirred_init(struct net *net, struct
> nlattr *nla,
>                          return ret;
>                  ret = ACT_P_CREATED;
>          } else {
> +               if (bind)
> +                       return 0;
>                  if (!ovr) {
>                          tcf_hash_release(a, bind);
>                          return -EEXIST;
>
