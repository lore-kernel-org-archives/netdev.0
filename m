From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync in bond_close
Date: Wed, 19 Oct 2011 12:09:57 -0700
Message-ID: <29731.1319051397@death>
References: <20111019081757.12455.24788.stgit@ltc219.sdl.hitachi.co.jp> <27007.1319047262@death> <20111019114129.162d895a@nehalam.linuxnetplumber.net>
Cc: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56074 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab1JSTYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 15:24:04 -0400
Received: from /spool/local
	by e1.ny.us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 19 Oct 2011 15:18:31 -0400
In-reply-to: <20111019114129.162d895a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>On Wed, 19 Oct 2011 11:01:02 -0700
>Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>> Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:
>> 
>> >The bond_close() calls cancel_delayed_work() to cancel delayed works.
>> >It, however, cannot cancel works that were already queued in workqueue.
>> >The bond_open() initializes work->data, and proccess_one_work() refers
>> >get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL when
>> >work->data has been initialized. Thus, a panic occurs.
>> >
>> >This patch uses flush_delayed_work_sync() instead of cancel_delayed_work()
>> >in bond_close(). It cancels delayed timer and waits for work to finish
>> >execution. So, it can avoid the null pointer dereference due to the
>> >parallel executions of proccess_one_work() and initializing proccess
>> >of bond_open().
>> 
>> 	I'm setting up to test this.  I have a dim recollection that we
>> tried this some years ago, and there was a different deadlock that
>> manifested through the flush path.  Perhaps changes since then have
>> removed that problem.
>> 
>> 	-J
>
>Won't this deadlock on RTNL.  The problem is that:
>
>   CPU0                            CPU1
>  rtnl_lock
>      bond_close
>                                 delayed_work
>                                   mii_work
>                                     read_lock(bond->lock);
>                                     read_unlock(bond->lock);
>                                     rtnl_lock... waiting for CPU0
>      flush_delayed_work_sync
>          waiting for delayed_work to finish...

	Yah, that was it.  We discussed this a couple of years ago in
regards to a similar patch:

http://lists.openwall.net/netdev/2009/12/17/3

	The short version is that we could rework the rtnl_lock inside
the montiors to be conditional and retry on failure (where "retry" means
"reschedule the work and try again later," not "spin retrying on rtnl").
That should permit the use of flush or cancel to terminate the work
items.

	I'll fiddle with it some later today and see if that seems
viable.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
