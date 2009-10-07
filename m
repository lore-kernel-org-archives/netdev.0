From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: extend hash tables to 256 slots
Date: Wed, 07 Oct 2009 06:43:31 +0200
Message-ID: <4ACC1C73.1010506@gmail.com>
References: <4ACBCDD8.5000306@gmail.com> <4ACBE3E7.60404@hp.com> <4ACC0CDE.1020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34769 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbZJGEoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 00:44:13 -0400
In-Reply-To: <4ACC0CDE.1020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> I was going to setup a bench lab, with a typical RTP mediaserver, wit=
h say
> 4000 UDP sockets, 2000 sockets exchanging 50 G.711 Alaw/ulaw
> messages per second tx and rx. (Total : 100.000 packets per second ea=
ch way)
>=20

Hmm, it seems we'll have too many sockets per udp hash chain unfortunat=
ly for this
workload to show any improvement.

(~32 sockets per chain : average of 16 misses to lookup the target sock=
et.)

David, I believe UDP_HTABLE_SIZE never changed from its initial value o=
f 128,
defined 15 years ago. Could we bump it to 256 ?

(back in 1995, SOCK_ARRAY_SIZE was 256)

(I'll probably use 1024 value for my tests)

[PATCH] udp: extend hash tables to 256 slots

UDP_HTABLE_SIZE was initialy defined to 128, which is a bit small for s=
everal setups.
4000 active sockets -> 32 sockets per chain in average.

Doubling hash table size has a memory cost of 128 (pointers + spinlocks=
) for UDP,
same for UDPLite, this should be OK.

It reduces the size of bitmap used in udp_lib_get_port() and speedup po=
rt allocation.
#define PORTS_PER_CHAIN (65536 / UDP_HTABLE_SIZE) -> 256 bits instead o=
f 512 bits

Use CONFIG_BASE_SMALL to keep hash tables small for small machines.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/udp.h b/include/linux/udp.h
index 0cf5c4c..8aaa151 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -45,7 +45,7 @@ static inline struct udphdr *udp_hdr(const struct sk_=
buff *skb)
 	return (struct udphdr *)skb_transport_header(skb);
 }
=20
-#define UDP_HTABLE_SIZE		128
+#define UDP_HTABLE_SIZE		(CONFIG_BASE_SMALL ? 128 : 256)
=20
 static inline int udp_hashfn(struct net *net, const unsigned num)
 {
