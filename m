From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Problem with e100.c and packets >mtu in 2.6.4
Date: Mon, 15 Mar 2004 00:51:05 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403150035530.27707@mercury.sdinet.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,

After a while, I decided to try a kernel 2.6 on my laptop again (after
unsatisfying results with 2.6.1). 2.6.4 works, only one problem is left.


I have got the following onboard ethernet adaptor in my laptop:

02:08.0 Ethernet controller: Intel Corp. 82801BA/BAM/CA/CAM Ethernet
Controller (rev 03)

One special thing about my setup may be that I'm using a mtu of only 1442,
because this way I don't have to reconfigure it every time I'm moving it
into a location with broken PMTU and some vpn tunnels. But in most
locations, the other hosts (including the gateway) use a standard mtu of
1500 on the ethernet, only my laptop is sending smaller packets.

This has till now never been a problem, I'm just sending smaller packets
and receiving the bigger ones.

But the e100 in kernel 2.6.4 just drops these packets, eepro100 and
orinoco_cs accept them just fine, as does my last kernel 2.4.23.


Reverting a part of
http://linux.bkbits.net:8080/linux-2.5/diffs/drivers/net/e100.c@1.7?nav=index.html|src/|src/drivers|src/drivers/net|hist/drivers/net/e100.c
of e100.c with the following patch fixes it:

--- linux-2.6.4/drivers/net/e100.c-2.6.4	2004-03-13 03:37:06.000000000 +0100
+++ linux-2.6.4/drivers/net/e100.c	2004-03-13 03:38:53.000000000 +0100
@@ -1436,11 +1436,6 @@
 		/* Don't indicate if hardware indicates errors */
 		nic->net_stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
-	} else if(actual_size > nic->netdev->mtu + VLAN_ETH_HLEN) {
-		/* Don't indicate oversized frames */
-		nic->net_stats.rx_over_errors++;
-		nic->net_stats.rx_dropped++;
-		dev_kfree_skb_any(skb);
 	} else {
 		nic->net_stats.rx_packets++;
 		nic->net_stats.rx_bytes += actual_size;


What is the reason behind this check? Could it be removed from the
official sources again?

c'ya
sven

-- 

The Internet treats censorship as a routing problem, and routes around it.
(John Gilmore on http://www.cygnus.com/~gnu/)
