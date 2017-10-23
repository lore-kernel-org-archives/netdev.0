From: Florian Westphal <fw@strlen.de>
Subject: Re: problem with rtnetlink 'reference' count
Date: Mon, 23 Oct 2017 17:32:00 +0200
Message-ID: <20171023153200.GA12422@breakpoint.cc>
References: <20171023142555.GF3165@worktop.lehotels.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
        netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43830 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751260AbdJWPcQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:32:16 -0400
Content-Disposition: inline
In-Reply-To: <20171023142555.GF3165@worktop.lehotels.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> wrote:
>   019a316992ee ("rtnetlink: add reference counting to prevent module unload while dump is in progress")
> 
> And that commit is _completely_ broken.
> 
>  1) it not in fact a refcount, so using refcount_t is silly

Your suggestion is...?

>  2) there is a distinct lack of memory barriers, so we can easily
>     observe the decrement while the msg_handler is still in progress.

I guess you mean it needs:

+	smp_mb__before_atomic();
	refcount_dec(&rtnl_msg_handlers_ref[family]);
?

However, this refcount_dec is misplaced anyway as it would need
to occur from nlcb->done() (the handler function gets stored in socket for
use by next recvmsg), so this change is indeed not helpful at all.

>  3) waiting with a schedule()/yield() loop is complete crap and subject
>     life-locks, imagine doing that rtnl_unregister_all() from a RT task.

Whats the alternative?

Only one I see is to pass THIS_MODULE to hook reg/unreg so we know what module registered the
family for purpose of module get/put but thats going to be messy.

Alternatively we can of course sleep instead of schedule() but that
doesn't appear too appealing either (albeit it is a lot less intrusive).

Any other idea?
