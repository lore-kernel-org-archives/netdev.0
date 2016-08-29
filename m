From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 07:55:37 -0400
Message-ID: <8bedb76f-44ae-9ebc-77c9-5e38416c174e@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
 <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
 <57C415EB.80806@iogearbox.net>
 <ffd6e8ca-118b-9cea-9c58-fb1820f9e735@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36680 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756705AbcH2Lzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:55:39 -0400
Received: by mail-it0-f65.google.com with SMTP id x131so6223099ite.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:55:39 -0700 (PDT)
In-Reply-To: <ffd6e8ca-118b-9cea-9c58-fb1820f9e735@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-29 07:40 AM, Jamal Hadi Salim wrote:
> On 16-08-29 07:00 AM, Daniel Borkmann wrote:

> Sorry missed that. Let me give it an attempt. I think challenge is
> going to be what length to use. For now it is ethernet; but i had
> a change which swapped VLANs that i took out.
>

something like this?

-----
/* XXX: if you are going to edit more fields beyond ethernet header
  * (example when you add IP header replacement or vlan swap)
  * then MAX_EDIT_LEN needs to change appropriately
*/
#define MAX_EDIT_LEN ETH_HLEN
static int tcf_skbmod_run(struct sk_buff *skb, const struct tc_action *a,
                           struct tcf_result *res)
{
         struct tcf_skbmod *d = to_skbmod(a);
         int action = READ_ONCE(d->tcf_action);
         int err;
         u64 flags;

         err = skb_ensure_writable(skb, ETH_HLEN);
         if (unlikely(err)) /* best policy is to drop on the floor */
                 action = TC_ACT_SHOT;

         tcf_lastuse_update(&d->tcf_tm);
         bstats_cpu_update(this_cpu_ptr(d->common.cpu_bstats), skb);
         if (unlikely(action == TC_ACT_SHOT)) {
                 qstats_drop_inc(this_cpu_ptr(d->common.cpu_qstats));
                 return action;
         }
----

cheers,
jamal
