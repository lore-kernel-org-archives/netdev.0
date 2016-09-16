From: Tejun Heo <tj@kernel.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Fri, 16 Sep 2016 16:24:04 -0400
Message-ID: <20160916202404.GE26371@htj.duckdns.org>
References: <20160318205231.GO20028@mtj.duckdns.org>
 <56F01A1C.40208@suse.cz>
 <56F0FDCE.1040701@suse.cz>
 <CACT4Y+b+9Ubsbfs58nHAraG+7iXRBkrn=XyCTPDJLike7w-mjQ@mail.gmail.com>
 <CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com>
 <20160905130832.GD20784@mtj.duckdns.org>
 <CACT4Y+axnBPkUpMyUC74TFwq-_3Aia-fQRoSSBwbZuiguhjEaA@mail.gmail.com>
 <CACT4Y+Z2dP--yr5oJYPnAmTtzJDHbR6h=6d0nSdg6KB-qseEzg@mail.gmail.com>
 <20160913153520.GC21123@htj.duckdns.org>
 <c70c2e6f-1451-0705-db14-71bc022102c6@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth <linux-bluetooth@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Takashi Iwai <tiwai@suse.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c70c2e6f-1451-0705-db14-71bc022102c6@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Sep 13, 2016 at 08:14:40PM +0200, Jiri Slaby wrote:
> I assume Dmitry sees the same what I am still seeing, so I reported this
> some time ago:
> https://lkml.org/lkml/2016/3/21/492
> 
> This warning is trigerred there and still occurs with "HEAD":
>   (pwq != wq->dfl_pwq) && (pwq->refcnt > 1)
> and the state dump is in the log empty too:
> destroy_workqueue: name='hci0' pwq=ffff88006b5c8f00
> wq->dfl_pwq=ffff88006b5c9b00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
>   pwq 13:
>  cpus=2-3 node=1 flags=0x4 nice=-20 active=0/1
>     in-flight: 2669:wq_barrier_func

Hmmm... I think it could be from rescuer holding reference on the pwq.
Both cases have WQ_MEM_RECLAIM and it could be that rescuer was still
in flight (even without work items pending) when the sanity checks
were done.  The following patch moves the sanity checks after rescuer
destruction.  Dmitry, Jiri, can you please see whether the warning
goes away with this patch?

Thanks.

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 984f6ff..e8046a1 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4042,8 +4042,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 			}
 		}
 
-		if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) ||
-		    WARN_ON(pwq->nr_active) ||
+		if (WARN_ON(pwq->nr_active) ||
 		    WARN_ON(!list_empty(&pwq->delayed_works))) {
 			mutex_unlock(&wq->mutex);
 			show_workqueue_state();
@@ -4080,6 +4079,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 		for_each_node(node) {
 			pwq = rcu_access_pointer(wq->numa_pwq_tbl[node]);
 			RCU_INIT_POINTER(wq->numa_pwq_tbl[node], NULL);
+			WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt != 1));
 			put_pwq_unlocked(pwq);
 		}
 
@@ -4089,6 +4089,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
 		 */
 		pwq = wq->dfl_pwq;
 		wq->dfl_pwq = NULL;
+		WARN_ON(pwq->refcnt != 1);
 		put_pwq_unlocked(pwq);
 	}
 }
