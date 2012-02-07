From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] e1000: Neaten e1000_dump function
Date: Tue, 07 Feb 2012 10:19:35 -0800
Message-ID: <1328638775.4837.10.camel@joe2Laptop>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328629203.4837.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Tushar Dave <tushar.n.dave@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60488 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753261Ab2BGSTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 13:19:36 -0500
In-Reply-To: <1328629203.4837.6.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_<level> for printk
Use temporary instead of multiple pr_conts
Coalesce formats.

Save a few bytes of object code too:

$ size drivers/net/ethernet/intel/e1000/e1000_main.o*
   text	   data	    bss	    dec	    hex	filename
  60507	    369	  14120	  74996	  124f4	drivers/net/ethernet/intel/e1000/e1000_main.o.new
  60717	    369	  14176	  75262	  125fe	drivers/net/ethernet/intel/e1000/e1000_main.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 1f86a70..1370057 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3247,16 +3247,16 @@ static void e1000_regdump(struct e1000_adapter *adapter)
 	u32 *regs_buff = regs;
 	int i = 0;
 
-	char *reg_name[] = {
-	"CTRL",  "STATUS",
-	"RCTL", "RDLEN", "RDH", "RDT", "RDTR",
-	"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
-	"TIDV", "TXDCTL", "TADV", "TARC0",
-	"TDBAL1", "TDBAH1", "TDLEN1", "TDH1", "TDT1",
-	"TXDCTL1", "TARC1",
-	"CTRL_EXT", "ERT", "RDBAL", "RDBAH",
-	"TDFH", "TDFT", "TDFHS", "TDFTS", "TDFPC",
-	"RDFH", "RDFT", "RDFHS", "RDFTS", "RDFPC"
+	static const char * const reg_name[] = {
+		"CTRL",  "STATUS",
+		"RCTL", "RDLEN", "RDH", "RDT", "RDTR",
+		"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
+		"TIDV", "TXDCTL", "TADV", "TARC0",
+		"TDBAL1", "TDBAH1", "TDLEN1", "TDH1", "TDT1",
+		"TXDCTL1", "TARC1",
+		"CTRL_EXT", "ERT", "RDBAL", "RDBAH",
+		"TDFH", "TDFT", "TDFHS", "TDFTS", "TDFPC",
+		"RDFH", "RDFT", "RDFHS", "RDFTS", "RDFPC"
 	};
 
 	regs_buff[0]  = er32(CTRL);
@@ -3302,10 +3302,8 @@ static void e1000_regdump(struct e1000_adapter *adapter)
 	regs_buff[37] = er32(RDFPC);
 
 	pr_info("Register dump\n");
-	for (i = 0; i < NUM_REGS; i++) {
-		printk(KERN_INFO "%-15s  %08x\n",
-		reg_name[i], regs_buff[i]);
-	}
+	for (i = 0; i < NUM_REGS; i++)
+		pr_info("%-15s  %08x\n", reg_name[i], regs_buff[i]);
 }
 
 /*
@@ -3356,10 +3354,8 @@ static void e1000_dump(struct e1000_adapter *adapter)
 	 *   +----------------------------------------------------------------+
 	 *   63       48 47     40 39  36 35    32 31     24 23  20 19        0
 	 */
-	printk(KERN_INFO "Tc[desc]     [Ce CoCsIpceCoS] [MssHlRSCm0Plen] [bi->dma       ]"
-	       " leng  ntw timestmp         bi->skb\n");
-	printk(KERN_INFO "Td[desc]     [address 63:0  ] [VlaPoRSCm1Dlen] [bi->dma       ]"
-	       " leng  ntw timestmp         bi->skb\n");
+	pr_info("Tc[desc]     [Ce CoCsIpceCoS] [MssHlRSCm0Plen] [bi->dma       ] leng  ntw timestmp         bi->skb\n");
+	pr_info("Td[desc]     [address 63:0  ] [VlaPoRSCm1Dlen] [bi->dma       ] leng  ntw timestmp         bi->skb\n");
 
 	if (!netif_msg_tx_done(adapter))
 		goto rx_ring_summary;
@@ -3369,21 +3365,23 @@ static void e1000_dump(struct e1000_adapter *adapter)
 		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
 		struct my_u { u64 a; u64 b; };
 		struct my_u *u = (struct my_u *)tx_desc;
-		printk(KERN_INFO "T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X "
-		       "%016llX %p",
-		       ((le64_to_cpu(u->b) & (1<<20)) ? 'd' : 'c'), i,
-		       le64_to_cpu(u->a), le64_to_cpu(u->b),
-		       (u64)buffer_info->dma, buffer_info->length,
-		       buffer_info->next_to_watch, (u64)buffer_info->time_stamp,
-		       buffer_info->skb);
+		const char *type;
+
 		if (i == tx_ring->next_to_use && i == tx_ring->next_to_clean)
-			printk(KERN_CONT" NTC/U\n");
+			type = "NTC/U";
 		else if (i == tx_ring->next_to_use)
-			printk(KERN_CONT " NTU\n");
+			type = "NTU";
 		else if (i == tx_ring->next_to_clean)
-			printk(KERN_CONT " NTC\n");
+			type = "NTC";
 		else
-			printk(KERN_CONT "\n");
+			type = "";
+
+		pr_info("T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X %016llX %p %s\n",
+			((le64_to_cpu(u->b) & (1<<20)) ? 'd' : 'c'), i,
+			le64_to_cpu(u->a), le64_to_cpu(u->b),
+			(u64)buffer_info->dma, buffer_info->length,
+			buffer_info->next_to_watch,
+			(u64)buffer_info->time_stamp, buffer_info->skb, type);
 
 
 		if (netif_msg_pktdata(adapter) && buffer_info->dma != 0)
@@ -3407,8 +3405,7 @@ rx_ring_summary:
 	 * +-----------------------------------------------------+
 	 * 63       48 47    40 39      32 31         16 15      0
 	 */
-	printk(KERN_INFO "R[desc]      [address 63:0  ] [vl er S cks ln] "
-		"[bi->dma       ] [bi->skb]\n");
+	pr_info("R[desc]      [address 63:0  ] [vl er S cks ln] [bi->dma       ] [bi->skb]\n");
 
 	if (!netif_msg_rx_status(adapter))
 		goto exit;
@@ -3418,15 +3415,18 @@ rx_ring_summary:
 		struct e1000_buffer *buffer_info = &rx_ring->buffer_info[i];
 		struct my_u { u64 a; u64 b; };
 		struct my_u *u = (struct my_u *)rx_desc;
-		printk(KERN_INFO "R[0x%03X]     %016llX %016llX %016llX %p",
-			i, le64_to_cpu(u->a), le64_to_cpu(u->b),
-			(u64)buffer_info->dma, buffer_info->skb);
+		const char *type;
+
 		if (i == rx_ring->next_to_use)
-			printk(KERN_CONT " NTU\n");
+			type = "NTU";
 		else if (i == rx_ring->next_to_clean)
-			printk(KERN_CONT " NTC\n");
+			type = "NTC";
 		else
-			printk(KERN_CONT "\n");
+			type = "";
+
+		pr_info("R[0x%03X]     %016llX %016llX %016llX %p %s\n",
+			i, le64_to_cpu(u->a), le64_to_cpu(u->b),
+			(u64)buffer_info->dma, buffer_info->skb, type);
 
 		if (netif_msg_pktdata(adapter))
 			print_hex_dump(KERN_INFO, "",
@@ -3438,24 +3438,24 @@ rx_ring_summary:
 
 	/* dump the descriptor caches */
 	/* rx */
-	printk(KERN_INFO "e1000: Rx descriptor cache in 64bit format\n");
+	pr_info("Rx descriptor cache in 64bit format\n");
 	for (i = 0x6000; i <= 0x63FF ; i += 0x10) {
-		printk(KERN_INFO "R%04X: %08X|%08X %08X|%08X\n",
-				i,
-				readl(adapter->hw.hw_addr + i+4),
-				readl(adapter->hw.hw_addr + i),
-				readl(adapter->hw.hw_addr + i+12),
-				readl(adapter->hw.hw_addr + i+8));
+		pr_info("R%04X: %08X|%08X %08X|%08X\n",
+			i,
+			readl(adapter->hw.hw_addr + i+4),
+			readl(adapter->hw.hw_addr + i),
+			readl(adapter->hw.hw_addr + i+12),
+			readl(adapter->hw.hw_addr + i+8));
 	}
 	/* tx */
-	printk(KERN_INFO "e1000: Tx descriptor cache in 64bit format\n");
+	pr_info("Tx descriptor cache in 64bit format\n");
 	for (i = 0x7000; i <= 0x73FF ; i += 0x10) {
-		printk(KERN_INFO "T%04X: %08X|%08X %08X|%08X\n",
-				i,
-				readl(adapter->hw.hw_addr + i+4),
-				readl(adapter->hw.hw_addr + i),
-				readl(adapter->hw.hw_addr + i+12),
-				readl(adapter->hw.hw_addr + i+8));
+		pr_info("T%04X: %08X|%08X %08X|%08X\n",
+			i,
+			readl(adapter->hw.hw_addr + i+4),
+			readl(adapter->hw.hw_addr + i),
+			readl(adapter->hw.hw_addr + i+12),
+			readl(adapter->hw.hw_addr + i+8));
 	}
 exit:
 	return;
