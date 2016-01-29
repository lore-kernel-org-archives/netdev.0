From: Jiri Bohac <jbohac@suse.cz>
Subject: xfrm: UFO + ESP = double fragmentation
Date: Sat, 30 Jan 2016 00:44:24 +0100
Message-ID: <20160129234424.GC7907@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33737 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932583AbcA2Xo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2016 18:44:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm seeing wrong fragmentation on locally generated UDPv6 packets
going out over ESP (transport mode):

UFO is turned on on the outgoing interface and MTU is 1500.
When 8 kB is written to a UDP socket, udpv6_sendmsg() calls
ip_append_data() which generates a single 8 kB GSO skb.

Through ip6_send_skb() it reaches xfrm_output(). Since
skb_is_gso(skb) is nonzero, xfrm_output_gso() is called.
It immediatelly segments the skb via skb_gso_segment() and then
calls xfrm_output2() on each individual segment.

This is wrong. RFC4303 says:
	3.3.4.  Fragmentation
	   If necessary, fragmentation is performed after ESP
	   processing within an IPsec implementation.  Thus,
	   transport mode ESP is applied only to whole IP
	   datagrams (not to IP fragments).

Instead, xfrm_output_gso() applies the transform to each segment.
Since both the fragmentation header _and_ the ESP headers now
don't fit in the MTU and the ESP-encapsulated segments
are fragmented for a second time in ip6_finish_output().

The outcome is:
- the original 8k UDP packet is split into 6 ESP fragments
- the first 5 ESP fragments are 1508 bytes each, thus fragmented
  again into two fragments 

The destination host replies with ICMP parameter problem.

How is this supposed to work?
This hack fixes this specific case:

--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -198,7 +198,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	if (skb_is_gso(skb))
-		return xfrm_output_gso(net, sk, skb);
+		return xfrm_output2(net, sk, skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);


Is there a situation when xfrm_output_gso() does the right thing?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
