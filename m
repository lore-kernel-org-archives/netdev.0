From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: Fix fragmentation issues with bridge netfilter
Date: Mon, 03 Apr 2006 15:43:13 +0200
Message-ID: <44312671.3090904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030705040105090900090502"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
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
--------------030705040105090900090502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix a regression from the netfilter/IPsec patches with bridging.
Bart, please review this patch, if everything is fine I think it
should also go in -stable.


--------------030705040105090900090502
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix fragmentation issues with bridge netfilter

The conntrack code doesn't do re-fragmentation of defragmented packets
anymore but relies on fragmentation in the IP layer. Purely bridged
packets don't pass through the IP layer, so the bridge netfilter code
needs to take care of fragmentation itself.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5d7b9a2f312fa867fa99adc5fd9cfb6d841f6fb6
tree 6a63c9cfe9804aa9d8050a14f8c6aed6ba1fbf84
parent 683aa4012f53b2ada0f430487e05d37b0d94e90a
author Patrick McHardy <kaber@trash.net> Mon, 03 Apr 2006 11:58:33 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 03 Apr 2006 11:58:33 +0200

 include/net/ip.h          |    1 +
 net/bridge/br_netfilter.c |   13 +++++++++++--
 net/ipv4/ip_output.c      |    6 +++---
 3 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 8fe6156..3d2e5ca 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -95,6 +95,7 @@ extern int		ip_local_deliver(struct sk_b
 extern int		ip_mr_input(struct sk_buff *skb);
 extern int		ip_output(struct sk_buff *skb);
 extern int		ip_mc_output(struct sk_buff *skb);
+extern int		ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f29450b..3da9264 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -765,6 +765,15 @@ out:
 	return NF_STOLEN;
 }
 
+static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP) &&
+	    skb->len > skb->dev->mtu &&
+	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
+		return ip_fragment(skb, br_dev_queue_push_xmit);
+	else
+		return br_dev_queue_push_xmit(skb);
+}
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
 static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff **pskb,
@@ -824,7 +833,7 @@ static unsigned int br_nf_post_routing(u
 		realoutdev = nf_bridge->netoutdev;
 #endif
 	NF_HOOK(pf, NF_IP_POST_ROUTING, skb, NULL, realoutdev,
-		br_dev_queue_push_xmit);
+		br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
 
@@ -869,7 +878,7 @@ static unsigned int ip_sabotage_out(unsi
 
 	if ((out->hard_start_xmit == br_dev_xmit &&
 	     okfn != br_nf_forward_finish &&
-	     okfn != br_nf_local_out_finish && okfn != br_dev_queue_push_xmit)
+	     okfn != br_nf_local_out_finish && okfn != br_nf_dev_queue_xmit)
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	    || ((out->priv_flags & IFF_802_1Q_VLAN) &&
 		VLAN_DEV_INFO(out)->real_dev->hard_start_xmit == br_dev_xmit)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f75ff1d..8dcba38 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -86,8 +86,6 @@
 
 int sysctl_ip_default_ttl = IPDEFTTL;
 
-static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*));
-
 /* Generate a checksum for an outgoing IP datagram. */
 __inline__ void ip_send_check(struct iphdr *iph)
 {
@@ -421,7 +419,7 @@ static void ip_copy_metadata(struct sk_b
  *	single device frame, and queue such a frame for sending.
  */
 
-static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 {
 	struct iphdr *iph;
 	int raw = 0;
@@ -673,6 +671,8 @@ fail:
 	return err;
 }
 
+EXPORT_SYMBOL(ip_fragment);
+
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
 {

--------------030705040105090900090502--
