From: Chris Lalancette <clalance@redhat.com>
Subject: Zero checksum in netconsole/netdump packets
Date: Mon, 06 Nov 2006 18:40:59 -0500
Message-ID: <454FC80B.9090001@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030500050308070302010709"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:27098 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1753931AbWKFXlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 18:41:01 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id kA6Nf0wj000918
	for <netdev@vger.kernel.org>; Mon, 6 Nov 2006 18:41:00 -0500
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id kA6Nf0nv024088
	for <netdev@vger.kernel.org>; Mon, 6 Nov 2006 18:41:00 -0500
Received: from [172.16.81.47] (locutus.boston.redhat.com [172.16.81.47])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id kA6Nex8n019587
	for <netdev@vger.kernel.org>; Mon, 6 Nov 2006 18:41:00 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030500050308070302010709
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello,
      I was reading some tcpdump's of netdump traffic today, and I realized that all of the packets that go from the crashing machine to the netdump server have a zero checksum.  Looking at the code, it looks like netconsole/netdump use the function netpoll_send_udp to send out the packets.  However, in netdump_send_udp, the checksum is set to 0, and never seems to be computed.  Is this intentional, or just an oversight?  I would think that we would always want to compute the UDP checksum, but there might be something I am overlooking.  Incidentally, it seems like the only user of netpoll_send_udp is netconsole (and netdump in RedHat kernels).
     Assuming that this is just an oversight, attached is a simple patch to compute the UDP checksum in netpoll_send_udp.

Signed-off-by: Chris Lalancette <clalance@redhat.com>

--------------030500050308070302010709
Content-Type: text/x-patch;
 name="linux-2.6.19-rc4-netpoll-udp-checksum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.19-rc4-netpoll-udp-checksum.patch"

--- linux-2.6/net/core/netpoll.c.orig	2006-11-06 18:16:58.000000000 -0500
+++ linux-2.6/net/core/netpoll.c	2006-11-06 18:31:20.000000000 -0500
@@ -356,6 +356,10 @@ void netpoll_send_udp(struct netpoll *np
 	put_unaligned(htonl(np->remote_ip), &(iph->daddr));
 	iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
+	udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr, udp_len,
+					IPPROTO_UDP,
+					csum_partial((unsigned char *)udph, udp_len, 0));
+
 	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
 	skb->mac.raw = skb->data;
 	skb->protocol = eth->h_proto = htons(ETH_P_IP);

--------------030500050308070302010709--
