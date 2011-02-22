From: Anders Berggren <anders@halon.se>
Subject: [PATCH] net: TX timestamps for IPv6 UDP packets
Date: Tue, 22 Feb 2011 22:43:47 +0100
Message-ID: <240353FF-7F9F-428C-84C3-3BD9B43213EE@halon.se>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: John Ronciak <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp.halon.se ([212.37.18.222]:54548 "EHLO vsp.halon.se"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751749Ab1BVVnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 16:43:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling TX timestamps (SO_TIMESTAMPING) for IPv6 UDP packets, in 
the same fashion as for IPv4. Necessary in order for NICs such as
Intel 82580 to timestamp IPv6 packets.

Signed-off-by: Anders Berggren <anders@halon.se>
---

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 94b5bf1..74d9343 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1115,6 +1115,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int err;
 	int offset = 0;
 	int csummode = CHECKSUM_NONE;
+	__u8 tx_flags = 0;
 
 	if (flags&MSG_PROBE)
 		return 0;
@@ -1199,6 +1200,13 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		}
 	}
 
+	/* For UDP, check if TX timestamp is enabled */
+	if (sk->sk_type == SOCK_DGRAM) {
+		err = sock_tx_timestamp(sk, &tx_flags);
+		if (err)
+			goto error;
+	}
+
 	/*
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
@@ -1303,6 +1311,10 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
+				else
+					/* only the initial fragment is
+					   time stamped */
+					tx_flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -1314,6 +1326,9 @@ alloc_new_skb:
 			/* reserve for fragmentation */
 			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
 
+			if (sk->sk_type == SOCK_DGRAM)
+				skb_shinfo(skb)->tx_flags = tx_flags;
+
 			/*
 			 *	Find where to start putting bytes
 			 */
