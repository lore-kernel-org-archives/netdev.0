From: "Laurent Chavey" <chavey@google.com>
Subject: [PATCH 2.6.25] bonding: Fix filtering of LLDP on inactive slave.
Date: Tue, 29 Apr 2008 18:42:06 -0700
Message-ID: <97949e3e0804291842n3cebde08j6265a7e60177d1fe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Laurent Chavey" <chavey@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60890 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbYD3BmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 21:42:14 -0400
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3U1g7Ue024871
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 02:42:08 +0100
Received: from rv-out-0506.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps37.corp.google.com with ESMTP id m3U1g6wZ022741
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 18:42:07 -0700
Received: by rv-out-0506.google.com with SMTP id b17so123942rvf.36
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 18:42:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modified the filtering of ingress packets on bonded interfaces to allow the
reception of LLDP packets on inactive slaves.
LLDP packets are point to point packets sent on every Ethernet link. LLPD
packets are use to pass L2 link layer information between a switch port
and a host.  The later information can be useful in detecting invalid topologies
for inactive slave links (i.e a link member of a bond is not connected to the
same switch as the other bond members).

Signed-off-by: Laurent Chavey <chavey@google.com>

--
diff -uNr linux-2.6.25/include/linux/if_ether.h
linux-2.6.25/include/linux/if_ether.h
--- linux-2.6.25/include/linux/if_ether.h   2008-04-16 19:49:44.000000000 -0700
+++ linux-2.6.25/include/linux/if_ether.h       2008-04-29
18:13:03.000000000 -0700
@@ -76,6 +76,7 @@
                                         */
 #define ETH_P_AOE      0x88A2          /* ATA over Ethernet            */
 #define ETH_P_TIPC     0x88CA          /* TIPC                         */
+#define ETH_P_LLDP     0x88CC          /* IEEE Std 802.1AB             */

 /*
  *     Non DIX types. Won't clash for 1500 types.
diff -uNr linux-2.6.25/include/linux/netdevice.h
linux-2.6.25/include/linux/netdevice.h
--- linux-2.6.25/include/linux/netdevice.h  2008-04-16 19:49:44.000000000 -0700
+++ linux-2.6.25/include/linux/netdevice.h      2008-04-29
18:12:02.000000000 -0700
@@ -1480,7 +1480,7 @@
 }

 /* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
+ * duplicates except for LLDP, 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
  */
 static inline int skb_bond_should_drop(struct sk_buff *skb)
@@ -1503,6 +1503,9 @@
                    skb->protocol == __constant_htons(ETH_P_SLOW))
                        return 0;

+               if (skb->protocol == __constant_htons(ETH_P_LLDP))
+                       return 0
+
                return 1;
        }
        return 0;
