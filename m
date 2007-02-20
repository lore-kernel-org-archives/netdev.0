From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Tue, 20 Feb 2007 09:23:41 +0100
Message-ID: <20070220082341.GB981@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216081051.GC1599@ff.dom.local> <45D569E9.7010407@candelatech.com> <20070216090425.GD1599@ff.dom.local> <20070216121245.GE1599@ff.dom.local> <45D5D681.5060104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>, Ingo Molnar <mingo@elte.hu>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:56514 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965217AbXBTIUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 03:20:18 -0500
Content-Disposition: inline
In-Reply-To: <45D5D681.5060104@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 08:06:25AM -0800, Ben Greear wrote:
...
> Well, I had lockdep and all of the locking debugging I could find 
> enabled, but
> it did not catch this problem..I had to use sysctl -t and manually dig 
> through the backtraces
> to find the deadlock....
> 
> It may be that lockdep could be enhanced to catch this sort of thing....

I think you are really good at traceing very interesting
(subtle) problems.

I guess the scenario is like this:

1) some process takes some lock (e.g. RTNL), 
2) kthread runs a work function, which tries to get the
   same lock,
3) the process with the lock calls flush_scheduled_work,
4) the flush_cpu_workqueue waits for kthread to finish.

So, the process #1 (with the lock) waits for the end 
of the process #2, which waits for the lock held by
process #1.

Of course it's a lockup - similar to circular dependency
but not the same: there is only one lock. I don't think
lockdep could be blamed here - if it's not a lock it
can't know the reason of process' #1 waiting.

In my opinion the solution should be looked for in the
workqueue code. My idea is: maybe there should be used
some additional lock taken by kthread before running
the workqueue and by a process calling the flush. Then
lockdep shouldn't have any problems with this dependency.
This lock could be #ifdef DEBUG_LOCK... so only where
it could be analyzed. Of course there may be some simpler
solution of this otherwise hard to track problem.

I CC this message to Ingo Molnar and hope he could find
some time to think about it.

Regards,
Jarek P.
