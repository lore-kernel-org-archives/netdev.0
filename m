From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 6 Feb 2007 10:21:32 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0702061001150.8163@tux.rsn.bth.se>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
 <20070205.181026.122835715.davem@davemloft.net> <20070205181810.bbfbf42c.akpm@linux-foundation.org>
 <20070205.184408.34759062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	dipankar@in.ibm.com, paulmck@us.ibm.com, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront2.netatonce.net ([217.10.96.66]:47914 "EHLO
	mailfront2.citynet.nu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbXBFJxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 04:53:44 -0500
In-Reply-To: <20070205.184408.34759062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Feb 2007, David Miller wrote:

> Let's audit NF_CT_STAT_INC() usage to make sure :-)
>
> net/netfilter/nf_conntrack_core.c:
>
> 	destroy_conntrack: Inside write_{lock,unlock}_bh().
> 	death_by_timeout: Ditto.
> 	__nf_conntrack_find: Inside read_{lock,unlock}_bh() via callers.
> 	__nf_conntrack_confirm: Inside write_{lock,unlock}_bh().
> 	early_drop: This one looks like it could be unprotected.
> 	init_conntrack: Inside of write_{lock,unlock}_bh().
> 	nf_conntrack_in: Packet receive path, softints disabled.

early_drop() is called from __nf_conntrack_alloc() which is called from
init_conntrack() and these days from ctnetlink_create_conntrack() as well.

init_conntrack() is called from nf_conntrack_in() which is packet receive
path. But ctnetlink_create_conntrack() is unprotected.

> So that leaves early_drop() as the only suspicious case that might
> not run inside of disabled BH's.

Looks that way.

> And in fact that case is a bug regardless of the preemptible rcu
> changes because this allows the counter bump to be corrupted by
> software interrupt context.

Yes, it's a bug, although not a very critical one.

> And OK, I see in the lockdep trace that it's the packet transmit
> path...   In fact, this assumption of preemption being disabled
> by the netfilter top-level dispatch is very deep.

Yes it is, and I have some future changes that wants to take this
assumption even further in order to possibly avoid the per packet
conntrack refcounts as far as possible, but this might not be possible and
there's still a long way to go before we are there. Currently it's just a
wet dream of mine.

> For example, several bits besides the NF_CT_STATIC_INC of
> nf_conntrack_in() (where the lockdep trigger backtrace hits) assume
> that preemption is enabled by that rcu_read_lock() in the top-level
> netfilter dispatch.

s/enabled/disabled/

> The __nf_ct_l{3,4}proto_find() calls there are just two examples.
>
> I imagine this assumption is quite pervasive throughout the
> netfilter code, so just patching up this NF_CT_STAT_INC() case
> will merely shut up lockdep and paper over the issue.
>
> I bet this rcu_read_lock()-implies-preempt_disable() assumption has
> spread into other areas of the tree as well.

I think so too.

/Martin
