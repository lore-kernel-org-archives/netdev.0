From: David Miller <davem@redhat.com>
Subject: Re: UNIX sockets kernel panic
Date: Thu, 06 Nov 2008 04:26:00 -0800 (PST)
Message-ID: <20081106.042600.114065285.davem@redhat.com>
References: <20081106001445.GA5595@shorty>
	<20081106011319.GA22389@x200.localdomain>
	<20081105.171822.193705306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.bittau@cs.ucl.ac.uk
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48111 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381AbYKFM0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 07:26:11 -0500
In-Reply-To: <20081105.171822.193705306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 05 Nov 2008 17:18:22 -0800 (PST)

> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Thu, 6 Nov 2008 04:13:19 +0300
> 
> > On Thu, Nov 06, 2008 at 12:14:46AM +0000, Andrea Bittau wrote:
> > > The following code causes a kernel panic on Linux 2.6.26:
> > > http://darkircop.org/unix.c
> > > 
> > > I haven't investigated the bug so I'm not sure what is causing it, and
> > > don't know if it's exploitable.  The code passes unix sockets from one
> > > process to another using unix sockets.  The bug probably has to do with
> > > closing file descriptors.
> > 
> > Aie, nice localhost DoS (random oopses)
> 
> Indeed.  I'm looking at it too and in my case I get random memory
> corruption, usually it's skb->destruct being set to garbage and then
> we hit the WARN_ON(in_irq()) in net/core/skbuff.c
> 
> I think the key is passing a unix socket fd (as opposed to some other
> kind of fd) using SCM_RIGHTS and the ordering of the fd closes.

Andrea, can you try this patch?

net: Fix recursive descent in __scm_destroy().

__scm_destroy() walks the list of file descriptors in the scm_fp_list
pointed to by the scm_cookie argument.

Those, in turn, can close sockets and invoke __scm_destroy() again.

There is nothing which limits how deeply this can occur.

The idea for how to fix this is from Linus.  Basically, we do all of
the fput()s at the top level by collecting all of the scm_fp_list
objects hit by an fput().  Inside of the initial __scm_destroy() we
keep running the list until it is empty.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b483f39..295b7c7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1349,6 +1349,8 @@ struct task_struct {
 	 */
 	unsigned long timer_slack_ns;
 	unsigned long default_timer_slack_ns;
+
+	struct list_head	*scm_work_list;
 };
 
 /*
diff --git a/include/net/scm.h b/include/net/scm.h
index 06df126..33e9986 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -14,8 +14,9 @@
 
 struct scm_fp_list
 {
-	int		count;
-	struct file	*fp[SCM_MAX_FD];
+	struct list_head	list;
+	int			count;
+	struct file		*fp[SCM_MAX_FD];
 };
 
 struct scm_cookie
diff --git a/net/core/scm.c b/net/core/scm.c
index 10f5c65..ab242cc 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -75,6 +75,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 		if (!fpl)
 			return -ENOMEM;
 		*fplp = fpl;
+		INIT_LIST_HEAD(&fpl->list);
 		fpl->count = 0;
 	}
 	fpp = &fpl->fp[fpl->count];
@@ -106,9 +107,25 @@ void __scm_destroy(struct scm_cookie *scm)
 
 	if (fpl) {
 		scm->fp = NULL;
-		for (i=fpl->count-1; i>=0; i--)
-			fput(fpl->fp[i]);
-		kfree(fpl);
+		if (current->scm_work_list) {
+			list_add_tail(&fpl->list, current->scm_work_list);
+		} else {
+			LIST_HEAD(work_list);
+
+			current->scm_work_list = &work_list;
+
+			list_add(&fpl->list, &work_list);
+			while (!list_empty(&work_list)) {
+				fpl = list_first_entry(&work_list, struct scm_fp_list, list);
+
+				list_del(&fpl->list);
+				for (i=fpl->count-1; i>=0; i--)
+					fput(fpl->fp[i]);
+				kfree(fpl);
+			}
+
+			current->scm_work_list = NULL;
+		}
 	}
 }
 
@@ -284,6 +301,7 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 
 	new_fpl = kmalloc(sizeof(*fpl), GFP_KERNEL);
 	if (new_fpl) {
+		INIT_LIST_HEAD(&new_fpl->list);
 		for (i=fpl->count-1; i>=0; i--)
 			get_file(fpl->fp[i]);
 		memcpy(new_fpl, fpl, sizeof(*fpl));
