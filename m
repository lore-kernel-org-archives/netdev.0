From: Andrew Morton <akpm@linux-foundation.org>
Subject: netlink locking warnings in 2.6.21-rc7-mm1
Date: Tue, 24 Apr 2007 12:42:50 -0700
Message-ID: <20070424124250.d55789cd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:52685 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423073AbXDXTmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 15:42:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l3OJgpTE007163
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 12:42:52 -0700
Received: from box (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id l3OJgox8017463
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 12:42:50 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://test.kernel.org/abat/84786/debug/console.log is saying

Starting udevd BUG: at kernel/mutex-debug.c:82 debug_mutex_unlock()

Call Trace:
 [<ffffffff80244b71>] debug_mutex_unlock+0x161/0x170
 [<ffffffff804b759c>] __mutex_unlock_slowpath+0x5c/0x160
 [<ffffffff80467902>] netlink_dump+0x82/0x1e0
 [<ffffffff8046a042>] netlink_dump_start+0x142/0x180
 [<ffffffff80461be0>] rtnl_dump_ifinfo+0x0/0x90
 [<ffffffff80461be0>] rtnl_dump_ifinfo+0x0/0x90
 [<ffffffff80461e26>] rtnetlink_rcv_msg+0xe6/0x240
 [<ffffffff80461d40>] rtnetlink_rcv_msg+0x0/0x240
 [<ffffffff80468bf9>] netlink_run_queue+0xb9/0x140
 [<ffffffff80461cc4>] rtnetlink_rcv+0x34/0x60
 [<ffffffff804690b2>] netlink_data_ready+0x12/0x50
 [<ffffffff80467bbb>] netlink_sendskb+0x2b/0x50
 [<ffffffff80468fc1>] netlink_sendmsg+0x221/0x300
 [<ffffffff8044d1cb>] sock_sendmsg+0xcb/0x100
 [<ffffffff8023f420>] autoremove_wake_function+0x0/0x30
 [<ffffffff80262d62>] __handle_mm_fault+0x1d2/0x8b0
 [<ffffffff8044c17e>] move_addr_to_kernel+0x2e/0x40
 [<ffffffff8044d5f6>] sys_sendto+0x146/0x1b0
 [<ffffffff8044dd6d>] move_addr_to_user+0x5d/0x70
 [<ffffffff8044e34b>] sys_getsockname+0xcb/0xe0
 [<ffffffff80209b5e>] system_call+0x7e/0x83

which is


static int netlink_dump(struct sock *sk)
{
	...
	len = cb->dump(skb, cb);

	if (len > 0) {
-->		mutex_unlock(nlk->cb_mutex);
		skb_queue_tail(&sk->sk_receive_queue, skb);
		sk->sk_data_ready(sk, len);
		return 0;
	}

and

void debug_mutex_unlock(struct mutex *lock)
{
	if (unlikely(!debug_locks))
		return;

-->	DEBUG_LOCKS_WARN_ON(lock->owner != current_thread_info());
	DEBUG_LOCKS_WARN_ON(lock->magic != lock);

so it's complaining that cb_mutex is being release by a thread other than
the one which acquired it.  I'm unable to reproduce it with their config,
naturally.

Can anyone see any conceivable way in which this can happen?  There's some
moderately tricky-looking rewriting of the ->cb_mutex pointer happening in
there.  If that were to happen concurrently then this might happen?

otoh, we're seeing several fairly unrelated whacko things coming out of the
lock debugging code in that kernel and I'm wondering if there's some common
bug which is causing false positives.

