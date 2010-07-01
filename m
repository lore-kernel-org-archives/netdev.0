From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 01 Jul 2010 15:30:24 +0200
Message-ID: <1277991024.1917.108.camel@laptop>
References: <20100624081135.GA937@redhat.com>
	 <1277419551.27868.27.camel@w-sridhar.beaverton.ibm.com>
	 <20100625101022.GA16321@redhat.com> <20100701110708.GA27368@redhat.com>
	 <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop>
	 <20100701115507.GA31333@redhat.com> <20100701122340.GB31333@redhat.com>
	 <1277987657.1917.32.camel@laptop> <1277988395.1917.47.camel@laptop>
	 <20100701130816.GB32223@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Ingo Molnar <mingo@elte.hu>, Sridhar Samudrala <sri@us.ibm.com>,
	Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100701130816.GB32223@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-01 at 16:08 +0300, Michael S. Tsirkin wrote:
> On Thu, Jul 01, 2010 at 02:46:35PM +0200, Peter Zijlstra wrote:
> > On Thu, 2010-07-01 at 14:34 +0200, Peter Zijlstra wrote:
> > > On Thu, 2010-07-01 at 15:23 +0300, Michael S. Tsirkin wrote:
> > > > 
> > > > The patch using this is here:
> > > > http://www.mail-archive.com/kvm@vger.kernel.org/msg35411.html
> > > > 
> > > > It simply copies the affinity from the parent when thread is created.
> > > 
> > > Sounds like policy, not something the kernel should do..
> > 
> > The alternative would be using clone() instead of thread_create() and
> > inherit everything from the creating task.
> > Inheriting from kthreadd and then undoing some aspects just sounds
> > like daft policy that really ought to be in userspace.
> 
> Yes, that's basically what this patchset is trying to do:
> create a workqueue inheriting everything from the creating task.
> Sridhar started with an API to do exactly this:
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-05/msg07478.html
> 
> Then we switched to raw kthread to avoid stepping on cwq toes.
> Maybe it makes sense to add kthread_clone (in addition to
> kthread_create) that would do what you suggest?
> If yes, any hints on an implementation?

I think that's called kernel_thread() see
kernel/kthread.c:create_kthread().

Doing the whole kthreadd dance and then copying bits and pieces back
sounds very fragile, so yeah, something like that should work.

The other issue to consider is the thread group status of these things,
I think it would be best if these threads were still considered part of
the process that spawned them so that they would die nicely when the
process gets whacked.

At which point one could wonder if the kthread interface makes any
sense, why not let userspace fork tasks and let them call into the
kernel to perform work...
