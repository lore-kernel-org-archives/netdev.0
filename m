From: Andrew Collins <acollins@cradlepoint.com>
Subject: Re: fq_codel and skb->hash
Date: Wed, 18 Jan 2017 13:21:26 -0700
Message-ID: <c8b93aa5-7e34-d6b0-aefc-6863e75402e0@cradlepoint.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
 <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
 <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S34ugaCqDtE=-4533mNsPgt_T0oHC1CN0-vx_uga+ihLdQ@mail.gmail.com>
 <1484666094.13165.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0102.outbound.protection.outlook.com ([104.47.42.102]:34997
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753547AbdARWAm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 17:00:42 -0500
In-Reply-To: <1484666094.13165.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 08:14 AM, Eric Dumazet wrote:
> Right, but that might add overhead in cases we do not need skb->hash
> after IPsec . I've heard IPsec is already quite slow :/

I've been running with the following change locally with good results:

--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -57,7 +57,6 @@ struct fq_codel_sched_data {
         struct fq_codel_flow *flows;    /* Flows table [flows_cnt] */
         u32             *backlogs;      /* backlog table [flows_cnt] */
         u32             flows_cnt;      /* number of flows */
-       u32             perturbation;   /* hash perturbation */
         u32             quantum;        /* psched_mtu(qdisc_dev(sch)); */
         u32             drop_batch_size;
         u32             memory_limit;
@@ -75,9 +74,7 @@ struct fq_codel_sched_data {
  static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
                                   struct sk_buff *skb)
  {
-       u32 hash = skb_get_hash_perturb(skb, q->perturbation);
-
-       return reciprocal_scale(hash, q->flows_cnt);
+       return reciprocal_scale(skb_get_hash(skb), q->flows_cnt);
  }

  static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
@@ -482,7 +479,6 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
         q->memory_limit = 32 << 20; /* 32 MBytes */
         q->drop_batch_size = 64;
         q->quantum = psched_mtu(qdisc_dev(sch));
-       q->perturbation = prandom_u32();
         INIT_LIST_HEAD(&q->new_flows);
         INIT_LIST_HEAD(&q->old_flows);
         codel_params_init(&q->cparams);

Any interest in me spinning a real patch for this?  I agree that it'd be better
if we were guaranteed to get a pre-encryption flow hash for any IPsec traffic,
but in my particular case I don't care, as I control the HW and can make it give
me a hash. :)

Thanks,
Andrew Collins
