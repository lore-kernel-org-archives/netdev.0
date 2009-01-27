From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 27 Jan 2009 15:53:16 -0800
Message-ID: <adawscgwbkj.fsf@cisco.com>
References: <497EF9AC.70104@poczta.onet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org
To: "aluno3\@poczta.onet.pl" <aluno3@poczta.onet.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:26671 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbZA0XxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 18:53:19 -0500
In-Reply-To: <497EF9AC.70104@poczta.onet.pl> (aluno3@poczta.onet.pl's message
	of "Tue, 27 Jan 2009 13:10:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting... looks like an unfortunate interaction with unclear
locking rules.  See below for full explanation.

BTW, what workload are you running to hit this?

I assume you have CONFIG_HIGHMEM set?

 > WARNING: at kernel/softirq.c:136 local_bh_enable+0x9b/0xa0()

I assume this is

	WARN_ON_ONCE(in_irq() || irqs_disabled());

The interesting parts of the stack trace seem to be (reversing the order
so the story makes sense):

 [<e8e3f815>] nes_netdev_start_xmit+0x815/0x8a0 [iw_nes]

nes_netdev_start_xmit() calls skb_linearize() for nonlinear skbs it
can't handle, which calls __pskb_pull_tail():

 [<c048982c>] __pskb_pull_tail+0x5c/0x2e0

__pskb_pull_tail() calls skb_copy_bits():

 [<c0489c05>] skb_copy_bits+0x155/0x290

At least in some cases, skb_copy_bits() calls kmap_skb_frag() and more
to the point kunmap_skb_frag(), which looks like:

	static inline void kunmap_skb_frag(void *vaddr)
	{
		kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
	#ifdef CONFIG_HIGHMEM
		local_bh_enable();
	#endif
	}

which leads to:

 [<c012a79b>] local_bh_enable+0x9b/0xa0

which hits the irqs_disabled() warning because iw_nes is using LLTX, and
nes_netdev_start_xmit() does:

	local_irq_save(flags);
	if (!spin_trylock(&nesnic->sq_lock)) {

at the very beginning.

The best solution is probably for iw_nes to stop using LLTX and use the
main netdev lock... but actually I still don't see how it's safe for a
net driver to call skb_linearize() from its transmit routine, since
there's a chance that that will unconditionally enable BHs?

 - R.
