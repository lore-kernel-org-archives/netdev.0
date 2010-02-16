From: Patrick McHardy <kaber@trash.net>
Subject: IPVS 05/62: Allow boot time change of hash size
Date: Tue, 16 Feb 2010 15:55:26 +0100 (MET)
Message-ID: <20100216145523.2796.46110.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6f7edb4881bf51300060e89915926e070ace8c4d
Author: Catalin(ux) M. BOIE <catab@embedromix.ro>
Date:   Tue Jan 5 05:50:24 2010 +0100

    IPVS: Allow boot time change of hash size
    
    I was very frustrated about the fact that I have to recompile the kernel
    to change the hash size. So, I created this patch.
    
    If IPVS is built-in you can append ip_vs.conn_tab_bits=?? to kernel
    command line, or, if you built IPVS as modules, you can add
    options ip_vs conn_tab_bits=??.
    
    To keep everything backward compatible, you still can select the size at
    compile time, and that will be used as default.
    
    It has been about a year since this patch was originally posted
    and subsequently dropped on the basis of insufficient test data.
    
    Mark Bergsma has provided the following test results which seem
    to strongly support the need for larger hash table sizes:
    
    We do however run into the same problem with the default setting (212 =
    4096 entries), as most of our LVS balancers handle around a million
    connections/SLAB entries at any point in time (around 100-150 kpps
    load). With only 4096 hash table entries this implies that each entry
    consists of a linked list of 256 connections *on average*.
    
    To provide some statistics, I did an oprofile run on an 2.6.31 kernel,
    with both the default 4096 table size, and the same kernel recompiled
    with IP_VS_CONN_TAB_BITS set to 18 (218 = 262144 entries). I built a
    quick test setup with a part of Wikimedia/Wikipedia's live traffic
    mirrored by the switch to the test host.
    
    With the default setting, at ~ 120 kpps packet load we saw a typical %si
    CPU usage of around 30-35%, and oprofile reported a hot spot in
    ip_vs_conn_in_get:
    
    samples  %        image name               app name
    symbol name
    1719761  42.3741  ip_vs.ko                 ip_vs.ko      ip_vs_conn_in_get
    302577    7.4554  bnx2                     bnx2          /bnx2
    181984    4.4840  vmlinux                  vmlinux       __ticket_spin_lock
    128636    3.1695  vmlinux                  vmlinux       ip_route_input
    74345     1.8318  ip_vs.ko                 ip_vs.ko      ip_vs_conn_out_get
    68482     1.6874  vmlinux                  vmlinux       mwait_idle
    
    After loading the recompiled kernel with 218 entries, %si CPU usage
    dropped in half to around 12-18%, and oprofile looks much healthier,
    with only 7% spent in ip_vs_conn_in_get:
    
    samples  %        image name               app name
    symbol name
    265641   14.4616  bnx2                     bnx2         /bnx2
    143251    7.7986  vmlinux                  vmlinux      __ticket_spin_lock
    140661    7.6576  ip_vs.ko                 ip_vs.ko     ip_vs_conn_in_get
    94364     5.1372  vmlinux                  vmlinux      mwait_idle
    86267     4.6964  vmlinux                  vmlinux      ip_route_input
    
    [ horms@verge.net.au: trivial up-port and minor style fixes ]
    Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>
    Cc: Mark Bergsma <mark@wikimedia.org>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8dc3296..a816c37 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -26,6 +26,11 @@
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>			/* for ipv6_addr_copy */
 
+
+/* Connections' size value needed by ip_vs_ctl.c */
+extern int ip_vs_conn_tab_size;
+
+
 struct ip_vs_iphdr {
 	int len;
 	__u8 protocol;
@@ -592,17 +597,6 @@ extern void ip_vs_init_hash_table(struct list_head *table, int rows);
  *     (from ip_vs_conn.c)
  */
 
-/*
- *     IPVS connection entry hash table
- */
-#ifndef CONFIG_IP_VS_TAB_BITS
-#define CONFIG_IP_VS_TAB_BITS   12
-#endif
-
-#define IP_VS_CONN_TAB_BITS	CONFIG_IP_VS_TAB_BITS
-#define IP_VS_CONN_TAB_SIZE     (1 << IP_VS_CONN_TAB_BITS)
-#define IP_VS_CONN_TAB_MASK     (IP_VS_CONN_TAB_SIZE - 1)
-
 enum {
 	IP_VS_DIR_INPUT = 0,
 	IP_VS_DIR_OUTPUT,
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 79a6980..c71e543 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -68,6 +68,10 @@ config	IP_VS_TAB_BITS
 	  each hash entry uses 8 bytes, so you can estimate how much memory is
 	  needed for your box.
 
+	  You can overwrite this number setting conn_tab_bits module parameter
+	  or by appending ip_vs.conn_tab_bits=? to the kernel command line
+	  if IP VS was compiled built-in.
+
 comment "IPVS transport protocol load balancing support"
 
 config	IP_VS_PROTO_TCP
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 27c30cf..60bb41a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -40,6 +40,21 @@
 #include <net/ip_vs.h>
 
 
+#ifndef CONFIG_IP_VS_TAB_BITS
+#define CONFIG_IP_VS_TAB_BITS	12
+#endif
+
+/*
+ * Connection hash size. Default is what was selected at compile time.
+*/
+int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
+module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
+MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
+
+/* size and mask values */
+int ip_vs_conn_tab_size;
+int ip_vs_conn_tab_mask;
+
 /*
  *  Connection hash table: for input and output packets lookups of IPVS
  */
@@ -125,11 +140,11 @@ static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
 	if (af == AF_INET6)
 		return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
 				    (__force u32)port, proto, ip_vs_conn_rnd)
-			& IP_VS_CONN_TAB_MASK;
+			& ip_vs_conn_tab_mask;
 #endif
 	return jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
 			    ip_vs_conn_rnd)
-		& IP_VS_CONN_TAB_MASK;
+		& ip_vs_conn_tab_mask;
 }
 
 
@@ -760,7 +775,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 	int idx;
 	struct ip_vs_conn *cp;
 
-	for(idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
+	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		ct_read_lock_bh(idx);
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (pos-- == 0) {
@@ -797,7 +812,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	idx = l - ip_vs_conn_tab;
 	ct_read_unlock_bh(idx);
 
-	while (++idx < IP_VS_CONN_TAB_SIZE) {
+	while (++idx < ip_vs_conn_tab_size) {
 		ct_read_lock_bh(idx);
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			seq->private = &ip_vs_conn_tab[idx];
@@ -976,8 +991,8 @@ void ip_vs_random_dropentry(void)
 	/*
 	 * Randomly scan 1/32 of the whole table every second
 	 */
-	for (idx = 0; idx < (IP_VS_CONN_TAB_SIZE>>5); idx++) {
-		unsigned hash = net_random() & IP_VS_CONN_TAB_MASK;
+	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
+		unsigned hash = net_random() & ip_vs_conn_tab_mask;
 
 		/*
 		 *  Lock is actually needed in this loop.
@@ -1029,7 +1044,7 @@ static void ip_vs_conn_flush(void)
 	struct ip_vs_conn *cp;
 
   flush_again:
-	for (idx=0; idx<IP_VS_CONN_TAB_SIZE; idx++) {
+	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		/*
 		 *  Lock is actually needed in this loop.
 		 */
@@ -1060,10 +1075,15 @@ int __init ip_vs_conn_init(void)
 {
 	int idx;
 
+	/* Compute size and mask */
+	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
+	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
+
 	/*
 	 * Allocate the connection hash table and initialize its list heads
 	 */
-	ip_vs_conn_tab = vmalloc(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head));
+	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size *
+				 sizeof(struct list_head));
 	if (!ip_vs_conn_tab)
 		return -ENOMEM;
 
@@ -1078,12 +1098,12 @@ int __init ip_vs_conn_init(void)
 
 	pr_info("Connection hash table configured "
 		"(size=%d, memory=%ldKbytes)\n",
-		IP_VS_CONN_TAB_SIZE,
-		(long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
+		ip_vs_conn_tab_size,
+		(long)(ip_vs_conn_tab_size*sizeof(struct list_head))/1024);
 	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
 		  sizeof(struct ip_vs_conn));
 
-	for (idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
+	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		INIT_LIST_HEAD(&ip_vs_conn_tab[idx]);
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6bde12d..93420ea 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1843,7 +1843,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq,
 			"IP Virtual Server version %d.%d.%d (size=%d)\n",
-			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
+			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
 		seq_puts(seq,
 			 "Prot LocalAddress:Port Scheduler Flags\n");
 		seq_puts(seq,
@@ -2374,7 +2374,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		char buf[64];
 
 		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
-			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
+			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
 		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
 			ret = -EFAULT;
 			goto out;
@@ -2387,7 +2387,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_getinfo info;
 		info.version = IP_VS_VERSION_CODE;
-		info.size = IP_VS_CONN_TAB_SIZE;
+		info.size = ip_vs_conn_tab_size;
 		info.num_services = ip_vs_num_services;
 		if (copy_to_user(user, &info, sizeof(info)) != 0)
 			ret = -EFAULT;
@@ -3231,7 +3231,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	case IPVS_CMD_GET_INFO:
 		NLA_PUT_U32(msg, IPVS_INFO_ATTR_VERSION, IP_VS_VERSION_CODE);
 		NLA_PUT_U32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
-			    IP_VS_CONN_TAB_SIZE);
+			    ip_vs_conn_tab_size);
 		break;
 	}
 
