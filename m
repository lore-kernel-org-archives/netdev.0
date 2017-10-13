From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 06/34] net: core: use dev->ingress_queue instead
 of tp->q
Date: Fri, 13 Oct 2017 08:30:19 +0200
Message-ID: <20171013063019.GC1952@nanopsycho.orion>
References: <20171012171823.1431-1-jiri@resnulli.us>
 <20171012171823.1431-7-jiri@resnulli.us>
 <59DFE287.2040400@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34825 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751414AbdJMGaV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 02:30:21 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so5092175wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 23:30:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59DFE287.2040400@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 12, 2017 at 11:45:43PM CEST, daniel@iogearbox.net wrote:
>On 10/12/2017 07:17 PM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> In sch_handle_egress and sch_handle_ingress, don't use tp->q and use
>> dev->ingress_queue which stores the same pointer instead.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>   net/core/dev.c | 21 +++++++++++++++------
>>   1 file changed, 15 insertions(+), 6 deletions(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index fcddccb..cb9e5e5 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3273,14 +3273,18 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>>   static struct sk_buff *
>>   sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>>   {
>> +	struct netdev_queue *netdev_queue =
>> +				rcu_dereference_bh(dev->ingress_queue);
>>   	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>>   	struct tcf_result cl_res;
>> +	struct Qdisc *q;
>> 
>> -	if (!cl)
>> +	if (!cl || !netdev_queue)
>>   		return skb;
>> +	q = netdev_queue->qdisc;
>
>NAK, no additional overhead in the software fast-path of
>sch_handle_{ingress,egress}() like this. There are users out there
>that use tc in software only, so performance is critical here.

Okay, how else do you suggest I can avoid the need to use tp->q?
I was thinking about storing q directly to net_device, which would safe
one dereference, resulting in the same amount as current cl->q.

Thanks.
