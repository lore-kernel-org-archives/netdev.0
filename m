From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/14] pktgen: cleanup checkpatch warnings
Date: Thu, 27 Aug 2009 16:55:19 -0700
Message-ID: <20090827235706.146908097@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58759 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069AbZH0X73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:29 -0400
Content-Disposition: inline; filename=pktgen-checkpatch.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-08-27 16:29:53.826372401 -0700
+++ b/net/core/pktgen.c	2009-08-27 16:30:05.614687981 -0700
@@ -163,13 +163,14 @@
 #include <asm/byteorder.h>
 #include <linux/rcupdate.h>
 #include <linux/bitops.h>
-#include <asm/io.h>
+#include <linux/io.h>
+#include <linux/timex.h>
+#include <linux/uaccess.h>
 #include <asm/dma.h>
-#include <asm/uaccess.h>
 #include <asm/div64.h>		/* do_div */
-#include <asm/timex.h>
 
-#define VERSION  "pktgen v2.70: Packet Generator for packet performance testing.\n"
+#define VERSION \
+	"pktgen v2.70: Packet Generator for packet performance testing.\n"
 
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
@@ -207,7 +208,7 @@
 #define PKTGEN_MAGIC 0xbe9be955
 #define PG_PROC_DIR "pktgen"
 #define PGCTRL	    "pgctrl"
-static struct proc_dir_entry *pg_proc_dir = NULL;
+static struct proc_dir_entry *pg_proc_dir;
 
 #define MAX_CFLOWS  65536
 
@@ -232,9 +233,9 @@ struct pktgen_dev {
 	 */
 	struct proc_dir_entry *entry;	/* proc file */
 	struct pktgen_thread *pg_thread;/* the owner */
-	struct list_head list;		/* Used for chaining in the thread's run-queue */
+	struct list_head list;		/* chaining in the thread's run-queue */
 
-	int running;		/* if this changes to false, the test will stop */
+	int running;		/* if false, the test will stop */
 
 	/* If min != max, then we will either do a linear iteration, or
 	 * we will do a random selection from within the range.
@@ -252,15 +253,16 @@ struct pktgen_dev {
 	__u64 count;		/* Default No packets to send */
 	__u64 sofar;		/* How many pkts we've sent so far */
 	__u64 tx_bytes;		/* How many bytes we've transmitted */
-	__u64 errors;		/* Errors when trying to transmit, pkts will be re-sent */
+	__u64 errors;		/* Errors when trying to transmit,
+				   pkts will be re-sent */
 
 	/* runtime counters relating to clone_skb */
 
 	__u64 allocated_skbs;
 	__u32 clone_count;
 	int last_ok;		/* Was last skb sent?
-				 * Or a failed transmit of some sort?  This will keep
-				 * sequence numbers in order, for example.
+				 * Or a failed transmit of some sort?
+				 * This will keep sequence numbers in order
 				 */
 	ktime_t next_tx;
 	ktime_t started_at;
@@ -269,11 +271,14 @@ struct pktgen_dev {
 
 	__u32 seq_num;
 
-	int clone_skb;		/* Use multiple SKBs during packet gen.  If this number
-				 * is greater than 1, then that many copies of the same
-				 * packet will be sent before a new packet is allocated.
-				 * For instance, if you want to send 1024 identical packets
-				 * before creating a new packet, set clone_skb to 1024.
+	int clone_skb;		/*
+				 * Use multiple SKBs during packet gen.
+				 * If this number is greater than 1, then
+				 * that many copies of the same packet will be
+				 * sent before a new packet is allocated.
+				 * If you want to send 1024 identical packets
+				 * before creating a new packet,
+				 * set clone_skb to 1024.
 				 */
 
 	char dst_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
@@ -305,8 +310,10 @@ struct pktgen_dev {
 	__u16 udp_dst_max;	/* exclusive, dest UDP port */
 
 	/* DSCP + ECN */
-	__u8 tos;            /* six most significant bits of (former) IPv4 TOS are for dscp codepoint */
-	__u8 traffic_class;  /* ditto for the (former) Traffic Class in IPv6 (see RFC 3260, sec. 4) */
+	__u8 tos;            /* six MSB of (former) IPv4 TOS
+				are for dscp codepoint */
+	__u8 traffic_class;  /* ditto for the (former) Traffic Class in IPv6
+				(see RFC 3260, sec. 4) */
 
 	/* MPLS */
 	unsigned nr_labels;	/* Depth of stack, 0 = no MPLS */
@@ -347,15 +354,17 @@ struct pktgen_dev {
 	 */
 	__u16 pad;		/* pad out the hh struct to an even 16 bytes */
 
-	struct sk_buff *skb;	/* skb we are to transmit next, mainly used for when we
+	struct sk_buff *skb;	/* skb we are to transmit next, used for when we
 				 * are transmitting the same one multiple times
 				 */
-	struct net_device *odev;	/* The out-going device.  Note that the device should
-					 * have it's pg_info pointer pointing back to this
-					 * device.  This will be set when the user specifies
-					 * the out-going device name (not when the inject is
-					 * started as it used to do.)
-					 */
+	struct net_device *odev; /* The out-going device.
+				  * Note that the device should have it's
+				  * pg_info pointer pointing back to this
+				  * device.
+				  * Set when the user specifies the out-going
+				  * device name (not when the inject is
+				  * started as it used to do.)
+				  */
 	struct flow_state *flows;
 	unsigned cflows;	/* Concurrent flows (config) */
 	unsigned lflow;		/* Flow length  (config) */
@@ -380,13 +389,14 @@ struct pktgen_hdr {
 };
 
 struct pktgen_thread {
-	spinlock_t if_lock;
+	spinlock_t if_lock;		/* for list of devices */
 	struct list_head if_list;	/* All device here */
 	struct list_head th_list;
 	struct task_struct *tsk;
 	char result[512];
 
-	/* Field for thread to receive "posted" events terminate, stop ifs etc. */
+	/* Field for thread to receive "posted" events terminate,
+	   stop ifs etc. */
 
 	u32 control;
 	int cpu;
@@ -453,8 +463,8 @@ static int pgctrl_show(struct seq_file *
 	return 0;
 }
 
-static ssize_t pgctrl_write(struct file *file, const char __user * buf,
-			    size_t count, loff_t * ppos)
+static ssize_t pgctrl_write(struct file *file, const char __user *buf,
+			    size_t count, loff_t *ppos)
 {
 	int err = 0;
 	char data[128];
@@ -545,11 +555,14 @@ static int pktgen_if_show(struct seq_fil
 			   "     daddr: %s  min_daddr: %s  max_daddr: %s\n", b1,
 			   b2, b3);
 
-	} else
+	} else {
+		seq_printf(seq,
+			   "     dst_min: %s  dst_max: %s\n",
+			   pkt_dev->dst_min, pkt_dev->dst_max);
 		seq_printf(seq,
-			   "     dst_min: %s  dst_max: %s\n     src_min: %s  src_max: %s\n",
-			   pkt_dev->dst_min, pkt_dev->dst_max, pkt_dev->src_min,
-			   pkt_dev->src_max);
+			   "        src_min: %s  src_max: %s\n",
+			   pkt_dev->src_min, pkt_dev->src_max);
+	}
 
 	seq_puts(seq, "     src_mac: ");
 
@@ -561,7 +574,8 @@ static int pktgen_if_show(struct seq_fil
 	seq_printf(seq, "%pM\n", pkt_dev->dst_mac);
 
 	seq_printf(seq,
-		   "     udp_src_min: %d  udp_src_max: %d  udp_dst_min: %d  udp_dst_max: %d\n",
+		   "     udp_src_min: %d  udp_src_max: %d"
+		   "  udp_dst_min: %d  udp_dst_max: %d\n",
 		   pkt_dev->udp_src_min, pkt_dev->udp_src_max,
 		   pkt_dev->udp_dst_min, pkt_dev->udp_dst_max);
 
@@ -577,23 +591,21 @@ static int pktgen_if_show(struct seq_fil
 				   i == pkt_dev->nr_labels-1 ? "\n" : ", ");
 	}
 
-	if (pkt_dev->vlan_id != 0xffff) {
+	if (pkt_dev->vlan_id != 0xffff)
 		seq_printf(seq, "     vlan_id: %u  vlan_p: %u  vlan_cfi: %u\n",
-			   pkt_dev->vlan_id, pkt_dev->vlan_p, pkt_dev->vlan_cfi);
-	}
+			   pkt_dev->vlan_id, pkt_dev->vlan_p,
+			   pkt_dev->vlan_cfi);
 
-	if (pkt_dev->svlan_id != 0xffff) {
+	if (pkt_dev->svlan_id != 0xffff)
 		seq_printf(seq, "     svlan_id: %u  vlan_p: %u  vlan_cfi: %u\n",
-			   pkt_dev->svlan_id, pkt_dev->svlan_p, pkt_dev->svlan_cfi);
-	}
+			   pkt_dev->svlan_id, pkt_dev->svlan_p,
+			   pkt_dev->svlan_cfi);
 
-	if (pkt_dev->tos) {
+	if (pkt_dev->tos)
 		seq_printf(seq, "     tos: 0x%02x\n", pkt_dev->tos);
-	}
 
-	if (pkt_dev->traffic_class) {
+	if (pkt_dev->traffic_class)
 		seq_printf(seq, "     traffic_class: 0x%02x\n", pkt_dev->traffic_class);
-	}
 
 	seq_printf(seq, "     Flags: ");
 
@@ -696,7 +708,8 @@ static int pktgen_if_show(struct seq_fil
 }
 
 
-static int hex32_arg(const char __user *user_buffer, unsigned long maxlen, __u32 *num)
+static int hex32_arg(const char __user *user_buffer, unsigned long maxlen,
+		     __u32 *num)
 {
 	int i = 0;
 	*num = 0;
@@ -846,9 +859,9 @@ static ssize_t pktgen_if_write(struct fi
 	/* Read variable name */
 
 	len = strn_len(&user_buffer[i], sizeof(name) - 1);
-	if (len < 0) {
+	if (len < 0)
 		return len;
-	}
+
 	memset(name, 0, sizeof(name));
 	if (copy_from_user(name, &user_buffer[i], len))
 		return -EFAULT;
@@ -872,9 +885,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "min_pkt_size")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value < 14 + 20 + 8)
 			value = 14 + 20 + 8;
@@ -889,9 +902,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "max_pkt_size")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value < 14 + 20 + 8)
 			value = 14 + 20 + 8;
@@ -908,9 +921,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "pkt_size")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value < 14 + 20 + 8)
 			value = 14 + 20 + 8;
@@ -925,9 +938,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "debug")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		debug = value;
 		sprintf(pg_result, "OK: debug=%u", debug);
@@ -936,9 +949,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "frags")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->nfrags = value;
 		sprintf(pg_result, "OK: frags=%u", pkt_dev->nfrags);
@@ -946,9 +959,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "delay")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value == 0x7FFFFFFF)
 			pkt_dev->delay = ULLONG_MAX;
@@ -961,9 +974,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "udp_src_min")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value != pkt_dev->udp_src_min) {
 			pkt_dev->udp_src_min = value;
@@ -974,9 +987,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "udp_dst_min")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value != pkt_dev->udp_dst_min) {
 			pkt_dev->udp_dst_min = value;
@@ -987,9 +1000,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "udp_src_max")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value != pkt_dev->udp_src_max) {
 			pkt_dev->udp_src_max = value;
@@ -1000,9 +1013,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "udp_dst_max")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value != pkt_dev->udp_dst_max) {
 			pkt_dev->udp_dst_max = value;
@@ -1013,9 +1026,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "clone_skb")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->clone_skb = value;
 
@@ -1024,9 +1037,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "count")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->count = value;
 		sprintf(pg_result, "OK: count=%llu",
@@ -1035,9 +1048,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "src_mac_count")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (pkt_dev->src_mac_count != value) {
 			pkt_dev->src_mac_count = value;
@@ -1049,9 +1062,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "dst_mac_count")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (pkt_dev->dst_mac_count != value) {
 			pkt_dev->dst_mac_count = value;
@@ -1065,9 +1078,9 @@ static ssize_t pktgen_if_write(struct fi
 		char f[32];
 		memset(f, 0, 32);
 		len = strn_len(&user_buffer[i], sizeof(f) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		if (copy_from_user(f, &user_buffer[i], len))
 			return -EFAULT;
 		i += len;
@@ -1166,9 +1179,8 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_min) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
 
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
@@ -1188,9 +1200,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "dst_max")) {
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_max) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
@@ -1301,9 +1313,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "src_min")) {
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_min) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
 		buf[len] = 0;
@@ -1322,9 +1334,9 @@ static ssize_t pktgen_if_write(struct fi
 	}
 	if (!strcmp(name, "src_max")) {
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_max) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
 		buf[len] = 0;
@@ -1348,9 +1360,9 @@ static ssize_t pktgen_if_write(struct fi
 		memcpy(old_dmac, pkt_dev->dst_mac, ETH_ALEN);
 
 		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		memset(valstr, 0, sizeof(valstr));
 		if (copy_from_user(valstr, &user_buffer[i], len))
 			return -EFAULT;
@@ -1390,9 +1402,9 @@ static ssize_t pktgen_if_write(struct fi
 		memcpy(old_smac, pkt_dev->src_mac, ETH_ALEN);
 
 		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		memset(valstr, 0, sizeof(valstr));
 		if (copy_from_user(valstr, &user_buffer[i], len))
 			return -EFAULT;
@@ -1433,9 +1445,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "flows")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value > MAX_CFLOWS)
 			value = MAX_CFLOWS;
@@ -1447,9 +1459,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "flowlen")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->lflow = value;
 		sprintf(pg_result, "OK: flowlen=%u", pkt_dev->lflow);
@@ -1458,9 +1470,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "queue_map_min")) {
 		len = num_arg(&user_buffer[i], 5, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->queue_map_min = value;
 		sprintf(pg_result, "OK: queue_map_min=%u", pkt_dev->queue_map_min);
@@ -1469,9 +1481,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "queue_map_max")) {
 		len = num_arg(&user_buffer[i], 5, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		pkt_dev->queue_map_max = value;
 		sprintf(pg_result, "OK: queue_map_max=%u", pkt_dev->queue_map_max);
@@ -1503,9 +1515,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "vlan_id")) {
 		len = num_arg(&user_buffer[i], 4, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (value <= 4095) {
 			pkt_dev->vlan_id = value;  /* turn on VLAN */
@@ -1530,9 +1542,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "vlan_p")) {
 		len = num_arg(&user_buffer[i], 1, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if ((value <= 7) && (pkt_dev->vlan_id != 0xffff)) {
 			pkt_dev->vlan_p = value;
@@ -1545,9 +1557,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "vlan_cfi")) {
 		len = num_arg(&user_buffer[i], 1, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if ((value <= 1) && (pkt_dev->vlan_id != 0xffff)) {
 			pkt_dev->vlan_cfi = value;
@@ -1560,9 +1572,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "svlan_id")) {
 		len = num_arg(&user_buffer[i], 4, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if ((value <= 4095) && ((pkt_dev->vlan_id != 0xffff))) {
 			pkt_dev->svlan_id = value;  /* turn on SVLAN */
@@ -1587,9 +1599,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "svlan_p")) {
 		len = num_arg(&user_buffer[i], 1, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if ((value <= 7) && (pkt_dev->svlan_id != 0xffff)) {
 			pkt_dev->svlan_p = value;
@@ -1602,9 +1614,9 @@ static ssize_t pktgen_if_write(struct fi
 
 	if (!strcmp(name, "svlan_cfi")) {
 		len = num_arg(&user_buffer[i], 1, &value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if ((value <= 1) && (pkt_dev->svlan_id != 0xffff)) {
 			pkt_dev->svlan_cfi = value;
@@ -1618,9 +1630,9 @@ static ssize_t pktgen_if_write(struct fi
 	if (!strcmp(name, "tos")) {
 		__u32 tmp_value = 0;
 		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (len == 2) {
 			pkt_dev->tos = tmp_value;
@@ -1634,9 +1646,9 @@ static ssize_t pktgen_if_write(struct fi
 	if (!strcmp(name, "traffic_class")) {
 		__u32 tmp_value = 0;
 		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
-		if (len < 0) {
+		if (len < 0)
 			return len;
-		}
+
 		i += len;
 		if (len == 2) {
 			pkt_dev->traffic_class = tmp_value;
@@ -1906,13 +1918,14 @@ static int pktgen_device_event(struct no
 	return NOTIFY_DONE;
 }
 
-static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev, const char *ifname)
+static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
+						 const char *ifname)
 {
 	char b[IFNAMSIZ+5];
 	int i = 0;
 
-	for(i=0; ifname[i] != '@'; i++) {
-		if(i == IFNAMSIZ)
+	for (i = 0; ifname[i] != '@'; i++) {
+		if (i == IFNAMSIZ)
 			break;
 
 		b[i] = ifname[i];
@@ -1979,7 +1992,7 @@ static void pktgen_setup_inject(struct p
 		printk(KERN_WARNING "pktgen: WARNING: Requested "
 		       "queue_map_min (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
-		       pkt_dev->queue_map_min, (ntxq ?: 1)- 1, ntxq,
+		       pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
 		       pkt_dev->odev->name);
 		pkt_dev->queue_map_min = ntxq - 1;
 	}
@@ -1987,7 +2000,7 @@ static void pktgen_setup_inject(struct p
 		printk(KERN_WARNING "pktgen: WARNING: Requested "
 		       "queue_map_max (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
-		       pkt_dev->queue_map_max, (ntxq ?: 1)- 1, ntxq,
+		       pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
 		       pkt_dev->odev->name);
 		pkt_dev->queue_map_max = ntxq - 1;
 	}
@@ -2028,7 +2041,8 @@ static void pktgen_setup_inject(struct p
 			 */
 
 			rcu_read_lock();
-			if ((idev = __in6_dev_get(pkt_dev->odev)) != NULL) {
+			idev = __in6_dev_get(pkt_dev->odev);
+			if (idev) {
 				struct inet6_ifaddr *ifp;
 
 				read_lock_bh(&idev->lock);
@@ -2181,7 +2195,7 @@ static void get_ipsec_sa(struct pktgen_d
 		if (x) {
 			pkt_dev->flows[flow].x = x;
 			set_pkt_overhead(pkt_dev);
-			pkt_dev->pkt_overhead+=x->props.header_len;
+			pkt_dev->pkt_overhead += x->props.header_len;
 		}
 
 	}
@@ -2320,18 +2334,18 @@ static void mod_cur_headers(struct pktge
 
 	if (!(pkt_dev->flags & F_IPV6)) {
 
-		if ((imn = ntohl(pkt_dev->saddr_min)) < (imx =
-							 ntohl(pkt_dev->
-							       saddr_max))) {
+		imn = ntohl(pkt_dev->saddr_min);
+		imx = ntohl(pkt_dev->saddr_max);
+		if (imn < imx) {
 			__u32 t;
 			if (pkt_dev->flags & F_IPSRC_RND)
 				t = random32() % (imx - imn) + imn;
 			else {
 				t = ntohl(pkt_dev->cur_saddr);
 				t++;
-				if (t > imx) {
+				if (t > imx)
 					t = imn;
-				}
+
 			}
 			pkt_dev->cur_saddr = htonl(t);
 		}
@@ -2442,7 +2456,7 @@ static int pktgen_output_ipsec(struct sk
 	if (err)
 		goto error;
 
-	x->curlft.bytes +=skb->len;
+	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
 error:
 	spin_unlock(&x->lock);
@@ -2474,11 +2488,11 @@ static int process_ipsec(struct pktgen_d
 			int ret;
 			__u8 *eth;
 			nhead = x->props.header_len - skb_headroom(skb);
-			if (nhead >0) {
+			if (nhead > 0) {
 				ret = pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
 				if (ret < 0) {
 					printk(KERN_ERR "Error expanding "
-					       "ipsec packet %d\n",ret);
+					       "ipsec packet %d\n", ret);
 					goto err;
 				}
 			}
@@ -2488,13 +2502,13 @@ static int process_ipsec(struct pktgen_d
 			ret = pktgen_output_ipsec(skb, pkt_dev);
 			if (ret) {
 				printk(KERN_ERR "Error creating ipsec "
-				       "packet %d\n",ret);
+				       "packet %d\n", ret);
 				goto err;
 			}
 			/* restore ll */
 			eth = (__u8 *) skb_push(skb, ETH_HLEN);
 			memcpy(eth, pkt_dev->hh, 12);
-			*(u16 *) & eth[12] = protocol;
+			*(u16 *) &eth[12] = protocol;
 		}
 	}
 	return 1;
@@ -2507,9 +2521,9 @@ err:
 static void mpls_push(__be32 *mpls, struct pktgen_dev *pkt_dev)
 {
 	unsigned i;
-	for (i = 0; i < pkt_dev->nr_labels; i++) {
+	for (i = 0; i < pkt_dev->nr_labels; i++)
 		*mpls++ = pkt_dev->labels[i] & ~MPLS_STACK_BOTTOM;
-	}
+
 	mpls--;
 	*mpls |= MPLS_STACK_BOTTOM;
 }
@@ -2676,8 +2690,9 @@ static struct sk_buff *fill_packet_ipv4(
 		}
 	}
 
-	/* Stamp the time, and sequence number, convert them to network byte order */
-
+	/* Stamp the time, and sequence number,
+	 * convert them to network byte order
+	 */
 	if (pgh) {
 		struct timeval timestamp;
 
@@ -2931,7 +2946,7 @@ static struct sk_buff *fill_packet_ipv6(
 	udph = udp_hdr(skb);
 
 	memcpy(eth, pkt_dev->hh, 12);
-	*(__be16 *) & eth[12] = protocol;
+	*(__be16 *) &eth[12] = protocol;
 
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 -
@@ -3025,8 +3040,10 @@ static struct sk_buff *fill_packet_ipv6(
 		}
 	}
 
-	/* Stamp the time, and sequence number, convert them to network byte order */
-	/* should we update cloned packets too ? */
+	/* Stamp the time, and sequence number,
+	 * convert them to network byte order
+	 * should we update cloned packets too ?
+	 */
 	if (pgh) {
 		struct timeval timestamp;
 
@@ -3174,7 +3191,8 @@ static void pktgen_run_all_threads(void)
 
 	mutex_unlock(&pktgen_thread_lock);
 
-	schedule_timeout_interruptible(msecs_to_jiffies(125));	/* Propagate thread->control  */
+	/* Propagate thread->control  */
+	schedule_timeout_interruptible(msecs_to_jiffies(125));
 
 	pktgen_wait_all_threads_run();
 }
@@ -3192,7 +3210,8 @@ static void pktgen_reset_all_threads(voi
 
 	mutex_unlock(&pktgen_thread_lock);
 
-	schedule_timeout_interruptible(msecs_to_jiffies(125));	/* Propagate thread->control  */
+	/* Propagate thread->control  */
+	schedule_timeout_interruptible(msecs_to_jiffies(125));
 
 	pktgen_wait_all_threads_run();
 }
@@ -3485,7 +3504,8 @@ static int pktgen_thread_worker(void *ar
 	init_waitqueue_head(&t->queue);
 	complete(&t->start_done);
 
-	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
+	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n",
+		 cpu, task_pid_nr(current));
 
 	set_current_state(TASK_INTERRUPTIBLE);
 

-- 

