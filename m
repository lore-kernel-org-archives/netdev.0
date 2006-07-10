From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NETROM] adsf
Date: Tue, 11 Jul 2006 00:14:46 +0100
Message-ID: <20060710231446.GA8579@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When establishing a new circuit in nr_rx_frame the locks are taken in a
different order than in the rest of the stack.  This should be harmless
but triggers lockdep.  Either way, reordering the code a little solves
the issue.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ecc7968..672d5f8 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -986,18 +986,18 @@ int nr_rx_frame(struct sk_buff *skb, str
 	nr_make->vl        = 0;
 	nr_make->state     = NR_STATE_3;
 	sk_acceptq_added(sk);
-
-	nr_insert_socket(make);
-
 	skb_queue_head(&sk->sk_receive_queue, skb);
 
-	nr_start_heartbeat(make);
-	nr_start_idletimer(make);
-
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb->len);
 
 	bh_unlock_sock(sk);
+
+	nr_insert_socket(make);
+
+	nr_start_heartbeat(make);
+	nr_start_idletimer(make);
+
 	return 1;
 }
 
