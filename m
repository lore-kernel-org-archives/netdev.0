From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread	workqueue
 attached to the current task's cgroup
Date: Thu, 27 May 2010 23:20:22 +0200
Message-ID: <4BFEE216.2070807@kernel.org>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:55059 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754875Ab0E0VVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 17:21:33 -0400
In-Reply-To: <20100527173207.GA21880@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Michael.

On 05/27/2010 07:32 PM, Michael S. Tsirkin wrote:
> Well, this is why I proposed adding a new API for creating
> workqueue within workqueue.c, rather than exposing the task
> and attaching it to cgroups in our driver: so that workqueue
> maintainers can fix the implementation if it ever changes.
> 
> And after all, it's an internal API, we can always change
> it later if we need.
...
> Well, yes but we are using APIs like flush_work etc. These are very
> handy.  It seems much easier than rolling our own queue on top of kthread.

The thing is that this kind of one-off usage becomes problemetic when
you're trying to change the implementation detail.  All current
workqueue users don't care which thread they run on and they shouldn't
as each work owns the context only for the duration the work is
executing.  If this sort of fundamental guidelines are followed, the
implementation can be improved in pretty much transparent way but when
you start depending on specific implementation details, things become
messy pretty quickly.

If this type of usage were more common, adding proper way to account
work usage according to cgroups would make sense but that's not the
case here and I removed the only exception case recently while trying
to implement cmwq and if this is added.  So, this would be the only
one which makes such extra assumptions in the whole kernel.  One way
or the other, workqueue needs to be improved and I don't really think
adding the single exception at this point is a good idea.

The thing I realized after stop_machine conversion was that there was
no reason to use workqueue there at all.  There already are more than
enough not-too-difficult synchronization constructs and if you're
using a thread for dedicated purposes, code complexity isn't that
different either way.  Plus, it would also be clearer that dedicated
threads are required there for what reason.  So, I strongly suggest
using a kthread.  If there are issues which are noticeably difficult
to solve with kthread, we can definitely talk about that and think
about things again.

Thank you.

-- 
tejun
