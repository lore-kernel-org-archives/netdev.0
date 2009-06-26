From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Thu, 25 Jun 2009 20:14:22 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
 <4A443033.8060401@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756302AbZFZDTD@vger.kernel.org>
In-Reply-To: <4A443033.8060401@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Jun 2009, Eric Dumazet wrote:

> I wont argue with you David, just try to correct bugs.
> 
> fs/ext4/ioctl.c line 182
> 
> 	set_current_state(TASK_INTERRUPTIBLE);
> 	add_wait_queue(&EXT4_SB(sb)->ro_wait_queue, &wait);
> 	if (timer_pending(&EXT4_SB(sb)->turn_ro_timer)) {
> 		schedule();
> 
> Another example of missing barrier after add_wait_queue()
> 
> Because add_wait_queue() misses a barrier, we have to add one after each call.
> 
> Maybe it would be safer to add barrier in add_wait_queue() itself, not in _pollwait().

Not all the code that uses add_wait_queue() does need to have the MB,
like code that does the most common pattern:

xxx_poll(...) {
	poll_wait(...);
	lock();
	flags = calc_flags(->status);
	unlock();
	return flags;
}

xxx_update(...) {
	lock();
	->status = ...;
	unlock();
	if (waitqueue_active())
		wake_up();
}

It's the code that does the lockless flags calculation in ->poll that 
might need it.
I dunno what the amount of changes are, but cross-matching MB across 
subsystems does not look nice.
IMHO that's a detail of the subsystem locking, and should be confined 
inside the subsystem itself.
No?



- Davide
