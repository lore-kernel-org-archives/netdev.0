From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 13:33:44 +0200
Message-ID: <48C11918.8020508@trash.net>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080905025838.GA2789@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Sep 04, 2008 at 06:54:16PM +0200, Patrick McHardy wrote:
>> adobriyan@gmail.com wrote:
>>> Make untracked conntrack per-netns. Compare conntracks with relevant
>>> untracked one.
>>>
>>> The following code you'll start laughing at this code:
>>>
>>> 	if (ct == ct->ct_net->ct.untracked)
>>> 		...
>>>
>>> let me remind you that ->ct_net is set in only one place, and never
>>> overwritten later.
>>>
>>> All of this requires some surgery with headers, otherwise horrible circular
>>> dependencies. And we lost nf_ct_is_untracked() as function, it became macro.
>> I think you could avoid this mess by using a struct nf_conntrack
>> for the untracked conntrack instead of struct nf_conn. It shouldn't
>> make any difference since its ignored anyways.
> 
> Ewww, can I?

I hope so :) A different possiblity suggest by Pablo some time ago
would be to mark untracked packets in skb->nfctinfo and not
attach a conntrack at all.

> Regardless of netns, switching to
> 
> 	struct nf_conntrack nf_conntrack_untracked;
> 
> means we must be absolutely sure that every place which uses, say,
> ct->status won't get untracked conntrack.
> 
> For example, does setting IPS_NAT_DONE_MASK and IPS_CONFIRMED_BIT on
> untracked conntracked really necessary?

I don't think so, untracked conntracks are skipped early in the NAT
table.

> In conntrack_mt_v0() "ct->status" can be used even for untracked connection,
> is this right?

It looks that way, but its not right. I think it should return false
for every match except on (untracked) state.
