From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3] vhost: replace vhost_workqueue with per-vhost
	kthread
Date: Mon, 31 May 2010 17:31:04 +0200
Message-ID: <20100531153104.GA9452@redhat.com>
References: <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C961.9050606@kernel.org> <20100531143945.GA6497@redhat.com> <4C03D0BE.1040601@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344Ab0EaPcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 11:32:45 -0400
Content-Disposition: inline
In-Reply-To: <4C03D0BE.1040601@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31, Tejun Heo wrote:
>
> On 05/31/2010 04:39 PM, Oleg Nesterov wrote:
>
> > What I can't understand is why we do have ->queue_seq and ->done_seq.
> >
> > Isn't the single "bool poll->active" enough? vhost_poll_queue() sets
> > ->active == T, vhost_poller() clears it before wake_up_all(poll->done).
>
> I might have slightly over engineered this part not knowing the
> expected workload.  ->queue_seq/->done_seq pair is to guarantee that
> flushers never get starved.

Ah, indeed.

Well, afaics we do not need 2 counters anyway, both vhost_poll_queue()
and vhost_poller() could increment the single counter and the flusher
can take bit 0 into account. But I agree 2 counters are much more clean.

> >> +static int vhost_poller(void *data)
> >> +{
> >> +	struct vhost_dev *dev = data;
> >> +	struct vhost_poll *poll;
> >> +
> >> +repeat:
> >> +	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
> >
> > I don't understand the comment... why do we need this barrier?
>
> So that either kthread_stop()'s should_stop = 1 in kthread_stop() is
> visible to kthread_should_stop() or task state is set to RUNNING.

Of course, you are right. I am really surprized I asked this question ;)

Thanks,

Oleg.

