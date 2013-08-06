From: Dong Fang <yp.fangdong@gmail.com>
Subject: [PATCH] net/ipv4: fix the conditions of entering TCP_CA_Disorder state
Date: Mon,  5 Aug 2013 20:45:51 -0400
Message-ID: <1375749951-11230-1-git-send-email-yp.fangdong@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dong Fang <yp.fangdong@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if have some packets loss by network, the kernel can't reach here, we can see
the tcp_time_to_recover() function:

static bool tcp_time_to_recover(struct sock *sk, int flag)
{
	struct tcp_sock *tp = tcp_sk(sk);
	__u32 packets_out;

	/* Trick#1: The loss is proven. */
	if (tp->lost_out)
		return true;
	//...
}

when it return true, the following condition will be failed:

//...
if (!tcp_time_to_recover(sk, flag)) {
	tcp_try_to_open(sk, flag, prior_unsacked);
	return;
}
//...


Signed-off-by: Dong Fang <yp.fangdong@gmail.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28af45a..8ab31c1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2449,7 +2449,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int state = TCP_CA_Open;
 
-	if (tcp_left_out(tp) || tcp_any_retrans_done(sk))
+	if (tp->sacked_out || tcp_any_retrans_done(sk))
 		state = TCP_CA_Disorder;
 
 	if (inet_csk(sk)->icsk_ca_state != state) {
-- 
1.7.1
