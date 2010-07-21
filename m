From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
Date: Wed, 21 Jul 2010 16:02:57 +0900
Message-ID: <4C469BA1.7050900@jp.fujitsu.com>
References: <4C44F12F.5090908@jp.fujitsu.com> <4C44F286.1050907@jp.fujitsu.com> <20100720115044.GD1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:34751 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762701Ab0GUHDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 03:03:09 -0400
In-Reply-To: <20100720115044.GD1995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/07/20 20:50), Neil Horman wrote:
> On Tue, Jul 20, 2010 at 09:49:10AM +0900, Koki Sanagi wrote:
>> [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
>> This patch adds tracepoint to consume_skb, dev_kfree_skb_irq and
>> skb_free_datagram_locked. Combinating with tracepoint on dev_hard_start_xmit,
>> we can check how long it takes to free transmited packets. And using it, we can
>> calculate how many packets driver had at that time. It is useful when a drop of
>> transmited packet is a problem.
>>
>>           <idle>-0     [001] 241409.218333: consume_skb: skbaddr=dd6b2fb8
>>           <idle>-0     [001] 241409.490555: dev_kfree_skb_irq: skbaddr=f5e29840
>>
>>         udp-recv-302   [001] 515031.206008: skb_free_datagram_locked: skbaddr=f5b1d900
>>
>>
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>>  include/trace/events/skb.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>>  net/core/datagram.c        |    1 +
>>  net/core/dev.c             |    2 ++
>>  net/core/skbuff.c          |    1 +
>>  4 files changed, 46 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
>> index 4b2be6d..84c9041 100644
>> --- a/include/trace/events/skb.h
>> +++ b/include/trace/events/skb.h
>> @@ -35,6 +35,48 @@ TRACE_EVENT(kfree_skb,
>>  		__entry->skbaddr, __entry->protocol, __entry->location)
>>  );
>>  
>> +DECLARE_EVENT_CLASS(free_skb,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	void *,	skbaddr	)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->skbaddr = skb;
>> +	),
>> +
>> +	TP_printk("skbaddr=%p", __entry->skbaddr)
>> +
>> +);
>> +
>> +DEFINE_EVENT(free_skb, consume_skb,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb)
>> +
>> +);
>> +
>> +DEFINE_EVENT(free_skb, dev_kfree_skb_irq,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb)
>> +
>> +);
>> +
>> +DEFINE_EVENT(free_skb, skb_free_datagram_locked,
>> +
>> +	TP_PROTO(struct sk_buff *skb),
>> +
>> +	TP_ARGS(skb)
>> +
>> +);
>> +
> 
> Why create these last two tracepoints at all?  dev_kfree_skb_irq will eventually
> pass through kfree_skb anyway, getting picked up by the tracepoint there, the
> while the latter won't (since it uses __kfree_skb instead), I think that could
> be fixed up by add a call to trace_kfree_skb there directly, saving you two
> tracepoints.
> 
> Neil
> 
I think dev_kfree_skb_irq isn't chased by trace_kfree_skb or trace_consume_skb
completely. Because net_tx_action frees skb by __kfree_skb. So it is better to
add trace_kfree_skb before it. skb_free_datagram_locked is same.

Thanks,
Koki Sanagi.
>>
> 
> 


