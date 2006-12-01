From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen
Date: Fri, 1 Dec 2006 09:14:01 +0100
Message-ID: <17775.58441.678623.396102@robur.slu.se>
References: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
	<17774.39482.949953.625608@robur.slu.se>
	<456F15F7.3000700@candelatech.com>
	<20061130.201423.118625277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, Robert.Olsson@data.slu.se,
	adobriyan@gmail.com, pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:11244 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S967499AbWLAIOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 03:14:16 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061130.201423.118625277.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:

 > Agreed.
 > 
 > Robert, please fix this by using a completion so that we can
 > wait for the threads to start up, something like this:

Included. It passes my test but Alexey and others test.
Cheers.
				--ro

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 733d86d..a630a73 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -147,6 +147,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/wait.h>
+#include <linux/completion.h>
 #include <linux/etherdevice.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
@@ -160,7 +161,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.69: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)
@@ -206,6 +207,11 @@ static struct proc_dir_entry *pg_proc_di
 #define VLAN_TAG_SIZE(x) ((x)->vlan_id == 0xffff ? 0 : 4)
 #define SVLAN_TAG_SIZE(x) ((x)->svlan_id == 0xffff ? 0 : 4)
 
+struct pktgen_thread_info {
+       struct pktgen_thread *t;
+       struct completion *c;
+};
+
 struct flow_state {
 	__u32 cur_daddr;
 	int count;
@@ -3264,10 +3270,11 @@ out:;
  * Main loop of the thread goes here
  */
 
-static void pktgen_thread_worker(struct pktgen_thread *t)
+static void pktgen_thread_worker(struct pktgen_thread_info *info)
 {
 	DEFINE_WAIT(wait);
 	struct pktgen_dev *pkt_dev = NULL;
+	struct pktgen_thread *t = info->t;
 	int cpu = t->cpu;
 	sigset_t tmpsig;
 	u32 max_before_softirq;
@@ -3307,6 +3314,8 @@ static void pktgen_thread_worker(struct 
 	__set_current_state(TASK_INTERRUPTIBLE);
 	mb();
 
+        complete(info->c);
+
 	while (1) {
 
 		__set_current_state(TASK_RUNNING);
@@ -3518,6 +3527,8 @@ static struct pktgen_thread *__init pktg
 static int __init pktgen_create_thread(const char *name, int cpu)
 {
 	int err;
+	struct pktgen_thread_info info;
+        struct completion started;
 	struct pktgen_thread *t = NULL;
 	struct proc_dir_entry *pe;
 
@@ -3558,7 +3569,11 @@ static int __init pktgen_create_thread(c
 
 	t->removed = 0;
 
-	err = kernel_thread((void *)pktgen_thread_worker, (void *)t,
+	init_completion(&started);
+        info.t = t;
+        info.c = &started;
+
+	err = kernel_thread((void *)pktgen_thread_worker, (void *)&info,
 			  CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 	if (err < 0) {
 		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
@@ -3568,6 +3583,7 @@ static int __init pktgen_create_thread(c
 		return err;
 	}
 
+	wait_for_completion(&started);
 	return 0;
 }
 
