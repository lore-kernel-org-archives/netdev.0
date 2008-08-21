From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 05:06:19 -0700 (PDT)
Message-ID: <20080821.050619.15769132.davem@davemloft.net>
References: <20080821112055.GB4079@ff.dom.local>
	<20080821112609.GA5052@gondor.apana.org.au>
	<20080821115521.GC4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750909AbYHUMGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:06:20 -0400
In-Reply-To: <20080821115521.GC4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Aug 2008 11:55:22 +0000

> Sure, here is a scenario:
> 
> cpu1					cpu2
> rtnl_lock()
> qdisc_graft()
> // parent != NULL
> ->cops-graft()
> notify_and_destroy()			qdisc_run()
> 					spin_lock(root_lock)
> qdisc_destroy(old)			dequeue_skb()
> 					tbf_dequeue()
> 					qdisc_tree_decrease_qlen()	
> 					qdisc_lookup()
> //deleting from qdisc_sleeping->list	//walking qdisc_sleeping->list
> //under rtnl_lock() only		//under qdisc root_lock only
> list_del(qdisc->list)			list_for_each_entry(txq_root)

Grrr... :-)

Note that this only happens when my arch nemesis, ->requeue(), fails.
Same applies to the netem case, and hfsc's "peek".

All other qdisc_tree_decrease_qlen() users hold RTNL.

Really, it proves ->requeue() should die, and be replaced with "peek"
and "unlink" methods.

