From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-yourcall] tcp: fix length used for checksum in a reset
Date: Wed, 8 Oct 2008 14:45:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810081436560.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1903026306-1223465850=:1034"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Adam Langley <agl@imperialviolet.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44507 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbYJHLqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 07:46:05 -0400
Content-ID: <Pine.LNX.4.64.0810081439280.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1903026306-1223465850=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810081439281.1034@wrl-59.cs.helsinki.fi>


While looking for some common code I came across difference
in checksum calculation between tcp_v6_send_(reset|ack) I
couldn't explain. I checked both v4 and v6 and found out that
both seem to have the same "feature". I couldn't find anything
in rfc nor anywhere else which would state that md5 option
should be ignored like it was in case of reset so I came to
a conclusion that this is probably a genuine bug. I suspect
that addition of md5 just was fooled by the excessive
copy-paste code in those functions and the reset part was
never tested well enough to find out the problem.

I don't see any urge to put this to net-2.6 right before
2.6.27 considering it has been broken for ages without anybody
noticing (considering the Linus' new always-been-like-that-
but-now-just-enforced rule :-)).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 24ffc5e..ba46769 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -589,7 +589,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
 				      ip_hdr(skb)->saddr, /* XXX */
-				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
+				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6268d26..26ac4fe 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1011,14 +1011,14 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	}
 #endif
 
-	buff->csum = csum_partial((char *)t1, sizeof(*t1), 0);
+	buff->csum = csum_partial((char *)t1, tot_len, 0);
 
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&fl.fl6_src, &ipv6_hdr(skb)->daddr);
 
 	t1->check = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
-				    sizeof(*t1), IPPROTO_TCP,
+				    tot_len, IPPROTO_TCP,
 				    buff->csum);
 
 	fl.proto = IPPROTO_TCP;
-- 
1.5.2.2
---696208474-1903026306-1223465850=:1034--
