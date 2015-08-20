From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: DEBUG_LOCKS_WARN_ON(in_interrupt()) triggering in socket code
Date: Thu, 20 Aug 2015 02:39:03 +0200
Message-ID: <CAHmME9p06qf36RPtROF767c5p37PggN12bSa9u8ZXgGGThA4BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:58302 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbbHTAjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

In setting up a socket, there are two functions I make use of that in
turn wind up calling static_key_slow_inc: setup_udp_tunnel_sock and
sk_set_memalloc. These both make use of static_key_slow_inc because
they selectively enable certain important code paths.

This is all fine, except it poses some problems when calling these
functions inside of .ndo_open. In that case, I get ugly (debug)
warnings like this:

WARNING: CPU: 1 PID: 2002 at kernel/locking/mutex.c:526
mutex_lock_nested+0x39b/0x3b0()
DEBUG_LOCKS_WARN_ON(in_interrupt())
 [<ffffffff81621d0e>] dump_stack+0x45/0x57
 [<ffffffff810505ca>] warn_slowpath_common+0x8a/0xc0
 [<ffffffff81050655>] warn_slowpath_fmt+0x55/0x70
 [<ffffffff8162513b>] mutex_lock_nested+0x39b/0x3b0
 [<ffffffff8113d699>] static_key_slow_inc+0x59/0xc0
 [<ffffffff8154ebc0>] udp_encap_enable+0x20/0x30
 [<ffffffff8157a885>] setup_udp_tunnel_sock+0x55/0x70
 [<ffffffff816028ac>] socket_init+0x1cc/0x3a0
 [<ffffffff81600341>] open+0x21/0x1b0
 [<ffffffff81476af0>] __dev_open+0xb0/0x110
 [<ffffffff81476e01>] __dev_change_flags+0xa1/0x160
 [<ffffffff81476ee9>] dev_change_flags+0x29/0x70
 [<ffffffff8148652a>] do_setlink+0x5da/0xa80
 [<ffffffff81487bed>] rtnl_newlink+0x50d/0x8a0
 [<ffffffff81485141>] rtnetlink_rcv_msg+0xa1/0x240
 [<ffffffff8149f1fb>] netlink_rcv_skb+0x9b/0xc0
 [<ffffffff8148508e>] rtnetlink_rcv+0x2e/0x40
 [<ffffffff8149ec3f>] netlink_unicast+0x16f/0x200
 [<ffffffff8149f009>] netlink_sendmsg+0x339/0x380
 [<ffffffff814559d9>] ___sys_sendmsg+0x2f9/0x310
 [<ffffffff814566d7>] __sys_sendmsg+0x57/0xa0
 [<ffffffff81456732>] SyS_sendmsg+0x12/0x20
 [<ffffffff816295b2>] entry_SYSCALL_64_fastpath+0x16/0x7a

The reason is that the static key code makes use of mutexes. And the
mutex debug code ensures that in_interrupt() is zero; otherwise it
prints that warning. In this case, in_interrupt() has a value of 512.

So, questions:

1. Is the best thing to do just move my socket creation routine into a
workqueue, and avoid this issue all together?
2. Is it, in fact, incorrect to check for in_interrupt(), and the
debug assertion is actually wrong?
3. Is it a bug that in_interrupt() is returning non-zero in relation
to a syscall?

Thanks,
Jason
