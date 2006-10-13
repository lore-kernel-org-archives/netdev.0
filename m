From: Ryan Nowakowski <ryan@britestream.com>
Subject: [PATCH] ipvs loopback connection
Date: Fri, 13 Oct 2006 15:12:41 -0500
Message-ID: <20061013201241.GD14789@britestream.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DO5DiztRLs659m5i"
Cc: lvs-users@LinuxVirtualServer.org, clozano@andago.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.britestream.com ([207.191.53.98]:22300 "EHLO
	gateway.layern.com") by vger.kernel.org with ESMTP id S1751873AbWJMUND
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 16:13:03 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DO5DiztRLs659m5i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This is a port of Carlos Lozano's 2.4 patch[1] to 2.6.16.  I believe
Carlos's comments about the original 2.4 patch still pertain here:

	We have a machine that must be both a client and director. The
	two problems to solve are:
		* ipvs doesn't handle loopback packets
		* the return packets are handled by ip_vs_in, and not
		  by ip_vs_out.

With kernel 2.6 there's an additional problem to solve:
  * there's a shortcut used to recompute the tcp checksum that doesn't
    work in this case

The attached patch fixes the problems listed above.

1. http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html#carlos_solution

--DO5DiztRLs659m5i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ipvs_loopback.patch"

diff -Naur linux-source-2.6.16/net/ipv4/ipvs/ip_vs_core.c linux-source-2.6.16-ipvs_loopback/net/ipv4/ipvs/ip_vs_core.c
--- linux-source-2.6.16/net/ipv4/ipvs/ip_vs_core.c	2006-03-19 23:53:29.000000000 -0600
+++ linux-source-2.6.16-ipvs_loopback/net/ipv4/ipvs/ip_vs_core.c	2006-10-02 17:28:18.000000000 -0500
@@ -953,7 +953,7 @@
 	 *	... don't know why 1st test DOES NOT include 2nd (?)
 	 */
 	if (unlikely(skb->pkt_type != PACKET_HOST
-		     || skb->dev == &loopback_dev || skb->sk)) {
+		     || skb->sk)) {
 		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
 			  skb->pkt_type,
 			  skb->nh.iph->protocol,
@@ -978,6 +978,14 @@
 
 	ihl = iph->ihl << 2;
 
+	cp = pp->conn_out_get(skb, pp, iph, ihl, 0);
+
+	if (cp) {
+		__ip_vs_conn_put(cp);
+
+		return (ip_vs_out(hooknum,pskb,in,out,okfn));
+	}
+
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
diff -Naur linux-source-2.6.16/net/ipv4/ipvs/ip_vs_proto_tcp.c linux-source-2.6.16-ipvs_loopback/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- linux-source-2.6.16/net/ipv4/ipvs/ip_vs_proto_tcp.c	2006-03-19 23:53:29.000000000 -0600
+++ linux-source-2.6.16-ipvs_loopback/net/ipv4/ipvs/ip_vs_proto_tcp.c	2006-10-02 17:27:08.000000000 -0500
@@ -200,23 +200,15 @@
 	/*
 	 *	Adjust TCP checksums
 	 */
-	if (!cp->app) {
-		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
-				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
-			(*pskb)->ip_summed = CHECKSUM_NONE;
-	} else {
-		/* full checksum calculation */
-		tcph->check = 0;
-		(*pskb)->csum = skb_checksum(*pskb, tcphoff,
-					     (*pskb)->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
-						(*pskb)->len - tcphoff,
-						cp->protocol,
-						(*pskb)->csum);
-		(*pskb)->ip_summed = CHECKSUM_UNNECESSARY;
-	}
+	/* full checksum calculation */
+	tcph->check = 0;
+	(*pskb)->csum = skb_checksum(*pskb, tcphoff,
+						 (*pskb)->len - tcphoff, 0);
+	tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
+					(*pskb)->len - tcphoff,
+					cp->protocol,
+					(*pskb)->csum);
+	(*pskb)->ip_summed = CHECKSUM_UNNECESSARY;
 	return 1;
 }
 

--DO5DiztRLs659m5i--
