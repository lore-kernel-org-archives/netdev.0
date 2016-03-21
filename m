From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Mon, 21 Mar 2016 16:58:20 +0100
Message-ID: <56F01A1C.40208@suse.cz>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org> <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz> <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz> <20160311171205.GB24046@htj.duckdns.org>
 <56EA9C4D.2080803@suse.cz> <20160318205231.GO20028@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
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
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35540 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863AbcCUP6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 11:58:25 -0400
In-Reply-To: <20160318205231.GO20028@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 03/18/2016, 09:52 PM, Tejun Heo wrote:
> On Thu, Mar 17, 2016 at 01:00:13PM +0100, Jiri Slaby wrote:
>>>> I have not done that yet, but today, I see:
>>>> destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
>>>> wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
>>>>    pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
>>>>      in-flight: 18568:wq_barrier_func
>>>
>>> So, this means that there's flush_work() racing against workqueue
>>> destruction, which can't be safe. :(
>>
>> But I cannot trigger the WARN_ONs in the attached patch, so I am
>> confused how this can happen :(. (While I am still seeing the destroy
>> WARNINGs.)
> 
> So, no operations should be in progress when destroy_workqueue() is
> called.  If somebody was flushing a work item, the flush call must
> have returned before destroy_workqueue() was invoked, which doesn't
> seem to be the case here.  Can you trigger BUG_ON() or sysrq-t when
> the above triggers?  There must be a task which is flushing a work
> item there and it shouldn't be difficult to pinpoint what's going on
> from it.

The output of sysrq-t is here (> 200k), but I cannot see anything
suspicious in it:
http://www.fi.muni.cz/~xslaby/sklad/panics/jctl.txt

This is what the code does now:
+               if ((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) {
+                       pr_info("%s: name='%s' pwq=%p wq->dfl_pwq=%p
pwq->refcnt=%d pwq->nr_active=%d delayed_works:",
+                                       __func__, wq->name, pwq,
wq->dfl_pwq,
+                                       pwq->refcnt, pwq->nr_active);
+
+                       show_pwq(pwq);
+
+                       mutex_unlock(&wq->mutex);
+                       show_state();
+                       show_workqueue_state();
+                       WARN_ON(1);
+                       return;
+               }

thanks,
-- 
js
suse labs
