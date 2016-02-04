From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 08/13] esp4: Add a software GSO codepath.
Date: Thu, 4 Feb 2016 07:37:01 +0100
Message-ID: <1454567826-13018-9-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36666 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754374AbcBDHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:48 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an esp4_gso_segment() callback and registers
functions for the new ESP encapsulation and crypto callbacks.

The work to get transport mode ready was done by
Sowmini Varadhan <sowmini.varadhan@oracle.com>

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/skbuff.h  |  3 +-
 net/ipv4/af_inet.c      |  1 +
 net/ipv4/esp4.c         | 92 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/esp4_offload.c | 85 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_offload.c  |  1 +
 5 files changed, 178 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4652f2c..dcc6c85 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -724,7 +724,8 @@ struct sk_buff {
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
 	__u8			xfrm_gro:1;
-	/* 2 or 4 bit hole */
+	__u8			hw_xfrm:1;
+	/* 1 or 3 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5c5db66..ac6c1aa 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1220,6 +1220,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_TUNNEL_REMCSUM |
+		       SKB_GSO_ESP |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4779374..550323d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -86,6 +86,15 @@ static inline struct scatterlist *esp_req_sg(struct crypto_aead *aead,
 			     __alignof__(struct scatterlist));
 }
 
+static void esp_output_done2(struct crypto_async_request *base, int err)
+{
+	struct sk_buff *skb = base->data;
+
+	kfree(ESP_SKB_CB(skb)->tmp);
+
+	skb_dst(skb)->dev->xfrmdev_ops->xdo_dev_resume(skb, err);
+}
+
 static void esp_output_done(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
@@ -118,6 +127,69 @@ static void esp_output_done_esn(struct crypto_async_request *base, int err)
 	esp_output_done(base, err);
 }
 
+static void esp4_gso_encap(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ip_esp_hdr *esph;
+	struct iphdr *iph = ip_hdr(skb);
+	int proto = iph->protocol;
+
+	skb_push(skb, -skb_network_offset(skb));
+	esph = ip_esp_hdr(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	esph->spi = x->id.spi;
+
+	/* save off the next_proto in seq_no to be used in
+	 * esp4_gso_encap() for invoking protocol specific
+	 * segmentation offload.
+	 */
+	esph->seq_no = proto;
+}
+
+static int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+	__be32 *seqhi;
+	int seqhilen;
+	u8 *iv;
+	struct crypto_aead *aead;
+	struct aead_request *req;
+	void *tmp;
+
+	aead = x->data;
+	tmp = ESP_SKB_CB(skb)->tmp;
+
+	seqhilen = 0;
+	if (x->props.flags & XFRM_STATE_ESN)
+		seqhilen += sizeof(__be32);
+
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
+	req = esp_tmp_req(aead, iv);
+
+	aead_request_set_callback(req, 0, esp_output_done2, skb);
+
+	err = crypto_aead_encrypt(req);
+
+	switch (err) {
+	case -EINPROGRESS:
+		goto error;
+
+	case -EBUSY:
+		err = NET_XMIT_DROP;
+		break;
+
+	case 0:
+		if ((x->props.flags & XFRM_STATE_ESN))
+			esp_output_restore_header(skb);
+	}
+
+	kfree(tmp);
+
+error:
+	return err;
+}
+
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
@@ -140,6 +212,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int seqhilen;
 	__be32 *seqhi;
 	__be64 seqno;
+	int proto;
 
 	/* skb is pure payload to encrypt */
 
@@ -167,6 +240,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	assoclen = sizeof(*esph);
 	seqhilen = 0;
+	proto = ip_esp_hdr(skb)->seq_no;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
 		seqhilen += sizeof(__be32);
@@ -196,12 +270,18 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			tail[i] = i + 1;
 	} while (0);
 	tail[plen - 2] = plen - 2;
-	tail[plen - 1] = *skb_mac_header(skb);
+	if (!skb->hw_xfrm)
+		tail[plen - 1] = *skb_mac_header(skb);
+	else
+		tail[plen - 1] = proto;
+
 	pskb_put(skb, trailer, clen - skb->len + alen);
 
 	skb_push(skb, -skb_network_offset(skb));
 	esph = ip_esp_hdr(skb);
-	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	if (!skb->hw_xfrm)
+		*skb_mac_header(skb) = IPPROTO_ESP;
 
 	/* this is non-NULL only with UDP Encapsulation */
 	if (x->encap) {
@@ -271,6 +351,10 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	       min(ivlen, 8));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
+
+	if (skb->hw_xfrm)
+		return 0;
+
 	err = crypto_aead_encrypt(req);
 
 	switch (err) {
@@ -735,7 +819,9 @@ static const struct xfrm_type esp_type =
 	.destructor	= esp_destroy,
 	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
-	.output		= esp_output
+	.output		= esp_output,
+	.output_tail	= esp_output_tail,
+	.encap		= esp4_gso_encap,
 };
 
 static struct xfrm4_protocol esp4_protocol = {
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index f2b0d6d..7c44c09 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -63,10 +63,95 @@ static int esp4_gro_complete(struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+static struct sk_buff *esp4_gso_segment(struct sk_buff *skb,
+				        netdev_features_t features)
+{
+	struct ip_esp_hdr *esph;
+	struct sk_buff *skb2;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_state *x;
+	struct crypto_aead *aead;
+	int err = 0;
+	const struct net_offload *ops;
+	int proto;
+
+	if (!dst || !dst->xfrm)
+		goto out;
+
+	x = dst->xfrm;
+	aead = x->data;
+	esph = ip_esp_hdr(skb);
+
+	proto = esph->seq_no;
+	if (esph->spi != x->id.spi)
+		goto out;
+
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead)))
+		goto out;
+
+	__skb_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead));
+
+	skb->encap_hdr_csum = 1;
+
+	if (proto == IPPROTO_IPIP) {
+		__skb_push(skb, skb->mac_len);
+		segs = skb_mac_gso_segment(skb, features);
+	} else {
+		skb->transport_header += x->props.header_len;
+		ops = rcu_dereference(inet_offloads[proto]);
+		if (likely(ops && ops->callbacks.gso_segment))
+			segs = ops->callbacks.gso_segment(skb, features);
+	}
+	if (IS_ERR(segs))
+		goto out;
+	if (segs == NULL)
+		return ERR_PTR(-EINVAL);
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
+
+	skb2 = segs;
+	do {
+		struct sk_buff *nskb = skb2->next;
+
+		if (proto == IPPROTO_IPIP) {
+			skb2->network_header = skb2->network_header - x->props.header_len;
+			skb2->transport_header = skb2->network_header + sizeof(struct iphdr);
+			skb_reset_mac_len(skb2);
+			skb_pull(skb2, skb2->mac_len + x->props.header_len);
+		} else {
+			/* skb2 mac and data are pointing at the start of
+			 * mac address. Pull data forward to point to tcp hdr
+			 */
+			 __skb_pull(skb2, skb2->transport_header - skb2->mac_header);
+
+			 /* move transport_header to point to esp header */
+			 skb2->transport_header -= x->props.header_len;
+		}
+
+		/* Set up eshp->seq_no to be used by esp_output()
+		 * for initializing trailer.
+		 */
+		ip_esp_hdr(skb2)->seq_no = proto;
+
+		err = dst->dev->xfrmdev_ops->xdo_dev_prepare(skb2);
+		if (err) {
+			kfree_skb_list(segs);
+			return ERR_PTR(err);
+		}
+
+		skb_push(skb2, skb2->mac_len);
+		skb2 = nskb;
+	} while (skb2);
+
+out:
+	return segs;
+}
+
 static const struct net_offload esp4_offload = {
 	.callbacks = {
 		.gro_receive = esp4_gro_receive,
 		.gro_complete = esp4_gro_complete,
+		.gso_segment = esp4_gso_segment,
 	},
 };
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 9864a2d..e67981e 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -97,6 +97,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_UDP_TUNNEL |
 			       SKB_GSO_UDP_TUNNEL_CSUM |
 			       SKB_GSO_TUNNEL_REMCSUM |
+			       SKB_GSO_ESP |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
-- 
1.9.1
