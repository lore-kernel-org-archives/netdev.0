From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-2.6 resent] af_packet: Don't use skb after
 dev_queue_xmit()
Date: Sat, 9 Jan 2010 13:38:27 +0100
Message-ID: <20100109123827.GB4386@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754078Ab0AIMig@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
which is illegal.

With debugging by: Stephen Hemminger <shemminger@vyatta.com>

Reported-by: Michael Breuer <mbreuer@majjas.com>
Tested-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---

 net/packet/af_packet.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e0516a2..aba2049 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1021,9 +1021,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 		status = TP_STATUS_SEND_REQUEST;
 		err = dev_queue_xmit(skb);
-		if (unlikely(err > 0 && (err = net_xmit_errno(err)) != 0))
-			goto out_xmit;
 		packet_increment_head(&po->tx_ring);
+		if (unlikely(err > 0 && (err = net_xmit_errno(err)) != 0))
+			goto out_put;
+
 		len_sum += tp_len;
 	} while (likely((ph != NULL) ||
 			((!(msg->msg_flags & MSG_DONTWAIT)) &&
@@ -1033,9 +1034,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	err = len_sum;
 	goto out_put;
 
-out_xmit:
-	skb->destructor = sock_wfree;
-	atomic_dec(&po->tx_ring.pending);
 out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
