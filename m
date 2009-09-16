From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 3/7] [PATCH] iucv: use correct output register in iucv_query_maxconn()
Date: Wed, 16 Sep 2009 16:37:24 +0200
Message-ID: <20090916144304.399679000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:57144 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbZIPOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:03 -0400
Content-Disposition: inline; filename=602-iucv-query-maxconn.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

The iucv_query_maxconn() function uses the wrong output register and
stores the size of the interrupt buffer instead of the maximum number
of connections.

According to the QUERY IUCV function, general register 1 contains the
maximum number of connections.

If the maximum number of connections is not set properly, the following
warning is displayed:

Badness at /usr/src/kernel-source/2.6.30-39.x.20090806/net/iucv/iucv.c:1808
Modules linked in: netiucv fsm af_iucv sunrpc qeth_l3 dm_multipath dm_mod vmur qeth ccwgroup
CPU: 0 Tainted: G        W  2.6.30 #4
Process seq (pid: 16925, task: 0000000030e24a40, ksp: 000000003033bd98)
Krnl PSW : 0404200180000000 000000000053b270 (iucv_external_interrupt+0x64/0x224)
           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3
Krnl GPRS: 00000000011279c2 00000000014bdb70 0029000000000000 0000000000000029
           000000000053b236 000000000001dba4 0000000000000000 0000000000859210
           0000000000a67f68 00000000008a6100 000000003f83fb90 0000000000004000
           000000003f8c7bc8 00000000005a2250 000000000053b236 000000003fc2fe08
Krnl Code: 000000000053b262: e33010000021	clg	%r3,0(%r1)
           000000000053b268: a7440010		brc	4,53b288
           000000000053b26c: a7f40001		brc	15,53b26e
          >000000000053b270: c03000184134	larl	%r3,8434d8
           000000000053b276: eb220030000c	srlg	%r2,%r2,48
           000000000053b27c: eb6ff0a00004	lmg	%r6,%r15,160(%r15)
           000000000053b282: c0f4fffff6a7	brcl	15,539fd0
           000000000053b288: 4310a003		ic	%r1,3(%r10)
Call Trace:
([<000000000053b236>] iucv_external_interrupt+0x2a/0x224)
 [<000000000010e09e>] do_extint+0x132/0x190
 [<00000000001184b6>] ext_no_vtime+0x1e/0x22
 [<0000000000549f7a>] _spin_unlock_irqrestore+0x96/0xa4
([<0000000000549f70>] _spin_unlock_irqrestore+0x8c/0xa4)
 [<00000000002101d6>] pipe_write+0x3da/0x5bc
 [<0000000000205d14>] do_sync_write+0xe4/0x13c
 [<0000000000206a7e>] vfs_write+0xae/0x15c
 [<0000000000206c24>] SyS_write+0x54/0xac
 [<0000000000117c8e>] sysc_noemu+0x10/0x16
 [<00000042ff8defcc>] 0x42ff8defcc

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2009-09-15 12:25:32.000000000 +0200
+++ linux-2.6-patched/net/iucv/iucv.c	2009-09-15 12:25:32.000000000 +0200
@@ -362,7 +362,7 @@ static int iucv_query_maxconn(void)
 		"	srl	%0,28\n"
 		: "=d" (ccode), "+d" (reg0), "+d" (reg1) : : "cc");
 	if (ccode == 0)
-		iucv_max_pathid = reg0;
+		iucv_max_pathid = reg1;
 	kfree(param);
 	return ccode ? -EPERM : 0;
 }

