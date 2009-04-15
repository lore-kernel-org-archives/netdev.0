From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to ifenslave a second interface to my bond
Date: Wed, 15 Apr 2009 11:11:53 -0700
Message-ID: <30789.1239819113@death.nxdomain.ibm.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com> <11276.1239757967@death.nxdomain.ibm.com> <1239814602.8944.593.camel@psmith-ubeta.netezza.com>
Cc: netdev@vger.kernel.org
To: paul@mad-scientist.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:36321 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbZDOSL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 14:11:56 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3FI1oQ9022885
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 14:01:50 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3FIBpvc3899616
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 14:11:51 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3FIBlit021510
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 12:11:47 -0600
In-reply-to: <1239814602.8944.593.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Smith <paul@mad-scientist.net> wrote:

>On Tue, 2009-04-14 at 18:12 -0700, Jay Vosburgh wrote:
>> 	I think I know what's going on.  I believe this patch will
>> resolve things, but I won't be able to test it until tomorrow.  If you
>> want to test this, great; if you want to wait, that's fine too.
>
>Hi Jay; as I mentioned last night this patch is working fine for me so
>far.

	Thanks for the test report.

>However, looking at the rest of this function it seems to me that there
>are other locking issues, at least based on the documentation in the
>header file:
>
> * Here are the locking policies for the two bonding locks:
> *
> * 1) Get bond->lock when reading/writing slave list.
> * 2) Get bond->curr_slave_lock when reading/writing bond->curr_active_slave.
> *    (It is unnecessary when the write-lock is put with bond->lock.)
> * 3) When we lock with bond->curr_slave_lock, we must lock with bond->lock
> *    beforehand.
>
>For example, don't you need to hold bond->curr_slave_lock at least
>around the "if (!bond->curr_active_slave)"?  What about around the
>"bond_for_each_slave" loop?
>
>Many of the other functions, later, also seem to work with
>bond->curr_active_slave and they don't take this lock.
>
>Unless I'm missing something, I think there are still more problems in
>the locking in bond_alb_set_mac_address().

	The various MAC manipulating functions are either called under
RTNL (as bond_alb_set_mac_address is) or take pains to acquire RTNL
before doing anything with the MAC.  Also, the slave list and
curr_active_slave are mutexed by RTNL, so those inspections should be
safe.

	I'm reasonably sure that the curr_slave_lock is superfluous
(which wasn't the case when it was originally introduced), but I haven't
had a chance to validate this.  The locking has changed from what's
documented in the header file; RTNL wasn't used for this when that was
written.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
