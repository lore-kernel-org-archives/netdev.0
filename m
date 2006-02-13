From: Patrick McHardy <kaber@trash.net>
Subject: [RFC,NETFILTER]: Fix xfrm lookup after SNAT
Date: Mon, 13 Feb 2006 18:25:01 +0100
Message-ID: <43F0C0ED.8000303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010609080701070402030304"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
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
--------------010609080701070402030304
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

I finally got around to fixing the "ip_finish_output2: No header cache
and no neighbour!" problem reported by Andi Kleen. Instead of rerouting
the packet in POST_ROUTING, we reuse the original route for the
xfrm_lookup. This introduces a small restriction (see changelog entry),
but I think it should work.

Herbert, do you see any problems with this patch?

--------------010609080701070402030304
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix xfrm lookup after SNAT

To find out if a packet needs to be handled by IPsec after SNAT, packets
are currently rerouted in POST_ROUTING and a new xfrm lookup is done. This
breaks SNAT of non-unicast packets to non-local addresses because the
packet is routed as incoming packet and no neighbour entry is bound to the
dst_entry. In general, it seems to be a bad idea to replace the dst_entry
after the packet was already sent to the output routine because its state
might not match what's expected.

This patch changes the xfrm lookup in POST_ROUTING to re-use the original
dst_entry without routing the packet again. This means no policy routing
can be used for transport mode transforms (which keep the original route)
when packets are SNATed to match the policy, but it looks like the best
we can do for now.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0ebf0a6fc360cf177712ed0f21f160e0ffea9f99
tree 5bef78d70573091e5055bf4e236d7d8a443d20df
parent b6d521bde1a8bcf7e3fcad139319a427c18d8012
author Patrick McHardy <kaber@trash.net> Mon, 13 Feb 2006 18:20:04 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 13 Feb 2006 18:20:04 +0100

 include/linux/netfilter_ipv4.h         |    2 +-
 net/ipv4/netfilter.c                   |   41 ++++++++++++++++++++++++++++++++
 net/ipv4/netfilter/ip_nat_standalone.c |    6 ++---
 3 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index fdc4a95..43c09d7 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -79,7 +79,7 @@ enum nf_ip_hook_priorities {
 
 #ifdef __KERNEL__
 extern int ip_route_me_harder(struct sk_buff **pskb);
-
+extern int ip_xfrm_me_harder(struct sk_buff **pskb);
 #endif /*__KERNEL__*/
 
 #endif /*__LINUX_IP_NETFILTER_H*/
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 52a3d7c..ed42cdc 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -78,6 +78,47 @@ int ip_route_me_harder(struct sk_buff **
 }
 EXPORT_SYMBOL(ip_route_me_harder);
 
+#ifdef CONFIG_XFRM
+int ip_xfrm_me_harder(struct sk_buff **pskb)
+{
+	struct flowi fl;
+	unsigned int hh_len;
+	struct dst_entry *dst;
+
+	if (IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)
+		return 0;
+	if (xfrm_decode_session(*pskb, &fl, AF_INET) < 0)
+		return -1;
+
+	dst = (*pskb)->dst;
+	if (dst->xfrm)
+		dst = ((struct xfrm_dst *)dst)->route;
+	dst_hold(dst);
+
+	if (xfrm_lookup(&dst, &fl, (*pskb)->sk, 0) < 0)
+		return -1;
+
+	dst_release((*pskb)->dst);
+	(*pskb)->dst = dst;
+
+	/* Change in oif may mean change in hh_len. */
+	hh_len = (*pskb)->dst->dev->hard_header_len;
+	if (skb_headroom(*pskb) < hh_len) {
+		struct sk_buff *nskb;
+
+		nskb = skb_realloc_headroom(*pskb, hh_len);
+		if (!nskb)
+			return -1;
+		if ((*pskb)->sk)
+			skb_set_owner_w(nskb, (*pskb)->sk);
+		kfree_skb(*pskb);
+		*pskb = nskb;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(ip_xfrm_me_harder);
+#endif
+
 void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
 EXPORT_SYMBOL(ip_nat_decode_session);
 
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index 92c5499..7c3f7d3 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -235,19 +235,19 @@ ip_nat_out(unsigned int hooknum,
 		return NF_ACCEPT;
 
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+#ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN
 	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.src.ip !=
 		    ct->tuplehash[!dir].tuple.dst.ip
-#ifdef CONFIG_XFRM
 		    || ct->tuplehash[dir].tuple.src.u.all !=
 		       ct->tuplehash[!dir].tuple.dst.u.all
-#endif
 		    )
-			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+			return ip_xfrm_me_harder(pskb) == 0 ? ret : NF_DROP;
 	}
+#endif
 	return ret;
 }
 

--------------010609080701070402030304--
