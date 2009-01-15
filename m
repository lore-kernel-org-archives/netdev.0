From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 09:01:20 +0000
Message-ID: <20090115090120.GE4190@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <200901141505.46929.denys@visp.net.lb> <20090114131257.GC6117@ff.dom.local> <1231938929.14825.6.camel@laptop> <20090114132603.GD6117@ff.dom.local> <1231939946.14825.9.camel@laptop> <20090114141311.GA6643@ff.dom.local> <1231943283.14825.14.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:46311 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbZAOJB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:01:58 -0500
Content-Disposition: inline
In-Reply-To: <1231943283.14825.14.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 03:28:03PM +0100, Peter Zijlstra wrote:
...
> Right, found all that...
> 
> Can't spot anything obviously wrong though.. hrtimer_start*() does
> remove_hrtimer() which checks STATE_ENQUEUED, STATE_PENDING and pulls it
> off the relevant list before it continues the enqueue.
> 
> However a loop in enqueue_hrtimer() would suggest a corrupted RB-tree,
> but I cannot find an RB-op that doesn't hold base-lock.
> 

I've revisited it yesterday, and if I don't miss something, there is
possible a scenario similar to this:

cpu1:				cpu2:

run_hrtimer_pending
spin_unlock
restart = fn(timer)

				hrtimer_start
				enqueue_hrtimer

				hrtimer_start
				remove_hrtimer
				(the HRTIMER_STATE_CALLBACK is removed)

				switch_hrtimer_base
spin_lock
(not this hrtimer's anymore)
__remove_hrtimer
list_add_tail			enqueue_hrtimer


Jarek P.
