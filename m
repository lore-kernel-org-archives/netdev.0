From: David Miller <davem@davemloft.net>
Subject: Re: bluetooth lockdep trace. (.25rc5-git4)
Date: Fri, 28 Mar 2008 18:20:21 -0700 (PDT)
Message-ID: <20080328.182021.46780895.davem@davemloft.net>
References: <20080327162156.GA8098@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hidave.darkstar@gmail.com
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752868AbYC2BUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:20:21 -0400
In-Reply-To: <20080327162156.GA8098@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Thu, 27 Mar 2008 12:21:56 -0400

> Mar 27 08:10:57 localhost kernel: Pid: 3611, comm: obex-data-serve Not tainted 2.6.25-0.121.rc5.git4.fc9 #1
> Mar 27 08:10:57 localhost kernel:  [__lock_acquire+2287/3089] __lock_acquire+0x8ef/0xc11
> Mar 27 08:10:57 localhost kernel:  [sched_clock+8/11] ? sched_clock+0x8/0xb
> Mar 27 08:10:57 localhost kernel:  [lock_acquire+106/144] lock_acquire+0x6a/0x90
> Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
> Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+182/198] lock_sock_nested+0xb6/0xc6
> Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
> Mar 27 08:10:57 localhost kernel:  [security_socket_post_create+22/27] ? security_socket_post_create+0x16/0x1b
> Mar 27 08:10:57 localhost kernel:  [__sock_create+388/472] ? __sock_create+0x184/0x1d8
> Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] l2cap_sock_bind+0x29/0x108 [l2cap]
> Mar 27 08:10:57 localhost kernel:  [kernel_bind+10/13] kernel_bind+0xa/0xd
> Mar 27 08:10:57 localhost kernel:  [<f8dad3d7>] rfcomm_dlc_open+0xc8/0x294 [rfcomm]
> Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+187/198] ? lock_sock_nested+0xbb/0xc6
> Mar 27 08:10:57 localhost kernel:  [<f8dae18c>] rfcomm_sock_connect+0x8b/0xc2 [rfcomm]
> Mar 27 08:10:57 localhost kernel:  [sys_connect+96/125] sys_connect+0x60/0x7d
> Mar 27 08:10:57 localhost kernel:  [__lock_acquire+1370/3089] ? __lock_acquire+0x55a/0xc11
> Mar 27 08:10:57 localhost kernel:  [sys_socketcall+140/392] sys_socketcall+0x8c/0x188
> Mar 27 08:10:57 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb

rfcomm connect locks the socket, then does rfcomm_dlc_open which in
turn can do a l2cap_sock_bind on a seperate second socket which in
turn locks that second socket.

Both of these sockets are AF_BLUETOOTH family, so lockdep thinks there
is a locking conflict, even though what is happening here is perfectly
fine since the two sockets are totally different AF_BLUETOOTH
sub-types.

Bluetooth will need to use sock_lock_init_class_and_name() and
lock sub-classes per AF_BLUETOOTH socket sub-type.

David, could you or someone else work on this?

Thanks!

