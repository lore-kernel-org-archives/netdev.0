From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH 2/4] pktgen: make sure that pktgen_thread_worker has been executed
Date: Tue, 20 May 2008 20:30:22 +0200
Message-ID: <18483.6334.468166.282922@robur.slu.se>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
	<1211277589-8565-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Ben Greear <greearb@candelatech.com>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47603 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765634AbYETSbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 14:31:03 -0400
In-Reply-To: <1211277589-8565-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Denis V. Lunev writes:

 > The problem is that pktgen_thread_worker can not be executed if kthread_stop
 > has been called too early. Insert a completion on the normal initialization
 > path to make sure that pktgen_thread_worker will gain the control for sure.


 Yes how about if we move the wait_for_completion() to pg_cleanup before
 we remove the threads. And move the complete() last in pktgen_thread_worker. 
 This completion would sync with both start and stop.

 Cheers.
					--ro


 > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
 > index 8dca211..fdf5377 100644
 > --- a/net/core/pktgen.c
 > +++ b/net/core/pktgen.c
 > @@ -390,6 +390,7 @@ struct pktgen_thread {
 >  	int cpu;
 >  
 >  	wait_queue_head_t queue;
 > +	struct completion start_done;
 >  };
 >  
 >  #define REMOVE 1
 > @@ -3414,6 +3415,7 @@ static int pktgen_thread_worker(void *arg)
 >  	BUG_ON(smp_processor_id() != cpu);
 >  
 >  	init_waitqueue_head(&t->queue);
 > +	complete(&t->start_done);
 >  
 >  	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 >  
 > @@ -3615,6 +3617,7 @@ static int __init pktgen_create_thread(int cpu)
 >  	INIT_LIST_HEAD(&t->if_list);
 >  
 >  	list_add_tail(&t->th_list, &pktgen_threads);
 > +	init_completion(&t->start_done);
 >  
 >  	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
 >  	if (IS_ERR(p)) {
 > @@ -3639,6 +3642,7 @@ static int __init pktgen_create_thread(int cpu)
 >  	}
 >  
 >  	wake_up_process(p);
 > +	wait_for_completion(&t->start_done);
 >  
 >  	return 0;
 >  }
 > -- 
 > 1.5.3.rc5
