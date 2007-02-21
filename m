From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 03/29] mm: allow PF_MEMALLOC from softirq context
Date: Wed, 21 Feb 2007 16:53:37 +0100
Message-ID: <1172073217.3531.200.camel@laptopd505.fenrus.org>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144841.823705000@taijtu.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40235 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161296AbXBUPxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 10:53:48 -0500
In-Reply-To: <20070221144841.823705000@taijtu.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Index: linux-2.6-git/kernel/softirq.c
> ===================================================================
> --- linux-2.6-git.orig/kernel/softirq.c	2006-12-14 10:02:18.000000000 +0100
> +++ linux-2.6-git/kernel/softirq.c	2006-12-14 10:02:52.000000000 +0100
> @@ -209,6 +209,8 @@ asmlinkage void __do_softirq(void)
>  	__u32 pending;
>  	int max_restart = MAX_SOFTIRQ_RESTART;
>  	int cpu;
> +	unsigned long pflags = current->flags;
> +	current->flags &= ~PF_MEMALLOC;
>  
>  	pending = local_softirq_pending();
>  	account_system_vtime(current);
> @@ -247,6 +249,7 @@ restart:
>  
>  	account_system_vtime(current);
>  	_local_bh_enable();
> +	current->flags = pflags;

this wipes out all the flags in one go.... evil.
What if something just selected this process for OOM killing? you nuke
that flag here again. Would be nicer if only the PF_MEMALLOC bit got
inherited in the restore path..




