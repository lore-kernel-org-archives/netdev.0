From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: tcp: tcp_v6_send_response() should give an
 owner to skb
Date: Wed, 28 Jan 2015 05:57:13 -0800
Message-ID: <1422453433.29618.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:58273 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbbA1U4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:56:07 -0500
Received: by mail-ie0-f172.google.com with SMTP id rd18so24844994iec.3
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:56:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

RST packets and ACK packets sent on behalf of TIME_WAIT sockets
do not have a socket owner currently.

For sch_fq users, this means fq classifier has to fallback to packet
dissection and allocate one flow structure, while we generally send
a single packet. This is also an attack vector.

Note that ip6_xmit() correctly uses skb_set_owner_w() if skb needs
to be reallocated when head room is not big enough.

Simply use sock_wmalloc() instead of alloc_skb().

Note: This might increase false sharing on the ctl_sk, which is
shared by all cpus for a given network namespace. We might switch later
to a percpu socket as we do for IPv4.

Also use MAX_TCP_HEADER, as it makes the code shorter.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832c6f72b89a278a3326918a3c8bff9afed4..cd4f7be3ecdd3628b07eb76bd2d4204753da23a6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -809,12 +809,11 @@ static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
 		tot_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
 
-	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
-	if (buff == NULL)
+	buff = sock_wmalloc(ctl_sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
+	if (!buff)
 		return;
 
-	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
+	skb_reserve(buff, MAX_TCP_HEADER);
 
 	t1 = (struct tcphdr *) skb_push(buff, tot_len);
 	skb_reset_transport_header(buff);
