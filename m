From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] tcp: avoid bogus warning in tcp_clean_rtx_queue
Date: Mon, 18 Sep 2017 22:48:47 +0200
Message-ID: <20170918204855.170920-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-4.9 warns that it cannot trace the state of the 'last_ackt'
variable since the change to the TCP timestamping code, when
CONFIG_PROFILE_ANNOTATED_BRANCHES is set:

net/ipv4/tcp_input.c: In function 'tcp_clean_rtx_queue':
include/net/tcp.h:757:23: error: 'last_ackt' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Other gcc versions, both older and newer do now show this
warning. Removing the 'likely' annotation makes it go away,
and has no effect on the object code without
CONFIG_PROFILE_ANNOTATED_BRANCHES, as tested with gcc-4.9
and gcc-7.1.1, so this seems to be a safe workaround.

Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5d7656beeee..c52bc8e35d4d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3173,7 +3173,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
-	if (likely(first_ackt) && !(flag & FLAG_RETRANS_DATA_ACKED)) {
+	if (first_ackt && !(flag & FLAG_RETRANS_DATA_ACKED)) {
 		seq_rtt_us = tcp_stamp_us_delta(tp->tcp_mstamp, first_ackt);
 		ca_rtt_us = tcp_stamp_us_delta(tp->tcp_mstamp, last_ackt);
 	}
-- 
2.9.0
