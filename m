From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch] s390: fix arp_tbl lock usage in qeth
Date: Mon, 14 Aug 2006 08:53:33 +0200
Message-ID: <20060814065333.GA9592@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Frank Pavlic <fpavlic@de.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:44474 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751878AbWHNGxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 02:53:37 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.7/8.13.7) with ESMTP id k7E6raLD188616
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 06:53:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7E6vNvL153374
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 08:57:23 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7E6rZPD003005
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 08:53:36 +0200
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

qeth: bhs must be disabled when accessing neighbour tables.

=================================
[ INFO: inconsistent lock state ]
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
modprobe/529 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&tbl->lock){-+..}, at: [<0000000040809384>] qeth_init+0x384/0x4c4 [qeth]
{in-softirq-W} state was registered at:
  [<000000000005f356>] lock_acquire+0x8a/0xb0
  [<000000000030ff06>] _write_lock+0x52/0x6c
  [<000000000024e3ec>] neigh_periodic_timer+0xa8/0x254
  [<0000000000046888>] run_timer_softirq+0x1e4/0x278
  [<000000000004072c>] __do_softirq+0xb4/0x144
  [<000000000001f1b0>] do_softirq+0xec/0xf0
  [<0000000000040938>] irq_exit+0x90/0xa8
  [<000000000001c1c0>] do_extint+0x100/0x11c
  [<000000000001fbf0>] ext_no_vtime+0x1c/0x26
  [<00000000004df5ba>] tcp_init+0x10e/0x3c4
irq event stamp: 15707
hardirqs last  enabled at (15707): [<000000000030e080>] __mutex_unlock_slowpath+0x104/0x1b4
hardirqs last disabled at (15706): [<000000000030dfd8>] __mutex_unlock_slowpath+0x5c/0x1b4
softirqs last  enabled at (13036): [<00000000000407a2>] __do_softirq+0x12a/0x144
softirqs last disabled at (13029): [<000000000001f1b0>] do_softirq+0xec/0xf0

other info that might help us debug this:
no locks held by modprobe/529.

stack backtrace:
000000003e38b200 000000003e38fb30 0000000000000002 0000000000000000
       000000003e38fbd0 000000003e38fb48 000000003e38fb48 0000000000016744
       0000000000000000 0000000000000000 0000000000000000 0000000000000000
       000000003e38fb30 000000000000000c 000000003e38fb30 000000003e38fba0
       000000000031e9f8 0000000000016744 000000003e38fb30 000000003e38fb80
Call Trace:
([<00000000000166d2>] show_trace+0x166/0x16c)
 [<000000000001679e>] show_stack+0xc6/0xf8
 [<00000000000167fe>] dump_stack+0x2e/0x3c
 [<000000000005cef2>] print_usage_bug+0x26e/0x280
 [<000000000005dc50>] mark_lock+0x620/0x6c4
 [<000000000005eb8c>] __lock_acquire+0x750/0xe90
 [<000000000005f356>] lock_acquire+0x8a/0xb0
 [<000000000030ff06>] _write_lock+0x52/0x6c
 [<0000000040809384>] qeth_init+0x384/0x4c4 [qeth]
 [<0000000000069fe2>] sys_init_module+0xd6/0x2c8
 [<000000000001f4a4>] sysc_noemu+0x10/0x16
 [<000002000010dc9e>] 0x2000010dc9e

Cc: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 5fff1f9..e1327b8 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -8510,9 +8510,9 @@ static int
 qeth_ipv6_init(void)
 {
 	qeth_old_arp_constructor = arp_tbl.constructor;
-	write_lock(&arp_tbl.lock);
+	write_lock_bh(&arp_tbl.lock);
 	arp_tbl.constructor = qeth_arp_constructor;
-	write_unlock(&arp_tbl.lock);
+	write_unlock_bh(&arp_tbl.lock);
 
 	arp_direct_ops = (struct neigh_ops*)
 		kmalloc(sizeof(struct neigh_ops), GFP_KERNEL);
@@ -8528,9 +8528,9 @@ qeth_ipv6_init(void)
 static void
 qeth_ipv6_uninit(void)
 {
-	write_lock(&arp_tbl.lock);
+	write_lock_bh(&arp_tbl.lock);
 	arp_tbl.constructor = qeth_old_arp_constructor;
-	write_unlock(&arp_tbl.lock);
+	write_unlock_bh(&arp_tbl.lock);
 	kfree(arp_direct_ops);
 }
 #endif /* CONFIG_QETH_IPV6 */
