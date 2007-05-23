From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [BUG] local_softirq_pending storm
Date: Wed, 23 May 2007 14:38:40 -0400
Message-ID: <46548A30.9000801@redhat.com>
References: <200705091942.22920.kernel@prachanda.hub> <200705191525.28400.kernel@prachanda.hub> <1179601868.12981.127.camel@chaos> <200705200253.44992.kernel@prachanda.hub> <1179697388.6570.26.camel@chaos> <6bffcb0e0705221203s1ba21ed3j641e91036859db7d@mail.gmail.com> <20070522201046.GA6113@elte.hu> <46547345.8000808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Anant Nitya <kernel@prachanda.info>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000AbXEWSjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 14:39:15 -0400
In-Reply-To: <46547345.8000808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> 
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240982

Another; these started to appear after the below patch was merged:

> Index: linux/kernel/sched.c
> > ===================================================================
> > --- linux.orig/kernel/sched.c
> > +++ linux/kernel/sched.c
> > @@ -4212,9 +4212,7 @@ int __sched cond_resched_softirq(void)
> >  	BUG_ON(!in_softirq());
> >  
> >  	if (need_resched() && system_state == SYSTEM_RUNNING) {
> > -		raw_local_irq_disable();
> > -		_local_bh_enable();
> > -		raw_local_irq_enable();
> > +		local_bh_enable();
> >  		__cond_resched();
> >  		local_bh_disable();
> >  		return 1;

May 23 19:26:26 localhost kernel: BUG: warning at kernel/softirq.c:138/local_bh_enable() (Not tainted)
May 23 19:26:26 localhost kernel:  [<c042b2ef>] local_bh_enable+0x45/0x92
May 23 19:26:26 localhost kernel:  [<c06036b7>] cond_resched_softirq+0x2c/0x42
May 23 19:26:26 localhost kernel:  [<c059d5d0>] release_sock+0x54/0xa3
May 23 19:26:26 localhost kernel:  [<c04373af>] prepare_to_wait+0x24/0x3f
May 23 19:26:26 localhost kernel:  [<c05e267f>] inet_stream_connect+0x116/0x1ff
May 23 19:26:26 localhost kernel:  [<c0437265>] autoremove_wake_function+0x0/0x35
May 23 19:26:26 localhost kernel:  [<c059c339>] sys_connect+0x82/0xad
May 23 19:26:26 localhost kernel:  [<c059d58f>] release_sock+0x13/0xa3
May 23 19:26:26 localhost kernel:  [<c0604ad5>] _spin_unlock_bh+0x5/0xd
May 23 19:26:26 localhost kernel:  [<c059e714>] sock_setsockopt+0x4a8/0x4b2
May 23 19:26:26 localhost kernel:  [<c059b6b6>] sock_attach_fd+0x70/0xd2
May 23 19:26:26 localhost kernel:  [<c04774a0>] get_empty_filp+0xfc/0x170
May 23 19:26:26 localhost kernel:  [<c059b54f>] sys_setsockopt+0x9b/0xa7
May 23 19:26:26 localhost kernel:  [<c059cb83>] sys_socketcall+0xac/0x261
May 23 19:26:26 localhost kernel:  [<c0404f70>] syscall_call+0x7/0xb

