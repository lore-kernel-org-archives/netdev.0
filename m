From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: PATCH: uninitialized memory access in tcp_parse_options
Date: Mon, 21 Jun 2010 15:34:09 +0200
Message-ID: <1277127249.9469.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-woEUGfWk49wmJMHdz7Ig"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:5229 "EHLO
	mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932275Ab0FUNn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 09:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-woEUGfWk49wmJMHdz7Ig
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

valgrind reports the following error:

==15996== Conditional jump or move depends on uninitialised value(s)
==15996==    at 0x6E63E4C: tcp_parse_options (tcp_input.c:3776)
==15996==    by 0x6E856A3: tcp_check_req (tcp_minisocks.c:532)
==15996==    by 0x6E7F0C6: tcp_v4_hnd_req (tcp_ipv4.c:1492)
==15996==    by 0x6E7F55A: tcp_v4_do_rcv (tcp_ipv4.c:1571)
==15996==    by 0x6E808C5: tcp_v4_rcv (tcp_ipv4.c:1690)
==15996==    by 0x6E2DA7B: ip_local_deliver_finish (ip_input.c:231)
==15996==    by 0x6E2DE0C: ip_local_deliver (netfilter.h:206)
==15996==    by 0x6E2E940: ip_rcv_finish (dst.h:255)
==15996==    by 0x6E2F17C: ip_rcv (netfilter.h:206)
==15996==    by 0x6D53D0E: __netif_receive_skb (dev.c:2873)
==15996==    by 0x6D5521F: process_backlog (dev.c:3305)
==15996==    by 0x6D55A20: net_rx_action (dev.c:3435)

The attached patch (generated against net-next-2.6) fixes that error by
making sure that user_mss is correctly initialized at the start of
tcp_parse_options, just like saw_tstamp is initialized at the start of
this function. To try to be coherent, this patch also removes the
redundant initialization of saw_tstamp from the caller, tcp_check_req.

hope this helps,
Mathieu
-- 
Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Tel: +33 4 9238 5056

--=-woEUGfWk49wmJMHdz7Ig
Content-Disposition: attachment; filename="tcp-options.patch"
Content-Type: text/x-patch; name="tcp-options.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ae3ec15..8b713ab 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3751,6 +3751,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
+	opt_rx->user_mss = 0;
 
 	while (length > 0) {
 		int opcode = *ptr++;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 794c2e1..21e47e7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -527,7 +527,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
 
-	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
 		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 

--=-woEUGfWk49wmJMHdz7Ig--

