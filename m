From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Subject: [PATCH] tcp: reinitialize MTU probing when setting MSS in a TCP
 repair
Date: Fri, 26 May 2017 14:28:00 -0300
Message-ID: <c5033bad-805d-c3f6-3de4-38ab5d3d84e8@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Pavel Emelyanov <xemul@parallels.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp862.redehostenvio.com.br ([187.84.239.76]:45084 "EHLO
        smtp862.redehostenvio.com.br" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756623AbdEZR23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 13:28:29 -0400
Received: by smtp837.redehostenvio.com.br id h51j4e29co8r for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:30:42 -0300 (envelope-from <douglascs@taghos.com.br>)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Caetano dos Santos <douglascs@taghos.com.br>

MTU probing initialization occurred only at connect() and at SYN or
SYN-ACK reception, but the former sets MSS to either the default or the
user set value (through TCP_MAXSEG sockopt) and the latter never happens
with repaired sockets.

The result was that, with MTU probing enabled and unless TCP_MAXSEG
sockopt was used before connect(), probing would be stuck at
tcp_base_mss value until tcp_probe_interval seconds have passed.

Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>
---
I'm not sure if there are any side effects doing this, so comments are welcome
as always.

Also, I changed the function's argument from struct tcp_sock to struct sock
because I couldn't find any inverse of tcp_sk() funciton and thought that using
"&tp->inet_conn.icsk_inet.sk" or "(struct sock *)tp" would be worse.

 net/ipv4/tcp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 842b575f8fdd..d782637e595e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2378,9 +2378,10 @@ static int tcp_repair_set_window(struct tcp_sock *tp, char __user *optbuf, int l
 	return 0;
 }
 
-static int tcp_repair_options_est(struct tcp_sock *tp,
+static int tcp_repair_options_est(struct sock *sk,
 		struct tcp_repair_opt __user *optbuf, unsigned int len)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_repair_opt opt;
 
 	while (len >= sizeof(opt)) {
@@ -2393,6 +2394,7 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 		switch (opt.opt_code) {
 		case TCPOPT_MSS:
 			tp->rx_opt.mss_clamp = opt.opt_val;
+			tcp_mtup_init(sk);
 			break;
 		case TCPOPT_WINDOW:
 			{
@@ -2552,7 +2554,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		if (!tp->repair)
 			err = -EINVAL;
 		else if (sk->sk_state == TCP_ESTABLISHED)
-			err = tcp_repair_options_est(tp,
+			err = tcp_repair_options_est(sk,
 					(struct tcp_repair_opt __user *)optval,
 					optlen);
 		else
-- 
2.12.2
