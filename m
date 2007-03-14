From: Patrick McHardy <kaber@trash.net>
Subject: Re: fib_hash removal
Date: Wed, 14 Mar 2007 23:49:56 +0100
Message-ID: <45F87C14.8010404@trash.net>
References: <20070314.154414.97293857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se, tgr@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48815 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbXCNWuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 18:50:04 -0400
In-Reply-To: <20070314.154414.97293857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Another thing I'd like to accomplish is to kill off
> fib_hash leaving just fib_trie.
> 
> I can't do that until any and all functionality regressions
> which may or may not exist in fib_trie vs. fib_hash are
> discussed and resolved.
> 
> So can we start composing a list of stuff to look into in this
> thread so work can begin in that area?

I noticed this a couple of times, but didn't manage to look
into it yet:

BUG: sleeping function called from invalid context at mm/slab.c:3032
in_atomic():1, irqs_disabled():0
no locks held by ip/14309.

Call Trace:
 [<ffffffff810956e9>] debug_show_held_locks+0x9/0xb
 [<ffffffff8100b0b0>] __might_sleep+0xd9/0xdb
 [<ffffffff8100f745>] __kmalloc_track_caller+0x67/0x10f
 [<ffffffff810aaff1>] __kzalloc+0x15/0x2f
 [<ffffffff811fc5a5>] tnode_new+0x55/0x122
 [<ffffffff811fcc88>] resize+0x616/0x966
 [<ffffffff811d2e08>] nlmsg_notify+0x43/0x6f
 [<ffffffff811fd074>] trie_rebalance+0x9c/0xef
 [<ffffffff811fd231>] trie_leaf_remove+0x16a/0x1c2
 [<ffffffff811fd7aa>] fn_trie_delete+0x150/0x1fc
 [<ffffffff811f94a3>] inet_rtm_delroute+0x37/0x3e
 [<ffffffff811c7237>] rtnetlink_rcv_msg+0x1ba/0x1dd
 [<ffffffff811d2ee8>] netlink_run_queue+0x72/0xfa
 [<ffffffff811c707d>] rtnetlink_rcv_msg+0x0/0x1dd
 [<ffffffff811c7028>] rtnetlink_rcv+0x32/0x50
 [<ffffffff811d32b9>] netlink_data_ready+0x1a/0x59
 [<ffffffff811d24bf>] netlink_sendskb+0x29/0x44
 [<ffffffff811d2bf2>] netlink_unicast+0x1e5/0x204
 [<ffffffff811d328a>] netlink_sendmsg+0x270/0x285
 [<ffffffff81051215>] sock_sendmsg+0xdf/0xf8
 [<ffffffff81090aac>] autoremove_wake_function+0x0/0x38
 [<ffffffff81090aac>] autoremove_wake_function+0x0/0x38
 [<ffffffff81008b4f>] __handle_mm_fault+0x5f7/0xb09
 [<ffffffff81020ab8>] __up_read+0x1a/0x83
 [<ffffffff811b734b>] move_addr_to_kernel+0x25/0x35
 [<ffffffff811bd1a7>] verify_iovec+0x4f/0x91
 [<ffffffff811b7e4d>] sys_sendmsg+0x1de/0x250
 [<ffffffff81092d7c>] up_read+0x26/0x2a
 [<ffffffff8106315f>] do_page_fault+0x407/0x765
 [<ffffffff81060cdb>] _spin_unlock_irqrestore+0x4c/0x69
 [<ffffffff8102e6e9>] __up_write+0xf0/0xff
 [<ffffffff81060249>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff8105a11e>] system_call+0x7e/0x83

Reproducable by running:

for i in $(seq 0 255); do ip r a 1.$i.1.1/32 dev lo; done
for i in $(seq 0 255); do ip r d 1.$i.1.1/32 dev lo; done

