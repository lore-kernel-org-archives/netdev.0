From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with
 per-vhost kthread
Date: Wed, 28 Jul 2010 13:48:59 +0300
Message-ID: <20100728104858.GB30643@redhat.com>
References: <20100726152510.GA26223@redhat.com>
 <4C4DAB14.5050809@kernel.org>
 <20100726155014.GA26412@redhat.com>
 <4C4DB247.9060709@kernel.org>
 <4C4DB466.6000409@kernel.org>
 <20100726165114.GA27353@redhat.com>
 <4C4DDE7E.8030406@kernel.org>
 <4C4DE2AE.40302@kernel.org>
 <20100727191911.GA16350@redhat.com>
 <4C4FE0CF.3070506@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C4FE0CF.3070506@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2010 at 09:48:31AM +0200, Tejun Heo wrote:
> On 07/27/2010 09:19 PM, Michael S. Tsirkin wrote:
> >> Thinking a bit more about it, it kind of sucks that queueing to
> >> another worker from worker->func() breaks flush.  Maybe the right
> >> thing to do there is using atomic_t for done_seq?
> > 
> > I don't believe it will help: we might have:
> > 
> > worker1 runs work
> > work requeues itself queued index = 1
> > worker1 reads queued index = 1
> > worker2 runs work
> > work requeues itself queued index = 2
> > worker2 runs work
> > worker2 reads queued index = 2
> > worker2 writes done index = 2
> > worker1 writes done index = 1
> > 
> > As you see, done index got moved back.
> 
> Yeah, I think the flushing logic should be moved to the worker.
> Are you interested in doing it w/ your change?
> 
> Thanks.

I'm unsure how flush_work operates under these conditions.  E.g. in
workqueue.c, this seems to work by keeping a pointer to current
workqueue in the work.  But what prevents us from destroying the
workqueue when work might not be running?

Is this currently broken if you use multiple workqueues
for the same work? If yes, I propose we do as I did,
making flush_work get worker pointer, and only flushing
on that worker.

> -- 
> tejun
