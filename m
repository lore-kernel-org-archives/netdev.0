From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] iucv: Fix mismerge again.
Date: Thu, 25 Sep 2008 13:09:07 +0200
Message-ID: <20080925110907.GA22433@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	Ursula Braun <braunu@de.ibm.com>,
	Peter Oberparleiter <peter.oberparleiter@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:46763 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbYIYLLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 07:11:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH] iucv: Fix mismerge again.

From: Heiko Carstens <heiko.carstens@de.ibm.com>

fb65a7c091529bfffb1262515252c0d0f6241c5c ("iucv: Fix bad merging.") fixed
a merge error, but in a wrong way. We now end up with the bug below.
This patch corrects the mismerge like it was intended.

BUG: scheduling while atomic: swapper/1/0x00000000
Modules linked in:
CPU: 1 Not tainted 2.6.27-rc7-00094-gc0f4d6d #9
Process swapper (pid: 1, task: 000000003fe7d988, ksp: 000000003fe838c0)
0000000000000000 000000003fe839b8 0000000000000002 0000000000000000
       000000003fe83a58 000000003fe839d0 000000003fe839d0 0000000000390de6
       000000000058acd8 00000000000000d0 000000003fe7dcd8 0000000000000000
       000000000000000c 000000000000000d 0000000000000000 000000003fe83a28
       000000000039c5b8 0000000000015e5e 000000003fe839b8 000000003fe83a00
Call Trace:
([<0000000000015d6a>] show_trace+0xe6/0x134)
 [<0000000000039656>] __schedule_bug+0xa2/0xa8
 [<0000000000391744>] schedule+0x49c/0x910
 [<0000000000391f64>] schedule_timeout+0xc4/0x114
 [<00000000003910d4>] wait_for_common+0xe8/0x1b4
 [<00000000000549ae>] call_usermodehelper_exec+0xa6/0xec
 [<00000000001af7b8>] kobject_uevent_env+0x418/0x438
 [<00000000001d08fc>] bus_add_driver+0x1e4/0x298
 [<00000000001d1ee4>] driver_register+0x90/0x18c
 [<0000000000566848>] netiucv_init+0x168/0x2c8
 [<00000000000120be>] do_one_initcall+0x3e/0x17c
 [<000000000054a31a>] kernel_init+0x1ce/0x248
 [<000000000001a97a>] kernel_thread_starter+0x6/0xc
 [<000000000001a974>] kernel_thread_starter+0x0/0xc
 iucv: NETIUCV driver initialized
initcall netiucv_init+0x0/0x2c8 returned with preemption imbalance

Cc: Peter Oberparleiter <peter.oberparleiter@de.ibm.com>
Cc: Ursula Braun <braunu@de.ibm.com>
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

If possible this should get in before 2.6.27.

 net/iucv/iucv.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/net/iucv/iucv.c
===================================================================
--- linux-2.6.orig/net/iucv/iucv.c
+++ linux-2.6/net/iucv/iucv.c
@@ -524,7 +524,6 @@ static int iucv_enable(void)
 	get_online_cpus();
 	for_each_online_cpu(cpu)
 		smp_call_function_single(cpu, iucv_declare_cpu, NULL, 1);
-	preempt_enable();
 	if (cpus_empty(iucv_buffer_cpumask))
 		/* No cpu could declare an iucv buffer. */
 		goto out_path;
@@ -547,7 +546,9 @@ out:
  */
 static void iucv_disable(void)
 {
+	get_online_cpus();
 	on_each_cpu(iucv_retrieve_cpu, NULL, 1);
+	put_online_cpus();
 	kfree(iucv_path_table);
 }
 
