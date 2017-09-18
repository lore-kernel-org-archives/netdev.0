From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH RFC V1 net-next 5/6] net: packet: Hook into time based transmission.
Date: Mon, 18 Sep 2017 09:41:20 +0200
Message-ID: <df72b2abd0c4b3abd9b2a99ea8ba116fe5478aa7.1505719061.git.rcochran@linutronix.de>
References: <cover.1505719061.git.rcochran@linutronix.de>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For raw layer-2 packets, copy the desired future transmit time from
the CMSG cookie into the skb.

Signed-off-by: Richard Cochran <rcochran@linutronix.de>
---
 net/packet/af_packet.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c26172995511..342c6cc81a42 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1984,6 +1984,7 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 		goto out_unlock;
 	}
 
+	sockc.transmit_time = 0;
 	sockc.tsflags = sk->sk_tsflags;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(sk, msg, &sockc);
@@ -1995,6 +1996,7 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
+	skb->transmit_time = sockc.transmit_time;
 
 	sock_tx_timestamp(sk, sockc.tsflags, &skb_shinfo(skb)->tx_flags);
 
@@ -2492,6 +2494,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
+	skb->transmit_time = sockc->transmit_time;
 	sock_tx_timestamp(&po->sk, sockc->tsflags, &skb_shinfo(skb)->tx_flags);
 	skb_shinfo(skb)->destructor_arg = ph.raw;
 
@@ -2668,6 +2671,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
 
+	sockc.transmit_time = 0;
 	sockc.tsflags = po->sk.sk_tsflags;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(&po->sk, msg, &sockc);
@@ -2863,6 +2867,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_unlock;
 
+	sockc.transmit_time = 0;
 	sockc.tsflags = sk->sk_tsflags;
 	sockc.mark = sk->sk_mark;
 	if (msg->msg_controllen) {
@@ -2934,6 +2939,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sockc.mark;
+	skb->transmit_time = sockc.transmit_time;
 
 	if (po->has_vnet_hdr) {
 		err = virtio_net_hdr_to_skb(skb, &vnet_hdr, vio_le());
-- 
2.11.0
