From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 05 Dec 2004 19:25:47 +0100
Message-ID: <41B352AB.4020700@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090208040808010503040206"
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>, Netdev <netdev@oss.sgi.com>,
        Martin Josefsson <gandalf@wlug.westbo.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090208040808010503040206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Lennert wrote:

> A dirty way, yes ;-)  Open up e1000_osdep.h and do:
>
> -#define E1000_READ_REG(a, reg) ( \
> -    readl((a)->hw_addr + \
> -        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
> +#define E1000_READ_REG(a, reg) ({ \
> +    unsigned long s, e, d, v; \
> +\
> +    (a)->mmio_reads++; \
> +    rdtsc(s, d); \
> +    v = readl((a)->hw_addr + \
> +        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)); \
> +    rdtsc(e, d); \
> +    e -= s; \
> +    printk(KERN_INFO "e1000: MMIO read took %ld clocks\n", e); \
> +    printk(KERN_INFO "e1000: in process %d(%s)\n", current->pid, current->comm); \
> +    dump_stack(); \
> +    v; \
> +})

Too dirty: rdtsc is not serializing, thus my Opteron happily reorders 
the read and the rdtsc and reports 9 cycles.
Attached is a longer patch that I usually use for microbenchmarks. I get 
around 506 cycles with it for an Opteron 2 GHz to the nForce 250 Gb nic 
(i.e. integrated nic in the chipset, just one HT hop):

Results - zero - shift 0
 40: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 :0 0 63 0 0 0 0 0 0 0 0 0 0 0 0 0
1e0: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 :0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0
Overflows: 0.
Sum: 100
 >>>>>>>>>>> benchmark overhead: 82 cycles
** reading register e08920b4
Results - readl - shift 0
240: 0 0 b 0 0 0 0 0 0 0 0 0 32 0 1 1 :0 0 0 0 0 0 a 0 0 0 0 0 0 0 0 0
260: 1a 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 :0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
300: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 :0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0
Overflows: 0.
Sum: 100
 >>>>>>>>>> total: 0x248, i.e. net 506 cycles.

--
    Manfred

--------------090208040808010503040206
Content-Type: text/plain;
 name="patch-perftest-forcedeth"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-perftest-forcedeth"

--- 2.6/drivers/net/forcedeth.c	2004-12-05 16:21:28.000000000 +0100
+++ build-2.6/drivers/net/forcedeth.c	2004-12-05 19:18:24.000000000 +0100
@@ -1500,6 +1500,131 @@
 	enable_irq(dev->irq);
 }
 
+int p_shift = 0;
+
+#define STAT_TABLELEN		16384
+static unsigned long totals[STAT_TABLELEN];
+static unsigned int overflows;
+
+static unsigned long long stime;
+static void start_measure(void)
+{
+	 __asm__ __volatile__ (
+		".align 64\n\t"
+	 	"pushal\n\t"
+		"cpuid\n\t"
+		"popal\n\t"
+		"rdtsc\n\t"
+		"movl %%eax,(%0)\n\t"
+		"movl %%edx,4(%0)\n\t"
+		: /* no output */
+		: "c"(&stime)
+		: "eax", "edx", "memory" );
+}
+
+static void end_measure(void)
+{
+static unsigned long long etime;
+	__asm__ __volatile__ (
+		"pushal\n\t"
+		"cpuid\n\t"
+		"popal\n\t"
+		"rdtsc\n\t"
+		"movl %%eax,(%0)\n\t"
+		"movl %%edx,4(%0)\n\t"
+		: /* no output */
+		: "c"(&etime)
+		: "eax", "edx", "memory" );
+	{
+		unsigned long time = (unsigned long)(etime-stime);
+		time >>= p_shift;
+		if(time < STAT_TABLELEN) {
+			totals[time]++;
+		} else {
+			overflows++;
+		}
+	}
+}
+
+static void clean_buf(void)
+{
+	memset(totals,0,sizeof(totals));
+	overflows = 0;
+}
+
+static void print_line(unsigned long* array)
+{
+	int i;
+	for(i=0;i<32;i++) {
+		if((i%32)==16)
+			printk(":");
+		printk("%lx ",array[i]); 
+	}
+}
+
+static void print_buf(char* caption)
+{
+	int i, other = 0;
+	printk("Results - %s - shift %d",
+		caption, p_shift);
+
+	for(i=0;i<STAT_TABLELEN;i+=32) {
+		int j;
+		int local = 0;
+		for(j=0;j<32;j++)
+			local += totals[i+j];
+
+		if(local) {
+			printk("\n%3x: ",i);
+			print_line(&totals[i]);
+			other += local;
+		}
+	}
+	printk("\nOverflows: %d.\n",
+		overflows);
+	printk("Sum: %d\n",other+overflows);
+}
+
+static void return_immediately(void *dummy)
+{
+}
+
+static void bench_readl(u8 __iomem *base)
+{ 
+	int i;
+
+	/* empty test measurement: */
+	printk("******** kernel cpu benchmark started **********\n");
+	clean_buf();
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(200);
+	for(i=0;i<100;i++) {
+		start_measure();
+		return_immediately(NULL);
+		return_immediately(NULL);
+		return_immediately(NULL);
+		return_immediately(NULL);
+		end_measure();
+	}
+	print_buf("zero");
+	clean_buf();
+
+	printk("** reading register %p\n", base);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(200);
+	for(i=0;i<100;i++) {
+		start_measure();
+		return_immediately(NULL);
+		return_immediately(NULL);
+		readl(base);
+		return_immediately(NULL);
+		return_immediately(NULL);
+		end_measure();
+	}
+	print_buf("readl");
+	clean_buf();
+}
+
 static int nv_open(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1635,6 +1760,8 @@
 		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 	spin_unlock_irq(&np->lock);
 
+	bench_readl(base + NvRegMulticastAddrB);
+	bench_readl(base + NvRegIrqStatus);
 	return 0;
 out_drain:
 	drain_ring(dev);

--------------090208040808010503040206--
