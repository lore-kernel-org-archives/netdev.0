From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] ibmtr: fix tr%d in dmesg
Date: Sat, 2 Oct 2010 21:35:15 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1010022056000.27121@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:34400 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab0JBSfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Oct 2010 14:35:17 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp1.it.da.ut.ee (Postfix) with ESMTP id 7810A6E4D55
	for <netdev@vger.kernel.org>; Sat,  2 Oct 2010 21:35:15 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 5563ADAF80
	for <netdev@vger.kernel.org>; Sat,  2 Oct 2010 21:35:15 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ibmtr and ibmtr_cs show tr%d in dmesg after alloc_netdev() but before 
register_netdev(). Fix it like e100 does - put a different name into 
dev->name until the device gets registered. I/O port seems to be unique
enough and is available for the time of printk messages. With the fix, 
dmesg shows

ibmtr@0a20: ISA P&P 16/4 Adapter/A (short) | 16/4 ISA-16 Adapter found
ibmtr@0a20: using irq 3, PIOaddr a20, 64K shared RAM.
ibmtr@0a20: Hardware address : 00:40:aa:a9:03:98
ibmtr@0a20: Shared RAM paging disabled. ti->page_mask 0
ibmtr@0a20: Maximum Receive Internet Protocol MTU 16Mbps: 16344, 4Mbps: 6104
tr0: port 0xa20, irq 3,  mmio 0xd4850000, sram 0xd0000, hwaddr=00:40:aa:a9:03:98

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 91e6c78..5de281f 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -368,6 +368,7 @@ int __devinit ibmtr_probe_card(struct net_device *dev)
 {
 	int err = ibmtr_probe(dev);
 	if (!err) {
+		strcpy(dev->name, "tr%d");
 		err = register_netdev(dev);
 		if (err)
 			ibmtr_cleanup_card(dev);
@@ -699,6 +700,7 @@ static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
 		printk(version);
 	}
 #endif /* !PCMCIA */
+	sprintf(dev->name, "ibmtr@%04x", PIOaddr);
 	DPRINTK("%s %s found\n",
 		channel_def[cardpresent - 1], adapter_def(ti->adapter_type));
 	DPRINTK("using irq %d, PIOaddr %hx, %dK shared RAM.\n",

-- 
Meelis Roos (mroos@linux.ee)
