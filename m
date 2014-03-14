From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH V6 net-next 0/5] xen-net{back, front}: Multiple transmit and receive queues
Date: Fri, 14 Mar 2014 17:21:23 +0100
Message-ID: <405829732.20140314172123@eikelenboom.it>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com> <13310465521.20140306175259@eikelenboom.it> <1394813175.6442.135.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <wei.liu2@citrix.com>,
	<david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:41822 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbaCNQVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 12:21:30 -0400
In-Reply-To: <1394813175.6442.135.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, March 14, 2014, 5:06:15 PM, you wrote:

> On Thu, 2014-03-06 at 17:52 +0100, Sander Eikelenboom wrote:
>> Hi Andrew,
>> 
>> Just tried your series but i ran into this lockdep warning:

> In the guest (so netfront), correct?

Erhmm yes correct, sorry for not mentioning that.

>> 
>> [    0.932289]
>> [    0.932293] =============================================
>> [    0.932297] [ INFO: possible recursive locking detected ]
>> [    0.932302] 3.14.0-rc5-20140306-xennext-netnext-bennie+ #1 Not tainted
>> [    0.932306] ---------------------------------------------
>> [    0.932311] xenwatch/26 is trying to acquire lock:
>> [    0.932315]  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
>> [    0.932328]
>> [    0.932328] but task is already holding lock:
>> [    0.932333]  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
>> [    0.932343]
>> [    0.932343] other info that might help us debug this:
>> [    0.932348]  Possible unsafe locking scenario:
>> [    0.932348]
>> [    0.932353]        CPU0
>> [    0.932355]        ----
>> [    0.932358]   lock(&(&queue->rx_lock)->rlock);
>> [    0.932363]   lock(&(&queue->rx_lock)->rlock);
>> [    0.932367]
>> [    0.932367]  *** DEADLOCK ***
>> [    0.932367]
>> [    0.932372]  May be due to missing lock nesting notation
>> [    0.932372]
>> [    0.932378] 3 locks held by xenwatch/26:
>> [    0.935540]  #0:  (xenwatch_mutex){+.+.+.}, at: [<ffffffff81581d96>] xenwatch_thread+0x86/0x130
>> [    0.935540]  #1:  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
>> [    0.935540]  #2:  (&(&queue->tx_lock)->rlock){......}, at: [<ffffffff817b3101>] netback_changed+0xc91/0xea0
>> [    0.935540]
>> [    0.935540] stack backtrace:
>> [    0.935540] CPU: 1 PID: 26 Comm: xenwatch Not tainted 3.14.0-rc5-20140306-xennext-netnext-bennie+ #1
>> [    0.935540]  ffffffff82766230 ffff88001eac3b98 ffffffff81b83684 ffff88001e97d870
>> [    0.935540]  ffffffff82766230 ffff88001eac3c68 ffffffff81115b7e 00000000000233a0
>> [    0.935540]  ffffffff00000003 ffffffff82766230 ffffffff82ca7ec0 5001f47aeae10000
>> [    0.935540] Call Trace:
>> [    0.935540]  [<ffffffff81b83684>] dump_stack+0x46/0x58
>> [    0.935540]  [<ffffffff81115b7e>] __lock_acquire+0x86e/0x2220
>> [    0.935540]  [<ffffffff811e40be>] ? kfree+0x1ee/0x200
>> [    0.935540]  [<ffffffff81117b9d>] lock_acquire+0xbd/0x150
>> [    0.935540]  [<ffffffff817b30f4>] ? netback_changed+0xc84/0xea0
>> [    0.935540]  [<ffffffff81b8c4fe>] ? mutex_unlock+0xe/0x10
>> [    0.935540]  [<ffffffff817b00f4>] ? xennet_release_tx_bufs+0x104/0x110
>> [    0.935540]  [<ffffffff81b8d7cf>] _raw_spin_lock_bh+0x3f/0x50
>> [    0.935540]  [<ffffffff817b30f4>] ? netback_changed+0xc84/0xea0
>> [    0.935540]  [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
>> [    0.935540]  [<ffffffff815835f0>] xenbus_otherend_changed+0xb0/0xc0
>> [    0.935540]  [<ffffffff81581d10>] ? xs_watch+0x60/0x60
>> [    0.935540]  [<ffffffff815851d3>] backend_changed+0x13/0x20
>> [    0.935540]  [<ffffffff81581d55>] xenwatch_thread+0x45/0x130
>> [    0.935540]  [<ffffffff8110d590>] ? __init_waitqueue_head+0x60/0x60
>> [    0.935540]  [<ffffffff810ee394>] kthread+0xe4/0x100
>> [    0.935540]  [<ffffffff81b8ddb0>] ? _raw_spin_unlock_irq+0x30/0x50
>> [    0.935540]  [<ffffffff810ee2b0>] ? __init_kthread_worker+0x70/0x70
>> [    0.935540]  [<ffffffff81b8efbc>] ret_from_fork+0x7c/0xb0
>> [    0.935540]  [<ffffffff810ee2b0>] ? __init_kthread_worker+0x70/0x70
>> 
>> 
>> 
>> --
>> Sander
>> 
