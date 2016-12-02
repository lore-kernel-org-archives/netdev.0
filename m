From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net v3] tcp: warn on bogus MSS and try to amend it
Date: Fri,  2 Dec 2016 20:51:51 -0200
Message-ID: <83a3345f2fae904fa59794d59703d86851cda7d5.1480718620.git.marcelo.leitner@gmail.com>
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
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35847 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbcLBWxm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:53:42 -0500
Received: by mail-qk0-f194.google.com with SMTP id h201so32361157qke.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:52:27 -0800 (PST)
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

v2: updated msg per David suggestion
v3: use skb_iif to find the interface and also log its name, per Eric
    Dumazet suggestion. As the skb may be backlogged and the interface
    gone by then, we need to check if the number still has a meaning.

Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/ipv4/tcp_input.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a27b9c0e27c08b4e4aeaff3d0bfdf3ae561ba4d8..042a8a895e97d04afbdc377830537e8fd3b15d1e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -144,7 +144,21 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	 */
 	len = skb_shinfo(skb)->gso_size ? : skb->len;
 	if (len >= icsk->icsk_ack.rcv_mss) {
-		icsk->icsk_ack.rcv_mss = len;
+		static bool __once __read_mostly;
+
+		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
+					       tcp_sk(sk)->advmss);
+		if (icsk->icsk_ack.rcv_mss != len && !__once) {
+			struct net_device *dev;
+
+			__once = true;
+
+			rcu_read_lock();
+			dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
+			pr_warn_once("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
+				     dev ? dev->name : "Unknown driver");
+			rcu_read_unlock();
+		}
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
-- 
2.9.3
