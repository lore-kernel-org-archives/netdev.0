From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 00/03] pktgen: Fix kernel_thread() fail leak.
Date: Mon, 23 Jan 2006 13:46:14 -0200
Message-ID: <20060123134614.90d92a45.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932356AbWAWQMy@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Leak fix: free all the alocated resources if kernel_thread() call fails.

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

 net/core/pktgen.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ee26c69..ccffcbb 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2998,6 +2998,7 @@ static struct pktgen_thread *__init pktg
 
 static int __init pktgen_create_thread(const char *name, int cpu)
 {
+	int err;
 	struct pktgen_thread *t = NULL;
 	struct proc_dir_entry *pe;
 
@@ -3036,9 +3037,15 @@ static int __init pktgen_create_thread(c
 
 	t->removed = 0;
 
-	if (kernel_thread((void *)pktgen_thread_worker, (void *)t,
-			  CLONE_FS | CLONE_FILES | CLONE_SIGHAND) < 0)
+	err = kernel_thread((void *)pktgen_thread_worker, (void *)t,
+			  CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
+	if (err < 0) {
 		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
+		remove_proc_entry(t->name, pg_proc_dir);
+		list_del(&t->th_list);
+		kfree(t);
+		return err;
+	}
 
 	return 0;
 }


-- 
Luiz Fernando N. Capitulino
