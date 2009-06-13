From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/07: nf_log: fix sleeping function called from invalid context
Date: Sat, 13 Jun 2009 15:09:36 +0200 (MEST)
Message-ID: <20090613130935.2112.24077.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37042 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbZFMNJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 09:09:34 -0400
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 266d07cb1c9a0c345d7d3aea889f92062894059e
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Jun 13 12:21:10 2009 +0200

    netfilter: nf_log: fix sleeping function called from invalid contex=
t
   =20
    Fix regression introduced by 17625274 "netfilter: sysctl support of
    logger choice":
   =20
    BUG: sleeping function called from invalid context at /mnt/s390test=
/linux-2.6-tip/arch/s390/include/asm/uaccess.h:234
    in_atomic(): 1, irqs_disabled(): 0, pid: 3245, name: sysctl
    CPU: 1 Not tainted 2.6.30-rc8-tipjun10-02053-g39ae214 #1
    Process sysctl (pid: 3245, task: 000000007f675da0, ksp: 000000007eb=
17cf0)
    0000000000000000 000000007eb17be8 0000000000000002 0000000000000000
           000000007eb17c88 000000007eb17c00 000000007eb17c00 000000000=
0048156
           00000000003e2de8 000000007f676118 000000007eb17f10 000000000=
0000000
           0000000000000000 000000007eb17be8 000000000000000d 000000007=
eb17c58
           00000000003e2050 000000000001635c 000000007eb17be8 000000007=
eb17c30
    Call Trace:
    (=DD<00000000000162e6>=A8 show_trace+0x13a/0x148)
     =DD<00000000000349ea>=A8 __might_sleep+0x13a/0x164
     =DD<0000000000050300>=A8 proc_dostring+0x134/0x22c
     =DD<0000000000312b70>=A8 nf_log_proc_dostring+0xfc/0x188
     =DD<0000000000136f5e>=A8 proc_sys_call_handler+0xf6/0x118
     =DD<0000000000136fda>=A8 proc_sys_read+0x26/0x34
     =DD<00000000000d6e9c>=A8 vfs_read+0xac/0x158
     =DD<00000000000d703e>=A8 SyS_read+0x56/0x88
     =DD<0000000000027f42>=A8 sysc_noemu+0x10/0x16
   =20
    Use the nf_log_mutex instead of RCU to fix this.
   =20
    Reported-and-tested-by: Maran Pakkirisamy <maranpsamy@in.ibm.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index beb3731..2fefe14 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -248,14 +248,14 @@ static int nf_log_proc_dostring(ctl_table *table,=
 int write, struct file *filp,
 		rcu_assign_pointer(nf_loggers[tindex], logger);
 		mutex_unlock(&nf_log_mutex);
 	} else {
-		rcu_read_lock();
-		logger =3D rcu_dereference(nf_loggers[tindex]);
+		mutex_lock(&nf_log_mutex);
+		logger =3D nf_loggers[tindex];
 		if (!logger)
 			table->data =3D "NONE";
 		else
 			table->data =3D logger->name;
 		r =3D proc_dostring(table, write, filp, buffer, lenp, ppos);
-		rcu_read_unlock();
+		mutex_unlock(&nf_log_mutex);
 	}
=20
 	return r;
