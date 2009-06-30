From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Tue, 30 Jun 2009 22:08:35 +0800
Message-ID: <20090630140835.GA20811@gondor.apana.org.au>
References: <20090622090731.GA22496@gondor.apana.org.au> <20090630070036.GA16225@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christophe Saout <christophe@saout.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51465 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751203AbZF3OIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 10:08:39 -0400
Content-Disposition: inline
In-Reply-To: <20090630070036.GA16225@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 03:00:36PM +0800, Herbert Xu wrote:
> 
> Now as to the technical problem of how to recompute the checksums
> cleanly, may I draw your attention to gso_send_checksum which does
> exactly what you want.

Something like this untested patch.  Note that I still think this
is totally wrong (see the patch description for an explanation).
Perhaps a better way to do this is to write a netfilter module to
fix up checksums on egress.  That way it would be even more explicit
that you should do the checksum verification on the opposite end
as well.

The real solution is to get natoa, or even better, ditch transport
mode if you're doing NAT.

ipsec: Optionally recompute transport mode NAT checksum

We never bothered adjusting transport mode NAT checksums because
as long as the packet originated on the IPsec peer and terminated
on our host, it doesn't really matter much.

However, once you put inner NAT into the equation, the checksum
must be updated for it to work at all.

This patch does this by inanely recomputing the checksum.  Note
that this is almost always wrong! It can only be right if the
traffic originated on the IPsec peer, and terminated beyond our
host.  If it went the other way, that is, it originated beyond
our IPsec peer and termianted on us, then the checksum will not
be verified for the path between the source and the IPsec peer.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 2d4ec15..52c96a6 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -344,6 +344,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_NATZAPCSUM	64
 };
 
 struct xfrm_usersa_id {
diff --git a/include/net/ip.h b/include/net/ip.h
index 4ac7577..146dcc7 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -405,4 +405,6 @@ int ipv4_doint_and_flush_strategy(ctl_table *table,
 extern int ip_misc_proc_init(void);
 #endif
 
+extern int __inet_gso_send_check(struct sk_buff *skb, int proto);
+
 #endif	/* _IP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f03373..ea31cfb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1149,7 +1149,6 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 static int inet_gso_send_check(struct sk_buff *skb)
 {
 	struct iphdr *iph;
-	struct net_protocol *ops;
 	int proto;
 	int ihl;
 	int err = -EINVAL;
@@ -1166,10 +1165,21 @@ static int inet_gso_send_check(struct sk_buff *skb)
 		goto out;
 
 	__skb_pull(skb, ihl);
-	skb_reset_transport_header(skb);
 	iph = ip_hdr(skb);
 	proto = iph->protocol & (MAX_INET_PROTOS - 1);
-	err = -EPROTONOSUPPORT;
+
+	return __inet_gso_send_check(skb, proto);
+
+out:
+	return err;
+}
+
+int __inet_gso_send_check(struct sk_buff *skb, int proto)
+{
+	struct net_protocol *ops;
+	int err = -EPROTONOSUPPORT;
+
+	skb_reset_transport_header(skb);
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_protos[proto]);
@@ -1177,9 +1187,9 @@ static int inet_gso_send_check(struct sk_buff *skb)
 		err = ops->gso_send_check(skb);
 	rcu_read_unlock();
 
-out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(__inet_gso_send_check);
 
 static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 {
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 18bb383..11f1a34 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -227,6 +227,31 @@ error:
 	return err;
 }
 
+static void esp_fix_csum(struct sk_buff *skb, int proto)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+
+	/*
+	 * Ignore UDP/TCP checksums in case
+	 * of NAT-T in Transport Mode, or
+	 * perform other post-processing fixes
+	 * as per draft-ietf-ipsec-udp-encaps-06,
+	 * section 3.1.2
+	 */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (!(x->props.flags & XFRM_STATE_NATZAPCSUM))
+		return;
+
+	/*
+	 * Aiee! This transport-mode packet may need to be forwarded.
+	 * Prepare the checksum for forwarding.  If it fails we'll
+	 * keep quiet about it since we only support this for very
+	 * few protocols.
+	 */
+	__inet_gso_send_check(skb, proto);
+}
+
 static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	struct iphdr *iph;
@@ -253,6 +278,9 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	if (padlen + 2 + alen >= elen)
 		goto out;
 
+	pskb_trim(skb, skb->len - (padlen + 2 + alen));
+	__skb_pull(skb, hlen);
+
 	/* ... check padding bits here. Silly. :-) */
 
 	iph = ip_hdr(skb);
@@ -284,19 +312,10 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 			 */
 		}
 
-		/*
-		 * 2) ignore UDP/TCP checksums in case
-		 *    of NAT-T in Transport Mode, or
-		 *    perform other post-processing fixes
-		 *    as per draft-ietf-ipsec-udp-encaps-06,
-		 *    section 3.1.2
-		 */
 		if (x->props.mode == XFRM_MODE_TRANSPORT)
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			esp_fix_csum(skb, nexthdr[1]);
 	}
 
-	pskb_trim(skb, skb->len - alen - padlen - 2);
-	__skb_pull(skb, hlen);
 	skb_set_transport_header(skb, -ihl);
 
 	err = nexthdr[1];

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
