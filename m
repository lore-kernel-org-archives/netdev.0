From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Fri, 30 Jul 2010 16:19:01 +0200
Message-ID: <20100730141901.GA9076@redhat.com>
References: <20100701144624.GA11171@redhat.com> <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop> <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop> <20100702210637.GA12433@redhat.com> <20100726171230.GA27644@redhat.com> <1280166688.3375.5.camel@localhost> <20100726180834.GA26988@redhat.com> <20100727154155.GA13419@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab0G3OWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jul 2010 10:22:37 -0400
Content-Disposition: inline
In-Reply-To: <20100727154155.GA13419@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the delay, I can't be responsive these days...

On 07/27, Michael S. Tsirkin wrote:
>
> On Mon, Jul 26, 2010 at 08:08:34PM +0200, Oleg Nesterov wrote:
> > On 07/26, Sridhar Samudrala wrote:
> > >
> > > I have been testing out a similar patch that uses kernel_thread() without CLONE_FILES
> > > flag rather than create_kthread() and then closing the files.
> >
> > !CLONE_FILES can't help. copy_files() does dup_fd() in this case.
> > The child still inherits the files.
> >
> > > Either version should be fine.
> >
> > I think neither version is fine ;)
> >
> > exit_files() is not enough too. How about the signals, reparenting?
> >
> >
> > I already forgot all details, probably I missed somethig. But it
> > seems to me that it is better to just export get/set affinity and
> > forget about all complications.
> >
> > Oleg.
>
> Oleg, so can I attach your Ack to the patch in question, and merge
> it all through net-next?

Well, I do not think you need my ack ;)


But I must admit, I personally dislike this idea. A kernel thread which
is the child of the user-space process, and in fact it is not the "real"
kernel thread. I think this is against the common case. If you do not
care the signals/reparenting, why can't you fork the user-space process
which does all the work via ioctl's ? OK, I do not understand the problem
domain, probably this can't work.

Anyway, the patch looks buggy to me. Starting from

	create_kthread(&create);
	wait_for_completion(&create.done);

At least you should check create_kthread() suceeds, otherwise
wait_for_completion() will hang forever. OTOH, if it suceeds then
wait_for_completion() is not needed. But this is minor.

create_kthread()->kernel_thread() uses CLONE_VM, this means that the
child will share ->mm. And this means that if the parent recieves
the coredumping signal it will hang forever in kernel space waiting
until this child exits.

This is just the immediate surprise I can see with this approach,
I am afraid there is something else.

And once again. We are doing this hacks only because we lack a
couples of exports (iiuk). This is, well, a bit strange ;)

Oleg.

