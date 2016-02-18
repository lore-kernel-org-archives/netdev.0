From: Tejun Heo <tj@kernel.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Thu, 18 Feb 2016 12:44:27 -0500
Message-ID: <20160218174427.GG13177@mtj.duckdns.org>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mP3DRpeJDSE+ciuQ"
Cc: Jiri Slaby <jslaby@suse.cz>, Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
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
In-Reply-To: <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Can you please do the followings?

1. Remove WQ_MEM_RECLAIM from the affected workqueue and see whether
   the problem is reproducible.  WQ_MEM_RECLAIM on anything bluetooth
   doesn't make sense btw.  Why is it there?

2. If WQ_MEM_RECLAIM makes the issue go away, see whether the attached
   patch works too.

Thanks.

-- 
tejun

--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 7ff5dc7..9824d4f 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4012,7 +4012,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 	/* drain it before proceeding with destruction */
 	drain_workqueue(wq);
 
-	/* sanity checks */
+	/* nothing should be in flight */
 	mutex_lock(&wq->mutex);
 	for_each_pwq(pwq, wq) {
 		int i;
@@ -4024,8 +4024,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 			}
 		}
 
-		if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) ||
-		    WARN_ON(pwq->nr_active) ||
+		if (WARN_ON(pwq->nr_active) ||
 		    WARN_ON(!list_empty(&pwq->delayed_works))) {
 			mutex_unlock(&wq->mutex);
 			return;
@@ -4046,6 +4045,13 @@ void destroy_workqueue(struct workqueue_struct *wq)
 	if (wq->rescuer)
 		kthread_stop(wq->rescuer->task);
 
+	/* rescuer is gone, everything should be quiescent now */
+	WARN_ON(!list_empty(&wq->maydays));
+	mutex_lock(&wq->mutex);
+	for_each_pwq(pwq, wq)
+		WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1));
+	mutex_unlock(&wq->mutex);
+
 	if (!(wq->flags & WQ_UNBOUND)) {
 		/*
 		 * The base ref is never dropped on per-cpu pwqs.  Directly

--mP3DRpeJDSE+ciuQ--
