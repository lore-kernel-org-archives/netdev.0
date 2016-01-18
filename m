From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH] af_packet: Raw socket destruction warning fix
Date: Mon, 18 Jan 2016 12:07:48 +0530
Message-ID: <1453099068-39022-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, gh007.kim@samsung.com,
	hakbong5.lee@samsung.com, Maninder Singh <maninder1.s@samsung.com>,
	Vaneet Narang <v.narang@samsung.com>
To: davem@davemloft.net, willemb@google.com, daniel@iogearbox.net,
	edumazet@google.com, eyal.birger@gmail.com, tklauser@distanz.ch,
	fruggeri@aristanetworks.com, dwmw2@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Receieve queue is not purged when socket dectruction is called
results in kernel warning because of non zero sk_rmem_alloc.

WARNING: at net/packet/af_packet.c:1142 packet_sock_destruct

Backtrace:
WARN_ON(atomic_read(&sk->sk_rmem_alloc)
packet_sock_destruct
__sk_free
sock_wfree
skb_release_head_state
skb_release_all
__kfree_skb
net_tx_action
__do_softirq
run_ksoftirqd

Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
 net/packet/af_packet.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 81b4b81..bcb37ba 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1310,6 +1310,7 @@ static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 
 static void packet_sock_destruct(struct sock *sk)
 {
+	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_error_queue);
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-- 
1.7.9.5
