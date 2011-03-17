From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Bug inkvm_set_irq
Date: Thu, 17 Mar 2011 10:21:59 +0200
Message-ID: <20110317082159.GB6459@redhat.com>
References: <4D70B339.3080001@univ-nantes.fr>
 <20110308111320.GA8002@redhat.com>
 <4D77727B.2000207@univ-nantes.fr>
 <20110309130000.GA30297@redhat.com>
 <4D777CDA.3050500@univ-nantes.fr>
 <20110309135918.GA31019@redhat.com>
 <4D788EF4.7040807@univ-nantes.fr>
 <20110315143230.GA6911@redhat.com>
 <4D7F7E82.4000600@univ-nantes.fr>
 <4D81BF9E.5090503@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D81BF9E.5090503@univ-nantes.fr>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2011 at 09:00:30AM +0100, Jean-Philippe Menil wrote:
> >>Are you running a preemptible kernel?
> >>Does the following help at all?
> >>
> >>diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
> >>index 2ca4535..cdf51c9 100644
> >>--- a/virt/kvm/eventfd.c
> >>+++ b/virt/kvm/eventfd.c
> >>@@ -90,7 +90,7 @@ irqfd_shutdown(struct work_struct *work)
> >>   	 * We know no new events will be scheduled at this point, so block
> >>   	 * until all previously outstanding events have completed
> >>   	 */
> >>-	flush_work(&irqfd->inject);
> >>+	flush_work_sync(&irqfd->inject);
> >>
> >>   	/*
> >>   	 * It is now safe to release the object's resources
> >>
> >Hi,
> >
> >thanks for the response.
> >
> >root@ayrshire:~# zcat /proc/config.gz | grep -i preempt
> ># CONFIG_PREEMPT_RCU is not set
> >CONFIG_PREEMPT_NOTIFIERS=y
> >CONFIG_PREEMPT_NONE=y
> ># CONFIG_PREEMPT_VOLUNTARY is not set
> ># CONFIG_PREEMPT is not set
> >
> >It does not seem to be a preemptible kernel.
> >
> >I will test tour patch, and report the result.
> >
> >Regards.
> >
> Hi,
> 
> i reboot the host with the "flush_work_sync", yesterday at lunchtime.
> I haven't see "Eventfd bug detected" or  "Wakeup bug detected" until now.
> 
> The modification seem to do the trick.
> 
> So, if my understand is correct, flush_work flush the last irqfd,
> but in my case, antoher irqfd was still queued to a cpu?
> Is that right?
> 
> Regards.

Yes, it says:

 * flush_work - wait for a work to finish executing the last queueing instance
 * @work: the work to flush
 *
 * Wait until @work has finished execution.  This function considers
 * only the last queueing instance of @work.  If @work has been
 * enqueued across different CPUs on a non-reentrant workqueue or on
 * multiple workqueues, @work might still be executing on return on
 * some of the CPUs from earlier queueing.
 *
 * If @work was queued only on a non-reentrant, ordered or unbound
 * workqueue, @work is guaranteed to be idle on return if it hasn't
 * been requeued since flush started.

kvm uses the default workqueue which is non-reentrant.
Thanks to Gleb for the suggestion!

-- 
MST
