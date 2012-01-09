From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Mon, 09 Jan 2012 11:36:29 -0800
Message-ID: <15858.1326137789@death>
References: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com> <7449.1325885605@death> <20120107.101450.2214394343146869929.davem@davemloft.net> <4F0B3923.4020707@oracle.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, amwang@redhat.com
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:54198 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933057Ab2AIThS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 14:37:18 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 9 Jan 2012 14:37:17 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09JabXg338850
	for <netdev@vger.kernel.org>; Mon, 9 Jan 2012 14:36:39 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09JaVTc024806
	for <netdev@vger.kernel.org>; Mon, 9 Jan 2012 12:36:33 -0700
In-reply-to: <4F0B3923.4020707@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Uvarov <maxim.uvarov@oracle.com> wrote:

>On 01/07/2012 10:14 AM, David Miller wrote:
>> From: Jay Vosburgh<fubar@us.ibm.com>
>> Date: Fri, 06 Jan 2012 13:33:25 -0800
>>
>>> Maxim Uvarov<maxim.uvarov@oracle.com>  wrote:
>>>
>>>> No need to lock soft irqs under bond_alb_xmit()
>>>> which already has softirq disabled.
>>>
>>> 	In commit:
>>>
>>> commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
>>> Author: Jay Vosburgh<fubar@us.ibm.com>
>>> Date:   Wed Oct 17 17:37:50 2007 -0700
>>>
>>>      bonding: Convert more locks to _bh, acquire rtnl, for new locking
>>>
>>>          Convert more lock acquisitions to _bh flavor to avoid deadlock
>>>      with workqueue activity and add acquisition of RTNL in appropriate places.
>>>      Affects ALB mode, as well as core bonding functions and sysfs.
>>>
>>>      Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
>>>      Signed-off-by: Jay Vosburgh<fubar@us.ibm.com>
>>>      Signed-off-by: Jeff Garzik<jeff@garzik.org>
>>>
>>> 	the _lock_tx_hashtbl was upgraded from regular to _bh to prevent
>>> deadlocks.  I don't recall right offhand what deadlock this prevented,
>>> but are we sure there are no possible issues with converting this lock
>>> back to a non-_bh acquisition?
>>
>> Maxim's patch is not changing the BH'ness of the list.
>>
>>
>> He's just avoiding a BH disable which is unnecessary because BH is
>> already disabled in the effected code path(s).
>>
>
>Yes, I only removed disabling BH for tlb_choose_channel(). In other places
>this lock still disables BH. This makes lock more accurate,
>because there are 2 paths for execution: 1. dev_queue_xmit() and BH
>are already disabled. 2. netpoll and irqs are disabled. So no need to
>enable/disable BH.

	The tlb_choose_channel and rlb_choose_channel parts look to be
as you describe, but you also modify tlb_clear_slave:

--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -135,7 +135,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 	struct tlb_client_info *tx_hash_table;
 	u32 index;

-	_lock_tx_hashtbl(bond);
+	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));

	This makes tlb_clear_slave acquire the tx_hashtbl_lock without
_bh.  The tlb_clear_slave function is called from multiple places
without already holding _bh, in addition to the call paths you list.
The cases I see are:

	bond_alb_monitor (which runs from a workqueue)

	bond_alb_handle_link_change (called from bond_miimon_commit,
from a workqueue)

	bond_alb_deinit_slave (called during slave removal)

	All three of these will call into tlb_clear_slave without
already holding something at _bh.  These paths do not enter
tlb_clear_slave through tlb_choose_channel or rlb_choose_channel.

	Are we sure this does not open a window wherein the non-_bh path
into tlb_clear_slave could deadlock against the with-_bh path?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
