From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 01 Sep 2010 12:46:30 -0700
Message-ID: <10270.1283370390@death>
References: <20136.1283288063@death> <20100901122356.GB9468@ff.dom.local> <20100901133056.GB12447@midget.suse.cz> <20100901151856.GB3091@del.dom.local> <20100901153730.GC3091@del.dom.local> <20100901190037.GA3030@del.dom.local> <20100901191106.GB25227@midget.suse.cz> <20100901192026.GA3151@del.dom.local>
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, chavey@google.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38351 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab0IATqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 15:46:38 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o81JW9GS010182
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 15:32:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o81JkbTU217036
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 15:46:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o81JkZ9V025662
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 16:46:37 -0300
In-reply-to: <20100901192026.GA3151@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:

>On Wed, Sep 01, 2010 at 09:11:06PM +0200, Jiri Bohac wrote:
>> On Wed, Sep 01, 2010 at 09:00:37PM +0200, Jarek Poplawski wrote:
>> > On Wed, Sep 01, 2010 at 05:37:30PM +0200, Jarek Poplawski wrote:
>> > > On Wed, Sep 01, 2010 at 05:18:56PM +0200, Jarek Poplawski wrote:
>> > > > On Wed, Sep 01, 2010 at 03:30:56PM +0200, Jiri Bohac wrote:
>> > > > > On Wed, Sep 01, 2010 at 12:23:56PM +0000, Jarek Poplawski wrote:
>> > > > > > On 2010-08-31 22:54, Jay Vosburgh wrote:
>> > > > > > > 	What prevents this from deadlocking such that cpu A is in
>> > > > > > > bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
>> > > > > > > in the above function, trying to acquire RTNL?
>> > > > > > 
>> > > > > > I guess this one isn't cancelled in bond_close, so it should be safe.
>> > > > > 
>> > > > > Nah, Jay was correct. Although this work item is not explicitly
>> > > > > cancelled with cancel_delayed_work_sync(), it is on the same
>> > > > > workqueue as work items that are being cancelled with
>> > > > > cancel_delayed_work_sync(), so this can still cause a deadlock.
>> > > > > Fixed in the new version of the patch by putting these on a
>> > > > > separate workqueue.
>> > > > > 
>> > > > 
>> > > > Maybe I miss something, but the same workqueue shouldn't matter here.
>> > > 
>> > > Hmm... I missed your point completely and Jay was correct!
>> > 
>> > Hmm#2... Alas, after getting back my sobriety, I've to say that Jay
>> > was wrong: the same workqueue shouldn't matter here. Similar things
>> > are done by other network code with the kernel-global workqueue, eg.
>> > in tg3_close(), rhine_close() etc. 
>> 
>> But these don't do rtnl_lock() inside the work item, do they?
>
>Exactly. Just like work items cancelled from bond_work_cancel_all()
>after your patch.

	I see what Jarek is getting at here: the mii_commit, etc, work
items new to the patch aren't cancelled by bond_close, so bond_close (in
cancel_delayed_work_sync) shouldn't care if they're executing or not.

	This still would leave the new work items (the "commit" ones
added in the patch) always free to run at some arbitrary time after
close, which makes me uneasy.  I don't think the extra "wq_rtnl" makes
any difference, though.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
