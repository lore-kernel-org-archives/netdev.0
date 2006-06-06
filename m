From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [ PATCH 2.6.17-rc6 1/1]  udp.c:  counting InDatagrams which are never delivered
Date: Tue, 6 Jun 2006 19:25:40 +0100
Message-ID: <200606061925.40327@this-message-has-been-logged>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kaber@coreworks.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47355 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1750825AbWFFSZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 14:25:55 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This problem involves MIB counter inaccuracies triggered by 
failed UDP checksums.

Problem: ip_local_deliver_finish calls udp_rcv, which calls
         udp_queue_rcv_skb. 
         Unless the sk_filter is set, the checksum of the incoming
         UDP datagram is not verified. If there are no other problems
         InDatagrams (UDP_MIB_INDATAGRAMS) is then incremented.
         Now, if udp_recvmsg is called as a handler for incoming
         UDP datagrams, the checksum is verified for the first time
         (unless sk_filter was set) and if the checksum fails, the
         `goto csum_copy_err' leads to forcibly removing the datagram
         _and_ incrementing InErrors (UDP_MIB_INERRORS). 

Issue:   When problem occurs in the manner described, the datagram
         is counted twice: once as InDatagram and once as InErrors.
         RFC 2013 defines InDatagrams as counter for delivered datagrams;
         these datagrams are counted but never delivered.

How to reproduce: Send UDP datagrams with checksums enabled, use middlebox
         which corrupts part of the traffic (e.g. bit errors / NetEm) and
         use /proc/net/snmp to watch the counters. The sum of InErrors,
         NoPorts and InDatagrams exceeds the real number of sent datagrams 
         by the number of datagrams which were counted twice and forcibly
         removed by udp_recvmsg.
Non-occurrence: The problem does not occur if the sender disabled 
         UDP checksums (zero field; allowed for IPv4, but not for IPv6), 
         since then the checksum code returns success.

Fix:   Move the `UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS)' statement from 
       udp_queue_rcv_skb to udp_recvmsg. Now InDatagrams only counts those
       datagrams which were really delivered (as per RFC 2013). 

Please CC: any correspondence to gerrit@erg.abdn.ac.uk  

Signed-off-by: <gerrit@erg.abdn.ac.uk>

---

diff -Nurp  a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2006-06-06 17:01:26.000000000 +0100
+++ b/net/ipv4/udp.c	2006-06-06 23:39:45.000000000 +0100
@@ -823,6 +823,7 @@ try_again:
 		goto out_free;
 
 	sock_recv_timestamp(msg, sk, skb);
+	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS);
 
 	/* Copy the address. */
 	if (sin)
@@ -1032,7 +1033,6 @@ static int udp_queue_rcv_skb(struct sock
 		kfree_skb(skb);
 		return -1;
 	}
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS);
 	return 0;
 }
 


