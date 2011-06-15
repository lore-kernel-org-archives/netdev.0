From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: rfs: enable RFS before first data packet
 is received
Date: Wed, 15 Jun 2011 04:15:28 +0200
Message-ID: <1308104128.4578.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	jamal <hadi@cyberus.ca>
To: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53204 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398Ab1FOCPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 22:15:41 -0400
Received: by wwa36 with SMTP id 36so6459528wwa.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 19:15:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First packet received on a passive tcp flow is not correctly RFS
steered.

One sock_rps_record_flow() call is missing in inet_accept()

But before that, we also must record rxhash when child socket is setup.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
---
Netconf2011 workshop ;)

 net/ipv4/af_inet.c  |    1 +
 net/ipv4/tcp_ipv4.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 83673d2..0600f0f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -676,6 +676,7 @@ int inet_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	lock_sock(sk2);
 
+	sock_rps_record_flow(sk2);
 	WARN_ON(!((1 << sk2->sk_state) &
 		  (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)));
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 617dee3..955b8e6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1594,6 +1594,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 			goto discard;
 
 		if (nsk != sk) {
+			sock_rps_save_rxhash(nsk, skb->rxhash);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;


