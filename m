From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 10:08:26 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908261006520.9924@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org> <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, niv@linux.vnet.ibm.com,
	sri@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:48965 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757402AbZHZOIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 10:08:54 -0400
In-Reply-To: <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also see no UDP stats for packet drops. If Erics fix gets in then
ip_push_pending_frames() will give us an error code on drop.
Incrementing SNDBUFERRORS would require this simple patch.


UDP: Account for TX drops

UDP layer is currently not incrementing error counters when packets are
dropped. Use the SNDBUFERRORS to indicate packet drops on send.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 net/ipv4/udp.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/net/ipv4/udp.c
===================================================================
--- linux-2.6.orig/net/ipv4/udp.c	2009-08-26 13:21:30.000000000 +0000
+++ linux-2.6/net/ipv4/udp.c	2009-08-26 13:46:35.000000000 +0000
@@ -559,6 +559,13 @@ static int udp_push_pending_frames(struc

 send:
 	err = ip_push_pending_frames(sk);
+
+	if (err)
+		/*
+		 * Packet was dropped.
+		 */
+		UDP_INC_STATS_USER(sock_net(sk),
+			UDP_MIB_SNDBUFERRORS, is_udplite);
 out:
 	up->len = 0;
 	up->pending = 0;
