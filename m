From: Anders Berggren <anders@halon.se>
Subject: [PATCH] TX timestamp IPv6 support
Date: Tue, 15 Feb 2011 14:56:21 +0100
Message-ID: <41D1D4BB-0CED-4396-B0FA-1DC42296DBCF@halon.se>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp.halon.se ([212.37.18.222]:61205 "EHLO vsp.halon.se"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751654Ab1BON42 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 08:56:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables UDP IPv6 TX timestamping (using SO_TIMESTAMPING, enabled by CONFIG_NETWORK_PHY_TIMESTAMPING) as Marcus D. Leech suggested in http://kerneltrap.org/mailarchive/linux-netdev/2009/11/10/6260604 and http://kerneltrap.org/mailarchive/linux-netdev/2009/11/11/6260643 

It's mostly copied from net/ipv4/udp.c. I guess it would be better to run sock_tx_timestamp in ipv6/udp.c and pass it to ipv6/ip6_output.c's ip6_append_data somehow, but I didn't find a suitable struct to extend for this purpose. 

Anders Berggren
Halon Security

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 94b5bf1..74d9343 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1115,6 +1115,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
        int err;
        int offset = 0;
        int csummode = CHECKSUM_NONE;
+       __u8 tx_flags = 0;
 
        if (flags&MSG_PROBE)
                return 0;
@@ -1199,6 +1200,13 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
                }
        }
 
+       /* For UDP, check if TX timestamp is enabled */ 
+       if (sk->sk_type == SOCK_DGRAM) {
+               err = sock_tx_timestamp(sk, &tx_flags);
+               if (err)
+                       goto error;
+       }
+
        /*
         * Let's try using as much space as possible.
         * Use MTU if total length of the message fits into the MTU.
@@ -1303,6 +1311,10 @@ alloc_new_skb:
                                                           sk->sk_allocation);
                                if (unlikely(skb == NULL))
                                        err = -ENOBUFS;
+                               else
+                                       /* only the initial fragment is
+                                          time stamped */
+                                       tx_flags = 0;
                        }
                        if (skb == NULL)
                                goto error;
@@ -1314,6 +1326,9 @@ alloc_new_skb:
                        /* reserve for fragmentation */
                        skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
 
+                       if (sk->sk_type == SOCK_DGRAM) 
+                               skb_shinfo(skb)->tx_flags = tx_flags;
+
                        /*
                         *      Find where to start putting bytes
                         */

