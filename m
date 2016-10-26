From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net] ipv6: Don't use ufo handling on later transformed packets
Date: Wed, 26 Oct 2016 11:21:14 +0200
Message-ID: <1477473674-21702-1-git-send-email-jkbs@redhat.com>
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37292 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757307AbcJZJVZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 05:21:25 -0400
Received: by mail-wm0-f43.google.com with SMTP id 140so9789466wmv.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 02:21:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c146066ab802 ("ipv4: Don't use ufo handling on later
transformed packets"), don't perform UFO on packets that will be IPsec
transformed. To detect it we rely on the fact that headerlen in
dst_entry is non-zero only for transformation bundles (xfrm_dst
objects).

Unwanted segmentation can be observed with a NETIF_F_UFO capable device,
such as a dummy device:

  DEV=dum0 LEN=1493

  ip li add $DEV type dummy
  ip addr add fc00::1/64 dev $DEV nodad
  ip link set $DEV up
  ip xfrm policy add dir out src fc00::1 dst fc00::2 \
     tmpl src fc00::1 dst fc00::2 proto esp spi 1
  ip xfrm state add src fc00::1 dst fc00::2 \
     proto esp spi 1 enc 'aes' 0x0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b

  tcpdump -n -nn -i $DEV -t &
  socat /dev/zero,readbytes=$LEN udp6:[fc00::2]:$LEN

tcpdump output before:

  IP6 fc00::1 > fc00::2: frag (0|1448) ESP(spi=0x00000001,seq=0x1), length 1448
  IP6 fc00::1 > fc00::2: frag (1448|48)
  IP6 fc00::1 > fc00::2: ESP(spi=0x00000001,seq=0x2), length 88

... and after:

  IP6 fc00::1 > fc00::2: frag (0|1448) ESP(spi=0x00000001,seq=0x1), length 1448
  IP6 fc00::1 > fc00::2: frag (1448|80)

Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..59eb4ed 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1366,7 +1366,7 @@ static int __ip6_append_data(struct sock *sk,
 	if (((length > mtu) ||
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO) &&
+	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
 	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen, exthdrlen,
-- 
2.7.4
