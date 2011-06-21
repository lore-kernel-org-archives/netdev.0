From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/3] net: ipv4: fix potential memory leak by assigning uhash_entries
Date: Tue, 21 Jun 2011 16:43:38 -0400
Message-ID: <1308689020-1873-2-git-send-email-paul.gortmaker@windriver.com>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Mark Asselstine <mark.asselstine@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58226 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240Ab1FUUn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:43:59 -0400
In-Reply-To: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Asselstine <mark.asselstine@windriver.com>

Commit f86dcc5a [udp: dynamically size hash tables at boot time]
introduced the uhash_entries boot option and made sure to keep
it set within acceptable limits -- if used.  It did not assign a
default value, however, so it defaults to zero.  This results in
alloc_large_system_hash() being relied upon to specify an acceptable
number of hash entries, something it can't be relied on to always do
correctly. For example, when it fails to set an acceptable minimum
(UDP_HTABLE_SIZE_MIN) we get a second allocation and a memory leak.
So we need to set a default value for uhash_entries to ensure we get
the required minimum and prevent a second allocation.

This was found by using DEBUG_KMEMLEAK, producing the following log:

unreferenced object 0xc1b0d000 (size 4096):
  comm "swapper", pid 1, jiffies 4294667562 (age 136.225s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<c10e9027>] create_object+0xd7/0x210
    [<c15d73d7>] kmemleak_alloc+0x27/0x50
    [<c1877032>] alloc_large_system_hash+0x16d/0x1f7
    [<c189121d>] udp_table_init+0x43/0xf8
    [<c18912e4>] udp_init+0x12/0x74
    [<c1891637>] inet_init+0x179/0x250
    [<c10011f0>] do_one_initcall+0x30/0x160
    [<c18607c9>] kernel_init+0xb9/0x14e
    [<c15fcff6>] kernel_thread_helper+0x6/0xd
    [<ffffffff>] 0xffffffff

This is fairly easy to reproduce using ARCH=x86 defconfig (i386_defconfig)
enabling DEBUG_KMEMLEAK and running on a system with 32MB of memory
(qemu -m 32). With systems with larger amounts of memory we may not
see this leak since the logic in alloc_large_system_hash() will result
in a large enough (>UDP_HTABLE_SIZE_MIN) number of entries being set.

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/ipv4/udp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index abca870..6f53a5a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2155,7 +2155,7 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-static __initdata unsigned long uhash_entries;
+static __initdata unsigned long uhash_entries = UDP_HTABLE_SIZE_MIN;
 static int __init set_uhash_entries(char *str)
 {
 	if (!str)
-- 
1.7.4.4

