From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Flow cache flush oops
Date: Thu, 19 Jun 2003 19:35:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619093518.GA27025@gondor.apana.org.au>
References: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com> <20030619000704.GA25135@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tom Lendacky <toml@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20030619000704.GA25135@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 19, 2003 at 10:07:04AM +1000, herbert wrote:
> 
> Thanks, you've found two bugs in my code :) Firstly it's only initialising
> one CPU so only that one has a flow cache.  Secondly flow_flush_cache is
> not checking whether the calling CPU has been initialised.
> 
> I'll post a patch tonight.

Here is the patch.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/net/core/flow.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/core/flow.c,v
retrieving revision 1.5
diff -u -r1.5 flow.c
--- kernel-source-2.5/net/core/flow.c	13 Jun 2003 11:22:17 -0000	1.5
+++ kernel-source-2.5/net/core/flow.c	19 Jun 2003 09:23:38 -0000
@@ -300,7 +300,8 @@
 
 	local_bh_disable();
 	smp_call_function(flow_cache_flush_per_cpu, &info, 1, 0);
-	flow_cache_flush_tasklet((unsigned long)&info);
+	if (test_bit(smp_processor_id(), &info.cpumap))
+		flow_cache_flush_tasklet((unsigned long)&info);
 	local_bh_enable();
 
 	wait_for_completion(&info.completion);
@@ -308,12 +309,13 @@
 	up(&flow_flush_sem);
 }
 
-static void __devinit flow_cache_cpu_online(int cpu)
+static void __devinit flow_cache_cpu_prepare(int cpu)
 {
 	struct tasklet_struct *tasklet;
 	unsigned long order;
 
 	flow_hash_rnd_recalc(cpu) = 1;
+	flow_count(cpu) = 0;
 
 	for (order = 0;
 	     (PAGE_SIZE << order) <
@@ -328,7 +330,10 @@
 
 	tasklet = flow_flush_tasklet(cpu);
 	tasklet_init(tasklet, flow_cache_flush_tasklet, 0);
+}
 
+static void __devinit flow_cache_cpu_online(int cpu)
+{
 	down(&flow_cache_cpu_sem);
 	set_bit(cpu, &flow_cache_cpu_map);
 	flow_cache_cpu_count++;
@@ -341,6 +346,9 @@
 	unsigned long cpu = (unsigned long)cpu;
 	switch (action) {
 	case CPU_UP_PREPARE:
+		flow_cache_cpu_prepare(cpu);
+		break;
+	case CPU_ONLINE:
 		flow_cache_cpu_online(cpu);
 		break;
 	}
@@ -353,6 +361,8 @@
 
 static int __init flow_cache_init(void)
 {
+	int i;
+
 	flow_cachep = kmem_cache_create("flow_cache",
 					sizeof(struct flow_cache_entry),
 					0, SLAB_HWCACHE_ALIGN,
@@ -370,8 +380,12 @@
 	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
 	add_timer(&flow_hash_rnd_timer);
 
-	flow_cache_cpu_online(smp_processor_id());
 	register_cpu_notifier(&flow_cache_cpu_nb);
+	for (i = 0; i < NR_CPUS; i++)
+		if (cpu_online(i)) {
+			flow_cache_cpu_prepare(i);
+			flow_cache_cpu_online(i);
+		}
 
 	return 0;
 }

--y0ulUmNC+osPPQO6--
