From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 6 Feb 2007 22:58:06 +0100
Message-ID: <20070206215806.GA5109@elte.hu>
References: <20070206123401.GA8052@elte.hu> <20070206.114325.98862918.davem@davemloft.net> <20070206210250.GB25430@elte.hu> <20070206.132357.58458400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35774 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965470AbXBFV6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:58:45 -0500
Content-Disposition: inline
In-Reply-To: <20070206.132357.58458400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 6 Feb 2007 22:02:51 +0100
> 
> > So i'm wondering what other assumptions there are (or can be) about 
> > rcu_read_lock() also being a preempt-off point. Thanks!
> 
> I showed the examples in my detailed analysis yesterday.
> 
> Beause I love hearing myself say the same thing over and over so much 
> I'll restate it for you.
> 
> net/netfilter/nf_conntrack_core.c, calls:
> 
> 	l4proto = __nf_ct_l4proto_find((u_int16_t)pf, protonum);
> 
> whichs assumes that preemption is disabled.

you are right - i mistakenly read that mail only up to the point where 
you point out the (slightly) buggy NF_CT_STATIC_INC use and missed your 
final point about other coding having implicit preempt_disable() 
assumptions.

I've looked at __nf_ct_l4proto_find() and it's not obvious to me what 
the hidden preempt_disable() assumption is. Its main use seems to be of 
nf_ct_protos[] array, which is protected by nf_conntrack_lock. I'm 
wondering whether what you say suggests that it's safe to call 
__nf_ct_l4proto_find() without the nf_conntrack_lock locked (as read or 
as write), and if it's safe, how it protects against simultaneous 
modifications to the nf_ct_protos[] array. 

Ahh ... unregister does a synchronize_net(), right? That means that 
removal of the pointer only happens if all CPUs have gone through a 
quiescent state.

this means that this particular use could be fixed by converting the 
preempt_disable()/enable() pair in nf_ct_l4proto_find_get() to 
rcu_read_lock()/unlock(), correct? Furthermore, every user of 
synchronize_net() [and synchronize_rcu() in general] needs to be 
reviewed.

	Ingo
