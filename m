From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 20:42:08 +0200
Message-ID: <467C1800.2020103@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903178F0B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36445 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759370AbXFVSmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 14:42:52 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903178F0B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>> #include <linux/module.h>
>>>@@ -40,9 +42,13 @@
>>> struct prio_sched_data
>>> {
>>> 	int bands;
>>>+#ifdef CONFIG_NET_SCH_RR
>>>+	int curband; /* for round-robin */
>>>+#endif
>>> 	struct tcf_proto *filter_list;
>>> 	u8  prio2band[TC_PRIO_MAX+1];
>>> 	struct Qdisc *queues[TCQ_PRIO_BANDS];
>>>+	u16 band2queue[TC_PRIO_MAX + 1];
>>>  
>>
>>Why is this still here? Its a 1:1 mapping.
> 
> 
> Thought about this more last night and this morning.  As far as I can
> tell, I still need this.  If the qdisc gets loaded with multiqueue
> turned on, I can just use the value of band to assign
> skb->queue_mapping.  But if the qdisc is loaded without multiqueue
> support, then I need to assign a value of zero to queue_mapping, or not
> assign it at all (it will be zero'd out before the call to ->enqueue()
> in dev_queue_xmit()).  But I'd rather not have a conditional in the
> hotpath checking if the qdisc is multiqueue; I'd rather have the array
> to match the bands so I can just do an assignment.
> 
> What do you think?


I very much doubt that it has any measurable impact. You can
also add a small inline function

void skb_set_queue_mapping(struct sk_buff *skb, unsigned int queue)
{
#ifdef CONFIG_NET_SCH_MULTIQUEUE
	skb->queue_mapping = queue;
#else
	skb->queue_mapping = 0;
#endif
}
