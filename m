From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: don't include Fast Open option in SYN-ACK on pure SYN-data
Date: Mon,  9 Feb 2015 12:35:23 -0800
Message-ID: <1423514123-6825-1-git-send-email-ycheng@google.com>
Cc: edumazet@google.com, ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:38773 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759672AbbBIUfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 15:35:43 -0500
Received: by pdbft15 with SMTP id ft15so33688619pdb.5
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 12:35:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a server has enabled Fast Open and it receives a pure SYN-data
packet (without a Fast Open option), it won't accept the data but it
incorrectly returns a SYN-ACK with a Fast Open cookie and also
increments the SNMP stat LINUX_MIB_TCPFASTOPENPASSIVEFAIL.

This patch makes the server include a Fast Open cookie in SYN-ACK
only if the SYN has some Fast Open option (i.e., when client
requests or presents a cookie).

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_fastopen.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 815c85e..53db2c3 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -255,6 +255,9 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
 
+	if (foc->len == 0) /* Client requests a cookie */
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENCOOKIEREQD);
+
 	if (!((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
 	      (syn_data || foc->len >= 0) &&
 	      tcp_fastopen_queue_check(sk))) {
@@ -265,7 +268,8 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	if (syn_data && (sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
 		goto fastopen;
 
-	if (tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
+	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
+	    tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
 	    foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
@@ -284,11 +288,10 @@ fastopen:
 					 LINUX_MIB_TCPFASTOPENPASSIVE);
 			return true;
 		}
-	}
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
+	} else if (foc->len > 0) /* Client presents an invalid cookie */
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
 
-	NET_INC_STATS_BH(sock_net(sk), foc->len ?
-			 LINUX_MIB_TCPFASTOPENPASSIVEFAIL :
-			 LINUX_MIB_TCPFASTOPENCOOKIEREQD);
 	*foc = valid_foc;
 	return false;
 }
-- 
2.2.0.rc0.207.ga3a616c
