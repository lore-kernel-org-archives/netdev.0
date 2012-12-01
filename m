From: Tejun Heo <tj@kernel.org>
Subject: Re: Wireless regression in workqueue: use mod_delayed_work() instead
 of __cancel + queue
Date: Sat, 1 Dec 2012 06:39:26 -0800
Message-ID: <20121201143926.GB2685@htj.dyndns.org>
References: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
 <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu>
 <20121130211435.GJ3873@htj.dyndns.org>
 <20121130225619.GD6021@htj.dyndns.org>
 <alpine.DEB.2.00.1211302234410.25064@dr-wily.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anders Kaseorg <andersk@MIT.EDU>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211302234410.25064@dr-wily.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey, Anders.

On Fri, Nov 30, 2012 at 11:15:50PM -0500, Anders Kaseorg wrote:
> Yes.  I tested that both directly on top of the bad commit, and on 
> v3.7-rc7, and it fixes the bug in both cases.

Can you please test this one too?  Thanks!

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 042d221..94964d1 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1364,6 +1364,11 @@ static void __queue_delayed_work(int cpu, struct workqueue_struct *wq,
 	BUG_ON(timer_pending(timer));
 	BUG_ON(!list_empty(&work->entry));
 
+	if (!delay) {
+		__queue_work(cpu, wq, &dwork->work);
+		return;
+	}
+
 	timer_stats_timer_set_start_info(&dwork->timer);
 
 	/*
@@ -1417,9 +1422,6 @@ bool queue_delayed_work_on(int cpu, struct workqueue_struct *wq,
 	bool ret = false;
 	unsigned long flags;
 
-	if (!delay)
-		return queue_work_on(cpu, wq, &dwork->work);
-
 	/* read the comment in __queue_work() */
 	local_irq_save(flags);
 
