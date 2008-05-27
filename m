From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup
 mode
Date: Tue, 27 May 2008 15:34:23 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0805271034010.18262@zuben.voltaire.com>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com>
 <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:32273 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755883AbYE0MeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 08:34:24 -0400
In-Reply-To: <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Second, bond_change_active_slave() is called on few occasions under write_lock_bh()
> which means it runs in atomic context. I was thinking that it might be better to
> invoke call_netdevice_notifiers() from thread context,

Sorry if I wasn't clear. As seen from the trace, current code indeed delivers the event
from a thread but the context is made atomic as of the _bh locking, so my question is whether
the context should be made not atomic before delivering the event (eg through queuing a work
struct to be executed later by the kernel work queue thread, etc)

Or


> Call Trace:
>  [<ffffffff804777d7>] schedule+0x98/0x57b
>  [<ffffffff80277836>] dbg_redzone1+0x16/0x1f
>  [<ffffffffa0106f22>] :ib_ipoib:ipoib_start_xmit+0x445/0x459
>  [<ffffffff802799c2>] kmem_cache_alloc_node+0x147/0x177
>  [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
>  [<ffffffff8022c99b>] __cond_resched+0x1c/0x43
>  [<ffffffff80477e11>] _cond_resched+0x2d/0x38
>  [<ffffffff802798a0>] kmem_cache_alloc_node+0x25/0x177
>  [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
>  [<ffffffff8041825e>] rtmsg_ifinfo+0x3a/0xd4
>  [<ffffffff80418335>] rtnetlink_event+0x3d/0x41
>  [<ffffffff8047b925>] notifier_call_chain+0x30/0x54
>  [<ffffffffa00a3d4b>] :bonding:bond_select_active_slave+0xb9/0xe8
>  [<ffffffffa00a495e>] :bonding:__bond_mii_monitor+0x43a/0x464
>  [<ffffffffa00a49e6>] :bonding:bond_mii_monitor+0x5e/0xaa
>  [<ffffffffa00a4988>] :bonding:bond_mii_monitor+0x0/0xaa
>  [<ffffffff8023d6fa>] run_workqueue+0x7f/0x107
>  [<ffffffff8023d782>] worker_thread+0x0/0xef
>  [<ffffffff8023d867>] worker_thread+0xe5/0xef
>  [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff8024055a>] kthread+0x3d/0x63
>  [<ffffffff8020c068>] child_rip+0xa/0x12
>  [<ffffffff8024051d>] kthread+0x0/0x63
>  [<ffffffff8020c05e>] child_rip+0x0/0x12
