From: Wei Wang <weiwan@google.com>
Subject: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Wed,  2 Mar 2016 11:19:21 -0800
Message-ID: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36610 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbcCBTTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:19:50 -0500
Received: by mail-pf0-f176.google.com with SMTP id 63so9602082pfe.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 11:19:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
the new mtu value is not properly updated in the dst_entry associated
with the socket.
This leads to the issue that the mtu value returned by getsockopt(sockfd,
IPPROTO_IPV6, IPV6_MTU, ...) is wrong.
The fix is to call the corresponding pmtu related function for connected
socket so that the dst_entry associated with the socket will get updated
with the new mtu value.
And before we call the above function to update mtu, we check to make
sure the source IP address, destination IP address, source port and
destination port are matching between the incoming flow and the socket.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 net/ipv6/udp.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0711f8f..5e6ba54 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -49,6 +49,7 @@
 #include <net/inet6_hashtables.h>
 #include <net/busy_poll.h>
 #include <net/sock_reuseport.h>
+#include <net/inet6_connection_sock.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -566,7 +567,16 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == ICMPV6_PKT_TOOBIG) {
 		if (!ip6_sk_accept_pmtu(sk))
 			goto out;
-		ip6_sk_update_pmtu(skb, sk, info);
+		bh_lock_sock(sk);
+		if (sk->sk_state == TCP_ESTABLISHED &&
+		    !sock_owned_by_user(sk) &&
+		    ipv6_addr_equal(saddr, &sk->sk_v6_rcv_saddr) &&
+		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr) &&
+		    uh->dest == sk->sk_dport)
+			inet6_csk_update_pmtu(sk, ntohl(info));
+		else
+			ip6_sk_update_pmtu(skb, sk, info);
+		bh_unlock_sock(sk);
 		if (np->pmtudisc != IPV6_PMTUDISC_DONT)
 			harderr = 1;
 	}
-- 
2.7.0.rc3.207.g0ac5344
