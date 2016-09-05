From: Tejun Heo <tj@kernel.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Mon, 5 Sep 2016 09:08:32 -0400
Message-ID: <20160905130832.GD20784@mtj.duckdns.org>
References: <56C70618.3010902@suse.cz>
 <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz>
 <20160311171205.GB24046@htj.duckdns.org>
 <56EA9C4D.2080803@suse.cz>
 <20160318205231.GO20028@mtj.duckdns.org>
 <56F01A1C.40208@suse.cz>
 <56F0FDCE.1040701@suse.cz>
 <CACT4Y+b+9Ubsbfs58nHAraG+7iXRBkrn=XyCTPDJLike7w-mjQ@mail.gmail.com>
 <CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth <linux-bluetooth@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Sasha Levin <sasha.levin@oracle.com>,
        Eric Dumazet <edumazet@google.com>,
        Takashi Iwai <tiwai@suse.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Sep 03, 2016 at 12:58:33PM +0200, Dmitry Vyukov wrote:
> > I've seen it only several times in several months, so I don't it will
> > be helpful.
> 
> 
> Bad news: I hit it again.
> On 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next, so I have
> bf389cabb3b8079c23f9762e62b05f291e2d5e99.

Hmmm... we're not getting anywhere.  I've applied the following patch
to wq/for-4.8-fixes so that when this happens the next time we can
actually tell what the hell is going wrong.

Thanks.

------ 8< ------
>From 278930ada88c972d20025b0f20def27b1a09dff7 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj@kernel.org>
Date: Mon, 5 Sep 2016 08:54:06 -0400
Subject: [PATCH] workqueue: dump workqueue state on sanity check failures in
 destroy_workqueue()

destroy_workqueue() performs a number of sanity checks to ensure that
the workqueue is empty before proceeding with destruction.  However,
it's not always easy to tell what's going on just from the warning
message.  Let's dump workqueue state after sanity check failures to
help debugging.

Signed-off-by: Tejun Heo <tj@kernel.org>
Link: http://lkml.kernel.org/r/CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com
Cc: Dmitry Vyukov <dvyukov@google.com>
---
 kernel/workqueue.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ef071ca..4eaec8b8 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4021,6 +4021,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 		for (i = 0; i < WORK_NR_COLORS; i++) {
 			if (WARN_ON(pwq->nr_in_flight[i])) {
 				mutex_unlock(&wq->mutex);
+				show_workqueue_state();
 				return;
 			}
 		}
@@ -4029,6 +4030,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 		    WARN_ON(pwq->nr_active) ||
 		    WARN_ON(!list_empty(&pwq->delayed_works))) {
 			mutex_unlock(&wq->mutex);
+			show_workqueue_state();
 			return;
 		}
 	}
-- 
2.7.4
