From: Mathieu SEGAUD <mathieu.segaud@regala.cx>
Subject: Lockup with tun/tap/bridge interface deregistration.
Date: Wed, 10 Dec 2008 15:44:13 +0100
Message-ID: <87fxkwhyyq.fsf@barad-dur.regala.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kernel@gentoo.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from def92-3-81-56-114-101.fbx.proxad.net ([81.56.114.101]:48162
	"EHLO barad-dur.regala.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbYLJOxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 09:53:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

we are experiencing some "virtual" network interfaces problem, especially
with tun/tap devices and with bridges, which occasionally get stuck and
won't deregister and hang the destroying process for very long time.

I can reliably (*) reproduce it, with any kernel version I tested, with
this script:


#! /bin/sh

for run in $(seq 1 1000000); do

echo "Run #$run"

  brctl addbr vbr$run
  tunctl -t vif$run
  ifconfig vif$run up
  brctl addif vbr$run vif$run
  ifconfig vbr$run 30.30.30.30 up
  ifconfig vbr$run down
  brctl delif vbr$run vif$run
  ifconfig vif$run down
  tunctl -d vif$run
  brctl delbr vbr$run

done



The box is responsive when these "lockups" occur, but the brctl or the
tunctl processes can get stuck for hours. Here is a link to a complete
task dump at a time where brctl was stuck:
http://bugs.gentoo.org/attachment.cgi?id=174835&action=view

especially the brctl process dump:
brctl         D 00000000     0 19796  30706
       c0d72400 00200086 013c5000 00000000 c0441e80 c0441900 c0441900
       cada6370 
       cada6510 c1806900 00000001 0225d2fd 000178f0 c02e5bb8 cada6510
       c02e5a3a 
       f785c000 f785c000 c0129bf2 062bd8e0 d9f5aed8 f785c000 c02e5bb8
       c0129d48 
Call Trace:
 [<c02e5bb8>] _spin_unlock_irqrestore+0xe/0x21
 [<c02e5a3a>] _spin_lock_irqsave+0x11/0x2a
 [<c0129bf2>] lock_timer_base+0x19/0x35
 [<c02e5bb8>] _spin_unlock_irqrestore+0xe/0x21
 [<c0129d48>] __mod_timer+0x93/0x9c
 [<c02e4855>] schedule_timeout+0x7e/0x99
 [<c01298a3>] process_timeout+0x0/0x5
 [<c0129d5e>] msleep+0xd/0x12
 [<c0266b41>] netdev_run_todo+0xf7/0x19d
 [<f8a7f3c5>] br_del_bridge+0x48/0x4c [bridge]
 [<f8a7ff61>] br_ioctl_deviceless_stub+0x190/0x19f [bridge]
 [<c018a66c>] inotify_d_instantiate+0x12/0x3a
 [<c02e5c1b>] _spin_unlock+0xc/0x1f
 [<f8a7fdd1>] br_ioctl_deviceless_stub+0x0/0x19f [bridge]
 [<c025bf6e>] sock_ioctl+0x11f/0x1d9
 [<c025be4f>] sock_ioctl+0x0/0x1d9
 [<c0170cdc>] vfs_ioctl+0x1c/0x5f
 [<c0170f47>] do_vfs_ioctl+0x228/0x23b
 [<c025d76f>] sys_socketcall+0x51/0x19d
 [<c0170f86>] sys_ioctl+0x2c/0x42
 [<c01038a9>] sysenter_do_call+0x12/0x25
 [<c02e0000>] print_cpu_info+0x7e/0x92

(This one was obtained with kernel version 2.6.27.4)

We, at Gentoo, are asking any ideas to solve this. This is reproducible,
even if it is time-consuming. I will rerun and try to ger back here with
a task dump long enough to have all tasks, and more debugging info.

Thanks a lot for reading that much.


(*) reliably because it always happened even though I may have to wait
for hours 

Here is an entry in the Gentoo bugzilla reporting this:
http://bugs.gentoo.org/show_bug.cgi?id=219400

-- 
Mathieu Segaud
