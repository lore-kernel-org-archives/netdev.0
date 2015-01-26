From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO segmentation if
	not set.
Date: Mon, 26 Jan 2015 09:37:04 -0500
Message-ID: <1422283026-27832-2-git-send-email-vyasevic@redhat.com>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, mst@redhat.com, ben@decadent.org.uk,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

If the IPv6 fragment id has not been set and we perform
fragmentation due to UFO, select a new fragment id.
When we store the fragment id into skb_shinfo, set the bit
in the skb so we can re-use the selected id.
This preserves the behavior of UFO packets generated on the
host and solves the issue of id generation for packet sockets
and tap/macvtap devices.

This patch moves ipv6_select_ident() back in to the header file.  
It also provides the helper function that sets skb_shinfo() frag
id and sets the bit.

It also makes sure that we select the fragment id when doing
just gso validation, since it's possible for the packet to
come from an untrusted source (VM) and be forwarded through
a UFO enabled device which will expect the fragment id.

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/skbuff.h |  3 ++-
 include/net/ipv6.h     |  2 ++
 net/ipv6/ip6_output.c  |  4 ++--
 net/ipv6/output_core.c |  9 ++++++++-
 net/ipv6/udp_offload.c | 10 +++++++++-
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..3ad5203 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -605,7 +605,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+	__u8			ufo_fragid_set:1;
+	/* 2 or 4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4292929..ca6137b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,7 +671,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
+void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 void ipv6_proxy_select_ident(struct sk_buff *skb);
+void ipv6_skb_set_fragid(struct sk_buff *skb, __be32 frag_id);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ce69a12..b940b3f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -537,7 +537,7 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
+void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
 	u32 hash, id;
@@ -1092,7 +1092,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 				     sizeof(struct frag_hdr)) & ~7;
 	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	ipv6_select_ident(&fhdr, rt);
-	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
+	ipv6_skb_set_fragid(skb, fhdr.identification);
 
 append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 97f41a3..68f879b 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -38,10 +38,17 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
 	hash = __ipv6_addr_jhash(&addrs[0], hash);
 
 	id = ip_idents_reserve(hash, 1);
-	skb_shinfo(skb)->ip6_frag_id = htonl(id);
+	ipv6_skb_set_fragid(skb, htonl(id));
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
+void ipv6_skb_set_fragid(struct sk_buff *skb, __be32 frag_id)
+{
+	skb_shinfo(skb)->ip6_frag_id = frag_id;
+	skb->ufo_fragid_set = 1;
+}
+EXPORT_SYMBOL_GPL(ipv6_skb_set_fragid);
+
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 {
 	u16 offset = sizeof(struct ipv6hdr);
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index b6aa8ed..7cda88d 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -52,6 +52,10 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 
 		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
 
+		/* Set the IPv6 fragment id if not set yet */
+		if (!skb->ufo_fragid_set)
+			ipv6_proxy_select_ident(skb);
+
 		segs = NULL;
 		goto out;
 	}
@@ -108,7 +112,11 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
 		fptr->nexthdr = nexthdr;
 		fptr->reserved = 0;
-		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
+		if (!skb->ufo_fragid_set)
+			fptr->identification = skb_shinfo(skb)->ip6_frag_id;
+		else
+			ipv6_select_ident(fptr,
+					  (struct rt6_info *)skb_dst(skb));
 
 		/* Fragment the skb. ipv6 header and the remaining fields of the
 		 * fragment header are updated in ipv6_gso_segment()
-- 
1.9.3
