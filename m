From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2] net: core: introduce mini_Qdisc and
 eliminate usage of tp->q for clsact fastpath
Date: Thu, 26 Oct 2017 18:22:14 +0200
Message-ID: <20171026162214.GI1928@nanopsycho.orion>
References: <20171026094103.10164-1-jiri@resnulli.us>
 <20171026155454.nkh5ykb2bw35wpnb@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        willemb@google.com, john.fastabend@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:55750 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932409AbdJZQWR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 12:22:17 -0400
Received: by mail-wr0-f196.google.com with SMTP id l8so3715666wre.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 09:22:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171026155454.nkh5ykb2bw35wpnb@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 26, 2017 at 05:54:56PM CEST, alexei.starovoitov@gmail.com wrote:
>On Thu, Oct 26, 2017 at 11:41:03AM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> In sch_handle_egress and sch_handle_ingress tp->q is used only in order
>> to update stats. So stats and filter list are the only things that are
>> needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
>> struct to hold those items. This removes need for tp->q usage without
>> added overhead.
>
>that is false claim. The patch adds run-time overhead instead.
>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v1->v2:
>> - Use dev instead of skb->dev in sch_handle_egress as pointed out by Daniel
>> - Fixed synchronize_rcu_bh() in mini_qdisc_disable and commented
>...
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 24ac908..44ea1c3 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3274,14 +3274,16 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>>  static struct sk_buff *
>>  sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>>  {
>> -	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> +	struct mini_Qdisc *miniq = rcu_dereference_bh(dev->miniq_egress);
>>  	struct tcf_result cl_res;
>> +	struct tcf_proto *cl;
>>  
>> -	if (!cl)
>> +	if (!miniq)
>>  		return skb;
>> +	cl = rcu_dereference_bh(miniq->filter_list);
>
>Just like Daniel pointed out in the earlier version of the patch
>it adds another rcu dereference to critical path of execution
>for every packet...
>
>> @@ -4189,16 +4191,19 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>>  		   struct net_device *orig_dev)
>>  {
>>  #ifdef CONFIG_NET_CLS_ACT
>> -	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
>> +	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_ingress);
>>  	struct tcf_result cl_res;
>> +	struct tcf_proto *cl;
>>  
>>  	/* If there's at least one ingress present somewhere (so
>>  	 * we get here via enabled static key), remaining devices
>>  	 * that are not configured with an ingress qdisc will bail
>>  	 * out here.
>>  	 */
>> -	if (!cl)
>> +	if (!miniq)
>>  		return skb;
>> +	cl = rcu_dereference_bh(miniq->filter_list);
>
>... both ingress and egress paths.
>There gotta be very strong reasons to penalize all users for this
>and I don't see them in commit log.

Okay, the reason is that in order to make tcf_proto instances
independent on qdisc instances so they could be shared amond multiple
qdiscs, I have to remove tp->q.

Since tp->q is there only needed to update stats, I introduced
mini_Qdisc just to hold those stats pointers and eliminate need to use
tp->q at all.

I understand that the 2 rcu_dereferences are adding additional overhead
(the desctiption is wrong, I admint), but I do not see another sane way
to do this. Do you see it?

I think that it might be possible to have miniq->filter_list as a
non-rcu pointer. However that would require allocate a new miniq and
replace every time head of the list changes. That would require even
more ugliness in the slow path. Is there a balance in overhead in the
fast path and ugliness in the slowpath?
