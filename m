From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [RFC 4/4] af_packet: efficient SOCK_TIMESTAMP support
Date: Sun, 20 Apr 2008 22:36:11 -0700
Message-ID: <20080421053611.GD31778@48M1231.sanmateo.corp.akamai.com>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay01.akamai.com ([72.246.2.12]:39270 "EHLO
	prod-mail-xrelay01.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972AbYDUFkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:40:03 -0400
Content-Disposition: inline
In-Reply-To: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement SOCK_TIMESTAMP support for AF_PACKET sockets by recording a
timestamp for each skb which makes it past the filter.

By implementing SOCK_TIMESTAMP at this layer, we avoid the overhead of
recording a timestamp in the net core for every packet before we
know whether the packet will be filtered.

This preserves the existing behavior of recording a timestamp in the
tpacket_hdr of every packet on an mmaped packet socket, regardless of
whether SOCK_TIMESTAMP is set (but at least now we'll always record
timestamps *after* the filter runs).

Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>


---
 net/packet/af_packet.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux/net/packet/af_packet.c
===================================================================
--- linux.orig/net/packet/af_packet.c	2008-04-20 21:03:53.000000000 -0700
+++ linux/net/packet/af_packet.c	2008-04-20 21:04:07.000000000 -0700
@@ -484,6 +484,8 @@
 	    (unsigned)sk->sk_rcvbuf)
 		goto drop_n_acct;
 
+	sock_timestamp(sk, skb);
+
 	if (skb_shared(skb)) {
 		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 		if (nskb == NULL)
@@ -638,10 +640,9 @@
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
-	if (skb->tstamp.tv64)
-		tv = ktime_to_timeval(skb->tstamp);
-	else
-		do_gettimeofday(&tv);
+	if (!skb->tstamp.tv64)
+		__net_timestamp(skb);
+	tv = ktime_to_timeval(skb->tstamp);
 	h->tp_sec = tv.tv_sec;
 	h->tp_usec = tv.tv_usec;
 
@@ -957,6 +958,7 @@
 	.name	  = "PACKET",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct packet_sock),
+	.flags	  = (1 << PROTO_HAS_SOCK_TIMESTAMP),
 };
 
 /*
