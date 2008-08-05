From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] pktgen multiqueue etc
Date: Tue, 5 Aug 2008 16:28:31 +0200
Message-ID: <18584.25487.497437.392345@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:54713 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754711AbYHEO2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 10:28:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Sofar far pktgen have had a restriction to only use one device per kernel 
thread. With the new multiqueue architecture this is no longer adequate.

The patch below is an effort to remove this by in pktgen configuration 
adding a tag to  the device name a la eth0@0 etc. The tag is used for 
usual device config just as before. Also a new flag is introduced to mirror 
queue_map with sending threads smp_processor_id() QUEUE_MAP_CPU.

An example: We use 4 CPU's to send to one 10g interface (eth0)
 and we use the new tagging to send a mix of packet sizes, 64, 576 and
 1500 bytes. Also we use TX queues according to smp_processor_id()

 PGDEV=/proc/net/pktgen/kpktgend_0
 pgset "add_device eth0@0" 

 PGDEV=/proc/net/pktgen/kpktgend_1
 pgset "add_device eth0@1" 

 PGDEV=/proc/net/pktgen/kpktgend_2
 pgset "add_device eth0@2" 

 PGDEV=/proc/net/pktgen/kpktgend_3
 pgset "add_device eth0@3" 
....
PGDEV=/proc/net/pktgen/eth0@0 
pgset "pkt_size 64"
pgset "flag QUEUE_MAP_CPU"

PGDEV=/proc/net/pktgen/eth0@1
pgset "pkt_size 572"
pgset "flag QUEUE_MAP_CPU"

PGDEV=/proc/net/pktgen/eth0@2
pgset "pkt_size 1496"

PGDEV=/proc/net/pktgen/eth0@3
pgset "pkt_size 1496"
pgset "flag QUEUE_MAP_CPU"

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
					--ro


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3284605..9204e19 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -168,7 +168,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.69: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.70: Packet Generator for packet performance testing.\n"
 
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
@@ -189,6 +189,7 @@
 #define F_FLOW_SEQ    (1<<11)	/* Sequential flows */
 #define F_IPSEC_ON    (1<<12)	/* ipsec on for flows */
 #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
+#define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -621,6 +622,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_QUEUE_MAP_RND)
 		seq_printf(seq,  "QUEUE_MAP_RND  ");
 
+	if (pkt_dev->flags & F_QUEUE_MAP_CPU)
+		seq_printf(seq,  "QUEUE_MAP_CPU  ");
+
 	if (pkt_dev->cflows) {
 		if (pkt_dev->flags & F_FLOW_SEQ)
 			seq_printf(seq,  "FLOW_SEQ  "); /*in sequence flows*/
@@ -1134,6 +1138,12 @@ static ssize_t pktgen_if_write(struct file *file,
 
 		else if (strcmp(f, "!QUEUE_MAP_RND") == 0)
 			pkt_dev->flags &= ~F_QUEUE_MAP_RND;
+
+		else if (strcmp(f, "QUEUE_MAP_CPU") == 0)
+			pkt_dev->flags |= F_QUEUE_MAP_CPU;
+
+		else if (strcmp(f, "!QUEUE_MAP_CPU") == 0)
+			pkt_dev->flags &= ~F_QUEUE_MAP_CPU;
 #ifdef CONFIG_XFRM
 		else if (strcmp(f, "IPSEC") == 0)
 			pkt_dev->flags |= F_IPSEC_ON;
@@ -1895,6 +1905,23 @@ static int pktgen_device_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
+static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev, const char *ifname)
+{
+	char b[IFNAMSIZ+5];
+	int i = 0;
+
+	for(i=0; ifname[i] != '@'; i++) {
+		if(i == IFNAMSIZ)
+			break;
+
+		b[i] = ifname[i];
+	}
+	b[i] = 0;
+
+	return dev_get_by_name(&init_net, b);
+}
+
+
 /* Associate pktgen_dev with a device. */
 
 static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
@@ -1908,7 +1935,7 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 		pkt_dev->odev = NULL;
 	}
 
-	odev = dev_get_by_name(&init_net, ifname);
+	odev = pktgen_dev_get_by_name(pkt_dev, ifname);
 	if (!odev) {
 		printk(KERN_ERR "pktgen: no such netdevice: \"%s\"\n", ifname);
 		return -ENODEV;
@@ -2125,7 +2152,11 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 #endif
 static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
 {
-	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
+	
+	if (pkt_dev->flags & F_QUEUE_MAP_CPU) 
+		pkt_dev->cur_queue_map = smp_processor_id();
+
+	else if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
 		__u16 t;
 		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
 			t = random32() %

