From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: Fix skb->nf_bridge lifetime issues
Date: Mon, 20 Feb 2006 08:44:02 +0100
Message-ID: <43F97342.9050806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000702070701030904050306"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
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

This is a multi-part message in MIME format.
--------------000702070701030904050306
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Bart, can you please have a look at this patch and ACK/NACK it?
We have a bugreport in the netfilter bugzilla of broken conntrack
with tunnels on top of bridge devices (#448), which should be cured
by this patch.

There is also another report of broken conntrack with vlan on top
of bridge devices (#400) that looks related, but probably this
patch won't help.

--------------000702070701030904050306
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix skb->nf_bridge lifetime issues

The bridge netfilter code simulates the NF_IP_PRE_ROUTING hook and skips
the real hook by registering with high priority and returning NF_STOP if
skb->nf_bridge is present and the BRNF_NF_BRIDGE_PREROUTING flag is not
set. The flag is only set during the simulated hook.

Because skb->nf_bridge is only freed when the packet is destroyed, the
packet will not only skip the first invocation of NF_IP_PRE_ROUTING, but
in the case of tunnel devices on top of the bridge also all further ones.
Forwarded packets from a bridge encapsulated by a tunnel device and sent
as locally outgoing packet will also still have the incorrect bridge
information from the input path attached.

We already have nf_reset calls on all RX/TX paths of tunnel devices,
so simply reset the nf_bridge field there too. As an added bonus,
the bridge information for locally delivered packets is now also freed
when the packet is queued to a socket.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 22e4dcb796d276db47a61c2382bdf2eaf76db32e
tree ccc5173acbe70506aa60e826e1881a4513f8c868
parent 337ba256a7e68f174a88ffba805b40622297fc22
author Patrick McHardy <kaber@trash.net> Mon, 20 Feb 2006 08:41:48 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Feb 2006 08:41:48 +0100

 include/linux/skbuff.h          |   24 ++++++++++++++----------
 net/ipv4/netfilter/ipt_REJECT.c |    4 ----
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 838ce0f..65bf1fa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1351,16 +1351,6 @@ static inline void nf_conntrack_put_reas
 		kfree_skb(skb);
 }
 #endif
-static inline void nf_reset(struct sk_buff *skb)
-{
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	nf_conntrack_put_reasm(skb->nfct_reasm);
-	skb->nfct_reasm = NULL;
-#endif
-}
-
 #ifdef CONFIG_BRIDGE_NETFILTER
 static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
 {
@@ -1373,6 +1363,20 @@ static inline void nf_bridge_get(struct 
 		atomic_inc(&nf_bridge->use);
 }
 #endif /* CONFIG_BRIDGE_NETFILTER */
+static inline void nf_reset(struct sk_buff *skb)
+{
+	nf_conntrack_put(skb->nfct);
+	skb->nfct = NULL;
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	nf_conntrack_put_reasm(skb->nfct_reasm);
+	skb->nfct_reasm = NULL;
+#endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_put(skb->nfct);
+	skb->nfct = NULL;
+#endif
+}
+
 #else /* CONFIG_NETFILTER */
 static inline void nf_reset(struct sk_buff *skb) {}
 #endif /* CONFIG_NETFILTER */
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 26ea6c1..9d3b357 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -154,10 +154,6 @@ static void send_reset(struct sk_buff *o
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
 	nskb->nfmark = 0;
-#ifdef CONFIG_BRIDGE_NETFILTER
-	nf_bridge_put(nskb->nf_bridge);
-	nskb->nf_bridge = NULL;
-#endif
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 

--------------000702070701030904050306--
