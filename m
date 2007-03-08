From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100 patch)
Date: Thu, 08 Mar 2007 13:37:41 -0800
Message-ID: <9975.1173389861@death>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
Cc: netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:38819 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030665AbXCHVif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 16:38:35 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l28LcYfL005121
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 16:38:34 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l28LcXSp507674
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 14:38:33 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l28LcXC8010411
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 14:38:33 -0700
In-reply-to: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Stromsoe <cbs@cts.ucla.edu> wrote:

>Within 2 or 3 minutes after issuing
>
>ip link set bond1 mtu 9000
>
>I get one "NETDEV WATCHDOG: eth2: transmit timed out" to the console, and
>then this starts to repeat:
>
>BUG: soft lockup detected on CPU#0!

	I believe this is the same bug that is fixed by this change:

commit c4f283b1f275e5528c13c119e5cfc80cdba55d00
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Feb 28 17:03:20 2007 -0800

    bonding: fix double dev_add_pack
    
        Bonding can erroneously register the same packet_type to receive
    ARPs (for use by ARP validation): once at device open time, and once via
    sysfs.  Since sysfs can change the validate setting (and thus register
    or unregister) at any time, a flag is needed to synchronize with device
    open in order to avoid double registrations, and the simplest place is
    within the packet_type structure itself.  Double unregister is not an
    issue.
    
        Bug reported by Ulrich Oelmann <ulrich.oelmann@web.de>.
    
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ea73ebf..68afcb5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3423,6 +3423,9 @@ void bond_register_arp(struct bonding *b
 {
 	struct packet_type *pt = &bond->arp_mon_pt;
 
+	if (pt->type)
+		return;
+
 	pt->type = htons(ETH_P_ARP);
 	pt->dev = NULL; /*bond->dev;XXX*/
 	pt->func = bond_arp_rcv;
@@ -3431,7 +3434,10 @@ void bond_register_arp(struct bonding *b
 
 void bond_unregister_arp(struct bonding *bond)
 {
-	dev_remove_pack(&bond->arp_mon_pt);
+	struct packet_type *pt = &bond->arp_mon_pt;
+
+	dev_remove_pack(pt);
+	pt->type = 0;
 }
 
 /*---------------------------- Hashing Policies -----------------------------*/


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
