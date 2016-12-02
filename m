From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net v2] tcp: warn on bogus MSS and try to amend it
Date: Fri,  2 Dec 2016 08:55:37 -0200
Message-ID: <ef61092947105261f8321a67f726a7fdf9b3c14e.1480675556.git.marcelo.leitner@gmail.com>
Cc: Jon Maxwell <jmaxwell37@gmail.com>,
        Alex Sidorenko <alexandre.sidorenko@hpe.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, tlfalcon@linux.vnet.ibm.com,
        Brian King <brking@linux.vnet.ibm.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        marcelo.leitner@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36441 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753678AbcLBK4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:56:24 -0500
Received: by mail-qt0-f194.google.com with SMTP id n34so26981535qtb.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 02:56:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There have been some reports lately about TCP connection stalls caused
by NIC drivers that aren't setting gso_size on aggregated packets on rx
path. This causes TCP to assume that the MSS is actually the size of the
aggregated packet, which is invalid.

Although the proper fix is to be done at each driver, it's often hard
and cumbersome for one to debug, come to such root cause and report/fix
it.

This patch amends this situation in two ways. First, it adds a warning
on when this situation occurs, so it gives a hint to those trying to
debug this. It also limit the maximum probed MSS to the adverised MSS,
as it should never be any higher than that.

The result is that the connection may not have the best performance ever
but it shouldn't stall, and the admin will have a hint on what to look
for.

Tested with virtio by forcing gso_size to 0.

Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
v2: Updated msg as suggested by David.

 net/ipv4/tcp_input.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a27b9c0e27c08b4e4aeaff3d0bfdf3ae561ba4d8..fd619eb93749b6de56a41669248b337c051d9fe2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -144,7 +144,10 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	 */
 	len = skb_shinfo(skb)->gso_size ? : skb->len;
 	if (len >= icsk->icsk_ack.rcv_mss) {
-		icsk->icsk_ack.rcv_mss = len;
+		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
+					       tcp_sk(sk)->advmss);
+		if (icsk->icsk_ack.rcv_mss != len)
+			pr_warn_once("Driver has suspect GRO implementation, TCP performance may be compromised.\n");
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
-- 
2.9.3
