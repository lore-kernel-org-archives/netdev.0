From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix outstanding ref's preventing ether driver unload
Date: Tue, 23 Dec 2003 14:29:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031223142931.703d5c88.shemminger@osdl.org>
References: <OFB4EC53DF.8138874D-ON88256DF9.0082A560@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>,
        "David S. Miller"
 <davem@redhat.com>,
        "YOSHIFUJI Hideaki / _$B5HF#1QL@"
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <OFB4EC53DF.8138874D-ON88256DF9.0082A560@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch against 2.6.0 to fix the problem of being unable to load the ethernet
driver because of reference's still being held.  The problem reference's
are from IPV6 network discovery packets that get captured by the af_packet protocol
and queued onto a socket queue (which may never drain).  The route dst entries
in the skbuff get clone'd and won't be freed until the socket read.

diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Tue Dec 23 14:25:10 2003
+++ b/net/packet/af_packet.c	Tue Dec 23 14:25:10 2003
@@ -246,6 +246,10 @@
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
 		goto oom;
 
+	/* drop any routing info */
+	dst_release(skb->dst);
+	skb->dst = NULL;
+
 	spkt = (struct sockaddr_pkt*)skb->cb;
 
 	skb_push(skb, skb->data-skb->mac.raw);
@@ -486,6 +490,9 @@
 
 	skb_set_owner_r(skb, sk);
 	skb->dev = NULL;
+	dst_release(skb->dst);
+	skb->dst = NULL;
+
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_packets++;
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
