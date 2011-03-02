From: "Alex G." <mr.nuke.me@gmail.com>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 02 Mar 2011 22:06:21 +0200
Message-ID: <4D6EA33D.70801@gmail.com>
References: <20110302163233.GA14491@core.hellgate.ch> <201103021901.39849.florian@openwrt.org> <4D6E883C.2000800@gmail.com> <20110302.113610.71137356.davem@davemloft.net> <20110302195205.GA15190@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060703080000000901080301"
Cc: David Miller <davem@davemloft.net>, florian@openwrt.org,
	netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40396 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab1CBULB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 15:11:01 -0500
Received: by bwz15 with SMTP id 15so518490bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 12:11:00 -0800 (PST)
In-Reply-To: <20110302195205.GA15190@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060703080000000901080301
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>
---

On 03/02/2011 09:52 PM, Roger Luethi wrote:
> Alex, can you redo the patch accordingly?
Done and tested.


[root@nukeserv2 mrnuke]# rmmod via-rhine
[root@nukeserv2 mrnuke]# insmod via-rhine.ko
[28234.938404] via-rhine.c:v1.10-LK1.4.3 2007-03-06 Written by Donald Becker
[28234.945186] via-rhine: Invalid MAC address: ef:9f:e9:f7:f7:f7.
[28234.945518] via-rhine: Using randomly generated address:
02:0f:c4:98:a6:fd instead.
[28234.948793] eth1: VIA Rhine II at 0xfaa00000, 02:0f:c4:98:a6:fd, IRQ 23.
[28234.950223] eth1: MII PHY found at address 1, status 0x7849
advertising 01e1 Link 0000.
[root@nukeserv2 mrnuke]# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 02:0F:C4:98:A6:FD
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:23


--------------060703080000000901080301
Content-Type: text/x-patch;
 name="rhine.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rhine.patch"

diff --git a/linux-2.6.35.11/drivers/net/via-rhine.c b/via-rhine.c
index 4930f9d..4c1b9e7 100644
--- a/linux-2.6.35.11/drivers/net/via-rhine.c
+++ b/via-rhine.c
@@ -762,13 +762,16 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	if (!is_valid_ether_addr(dev->perm_addr)) {
-		rc = -EIO;
-		printk(KERN_ERR "Invalid MAC address\n");
-		goto err_out_unmap;
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		printk(KERN_ERR "via-rhine: Invalid MAC address: %pM. \n",
+				dev->dev_addr);
+		/* The device may still be used normally if a valid MAC is configured */
+		random_ether_addr(dev->dev_addr);
+		printk(KERN_ERR "via-rhine: Using randomly generated address: %pM instead. \n",
+				dev->dev_addr);
 	}
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* For Rhine-I/II, phy_id is loaded from EEPROM */
 	if (!phy_id)

--------------060703080000000901080301--
