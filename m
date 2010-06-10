From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH 2/2] pktgen: receive packets and process incoming rate
Date: Thu, 10 Jun 2010 16:05:11 +0200
Message-ID: <4C10F117.60800@gmail.com>
References: <4C06453B.1080801@gmail.com> <1275483650.2725.173.camel@edumazet-laptop> <4C065C7C.4000506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@herjulf.net, jens.laas@its.uu.se,
	voravit@kth.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50018 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758780Ab0FJOFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 10:05:08 -0400
Received: by fxm8 with SMTP id 8so4331169fxm.19
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 07:05:06 -0700 (PDT)
In-Reply-To: <4C065C7C.4000506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds receiver part to pktgen taking advantages of SMP systems
with multiple rx queues:
- Creation of new proc file  /proc/net/pktgen/pgrx to control and display the receiver.
- It uses PER-CPU variable to store the results per each CPU.
- Results displayed per CPU and aggregated.
- The packet handler is add in the protocols handlers (dev_add_pack())
- Available statistics: packets and bytes received, work time and rate
- Only process pktgen packets
- It is possible to select the incoming interface 
- Documentation updated with the new commands to control the receiver part.

Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

---
diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index ac0e4ff..ed3016a 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -22,7 +22,7 @@ For monitoring and control pktgen creates:
 	/proc/net/pktgen/pgctrl
 	/proc/net/pktgen/kpktgend_X
         /proc/net/pktgen/ethX
-
+	/proc/net/pktgen/pgrx
 
 Viewing threads
 ===============
@@ -155,6 +155,42 @@ Examples:
  pgset stop    	          aborts injection. Also, ^C aborts generator.
 
 
+Viewing receiver
+================
+
+/proc/net/pktgen/pgrx
+
+		RECEPTION STATISTICS
+	PER-CPU Stats.
+CPU 0: 	Rx packets: 0	 Rx bytes: 0
+CPU 1: 	Rx packets: 2502400	 Rx bytes: 150144000
+	Rate:  22218pps 10 Mb/sec (10665033bps)
+	Worktime 112625248 us
+CPU 2: 	Rx packets: 1251200	 Rx bytes: 75072000
+	Rate:  11109pps 5 Mb/sec (5332412bps)
+	Worktime 112627453 us
+CPU 3: 	Rx packets: 1251100	 Rx bytes: 75066000
+	Rate:  11108pps 5 Mb/sec (5332035bps)
+	Worktime 112626413 us
+CPU 4: 	Rx packets: 1251400	 Rx bytes: 75084000
+	Rate:  11111pps 5 Mb/sec (5333458bps)
+	Worktime 112623364 us
+CPU 5: 	Rx packets: 1251200	 Rx bytes: 75072000
+	Rate:  11110pps 5 Mb/sec (5332844bps)
+	Worktime 112618314 us
+CPU 6: 	Rx packets: 1241500	 Rx bytes: 74490000
+	Rate:  11023pps 5 Mb/sec (5291273bps)
+	Worktime 112623172 us
+CPU 7: 	Rx packets: 1251200	 Rx bytes: 75072000
+	Rate:  11109pps 5 Mb/sec (5332628bps)
+	Worktime 112622877 us
+
+	Global Statistics
+Packets Rx: 10000000	 Bytes Rx: 600000000
+Start: 64952587054 us	 Stop: 65065224574 us	 Worktime  112637519 us
+Received throughput:
+  88780pps 42 Mb/sec (42614574bps)
+
 Example scripts
 ===============
 
@@ -247,6 +283,12 @@ src6
 flows
 flowlen
 
+**Receiver commands:
+
+rx [device]
+rx_reset
+rx_disable
+
 References:
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6428653..1cb2c67 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -114,6 +114,7 @@
  * Fixed src_mac command to set source mac of packet to value specified in
  * command by Adit Ranadive <adit.262@gmail.com>
  *
+ * Receiver support and rate control by Daniel Turull <daniel.turull@gmail.com>
  */
 #include <linux/sys.h>
 #include <linux/types.h>
@@ -204,8 +205,10 @@
 
 /* Used to help with determining the pkts on receive */
 #define PKTGEN_MAGIC 0xbe9be955
+#define PKTGEN_MAGIC_NET htonl(PKTGEN_MAGIC)
 #define PG_PROC_DIR "pktgen"
 #define PGCTRL	    "pgctrl"
+#define PGRX        "pgrx"
 static struct proc_dir_entry *pg_proc_dir;
 
 #define MAX_CFLOWS  65536
@@ -406,6 +409,15 @@ struct pktgen_thread {
 	struct completion start_done;
 };
 
+/*Recevier parameters per cpu*/
+struct pktgen_rx {
+	u64 rx_packets;		/*packets arrived*/
+	u64 rx_bytes;		/*bytes arrived*/
+
+	ktime_t start_time;	/*first time stamp of a packet*/
+	ktime_t last_time;	/*last packet arrival */
+};
+
 #define REMOVE 1
 #define FIND   0
 
@@ -438,6 +450,13 @@ static void pktgen_stop_all_threads_ifs(void);
 static void pktgen_stop(struct pktgen_thread *t);
 static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
 
+/*Receiver functions*/
+static int pktgen_rcv_basic(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *pt, struct net_device *orig_dev);
+static int pktgen_add_rx(const char *ifname);
+static int pktgen_clean_rx(void);
+static void pg_reset_rx(void);
+
 static unsigned int scan_ip6(const char *s, char ip[16]);
 static unsigned int fmt_ip6(char *s, const char ip[16]);
 
@@ -450,10 +469,19 @@ static int debug  __read_mostly;
 static DEFINE_MUTEX(pktgen_thread_lock);
 static LIST_HEAD(pktgen_threads);
 
+DEFINE_PER_CPU(struct pktgen_rx, pktgen_rx_data);
+static int pg_initialized;
+
 static struct notifier_block pktgen_notifier_block = {
 	.notifier_call = pktgen_device_event,
 };
 
+/*Reception functions test*/
+static struct packet_type pktgen_packet_type __read_mostly = {
+	.type = __constant_htons(ETH_P_IP),
+	.func = pktgen_rcv_basic,
+};
+
 /*
  * /proc handling functions
  *
@@ -1876,6 +1904,190 @@ static const struct file_operations pktgen_thread_fops = {
 	.release = single_release,
 };
 
+/*
+ * Function that show Receiver statistics
+ */
+static int pgrx_show(struct seq_file *seq, void *v)
+{
+	struct pktgen_rx *data_cpu;
+	__u64 bps, mbps, pps;
+	int cpu;
+	u64 total_packets = 0, total_bytes = 0, work_time_us = 0;
+	u64 packets = 0, bytes = 0;
+	ktime_t start_global, stop_global, tmp;
+	start_global.tv64 = 0;
+	stop_global.tv64 = 0;
+
+
+	seq_puts(seq, "\t\tRECEPTION STATISTICS\n");
+	if (pg_initialized == 0) {
+		seq_puts(seq, "Not enabled.\n");
+		return 0;
+	}
+	seq_puts(seq, "\tPER-CPU Stats.\n");
+
+	for_each_online_cpu(cpu) {
+		data_cpu = &per_cpu(pktgen_rx_data, cpu);
+		seq_printf(seq, "CPU %d: ", cpu);
+		packets = data_cpu->rx_packets;
+		bytes = data_cpu->rx_bytes;
+
+		total_packets += packets;
+		total_bytes += bytes;
+		seq_printf(seq, "\tRx packets: %llu\t Rx bytes: %llu\n",
+			packets, bytes);
+
+		tmp = data_cpu->start_time;
+		if (start_global.tv64 == 0 && tmp.tv64 != 0)
+			start_global = tmp;
+		else if (tmp.tv64 < start_global.tv64 && tmp.tv64 != 0)
+			start_global = tmp;
+
+		tmp = data_cpu->last_time;
+		if (ktime_to_ns(tmp) > ktime_to_ns(stop_global))
+			stop_global = tmp;
+
+		work_time_us = ktime_to_us(ktime_sub(data_cpu->last_time,
+			data_cpu->start_time));
+
+		if (!work_time_us)
+			continue;
+
+		bps = div64_u64(bytes*8*USEC_PER_SEC, work_time_us);
+		mbps = bps;
+		do_div(mbps, 1000000);
+		pps = div64_u64(packets * USEC_PER_SEC, work_time_us);
+
+		seq_printf(seq, "\tRate:  %llupps %llu Mb/sec (%llubps)\n",
+				(unsigned long long)pps,
+				(unsigned long long)mbps,
+				(unsigned long long)bps);
+		seq_printf(seq, "\tWork time %llu us\n", work_time_us);
+
+	}
+
+	seq_puts(seq, "\n\tGlobal Statistics\n");
+
+	seq_printf(seq, "Packets Rx: %llu\t Bytes Rx: %llu\n",
+		(unsigned long long) total_packets,
+		(unsigned long long) total_bytes);
+
+	/*Bandwidth*/
+	work_time_us = ktime_to_us(ktime_sub(stop_global, start_global));
+
+	seq_printf(seq, "Start: %llu us\t Stop: %llu us\t Work time  %llu us\n",
+		ktime_to_us(start_global),
+		ktime_to_us(stop_global),
+		work_time_us);
+
+	if (!work_time_us)
+		return 0;
+
+	bps = div64_u64(total_bytes*8*USEC_PER_SEC, work_time_us);
+	mbps = bps;
+	do_div(mbps, 1000000);
+	pps = div64_u64(total_packets * USEC_PER_SEC, work_time_us);
+
+	seq_puts(seq, "Received throughput:\n");
+
+	seq_printf(seq, "  %llupps %llu Mb/sec (%llubps)\n",
+		     (unsigned long long)pps,
+		     (unsigned long long)mbps,
+		     (unsigned long long)bps);
+
+	return 0;
+}
+/*receiver configuration*/
+static ssize_t pgrx_write(struct file *file, const char __user * user_buffer,
+				size_t count, loff_t *ppos)
+{
+	int i = 0, max, len, ret;
+	char name[40];
+
+	if (count < 1)
+		return -EINVAL;
+
+	max = count - i;
+	len = count_trail_chars(&user_buffer[i], max);
+	if (len < 0)
+		return len;
+
+	i += len;
+
+	/* Read variable name */
+
+	len = strn_len(&user_buffer[i], sizeof(name) - 1);
+	if (len < 0)
+		return len;
+
+	memset(name, 0, sizeof(name));
+	if (copy_from_user(name, &user_buffer[i], len))
+		return -EFAULT;
+	i += len;
+
+	max = count - i;
+	len = count_trail_chars(&user_buffer[i], max);
+	if (len < 0)
+		return len;
+
+	i += len;
+
+	if (debug)
+		printk(KERN_DEBUG "pktgen: t=%s, count=%lu\n",
+		       name, (unsigned long)count);
+
+	if (!strcmp(name, "rx")) {
+		char f[32];
+		memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+		if (len < 0) {
+			ret = len;
+			goto out;
+		}
+		if (copy_from_user(f, &user_buffer[i], len))
+			return -EFAULT;
+		i += len;
+
+		if (debug)
+			printk(KERN_INFO "pktgen: Adding rx %s\n", f);
+		pktgen_add_rx(f);
+		ret = count;
+		goto out;
+	} else if (!strcmp(name, "rx_reset")) {
+		ret = count;
+		pg_reset_rx();
+		if (debug)
+			printk(KERN_INFO "pktgen: Reseting reception\n");
+		goto out;
+	} else if (!strcmp(name, "rx_disable")) {
+		ret = count;
+		pktgen_clean_rx();
+		if (debug)
+			printk(KERN_INFO "pktgen: Cleaning reception\n");
+		goto out;
+	} else
+		printk(KERN_WARNING "pktgen: Unknown command: %s\n", name);
+
+	ret = count;
+
+out:
+	return ret;
+}
+
+static int pgrx_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, pgrx_show, PDE(inode)->data);
+}
+
+static const struct file_operations pktgen_rx_fops = {
+	.owner   = THIS_MODULE,
+	.open    = pgrx_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.write   = pgrx_write,
+	.release = single_release,
+};
+
 /* Think find or remove for NN */
 static struct pktgen_dev *__pktgen_NN_threads(const char *ifname, int remove)
 {
@@ -3886,6 +4098,88 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	return 0;
 }
 
+static void pg_reset_rx(void)
+{
+	int cpu;
+	for_each_online_cpu(cpu) {
+		per_cpu(pktgen_rx_data, cpu).rx_packets = 0;
+		per_cpu(pktgen_rx_data, cpu).rx_bytes = 0;
+		per_cpu(pktgen_rx_data, cpu).last_time.tv64 = 0;
+		per_cpu(pktgen_rx_data, cpu).start_time.tv64 = 0;
+	}
+}
+
+static int pktgen_add_rx(const char *ifname)
+{
+	int err = 0;
+	struct net_device *idev = NULL;
+
+	pg_reset_rx();
+
+	idev = pktgen_dev_get_by_name(NULL, ifname);
+	if (!idev)
+		printk(KERN_INFO
+			"pktgen: device not present %s. Using all\n", ifname);
+
+	if (!pg_initialized) {
+		pktgen_packet_type.dev = idev;
+		dev_add_pack(&pktgen_packet_type);
+		err = 0;
+		net_disable_timestamp();
+		pg_initialized = 1;
+	} else {
+		dev_remove_pack(&pktgen_packet_type);
+		pktgen_packet_type.dev = idev;
+		dev_add_pack(&pktgen_packet_type);
+		err = 0;
+	}
+	if (idev)
+		dev_put(idev);
+	return err;
+}
+
+static int pktgen_clean_rx(void)
+{
+	if (pg_initialized) {
+		dev_remove_pack(&pktgen_packet_type);
+		pg_initialized = 0;
+	}
+	return 0;
+}
+
+int pktgen_rcv_basic(struct sk_buff *skb, struct net_device *dev,
+			 struct packet_type *pt, struct net_device *orig_dev)
+{
+	/* Check magic*/
+	struct iphdr *iph = ip_hdr(skb);
+	struct pktgen_hdr *pgh;
+	struct pktgen_rx *data_cpu;
+	int pktgen_offset = iph->ihl*4 + sizeof(struct udphdr);
+
+	if (!pskb_may_pull(skb, pktgen_offset + sizeof(struct pktgen_hdr)))
+		goto end;
+
+	pgh = (struct pktgen_hdr *)(((char *)(iph)) + pktgen_offset);
+
+	if (unlikely(pgh->pgh_magic != PKTGEN_MAGIC_NET))
+		goto end;
+
+	data_cpu = &__get_cpu_var(pktgen_rx_data);
+
+	if (unlikely(!data_cpu->rx_packets))
+		data_cpu->start_time = ktime_now();
+
+	data_cpu->last_time = ktime_now();
+
+	/* Update counter of packets*/
+	data_cpu->rx_packets++;
+	data_cpu->rx_bytes += skb->len + ETH_HLEN;
+
+end:
+	kfree_skb(skb);
+	return 0;
+}
+
 static int __init pg_init(void)
 {
 	int cpu;
@@ -3908,6 +4202,15 @@ static int __init pg_init(void)
 	/* Register us to receive netdevice events */
 	register_netdevice_notifier(&pktgen_notifier_block);
 
+	/*Create proc rx*/
+	pe = proc_create(PGRX, 0600, pg_proc_dir, &pktgen_rx_fops);
+	if (pe == NULL) {
+		printk(KERN_ERR "pktgen: ERROR: cannot create %s "
+		       "procfs entry.\n", PGRX);
+		proc_net_remove(&init_net, PG_PROC_DIR);
+		return -EINVAL;
+	}
+
 	for_each_online_cpu(cpu) {
 		int err;
 
@@ -3921,6 +4224,8 @@ static int __init pg_init(void)
 		printk(KERN_ERR "pktgen: ERROR: Initialization failed for "
 		       "all threads\n");
 		unregister_netdevice_notifier(&pktgen_notifier_block);
+		pktgen_clean_rx();
+		remove_proc_entry(PGRX, pg_proc_dir);
 		remove_proc_entry(PGCTRL, pg_proc_dir);
 		proc_net_remove(&init_net, PG_PROC_DIR);
 		return -ENODEV;
@@ -3947,6 +4252,9 @@ static void __exit pg_cleanup(void)
 	/* Un-register us from receiving netdevice events */
 	unregister_netdevice_notifier(&pktgen_notifier_block);
 
+	pktgen_clean_rx();
+	remove_proc_entry(PGRX, pg_proc_dir);
+
 	/* Clean up proc file system */
 	remove_proc_entry(PGCTRL, pg_proc_dir);
 	proc_net_remove(&init_net, PG_PROC_DIR);
