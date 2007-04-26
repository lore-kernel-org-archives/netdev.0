From: Sergey Vlasov <vsu@altlinux.ru>
Subject: [PATCH] [IPV4] nl_fib_lookup: Initialise res.r before
 fib_res_put(&res)
Date: Thu, 26 Apr 2007 19:44:44 +0400
Message-ID: <20070426194444.0f121293.vsu@altlinux.ru>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
	<alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
	<20070426052912.GA17402@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	security@kernel.org, netdev@vger.kernel.org, jaco@kroon.co.za
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mivlgu.ru ([81.18.140.87]:35615 "EHLO mail.mivlgu.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031293AbXDZP7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 11:59:36 -0400
In-Reply-To: <20070426052912.GA17402@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_IP_MULTIPLE_TABLES is enabled, the code in nl_fib_lookup()
needs to initialize the res.r field before fib_res_put(&res) - unlike
fib_lookup(), a direct call to ->tb_lookup does not set this field.

Signed-off-by: Sergey Vlasov <vsu@altlinux.ru>
---
 net/ipv4/fib_frontend.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

On Wed, 25 Apr 2007 22:29:12 -0700 Greg KH wrote:

> On Wed, Apr 25, 2007 at 01:15:12PM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Wed, 25 Apr 2007, Alexey Kuznetsov wrote:
> > > 
> > > Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> > > which resulted in infinite recursion and stack overflow.
> 
> Wait, I just had the bright idea of actually testing this before I
> pushed out a 2.6.20.9 kernel with another fix in it, and nope, still
> crashes, even with this patch  :(
> 
> Full stackdump in a picture (forgot to have netconsole running) at:
> 	http://www.kroah.com/netlink_oops.jpg

 Here is an oops from the 2.6.18 backport of that patch (just adjusted
 for whitespace changes):
 
 BUG: unable to handle kernel paging request at virtual address 80000007
  printing eip:
 c027a9f7
 *pde = 00000000
 Oops: 0002 [#1]
 SMP 
 Modules linked in: nfs lockd nfs_acl sunrpc af_packet dm_mod rtc tsdev psmouse ne2k_pci i2c_piix4 ide_cd cdrom serio_raw 8390 pcspkr i2c_core evdev ext2 mbcache ide_generic generic ide_disk piix ide_core
 CPU:    0
 EIP:    0060:[<c027a9f7>]    Not tainted VLI
 EFLAGS: 00010292   (2.6.18-std-smp-alt5.2 #2) 
 EIP is at fib_rule_put+0x6/0x38
 eax: 7fffffff   ebx: d626de10   ecx: 00000000   edx: 7fffffff
 esi: d7f523c0   edi: d6126bc0   ebp: d6909d1c   esp: d6909d08
 ds: 007b   es: 007b   ss: 0068
 Process netlink1 (pid: 1960, ti=d6908000 task=d7ec8bd0 task.ti=d6908000)
 Stack: d6126bc0 d6909d1c c0276778 00000202 d7e31400 00000000 00000000 00000000 
        00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
        00000000 00000000 00000000 00000000 00000000 00000000 00000000 00010000 
 Call Trace:
  [<c0276778>] nl_fib_input+0xf2/0x128
  [<c024a230>] netlink_data_ready+0x12/0x4c
  [<c0249234>] netlink_sendskb+0x19/0x30
  [<c024a212>] netlink_sendmsg+0x278/0x284
  [<c022cdc1>] sock_sendmsg+0xd0/0xeb
  [<c022de88>] sys_sendto+0x113/0x13d
  [<c022e883>] sys_socketcall+0x17b/0x261
  [<c0102e17>] syscall_call+0x7/0xb
 DWARF2 unwinder stuck at syscall_call+0x7/0xb
 Leftover inexact backtrace:
 Code: a1 c0 b3 3f c0 31 c9 89 da c7 44 24 04 d0 00 00 00 c7 04 24 08 00 00 00 e8 a6 eb fc ff 83 c4 10 5b 5e 5f 5d c3 83 ec 08 89 c2 90 <ff> 48 08 0f 94 c0 84 c0 74 25 83 7a 48 00 74 0f 59 59 8d 42 4c 
 EIP: [<c027a9f7>] fib_rule_put+0x6/0x38 SS:ESP 0068:d6909d08
  <0>Kernel panic - not syncing: Fatal exception in interrupt
 
 This does not exactly match your oops - probably due to different
 inlining, but looks sufficiently similar.  Was your test kernel
 configured with CONFIG_IP_MULTIPLE_TABLES=y (this 2.6.18 has it)?
 
 I have noticed that in two other places in fib_frontend.c the following
 code is used to initialize struct fib_result:
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r = NULL;
 #endif
 
 The .r field is initialized after a successful fib_lookup() call, but in
 places where ->tb_lookup is called directly this field needs to be
 initialized manually.  Calling fib_res_put() with uninitialized res.r
 pointer causes an oops; this patch fixes the problem.


diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cac06c4..444a56b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -777,6 +777,10 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb )
 							    .tos = frn->fl_tos,
 							    .scope = frn->fl_scope } } };
 
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	res.r = NULL;
+#endif
+
 	frn->err = -ENOENT;
 	if (tb) {
 		local_bh_disable();
-- 
1.5.1.1.197.g66b3
