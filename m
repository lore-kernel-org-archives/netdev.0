From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for
 more than 120 seconds' after resume
Date: Thu, 05 Apr 2012 22:23:29 +0200
Message-ID: <1333657409.3494.22.camel@jlt3.sipsolutions.net>
References: <201204022157.05598.maciej.rutecki@gmail.com>
	 <201204052037.37497.maciej.rutecki@gmail.com>
	 <1333652183.3494.21.camel@jlt3.sipsolutions.net>
	 <201204052208.21270.maciej.rutecki@gmail.com>
	 (sfid-20120405_220856_703301_4FEFCE15)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: maciej.rutecki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:42719 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab2DEUXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 16:23:33 -0400
In-Reply-To: <201204052208.21270.maciej.rutecki@gmail.com> (sfid-20120405_220856_703301_4FEFCE15)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-05 at 22:08 +0200, Maciej Rutecki wrote:

> Dmesg when CONFIG_LOCKDEP is set:
> 
> http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/dmesg-lockdep.txt

Looks like rtl8169's fault:

[  240.541718] 2 locks held by ifconfig/4964:
[  240.541722]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8138c86c>]
rtnl_lock+0x12/0x14
[  240.541737]  #1:  (&tp->wk.mutex){+.+...}, at: [<ffffffffa00c1556>]
rtl_lock_work+0x12/0x14 [r8169]
[  360.350345] INFO: task nmbd:2378 blocked for more than 120 seconds.
[  360.353186] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  360.356124] nmbd            D ffffffff81a76ab8     0  2378      1
0x00000000
[  360.359078]  ffff88022f573ab8 0000000000000046 ffff880233aa8040
ffff88022f573fd8
[  360.362098]  ffff88022f573fd8 0000000000013a40 ffff8802351b8040
ffff880233aa8040
[  360.365170]  ffffffff814532aa 000000001e3e7680 ffffffff81a76ab0
ffff880233aa8040
[  360.368208] Call Trace:
[  360.371129]  [<ffffffff814532aa>] ? __mutex_lock_common+0x230/0x36e
[  360.374159]  [<ffffffff814543ca>] schedule+0x5f/0x61
[  360.377195]  [<ffffffff8145458e>] schedule_preempt_disabled+0x9/0xb
[  360.380240]  [<ffffffff814532b7>] __mutex_lock_common+0x23d/0x36e
[  360.383262]  [<ffffffff8138c86c>] ? rtnl_lock+0x12/0x14
[  360.386260]  [<ffffffff8139fe60>] ? netlink_lookup+0x2b/0x7e
[  360.389279]  [<ffffffff8138c86c>] ? rtnl_lock+0x12/0x14
[  360.392352]  [<ffffffff814534a7>] mutex_lock_nested+0x2a/0x31
[  360.395393]  [<ffffffff8138c86c>] rtnl_lock+0x12/0x14
[  360.398376]  [<ffffffff8138c87f>] rtnetlink_rcv+0x11/0x28
[  360.401292]  [<ffffffff813a1d9a>] netlink_unicast+0xe7/0x151
[  360.404192]  [<ffffffff813a2002>] netlink_sendmsg+0x1fe/0x236
[  360.407089]  [<ffffffff8136cd79>] sock_sendmsg+0xea/0x10d
[  360.409971]  [<ffffffff81080679>] ? lock_acquire+0xef/0xfe
[  360.412825]  [<ffffffff810e6bf8>] ? might_fault+0x40/0x90
[  360.415640]  [<ffffffff81080679>] ? lock_acquire+0xef/0xfe
[  360.418447]  [<ffffffff810e6bf8>] ? might_fault+0x40/0x90
[  360.421239]  [<ffffffff8108057e>] ? lock_release+0x175/0x181
[  360.424039]  [<ffffffff810e6c41>] ? might_fault+0x89/0x90
[  360.426896]  [<ffffffff8136b5ec>] ? copy_from_user+0x2a/0x2c
[  360.429661]  [<ffffffff8136e9e5>] sys_sendto+0x12a/0x16c
[  360.432430]  [<ffffffff8107d74f>] ? trace_hardirqs_off_caller
+0x33/0x90
[  360.435219]  [<ffffffff81455515>] ? retint_swapgs+0x13/0x1b
[  360.437978]  [<ffffffff81080a85>] ? trace_hardirqs_on_caller
+0x121/0x158
[  360.440795]  [<ffffffff8121250e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  360.443868]  [<ffffffff8145acb9>] system_call_fastpath+0x16/0x1b

johannes
