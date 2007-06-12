From: jamal <hadi@cyberus.ca>
Subject: Resend: [PATCH] pktgen IPSEC 4/4: Add IPSEC support to pktgen
Date: Tue, 12 Jun 2007 19:08:39 -0400
Message-ID: <1181689719.4085.58.camel@localhost>
References: <1181649373.4060.50.camel@localhost>
	 <1181649628.4060.54.camel@localhost>  <1181649715.4060.56.camel@localhost>
	 <1181649791.4060.59.camel@localhost>  <1181649848.4060.62.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XevoZUvAY+jll5Rhwi2e"
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:48452 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529AbXFLXIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 19:08:43 -0400
Received: by py-out-1112.google.com with SMTP id a29so23258pyi
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 16:08:42 -0700 (PDT)
In-Reply-To: <1181649848.4060.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XevoZUvAY+jll5Rhwi2e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Sorry Robert, I found a problem compiling when i turned off XFRM. This
fixes it.

cheers,
jamal


--=-XevoZUvAY+jll5Rhwi2e
Content-Disposition: attachment; filename=pg-ipsec3
Content-Type: text/plain; name=pg-ipsec3; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit bfd389bba7654aa118f0949ff0de45a3bce9700c
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Jun 12 18:59:33 2007 -0400

    [PKTGEN] IPSEC support
    Added transport mode ESP support for starters.
    I will send more of these modes and types once i have resolved
    the tunnel mode isses.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index bc4fb3b..e7d1dff 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -152,6 +152,9 @@
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#ifdef CONFIG_XFRM
+#include <net/xfrm.h>
+#endif
 #include <asm/byteorder.h>
 #include <linux/rcupdate.h>
 #include <asm/bitops.h>
@@ -182,6 +185,7 @@
 #define F_VID_RND     (1<<9)	/* Random VLAN ID */
 #define F_SVID_RND    (1<<10)	/* Random SVLAN ID */
 #define F_FLOW_SEQ    (1<<11)	/* Sequential flows */
+#define F_IPSEC_ON    (1<<12)	/* ipsec on for flows */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -208,6 +212,9 @@ static struct proc_dir_entry *pg_proc_dir = NULL;
 struct flow_state {
 	__be32 cur_daddr;
 	int count;
+#ifdef CONFIG_XFRM
+	struct xfrm_state *x;
+#endif
 	__u32 flags;
 };
 
@@ -348,7 +355,10 @@ struct pktgen_dev {
 	unsigned lflow;		/* Flow length  (config) */
 	unsigned nflows;	/* accumulated flows (stats) */
 	unsigned curfl;		/* current sequenced flow (state)*/
-
+#ifdef CONFIG_XFRM
+	__u8	ipsmode;		/* IPSEC mode (config) */
+	__u8	ipsproto;		/* IPSEC type (config) */
+#endif
 	char result[512];
 };
 
@@ -704,6 +714,11 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 			seq_printf(seq,  "FLOW_RND  ");
 	}
 
+#ifdef CONFIG_XFRM
+	if (pkt_dev->flags & F_IPSEC_ON)
+		seq_printf(seq,  "IPSEC  ");
+#endif
+
 	if (pkt_dev->flags & F_MACSRC_RND)
 		seq_printf(seq, "MACSRC_RND  ");
 
@@ -1198,6 +1213,11 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "FLOW_SEQ") == 0)
 			pkt_dev->flags |= F_FLOW_SEQ;
 
+#ifdef CONFIG_XFRM
+		else if (strcmp(f, "IPSEC") == 0)
+			pkt_dev->flags |= F_IPSEC_ON;
+#endif
+
 		else if (strcmp(f, "!IPV6") == 0)
 			pkt_dev->flags &= ~F_IPV6;
 
@@ -1206,7 +1226,7 @@ static ssize_t pktgen_if_write(struct file *file,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, IPSEC\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
@@ -2094,6 +2114,7 @@ static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
 {
+	pkt_dev->pkt_overhead = 0;
 	pkt_dev->pkt_overhead += pkt_dev->nr_labels*sizeof(u32);
 	pkt_dev->pkt_overhead += VLAN_TAG_SIZE(pkt_dev);
 	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
@@ -2130,6 +2151,31 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 	return pkt_dev->curfl;
 }
 
+
+#ifdef CONFIG_XFRM
+/* If there was already an IPSEC SA, we keep it as is, else
+ * we go look for it ...
+*/
+inline
+void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
+{
+	struct xfrm_state *x = pkt_dev->flows[flow].x;
+	if (!x) {
+		/*slow path: we dont already have xfrm_state*/
+		x = xfrm_stateonly_find((xfrm_address_t *)&pkt_dev->cur_daddr,
+					(xfrm_address_t *)&pkt_dev->cur_saddr,
+					AF_INET,
+					pkt_dev->ipsmode,
+					pkt_dev->ipsproto, 0);
+		if (x) {
+			pkt_dev->flows[flow].x = x;
+			set_pkt_overhead(pkt_dev);
+			pkt_dev->pkt_overhead+=x->props.header_len;
+		}
+
+	}
+}
+#endif
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2289,6 +2335,10 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				pkt_dev->flows[flow].flags |= F_INIT;
 				pkt_dev->flows[flow].cur_daddr =
 				    pkt_dev->cur_daddr;
+#ifdef CONFIG_XFRM
+				if (pkt_dev->flags & F_IPSEC_ON)
+					get_ipsec_sa(pkt_dev, flow);
+#endif
 				pkt_dev->nflows++;
 			}
 		}
@@ -2329,6 +2379,91 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 	pkt_dev->flows[flow].count++;
 }
 
+
+#ifdef CONFIG_XFRM
+static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
+{
+	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
+	int err = 0;
+	struct iphdr *iph;
+
+	if (!x)
+		return 0;
+	/* XXX: we dont support tunnel mode for now until
+	 * we resolve the dst issue */
+	if (x->props.mode != XFRM_MODE_TRANSPORT)
+		return 0;
+
+	spin_lock(&x->lock);
+	iph = ip_hdr(skb);
+
+	err = x->mode->output(x, skb);
+	if (err)
+		goto error;
+	err = x->type->output(x, skb);
+	if (err)
+		goto error;
+
+	x->curlft.bytes +=skb->len;
+	x->curlft.packets++;
+	spin_unlock(&x->lock);
+
+error:
+	spin_unlock(&x->lock);
+	return err;
+}
+
+static inline void free_SAs(struct pktgen_dev *pkt_dev)
+{
+	if (pkt_dev->cflows) {
+		/* let go of the SAs if we have them */
+		int i = 0;
+		for (;  i < pkt_dev->nflows; i++){
+			struct xfrm_state *x = pkt_dev->flows[i].x;
+			if (x) {
+				xfrm_state_put(x);
+				pkt_dev->flows[i].x = NULL;
+			}
+		}
+	}
+}
+
+static inline int process_ipsec(struct pktgen_dev *pkt_dev,
+			      struct sk_buff *skb, __be16 protocol)
+{
+	if (pkt_dev->flags & F_IPSEC_ON) {
+		struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
+		int nhead = 0;
+		if (x) {
+			int ret;
+			__u8 *eth;
+			nhead = x->props.header_len - skb_headroom(skb);
+			if (nhead >0) {
+				ret = pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
+				if (ret < 0) {
+					printk("Error expanding ipsec packet %d\n",ret);
+					return 0;
+				}
+			}
+
+			/* ipsec is not expecting ll header */
+			skb_pull(skb, ETH_HLEN);
+			ret = pktgen_output_ipsec(skb, pkt_dev);
+			if (ret) {
+				printk("Error creating ipsec packet %d\n",ret);
+				kfree_skb(skb);
+				return 0;
+			}
+			/* restore ll */
+			eth = (__u8 *) skb_push(skb, ETH_HLEN);
+			memcpy(eth, pkt_dev->hh, 12);
+			*(u16 *) & eth[12] = protocol;
+		}
+	}
+	return 1;
+}
+#endif
+
 static void mpls_push(__be32 *mpls, struct pktgen_dev *pkt_dev)
 {
 	unsigned i;
@@ -2512,6 +2647,11 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		pgh->tv_usec = htonl(timestamp.tv_usec);
 	}
 
+#ifdef CONFIG_XFRM
+	if (!process_ipsec(pkt_dev, skb, protocol))
+		return NULL;
+#endif
+
 	return skb;
 }
 
@@ -3493,11 +3633,18 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	}
 	pkt_dev->entry->proc_fops = &pktgen_if_fops;
 	pkt_dev->entry->data = pkt_dev;
+#ifdef CONFIG_XFRM
+	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;
+	pkt_dev->ipsproto = IPPROTO_ESP;
+#endif
 
 	return add_dev_to_thread(t, pkt_dev);
 out2:
 	dev_put(pkt_dev->odev);
 out1:
+#ifdef CONFIG_XFRM
+	free_SAs(pkt_dev);
+#endif
 	if (pkt_dev->flows)
 		vfree(pkt_dev->flows);
 	kfree(pkt_dev);
@@ -3592,6 +3739,9 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	if (pkt_dev->entry)
 		remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
 
+#ifdef CONFIG_XFRM
+	free_SAs(pkt_dev);
+#endif
 	if (pkt_dev->flows)
 		vfree(pkt_dev->flows);
 	kfree(pkt_dev);

--=-XevoZUvAY+jll5Rhwi2e--

