From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 4/4]  pktgen: Fix Initialization fail leak.
Date: Sun, 29 Jan 2006 23:21:28 -0200
Message-ID: <20060129232128.44e6022b@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751220AbWA3BYH@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Even if pktgen's thread initialization fails for all CPUs, the module
will be successfully loaded.

 This patch changes that behaivor, by returning error on module load time,
and also freeing all the resources allocated. It also prints a warning if a
thread initialization has failed.

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>


---

 net/core/pktgen.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

909df2e921dabd2f43f80f4fe067bf3b86fbc3cd
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index af310e5..3806068 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3136,11 +3136,24 @@ static int __init pg_init(void)
 	register_netdevice_notifier(&pktgen_notifier_block);
 
 	for_each_online_cpu(cpu) {
+		int err;
 		char buf[30];
 
 		sprintf(buf, "kpktgend_%i", cpu);
-		pktgen_create_thread(buf, cpu);
+		err = pktgen_create_thread(buf, cpu);
+		if (err)
+			printk("pktgen: WARNING: Cannot create thread for cpu %d (%d)\n",
+					cpu, err);
 	}
+
+	if (list_empty(&pktgen_threads)) {
+		printk("pktgen: ERROR: Initialization failed for all threads\n");
+		unregister_netdevice_notifier(&pktgen_notifier_block);
+		remove_proc_entry(PGCTRL, pg_proc_dir);
+		proc_net_remove(PG_PROC_DIR);
+		return -ENODEV;
+	}
+
 	return 0;
 }
 
-- 
1.1.5.g3480


-- 
Luiz Fernando N. Capitulino
