From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 05:42:30 +0000
Message-ID: <20090626054230.GA5204@ff.dom.local>
References: <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:33748 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbZFZFmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 01:42:33 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-06-2009 05:14, Davide Libenzi wrote:
> On Fri, 26 Jun 2009, Eric Dumazet wrote:
> 
>> I wont argue with you David, just try to correct bugs.
>>
>> fs/ext4/ioctl.c line 182
>>
>> 	set_current_state(TASK_INTERRUPTIBLE);
>> 	add_wait_queue(&EXT4_SB(sb)->ro_wait_queue, &wait);
>> 	if (timer_pending(&EXT4_SB(sb)->turn_ro_timer)) {
>> 		schedule();
>>
>> Another example of missing barrier after add_wait_queue()
>>
>> Because add_wait_queue() misses a barrier, we have to add one after each call.
>>
>> Maybe it would be safer to add barrier in add_wait_queue() itself, not in _pollwait().
> 
> Not all the code that uses add_wait_queue() does need to have the MB,
> like code that does the most common pattern:
> 
> xxx_poll(...) {
> 	poll_wait(...);
> 	lock();
> 	flags = calc_flags(->status);
> 	unlock();
> 	return flags;
> }
> 
> xxx_update(...) {
> 	lock();
> 	->status = ...;
> 	unlock();
> 	if (waitqueue_active())
> 		wake_up();
> }
> 
> It's the code that does the lockless flags calculation in ->poll that 
> might need it.
> I dunno what the amount of changes are, but cross-matching MB across 
> subsystems does not look nice.
> IMHO that's a detail of the subsystem locking, and should be confined 
> inside the subsystem itself.
> No?

How about poll_wait_mb() and waitqueue_active_mb() (with mb and
additional check for NULL of wait_queue_head)?

Jarek P.
