From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Thu, 30 Nov 2006 20:14:23 -0800 (PST)
Message-ID: <20061130.201423.118625277.davem@davemloft.net>
References: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
	<17774.39482.949953.625608@robur.slu.se>
	<456F15F7.3000700@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, adobriyan@gmail.com,
	pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:27555
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758862AbWLAEOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 23:14:20 -0500
To: greearb@candelatech.com
In-Reply-To: <456F15F7.3000700@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 30 Nov 2006 09:33:43 -0800

> Robert Olsson wrote:
> > @@ -3673,6 +3673,8 @@ static void __exit pg_cleanup(void)
> >  	struct list_head *q, *n;
> >  	wait_queue_head_t queue;
> >  	init_waitqueue_head(&queue);
> > +	
> > +	schedule_timeout_interruptible(msecs_to_jiffies(125));
> >  
> >  	/* Stop all interfaces & threads */
> >  
>
> That strikes me as a hack..surely there is a better method than just adding
> a sleep??

Agreed.

Robert, please fix this by using a completion so that we can
wait for the threads to start up, something like this:

...
#include <linux/completion.h>
...

struct pktgen_thread_info {
       struct pktgen_thread *t;
       struct completion *c;
};

static void pktgen_thread_worker(struct pktgen_thread_info *info)
{
	struct pktgen_thread *t = info->t;
 ...
	__set_current_state(TASK_INTERRUPTIBLE);
	mb();

	complete(info->c);
 ...
}

static int __init pktgen_create_thread(const char *name, int cpu)
{
 ...
	struct pktgen_thread_info info;
	struct complation started;
 ...
        init_completion(&started);

	info.t = t;
	info.c = &started;

	err = kernel_thread((void *)pktgen_thread_worker, (void *)t,
			  CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
	if (err < 0) {
		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
		remove_proc_entry(t->name, pg_proc_dir);
		list_del(&t->th_list);
		kfree(t);
		return err;
	}

	wait_for_completion(&started);
	return 0;
}

We can horse around with fixing the initial t->control bit flipping
in pktgen_thread_worker() in a future changeset if we want.
