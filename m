From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 12:48:47 -0700 (PDT)
Message-ID: <200710301948.MAA04351@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:40207 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536AbXJ3Tst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 15:48:49 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id D695C35792
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 12:48:48 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id MAA04351
	for netdev@vger.kernel.org; Tue, 30 Oct 2007 12:48:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the text which suggests that many balance_rr links feeding into
a single uplink will not experience packet reordering.

More up-to-date tests, with 1G links feeding into a switch with a 10G
uplink, using a 2.6.23-rc8 kernel on the system on which the 1G links
were bonded with balance_rr (mode=0) shows that even a many to one
link configuration will experience packet reordering and the attendant
TCP issues involving spurrious retransmissions and the congestion
window.  This happens even with a single, simple bulk transfer such as
a netperf TCP_STREAM test.  A more complete description of the tests
and results, including tcptrace analysis of packet traces showing the
degree of reordering and such can be found at:

http://marc.info/?l=linux-netdev&m=119101513406349&w=2

Also, note that some switches use the term "trunking" in a context
other than link aggregation.

Signed-off-by:  Rick Jones <rick.jones2@hp.com>

---
diff -r 35e54d4beaad Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	Wed Oct 24 05:06:40 2007 +0000
+++ b/Documentation/networking/bonding.txt	Mon Oct 29 03:47:19 2007 -0700
@@ -1696,23 +1696,6 @@ balance-rr: This mode is the only mode t
 	interface's worth of throughput, even after adjusting
 	tcp_reordering.
 
-	Note that this out of order delivery occurs when both the
-	sending and receiving systems are utilizing a multiple
-	interface bond.  Consider a configuration in which a
-	balance-rr bond feeds into a single higher capacity network
-	channel (e.g., multiple 100Mb/sec ethernets feeding a single
-	gigabit ethernet via an etherchannel capable switch).  In this
-	configuration, traffic sent from the multiple 100Mb devices to
-	a destination connected to the gigabit device will not see
-	packets out of order.  However, traffic sent from the gigabit
-	device to the multiple 100Mb devices may or may not see
-	traffic out of order, depending upon the balance policy of the
-	switch.  Many switches do not support any modes that stripe
-	traffic (instead choosing a port based upon IP or MAC level
-	addresses); for those devices, traffic flowing from the
-	gigabit device to the many 100Mb devices will only utilize one
-	interface.
-
 	If you are utilizing protocols other than TCP/IP, UDP for
 	example, and your application can tolerate out of order
 	delivery, then this mode can allow for single stream datagram
@@ -1720,7 +1703,9 @@ balance-rr: This mode is the only mode t
 	to the bond.
 
 	This mode requires the switch to have the appropriate ports
-	configured for "etherchannel" or "trunking."
+	configured for "etherchannel" or "aggregation." N.B. some
+	switches might use the term "trunking" for something other 
+	than link aggregation.
 
 active-backup: There is not much advantage in this network topology to
 	the active-backup mode, as the inactive backup devices are all
