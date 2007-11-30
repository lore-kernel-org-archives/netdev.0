From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH -mm] [RFC] I/OAT: Handle incoming udp through ioatdma
Date: Thu, 29 Nov 2007 17:27:36 -0800
Message-ID: <BAE9DCEF64577A439B3A37F36F9B691C03853691@orsmsx418.amr.corp.intel.com>
References: <BAE9DCEF64577A439B3A37F36F9B691C03853146@orsmsx418.amr.corp.intel.com> <1196379815.4450.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65464 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932616AbXK3B2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 20:28:38 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1196379815.4450.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal
>
>On Thu, 2007-29-11 at 12:08 -0800, Nelson, Shannon wrote:
>> [RFC] I/OAT: Handle incoming udp through ioatdma
>> 
>> From: Shannon Nelson <shannon.nelson@intel.com>
>> 
>> If the incoming udp packet is larger than 
>sysctl_udp_dma_copybreak, try
>> pushing it through the ioatdma asynchronous memcpy.  This is 
>very much
>> the
>> same as the tcp copy offload.  This is an RFC because we 
>know there are
>> stability problems under high traffic.
>
>
>What stability problems?

Under a heavy stress test combining TCP and UDP traffic we would get a
kernel panic from a NULL dereference in dma_unpin_iovec_pages().  Remove
this patch and the panic goes away.  Unfortunately, this problem is
below our priority line so it has received little attention since then.
We know of interest in this patch, however, so decided to release it
into the wild and see if it garners any other attention.

Part of the panic message:

Unable to handle kernel NULL pointer dereference at 0000000000000000
RIP: 
 [<ffffffff8025b406>] set_page_dirty_lock+0xe/0x3a
PGD 2b91f067 PUD 2a04b067 PMD 0 
Oops: 0002 [1] SMP 
CPU 5 
Modules linked in: ioatdma dca igb i2c_dev i2c_core e1000
Pid: 10998, comm: netserver Not tainted 2.6.22.9_CB-2.05_patched #1
RIP: 0010:[<ffffffff8025b406>]  [<ffffffff8025b406>]
set_page_dirty_lock+0xe/0x3a
RSP: 0018:ffff810028fedb68  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff81003afea648 RCX: ffff81002a382b88
RDX: ffff810028fedfd8 RSI: 0000000000000282 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000001 R09: 0000000000000000
R10: ffffffff806c13e0 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000001 R14: 0000000000000000 R15: ffff81003afea660
FS:  00002b23ba4177c0(0000) GS:ffff810001164e40(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000029831000 CR4: 00000000000006e0
Process netserver (pid: 10998, threadinfo ffff810028fec000, task
ffff81003a881590)
Stack:  ffff810039887c80 ffff81003afea648 ffff81003afea640
ffffffff8048545a
 fffffffffffffff4 ffff810028fedf38 ffff81003afea658 ffff81003afea670
 ffff81003afea640 ffffffff80485657 ffff81003afea660 0000000000000000
Call Trace:
 [<ffffffff8048545a>] dma_unpin_iovec_pages+0x31/0x6e
 [<ffffffff80485657>] dma_pin_iovec_pages+0x1c0/0x1d9
 [<ffffffff804ce479>] udp_recvmsg+0x94/0x43e
 [<ffffffff8049268e>] sock_common_recvmsg+0x30/0x45
 [<ffffffff80491013>] sock_recvmsg+0xd5/0xed
 [<ffffffff80518d48>] mutex_lock+0xd/0x1e
 [<ffffffff802425ff>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802564ca>] find_get_page+0x21/0x50
 [<ffffffff80258572>] filemap_nopage+0x180/0x2b0
 [<ffffffff80262b59>] __handle_mm_fault+0x404/0x9fc
 [<ffffffff80245b35>] getnstimeofday+0x32/0x8d
 [<ffffffff80245b35>] getnstimeofday+0x32/0x8d
 [<ffffffff80491dc8>] sys_recvfrom+0xe2/0x130
 [<ffffffff802445ca>] enqueue_hrtimer+0x64/0x6b
 [<ffffffff80244b18>] hrtimer_start+0xf2/0x104
 [<ffffffff80234d27>] do_setitimer+0x15e/0x329
 [<ffffffff80234fb9>] alarm_setitimer+0x35/0x65
 [<ffffffff8020935e>] system_call+0x7e/0x83


Code: f0 0f ba 6d 00 00 19 c0 85 c0 74 08 48 89 ef e8 89 ce ff ff 
RIP  [<ffffffff8025b406>] set_page_dirty_lock+0xe/0x3a
 RSP <ffff810028fedb68>
CR2: 0000000000000000

>
>Is there some magic sysctl_udp_dma_copybreak threshold value where you
>start seeing the benefit of IOAT-ing? Since you mentioned
>"students"<evil grin here>, it would be interesting to see data where
>udp starts benefitting.

As I said, this is low on our priority list, so this data has not been
gathered.

>cheers,
>jamal

Thanks for your interest.
sln
--
======================================================================
Mr. Shannon Nelson                 LAN Access Division, Intel Corp.
Shannon.Nelson@intel.com                I don't speak for Intel
(503) 712-7659                    Parents can't afford to be squeamish.
