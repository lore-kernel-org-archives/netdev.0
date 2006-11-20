From: Aaron Straus <aaron@merfinllc.com>
Subject: Lockdep traceback under heavy load
Date: Mon, 20 Nov 2006 11:52:36 -0800
Message-ID: <20061120195236.GE25908@hydra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mmsmtp.merfinllc.com ([63.73.180.145]:47039 "EHLO
	mule.merfinllc.com") by vger.kernel.org with ESMTP id S966598AbWKTTwi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 14:52:38 -0500
Received: from mule.merfinllc.com (localhost [127.0.0.1])
	by mule.merfinllc.com (8.13.4/8.13.4/Debian-3sarge3) with ESMTP id kAKJqa6A010421
	for <netdev@vger.kernel.org>; Mon, 20 Nov 2006 11:52:37 -0800
Received: (from aaron@localhost)
	by mule.merfinllc.com (8.13.4/8.13.4/Submit) id kAKJqaEK010420
	for netdev@vger.kernel.org; Mon, 20 Nov 2006 11:52:36 -0800
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  I got a lockdep traceback recently.  The machine is a i386 dell
inspiron 700m running 2.6.19-rc6.  I was putting NFS through a workout
at the time.

This was the mount I was putting through a workout:

mamba:/export/data on /mnt/merfin/data type nfs
(ro,rsize=8192,wsize=8192,hard,intr,addr=...)

firefox was using a different mount to a different machine. 

  I sent this to Trond originally who suggested sending it to netdev.

  If you want any more information, let me know.

				Regards,
				=aaron=

Here is the traceback:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.19-rc6-asb #8
-------------------------------------------------------
firefox-bin/6488 is trying to acquire lock:
 (&mm->mmap_sem){----}, at: [<c0112d71>] do_page_fault+0x19f/0x562

but task is already holding lock:
 (sk_lock-AF_INET){--..}, at: [<c0298f90>] tcp_recvmsg+0x13/0x6fb

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (sk_lock-AF_INET){--..}:
       [<c012f75f>] add_lock_to_list+0x62/0x7e
       [<c013002c>] __lock_acquire+0x8b1/0x9a9
       [<c01303e2>] lock_acquire+0x5a/0x78
       [<c027288e>] lock_sock+0xce/0xdb
       [<c02ac2b7>] udp_sendmsg+0x36c/0x517
       [<c02b2b60>] inet_sendmsg+0x45/0x4f
       [<c0271cdf>] sock_sendmsg+0xda/0xf2
       [<c0272061>] kernel_sendmsg+0x3d/0x4e
       [<f8b7bfc9>] xs_udp_send_request+0x10d/0x295 [sunrpc]
       [<f8b7a53a>] xprt_transmit+0xd5/0x1d5 [sunrpc]
       [<f8b78e8e>] call_transmit+0x1d0/0x1fe [sunrpc]
       [<f8b7e0b3>] __rpc_execute+0x89/0x1be [sunrpc]
       [<f8b7e1fd>] rpc_execute+0x15/0x17 [sunrpc]
       [<f8bfef7e>] nfs_execute_read+0x3f/0x58 [nfs]
       [<f8bff7c3>] nfs_pagein_one+0x212/0x22a [nfs]
       [<f8bff941>] nfs_readpages+0x166/0x1d6 [nfs]
       [<c0142b51>] __do_page_cache_readahead+0x14b/0x20f
       [<c0142d22>] do_page_cache_readahead+0x48/0x51
       [<c013e7c0>] filemap_nopage+0x1a2/0x3ad
       [<c0148a65>] __handle_mm_fault+0x148/0x847
       [<c0112e11>] do_page_fault+0x23f/0x562
       [<c02cd101>] error_code+0x39/0x40
       [<ffffffff>] 0xffffffff

-> #0 (&mm->mmap_sem){----}:
       [<c012f6c7>] print_circular_bug_tail+0x30/0x66
       [<c012ff2b>] __lock_acquire+0x7b0/0x9a9
       [<c01303e2>] lock_acquire+0x5a/0x78
       [<c012c258>] down_read+0x50/0x61
       [<c0112d71>] do_page_fault+0x19f/0x562
       [<c02cd101>] error_code+0x39/0x40
       [<c01c6f4a>] copy_to_user+0x58/0x66
       [<c0277777>] memcpy_toiovec+0x34/0x5a
       [<c0277f71>] skb_copy_datagram_iovec+0x4d/0x1c1
       [<c02993ce>] tcp_recvmsg+0x451/0x6fb
       [<c0272a71>] sock_common_recvmsg+0x4d/0x62
       [<c0272157>] sock_recvmsg+0xe5/0xfe
       [<c02723d4>] sys_recvfrom+0x9d/0xec
       [<c0272459>] sys_recv+0x36/0x38
       [<c02725d3>] sys_socketcall+0x178/0x22d
       [<c0102eed>] sysenter_past_esp+0x56/0x8d
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by firefox-bin/6488:
 #0:  (sk_lock-AF_INET){--..}, at: [<c0298f90>] tcp_recvmsg+0x13/0x6fb

stack backtrace:
 [<c0103f18>] dump_trace+0x76/0x1ed
 [<c01040b5>] show_trace_log_lvl+0x26/0x3c
 [<c010441e>] show_trace+0x19/0x1b
 [<c0104446>] dump_stack+0x26/0x28
 [<c012f6f4>] print_circular_bug_tail+0x5d/0x66
 [<c012ff2b>] __lock_acquire+0x7b0/0x9a9
 [<c01303e2>] lock_acquire+0x5a/0x78
 [<c012c258>] down_read+0x50/0x61
 [<c0112d71>] do_page_fault+0x19f/0x562
 [<c02cd101>] error_code+0x39/0x40
DWARF2 unwinder stuck at error_code+0x39/0x40

Leftover inexact backtrace:

 [<c01c6f4a>] copy_to_user+0x58/0x66
 [<c0277777>] memcpy_toiovec+0x34/0x5a
 [<c0277f71>] skb_copy_datagram_iovec+0x4d/0x1c1
 [<c02993ce>] tcp_recvmsg+0x451/0x6fb
 [<c0272a71>] sock_common_recvmsg+0x4d/0x62
 [<c0272157>] sock_recvmsg+0xe5/0xfe
 [<c02723d4>] sys_recvfrom+0x9d/0xec
 [<c0272459>] sys_recv+0x36/0x38
 [<c02725d3>] sys_socketcall+0x178/0x22d
 [<c0102eed>] sysenter_past_esp+0x56/0x8d
 =======================

-- 
===================
Aaron Straus
aaron@merfinllc.com
