From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 00/04] pktgen: Fix Initialization fail leak.
Date: Mon, 23 Jan 2006 13:47:34 -0200
Message-ID: <20060123134734.4674646b.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932411AbWAWQMu@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Even if pktgen's thread initialization fails for all CPUs, the module
will be successfully loaded.

 This patch changes that behaivor, by returning error on module load time,
and also freeing all the resources allocated. It also prints a warning if a
thread initialization has failed.

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

 net/core/pktgen.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ccffcbb..83d875b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3132,11 +3132,24 @@ static int __init pg_init(void)
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
Luiz Fernando N. Capitulino
