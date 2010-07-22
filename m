From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
Date: Thu, 22 Jul 2010 10:57:21 -0400
Message-ID: <20100722145721.GA20182@hmsreliant.think-freely.org>
References: <4C44F12F.5090908@jp.fujitsu.com>
 <4C44F286.1050907@jp.fujitsu.com>
 <20100720115044.GD1995@hmsreliant.think-freely.org>
 <4C469BA1.7050900@jp.fujitsu.com>
 <20100721105645.GA21259@hmsreliant.think-freely.org>
 <4C4803B3.1020808@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39953 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab0GVPAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 11:00:10 -0400
Content-Disposition: inline
In-Reply-To: <4C4803B3.1020808@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 05:39:15PM +0900, Koki Sanagi wrote:
> (2010/07/21 19:56), Neil Horman wrote:
> > On Wed, Jul 21, 2010 at 04:02:57PM +0900, Koki Sanagi wrote:
> >> (2010/07/20 20:50), Neil Horman wrote:
> >>> On Tue, Jul 20, 2010 at 09:49:10AM +0900, Koki Sanagi wrote:
> >>>> [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
> >>>> This patch adds tracepoint to consume_skb, dev_kfree_skb_irq and
> >>>> skb_free_datagram_locked. Combinating with tracepoint on dev_hard_start_xmit,
> >>>> we can check how long it takes to free transmited packets. And using it, we can
> >>>> calculate how many packets driver had at that time. It is useful when a drop of
> >>>> transmited packet is a problem.
> >>>>
> >>>>           <idle>-0     [001] 241409.218333: consume_skb: skbaddr=dd6b2fb8
> >>>>           <idle>-0     [001] 241409.490555: dev_kfree_skb_irq: skbaddr=f5e29840
> >>>>
> >>>>         udp-recv-302   [001] 515031.206008: skb_free_datagram_locked: skbaddr=f5b1d900
> >>>>
> >>>>
> >>>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> >>>> ---
> >>>>  include/trace/events/skb.h |   42 ++++++++++++++++++++++++++++++++++++++++++
> >>>>  net/core/datagram.c        |    1 +
> >>>>  net/core/dev.c             |    2 ++
> >>>>  net/core/skbuff.c          |    1 +
> >>>>  4 files changed, 46 insertions(+), 0 deletions(-)
> >>>>
> >>>> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> >>>> index 4b2be6d..84c9041 100644
> >>>> --- a/include/trace/events/skb.h
> >>>> +++ b/include/trace/events/skb.h
> >>>> @@ -35,6 +35,48 @@ TRACE_EVENT(kfree_skb,
> >>>>  		__entry->skbaddr, __entry->protocol, __entry->location)
> >>>>  );
> >>>>  
> >>>> +DECLARE_EVENT_CLASS(free_skb,
> >>>> +
> >>>> +	TP_PROTO(struct sk_buff *skb),
> >>>> +
> >>>> +	TP_ARGS(skb),
> >>>> +
> >>>> +	TP_STRUCT__entry(
> >>>> +		__field(	void *,	skbaddr	)
> >>>> +	),
> >>>> +
> >>>> +	TP_fast_assign(
> >>>> +		__entry->skbaddr = skb;
> >>>> +	),
> >>>> +
> >>>> +	TP_printk("skbaddr=%p", __entry->skbaddr)
> >>>> +
> >>>> +);
> >>>> +
> >>>> +DEFINE_EVENT(free_skb, consume_skb,
> >>>> +
> >>>> +	TP_PROTO(struct sk_buff *skb),
> >>>> +
> >>>> +	TP_ARGS(skb)
> >>>> +
> >>>> +);
> >>>> +
> >>>> +DEFINE_EVENT(free_skb, dev_kfree_skb_irq,
> >>>> +
> >>>> +	TP_PROTO(struct sk_buff *skb),
> >>>> +
> >>>> +	TP_ARGS(skb)
> >>>> +
> >>>> +);
> >>>> +
> >>>> +DEFINE_EVENT(free_skb, skb_free_datagram_locked,
> >>>> +
> >>>> +	TP_PROTO(struct sk_buff *skb),
> >>>> +
> >>>> +	TP_ARGS(skb)
> >>>> +
> >>>> +);
> >>>> +
> >>>
> >>> Why create these last two tracepoints at all?  dev_kfree_skb_irq will eventually
> >>> pass through kfree_skb anyway, getting picked up by the tracepoint there, the
> >>> while the latter won't (since it uses __kfree_skb instead), I think that could
> >>> be fixed up by add a call to trace_kfree_skb there directly, saving you two
> >>> tracepoints.
> >>>
> >>> Neil
> >>>
> >> I think dev_kfree_skb_irq isn't chased by trace_kfree_skb or trace_consume_skb
> >> completely. Because net_tx_action frees skb by __kfree_skb. So it is better to
> >> add trace_kfree_skb before it. skb_free_datagram_locked is same.
> >>
> > It isn't, you're right, but that was the point I made above.  Those missed areas
> > could be easily handled by adding calls to trace_kfree_skb which already exists,
> > to the missed areas.  Then you don't need to create those new tracepoints.  The
> > way your doing this, if someone wants to trace all skb frees in debugfs, they
> > would have to enable three tracepoints, not just one.  Not that thats the point
> > of your patch, but its something to consider, and it simplifies your code.
> > Neil
> > 
> 
> O.K. I've re-made a patch to use trace_kfree_skb instead of
> trace_dev_kfree_skb_irq and trace_skb_free_datagram_locked.
> But I've got a problem.
> I should use not __builtin_return_address, but macro or function which returns
> current address. But I don't know any macro like that. Do you know any solution ?
> 
Since the trace call is the first thing in the function, why not just pass in
skb_free_datagram_locked as the pointer.  That should work out properly
Neil

> 
