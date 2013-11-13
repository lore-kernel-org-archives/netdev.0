From: Oleg Nesterov <oleg@redhat.com>
Subject: __refrigerator() && saved task->state
Date: Wed, 13 Nov 2013 20:11:43 +0100
Message-ID: <20131113191143.GA24005@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112145243.GU5056@laptop.programming.kicks-ass.net> <20131112162136.GA29065@redhat.com> <20131112165643.GA31278@redhat.com> <20131113032053.GA19394@mtj.dyndns.org> <20131113170724.GA17739@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	David Rientjes <rientjes@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757139Ab3KMTKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 14:10:55 -0500
Content-Disposition: inline
In-Reply-To: <20131113170724.GA17739@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for noise, but I am totally confused.

Could you please remind why __refrigerator() saves/restores
task->state?

I can see only one reason: set_freezable() kernel threads which
check kthread_should_stop() and do try_to_freeze() by hand.

But does this save/restore actually help?

For example kauditd_thread() looks obviously racy exactly because
try_to_freeze() can return in TASK_INTERRUPTIBLE state after
wake_up(kauditd_wait) was already called, we can miss an event.

At first glance it would be better to simply kill this logic? If
it was called with ->state != 0, the caller is going to schedule()
and it probably executes the wait_event-like code, in this case
it would me more safe to pretend the task got a spurious wakeup?

(as for kauditd_thread() in particular, it looks wrong in any
 case, even kthread_should_stop() check doesn't look right, it
 needs kthread_freezable_should_stop() afaics).

But I guess I missed something else...

Oleg.
