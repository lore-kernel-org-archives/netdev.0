From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Mon, 05 Feb 2007 18:44:08 -0800 (PST)
Message-ID: <20070205.184408.34759062.davem@davemloft.net>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
	<20070205.181026.122835715.davem@davemloft.net>
	<20070205181810.bbfbf42c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, dipankar@in.ibm.com,
	paulmck@us.ibm.com, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965463AbXBFCoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:44:10 -0500
In-Reply-To: <20070205181810.bbfbf42c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 5 Feb 2007 18:18:10 -0800

> I think the finger was pointed at preemptible rcu, in -mm.  iirc,
> the net stats code is assuming that rcu_read_lock() disables
> preemption as a side-effect, which rcu-preempt makes no-longer-true.
>
> Not sure what to do there.  Perhaps add a new
> rcu_read_lock_with_preempt_disable() thing which will dtrt with
> either config.

Hmmm, really?

Let's audit NF_CT_STAT_INC() usage to make sure :-)

net/netfilter/nf_conntrack_core.c:

	destroy_conntrack: Inside write_{lock,unlock}_bh().
	death_by_timeout: Ditto.
	__nf_conntrack_find: Inside read_{lock,unlock}_bh() via callers.
	__nf_conntrack_confirm: Inside write_{lock,unlock}_bh().
	early_drop: This one looks like it could be unprotected.
	init_conntrack: Inside of write_{lock,unlock}_bh().
	nf_conntrack_in: Packet receive path, softints disabled.

net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c:

	ipv6_prepare: Packet input path, BH's disabled.

net/netfilter/nf_conntrack_expect.c:

	nf_ct_unlink_expect: Inside if write_{lock,unlock}_bh() via callers.
	nf_conntrack_expect_insert: Ditto.

So that leaves early_drop() as the only suspicious case that might
not run inside of disabled BH's.

And in fact that case is a bug regardless of the preemptible rcu
changes because this allows the counter bump to be corrupted by
software interrupt context.

And OK, I see in the lockdep trace that it's the packet transmit
path...   In fact, this assumption of preemption being disabled
by the netfilter top-level dispatch is very deep.

For example, several bits besides the NF_CT_STATIC_INC of
nf_conntrack_in() (where the lockdep trigger backtrace hits) assume
that preemption is enabled by that rcu_read_lock() in the top-level
netfilter dispatch.

The __nf_ct_l{3,4}proto_find() calls there are just two examples.

I imagine this assumption is quite pervasive throughout the
netfilter code, so just patching up this NF_CT_STAT_INC() case
will merely shut up lockdep and paper over the issue.

I bet this rcu_read_lock()-implies-preempt_disable() assumption has
spread into other areas of the tree as well.
