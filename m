From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] Conntrack leak with raw sockets
Date: Fri, 25 Mar 2005 12:11:27 -0800
Message-ID: <20050325201127.GA3400@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
To: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

In the event a raw socket is created for sending purposes only, the creator
never bothers to check the socket's receive queue.  But we continue to
add skbs to its queue until it fills up.

Unfortunately, if ip_conntrack is loaded on the box, each skb we add to the
queue potentially holds a reference to a conntrack.  If the user attempts
to unload ip_conntrack, we will spin around forever since the queued skbs
are pinned.

This behaviour can be witnessed in Fedora distributions which use
NetworkManager.  Arguably there should be an option to create a 'sending-only'
socket which won't suffer from this problem, but in the interim I think
the cleanest solution is to drop the conntrack reference before adding the skb
to the socket's queue.  The below patch does just that.

This fixes Netfilter bugzilla #91 and Redhat bugzilla #112630.

Phil

Signed-off-by: Phil Oester <kernel@linuxace.com>




--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-ref

diff -ru linux-orig/net/packet/af_packet.c linux-new/net/packet/af_packet.c
--- linux-orig/net/packet/af_packet.c	2005-03-25 14:48:13.597903552 -0500
+++ linux-new/net/packet/af_packet.c	2005-03-25 14:51:05.480773384 -0500
@@ -274,6 +274,10 @@
 	dst_release(skb->dst);
 	skb->dst = NULL;
 
+	/* drop conntrack reference */
+	nf_conntrack_put(skb->nfct);
+	skb->nfct = NULL;
+
 	spkt = (struct sockaddr_pkt*)skb->cb;
 
 	skb_push(skb, skb->data-skb->mac.raw);
@@ -517,6 +521,10 @@
 	dst_release(skb->dst);
 	skb->dst = NULL;
 
+	/* drop conntrack reference */
+	nf_conntrack_put(skb->nfct);
+	skb->nfct = NULL;
+
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_packets++;
 	__skb_queue_tail(&sk->sk_receive_queue, skb);

--r5Pyd7+fXNt84Ff3--
