From: Tim Small <tim@buttersideup.com>
Subject: larger than 1500 MTU support for 8139too - request for comments
Date: Sat, 27 Jul 2013 22:35:10 +0100
Message-ID: <51F43D0E.3020303@buttersideup.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090802090004000404080800"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.allsecuredomains.com ([78.47.234.210]:34355 "EHLO
	relay1.allsecuredomains.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724Ab3G0Vw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 17:52:29 -0400
Received: from [78.105.152.189] (helo=zebedee.buttersideup.com)
	by relay1.allsecuredomains.com with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <tim@buttersideup.com>)
	id 1V3C8t-0001E0-F2
	for netdev@vger.kernel.org; Sat, 27 Jul 2013 22:35:13 +0100
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by zebedee.buttersideup.com (Postfix) with ESMTP id CDBE640D04
	for <netdev@vger.kernel.org>; Sat, 27 Jul 2013 22:35:10 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090802090004000404080800
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I'm interested in enabling > 1500 octet MTU support for the 8139 so that
I can use it for GRE and PPPoE etc. encapsulation with a 1500 MTU
payload - the datasheet suggests that it'll receive 4k frames, but it
the 8139B and 8139D which I have seem to stop receiving packets with an
MTU of more than 1722 (the cards start logging receive errors).  Still -
plenty for 'mini jumbos' / 'baby giants' or whatever you want to call
them.  I've tried poking a few other things in the driver to see if I
can improve on this without success.

The patch is pretty straightforward - the only possible downside which I
can see in normal operation is that the total tx buffer size goes from
6144 bytes to 6944 bytes.

I think I have a few other 8139 variant cards somewhere, but before I
try to find them and do further testing with more real and virtual
hardware (I'm currently working on 3.2.46 - because that's my distro
kernel), I thought I'd see if this was likely to be accepted upstream at
all?

As an MTU of 1600 seems to be what's frequently defined as 'baby giant'
for encapsulation purposes, I was wondering if this would be a better
figure to pick (tx buffer alloc goes from 6144 to 6544 bytes).  I assume
that I shouldn't bother to implement dynamic buffer allocation for that
gain of 400 bytes, but perhaps that's wrong?

Alternatively, if anyone has any other ideas for getting 4k frames
working on these chips, it'd be interesting to see if that'd work.

Thanks,

Tim.




--------------090802090004000404080800
Content-Type: text/x-patch;
 name="8139too-mtu.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="8139too-mtu.diff"

--- 8139too.c.old	2013-05-30 14:35:16.000000000 +0100
+++ 8139too.c	2013-07-27 22:09:50.519097242 +0100
@@ -182,8 +182,11 @@
 /* Number of Tx descriptor registers. */
 #define NUM_TX_DESC	4
 
-/* max supported ethernet frame size -- must be at least (dev->mtu+14+4).*/
-#define MAX_ETH_FRAME_SIZE	1536
+/* max supported ethernet frame size -- must be at least (dev->mtu+14+4).
+ * Whilst the 8139 datasheets suggest that "4k" frames can be received,
+ * this figure has been derived impirically using 8139B and 8139D hardware.
+ */
+#define MAX_ETH_FRAME_SIZE	1736
 
 /* Size of the Tx bounce buffers -- must be at least (dev->mtu+14+4). */
 #define TX_BUF_SIZE	MAX_ETH_FRAME_SIZE
@@ -639,6 +642,7 @@
 static int rtl8139_set_mac_address(struct net_device *dev, void *p);
 static int rtl8139_poll(struct napi_struct *napi, int budget);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance);
+static int rtl8139_change_mtu (struct net_device *dev, int new_mtu);
 static int rtl8139_close (struct net_device *dev);
 static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev);
@@ -912,7 +916,7 @@
 	.ndo_open		= rtl8139_open,
 	.ndo_stop		= rtl8139_close,
 	.ndo_get_stats		= rtl8139_get_stats,
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= rtl8139_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= rtl8139_set_mac_address,
 	.ndo_start_xmit		= rtl8139_start_xmit,
@@ -924,6 +928,14 @@
 #endif
 };
 
+static int rtl8139_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < 68 || new_mtu > (MAX_ETH_FRAME_SIZE - 36))
+                return -EINVAL;
+        dev->mtu = new_mtu;
+        return 0;
+}
+
 static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {


--------------090802090004000404080800--
