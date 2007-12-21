From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TCP] tcp_write_timeout.c cleanup
Date: Fri, 21 Dec 2007 06:56:17 +0100
Message-ID: <476B5581.6040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020606060208010307050004"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35593 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbXLUF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 00:56:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020606060208010307050004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Before submiting a patch to change a divide to a right shift, I felt
necessary to create a helper function tcp_mtu_probing() to reduce length of 
lines exceeding 100 chars in tcp_write_timeout().

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------020606060208010307050004
Content-Type: text/plain;
 name="tcp_timer_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_timer_cleanup.patch"

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index d8970ec..8f14808 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -114,13 +114,31 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
 	return retries;
 }
 
+static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
+{
+	int mss;
+
+	/* Black hole detection */
+	if (sysctl_tcp_mtu_probing) {
+		if (!icsk->icsk_mtup.enabled) {
+			icsk->icsk_mtup.enabled = 1;
+			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
+		} else {
+			struct tcp_sock *tp = tcp_sk(sk);
+			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;
+			mss = min(sysctl_tcp_base_mss, mss);
+			mss = max(mss, 68 - tp->tcp_header_len);
+			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
+			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
+		}
+	}
+}
+
 /* A write timeout has occurred. Process the after effects. */
 static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
 	int retry_until;
-	int mss;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
@@ -129,18 +147,7 @@ static int tcp_write_timeout(struct sock *sk)
 	} else {
 		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
 			/* Black hole detection */
-			if (sysctl_tcp_mtu_probing) {
-				if (!icsk->icsk_mtup.enabled) {
-					icsk->icsk_mtup.enabled = 1;
-					tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
-				} else {
-					mss = min(sysctl_tcp_base_mss,
-						  tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2);
-					mss = max(mss, 68 - tp->tcp_header_len);
-					icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
-					tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
-				}
-			}
+			tcp_mtu_probing(icsk, sk);
 
 			dst_negative_advice(&sk->sk_dst_cache);
 		}

--------------020606060208010307050004--
