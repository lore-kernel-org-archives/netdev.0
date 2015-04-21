From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH] tc filter not show last u32 filter
Date: Tue, 21 Apr 2015 21:17:42 +0300
Message-ID: <55369446.10806@cogentembedded.com>
References: <55368E7F.4030005@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com
To: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:33863 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbbDUSRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 14:17:46 -0400
Received: by lbcga7 with SMTP id ga7so162388788lbc.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 11:17:45 -0700 (PDT)
In-Reply-To: <55368E7F.4030005@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/21/2015 08:53 PM, Vitaly E. Lavrov wrote:

> "tc filter show" does not show last U32 filter on 32-bit systems (tested on x86).

> Additional condition: filter does not have action and CONFIG_NET_CLS_ACT=y

> Example: tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip
> dst 10.200.2.2 flowid 1:20

> Function tcf_action_copy_stats() returns an error because the (struct
> tc_action *)a->priv is NULL (for 32bit systems).

> The sequence of calls:

> u32_dump()
>    cls_u32.c:1009 if (tcf_exts_dump_stats(skb, &n->exts) < 0) goto
> nla_put_failure;

>    tcf_exts_dump_stats()
>       cls_api.c:606  if (tcf_action_copy_stats(skb, a, 1) < 0) return -1;
>
>       tcf_action_copy_stats()
>          act_api.c:604 struct tcf_common *p = a->priv;
>          act_api.c:606 if (p == NULL) goto errout; // return -1;

> One of variants correcting this error is a verify the existence of action
> before calling tcf_action_copy_stats().

> Patch for kernel 3.18.10

    You need to send patches against the latest kernel. Look for DaveM's 
'net.git' repo on git.kernel.org.

> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index aad6a67..8e7ad61 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -602,9 +602,11 @@ EXPORT_SYMBOL(tcf_exts_dump);
>   int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
>   {
>   #ifdef CONFIG_NET_CLS_ACT
> -       struct tc_action *a = tcf_exts_first_act(exts);
> -       if (tcf_action_copy_stats(skb, a, 1) < 0)
> -               return -1;
> +       if(tcf_exts_is_available(exts)) {

    Please run your patches thru scripts/chackpatch.pl; space is needed after 
*if*.

> +               struct tc_action *a = tcf_exts_first_act(exts);

    Empty line needed here.

WBR, Sergei
