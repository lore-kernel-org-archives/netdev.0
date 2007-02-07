From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Wed, 07 Feb 2007 07:43:09 +0100
Message-ID: <45C974FD.5070404@trash.net>
References: <20070206123401.GA8052@elte.hu> <20070206.114325.98862918.davem@davemloft.net> <20070206210250.GB25430@elte.hu> <20070206.132357.58458400.davem@davemloft.net> <20070206215806.GA5109@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, dipankar@in.ibm.com, paulmck@us.ibm.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965539AbXBGGnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 01:43:12 -0500
In-Reply-To: <20070206215806.GA5109@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * David Miller <davem@davemloft.net> wrote:
> 
>>net/netfilter/nf_conntrack_core.c, calls:
>>
>>	l4proto = __nf_ct_l4proto_find((u_int16_t)pf, protonum);
>>
>>whichs assumes that preemption is disabled.

Yes, that is certainly broken.

> you are right - i mistakenly read that mail only up to the point where 
> you point out the (slightly) buggy NF_CT_STATIC_INC use and missed your 
> final point about other coding having implicit preempt_disable() 
> assumptions.
> 
> I've looked at __nf_ct_l4proto_find() and it's not obvious to me what 
> the hidden preempt_disable() assumption is. Its main use seems to be of 
> nf_ct_protos[] array, which is protected by nf_conntrack_lock. I'm 
> wondering whether what you say suggests that it's safe to call 
> __nf_ct_l4proto_find() without the nf_conntrack_lock locked (as read or 
> as write), and if it's safe, how it protects against simultaneous 
> modifications to the nf_ct_protos[] array. 
> 
> Ahh ... unregister does a synchronize_net(), right? That means that 
> removal of the pointer only happens if all CPUs have gone through a 
> quiescent state.
> 
> this means that this particular use could be fixed by converting the 
> preempt_disable()/enable() pair in nf_ct_l4proto_find_get() to 
> rcu_read_lock()/unlock(), correct? 

That is another bug (all uses of preempt_disable in netfilter
actually), but calling __nf_ct_l[34]proto_find without
rcu_read_lock is broken as well.

> Furthermore, every user of 
> synchronize_net() [and synchronize_rcu() in general] needs to be 
> reviewed.

I'll take care of netfilter.
