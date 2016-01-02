From: =?UTF-8?Q?Fl=c3=a1vio_Silveira?= <fggs@terra.com.br>
Subject: Attansic L1 driver issue
Date: Sat, 2 Jan 2016 03:58:43 -0200
Message-ID: <56876713.9090100@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Chris Snook <chris.snook@gmail.com>,
	jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from if01-mail-fb01-mia.mta.terra.com ([208.84.243.145]:52782 "EHLO
	if01-mail-fb01-mia.mta.terra.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbcABGTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 01:19:13 -0500
Received: from if01-mail-sr04-mia.mta.terra.com (unknown [208.84.243.21])
	by mail-fb01-mia.tpn.terra.com (Postfix) with ESMTP id 82BA118006578
	for <netdev@vger.kernel.org>; Sat,  2 Jan 2016 05:58:50 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good morning,

   I'm investigating a possible issue with atl1 driver used by Attansic L1.

   During my tests with iperf3 I saw a performance drop when the 
computer is client.

   I can hit only about 580~600Mbit/s, if I disable 
generic-segmentation-offload (GSO) I can hit 660~670Mbit/s.

   When the computer is server, I can hit 940~950Mbit/s.

   My tests are done with 2 computers directly connected with a cat6 
cable, static addresses on both, no iptables rules and commands below:

   # for the server
   iperf3 -s

   # for the client
   iperf3 -c <server ip> -P 1 -i 1 -p 5201 -f m -t 10

   To rule out a few things, I've tested with Fedora 23 live usb (kernel 
4.2.7) and Debian 8 Jessie (kernels 3.16.7 and latest stable 4.3.3).

   The other computer on the test ran Fedora 23 live usb and Windows 7 
SP1 x64, same results.

   I've been talking to Chris Snook (in CC), one of the maintainers of 
this driver and he suspects of a PCI regression. Unfortunately I 
couldn't git bisect for him, I'm actually thinking about installing 
Debian 6 Squeeze which ships with kernel 2.6.32 and it is close to the 
kernel this driver was mainlined (2.6.21 IIRC) and do the git bisect there.

   What I could do so far is enable debug in the driver and when I run 
iperf I see "tx busy" message. This message comes from this part of the 
driver:

# This is inside atl1_xmit_frame function and count is initialized with 1

if (atl1_tpd_avail(&adapter->tpd_ring) < count) {
         /* not enough descriptors */
         netif_stop_queue(netdev);
         if (netif_msg_tx_queued(adapter))
             dev_printk(KERN_DEBUG, &adapter->pdev->dev,
                 "tx busy\n");
         return NETDEV_TX_BUSY;
     }

   So I thought it could be TX ring too small, but I've played with 
available values and no change. Default value is 256 for TX ring and up 
to 1024 as max value.

   As you could notice I'm not knowledgeable, but I hope to get some 
insight on this, so it can hopefully be fixed.

Regards,
   Flavio Silveira
