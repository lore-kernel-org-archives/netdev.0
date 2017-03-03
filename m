From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH] udp: avoid ufo handling on IP payload compression packets
Date: Fri,  3 Mar 2017 15:37:32 +0300
Message-ID: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47610 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdCCMbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 07:31:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c146066ab802 ("ipv4: Don't use ufo handling on later transformed
packets") and commit f89c56ce710a ("ipv6: Don't use ufo handling on
later transformed packets") added a check that 'rt->dst.header_len' isn't
zero in order to skip UFO, but it doesn't include IPcomp in transport mode
where it equals zero.

Packets, after payload compression, may not require further fragmentation,
and if original length exceeds MTU, later compressed packets will be
transmitted incorrectly. This can be reproduced with LTP udp_ipsec.sh test
on veth device with enabled UFO, MTU is 1500 and UDP payload is 2000:

* IPv4 case, offset is wrong + unnecessary fragmentation
    udp_ipsec.sh -p comp -m transport -s 2000 &
    tcpdump -ni ltp_ns_veth2
    ...
    IP (tos 0x0, ttl 64, id 45203, offset 0, flags [+],
      proto Compressed IP (108), length 49)
      10.0.0.2 > 10.0.0.1: IPComp(cpi=0x1000)
    IP (tos 0x0, ttl 64, id 45203, offset 1480, flags [none],
      proto UDP (17), length 21) 10.0.0.2 > 10.0.0.1: ip-proto-17

* IPv6 case, sending small fragments
    udp_ipsec.sh -6 -p comp -m transport -s 2000 &
    tcpdump -ni ltp_ns_veth2
    ...
    IP6 (flowlabel 0x6b9ba, hlim 64, next-header Compressed IP (108)
      payload length: 37) fd00::2 > fd00::1: IPComp(cpi=0x1000)
    IP6 (flowlabel 0x6b9ba, hlim 64, next-header Compressed IP (108)
      payload length: 21) fd00::2 > fd00::1: IPComp(cpi=0x1000)

Fix it by checking 'rt->dst.xfrm' pointer to 'xfrm_state' struct, skip UFO
if xfrm is set. So the new check will include both cases: IPcomp and IPsec.

Fixes: c146066ab802 ("ipv4: Don't use ufo handling on later transformed packets")
Fixes: f89c56ce710a ("ipv6: Don't use ufo handling on later transformed packets")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/ipv4/ip_output.c  |    5 ++++-
 net/ipv6/ip6_output.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b67719f..18383ef 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -960,7 +960,10 @@ static int __ip_append_data(struct sock *sk,
 	cork->length += length;
 	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
+	    (rt->dst.dev->features & NETIF_F_UFO) &&
+#ifdef CONFIG_XFRM
+	    !rt->dst.xfrm &&
+#endif
 	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7cebee5..2a4d5ab 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1381,7 +1381,10 @@ static int __ip6_append_data(struct sock *sk,
 	if ((((length + fragheaderlen) > mtu) ||
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
+	    (rt->dst.dev->features & NETIF_F_UFO) &&
+#ifdef CONFIG_XFRM
+	    !rt->dst.xfrm &&
+#endif
 	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen, exthdrlen,
-- 
1.7.1
