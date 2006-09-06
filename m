From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Wed, 06 Sep 2006 08:14:54 -0400
Message-ID: <1157544895.5039.33.camel@jzny2>
References: <1157204582.5197.4.camel@jzny2>
	 <20060905233823.GA9217@gondor.apana.org.au>
	 <1157541639.5039.28.camel@jzny2>
	 <20060906112644.GA22930@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GbFFRGJ1DX1baSTkZl3n"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:49640 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750782AbWIFMPB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 08:15:01 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GKwJ4-00012P-1l
	for netdev@vger.kernel.org; Wed, 06 Sep 2006 08:15:02 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060906112644.GA22930@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GbFFRGJ1DX1baSTkZl3n
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2006-06-09 at 21:26 +1000, Herbert Xu wrote:
> On Wed, Sep 06, 2006 at 07:20:39AM -0400, jamal wrote:
> >
> > > Any reason why xfrm_state_find can't be used? 
> > 
> > xfrm_state_find is overkill (if you compare the two functionalities). 
> 
> Could you show me how you plan to use this in pktgen? 

Older patch attached - has a few bugs; just ignore them.

> Perhaps we can
> move it to the slow path where it wouldn't matter whether it's an
> overkill or not.  There should be no reason to be looking up an SA
> in the pktgen fast path.

It is needed if you want replay protection - unless you can come with
some clever way to handle it without violating the integrity. 
For non replay protection, thats easy: We just do one lookup and reclone
the packet within pktgen - maybe thats what you meant by "slow path"?

cheers,
jamal

--=-GbFFRGJ1DX1baSTkZl3n
Content-Disposition: attachment; filename=pig3
Content-Type: text/plain; name=pig3; charset=utf-8
Content-Transfer-Encoding: 7bit

    Add IPSEC support to pktgen. Currently only IPV4 and ESP/Transport
    mode. IPV6 next. And Tunnel mode to follow after some discussions with
    Herbert and Dave.

---
commit 0721d8f9d3e1a9a8f5f038365ae12ec605a2d5d6
tree 3069707bec44c992c0bfdbe871c7e3bd68d37882
parent 1a4c28d2bd2fcf82b84bffdb7be47aa9224483d0
author Jamal Hadi Salim <hadi@znyx.com> Tue, 22 Aug 2006 21:43:37 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Tue, 22 Aug 2006 21:43:37 -0400

 net/core/pktgen.c |  169 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 156 insertions(+), 13 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 67ed14d..5fc725d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -148,6 +148,7 @@ #include <linux/etherdevice.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#include <net/xfrm.h>
 #include <asm/byteorder.h>
 #include <linux/rcupdate.h>
 #include <asm/bitops.h>
@@ -178,6 +179,8 @@ #define F_MACDST_RND  (1<<5)	/* MAC-Dst 
 #define F_TXSIZE_RND  (1<<6)	/* Transmit size is random */
 #define F_IPV6        (1<<7)	/* Interface in IPV6 Mode */
 #define F_MPLS_RND    (1<<8)	/* Random MPLS labels */
+#define F_FLOW_RND    (1<<9)	/* Random flows */
+#define F_IPSEC_ON    (1<<10)	/* Run ipsec when possible */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -200,6 +203,7 @@ #define MAX_CFLOWS  65536
 
 struct flow_state {
 	__u32 cur_daddr;
+	struct xfrm_state *x;
 	int count;
 };
 
@@ -226,6 +230,7 @@ struct pktgen_dev {
 
 	int min_pkt_size;	/* = ETH_ZLEN; */
 	int max_pkt_size;	/* = ETH_ZLEN; */
+	int pkt_overhead;	/* overhead in case of MPLS or IPSEC */
 	int nfrags;
 	__u32 delay_us;		/* Default delay */
 	__u32 delay_ns;
@@ -324,6 +329,8 @@ struct pktgen_dev {
 					 */
 	struct flow_state *flows;
 	unsigned cflows;	/* Concurrent flows (config) */
+	unsigned nextfl;	/* next flow when not random */
+	unsigned curfl;		/* current running flow */
 	unsigned lflow;		/* Flow length  (config) */
 	unsigned nflows;	/* accumulated flows (stats) */
 };
@@ -667,6 +674,14 @@ static int pktgen_if_show(struct seq_fil
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_printf(seq,  "MPLS_RND  ");
 
+	if (pkt_dev->flags & F_FLOW_RND)
+		seq_printf(seq,  "FLOW_RND  ");
+	else
+		seq_printf(seq,  "FLOW_SQN  "); /*in sequence */
+
+	if (pkt_dev->flags & F_IPSEC_ON)
+		seq_printf(seq,  "IPSEC_ON  ");
+
 	if (pkt_dev->flags & F_MACSRC_RND)
 		seq_printf(seq, "MACSRC_RND  ");
 
@@ -1140,6 +1155,12 @@ static ssize_t pktgen_if_write(struct fi
 		else if (strcmp(f, "!MPLS_RND") == 0)
 			pkt_dev->flags &= ~F_MPLS_RND;
 
+		else if (strcmp(f, "IPSEC_ON") == 0)
+			pkt_dev->flags |= F_IPSEC_ON;
+
+		else if (strcmp(f, "!IPSEC_ON") == 0)
+			pkt_dev->flags &= ~F_IPSEC_ON;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -1447,6 +1468,10 @@ static ssize_t pktgen_if_write(struct fi
 					  n == pkt_dev->nr_labels-1 ? "" : ",");
 		return count;
 	}
+	if (!strcmp(name, "ipsec")) {
+		/*XXX: Add the "OK: ipsec on" thing */
+		pkt_dev->flags |= F_IPSEC_ON;
+	}
 
 	sprintf(pkt_dev->result, "No such parameter \"%s\"", name);
 	return -EINVAL;
@@ -1879,11 +1904,26 @@ static void mod_cur_headers(struct pktge
 	__u32 imx;
 	int flow = 0;
 
+	pkt_dev->pkt_overhead = 0;
 	if (pkt_dev->cflows) {
-		flow = pktgen_random() % pkt_dev->cflows;
+		if (pkt_dev->flags & F_FLOW_RND) {
+			flow = pktgen_random() % pkt_dev->cflows;
+			if (pkt_dev->flows[flow].count > pkt_dev->lflow)
+				pkt_dev->flows[flow].count = 0;
+		} else {
+			flow = pkt_dev->nextfl;
+			if (pkt_dev->flows[flow].count > pkt_dev->lflow) {
+				/* reset time */
+				pkt_dev->nextfl+=1;
+				if (pkt_dev->nextfl > pkt_dev->cflows)
+					 pkt_dev->nextfl = 0; /*reset */
+
+				flow = pkt_dev->nextfl;
+			}
 
-		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
-			pkt_dev->flows[flow].count = 0;
+		}
+		pkt_dev->curfl = flow;
+		pkt_dev->nextfl+=1;
 	}
 
 	/*  Deal with source MAC */
@@ -1947,6 +1987,9 @@ static void mod_cur_headers(struct pktge
 				pkt_dev->labels[i] = MPLS_STACK_BOTTOM |
 						     (pktgen_random() &
 						      htonl(0x000fffff));
+
+		pkt_dev->pkt_overhead+=pkt_dev->nr_labels*sizeof(u32);
+
 	}
 
 	if (pkt_dev->udp_src_min < pkt_dev->udp_src_max) {
@@ -2068,9 +2111,62 @@ static void mod_cur_headers(struct pktge
 		pkt_dev->cur_pkt_size = t;
 	}
 
+	if (pkt_dev->cflows && pkt_dev->flags & F_IPSEC_ON) {
+		struct xfrm_state *x = pkt_dev->flows[flow].x;
+	       	if (!x) {
+			/*slow path: we dont already have xfrm_state*/
+			x = xfrm_stateonly_find((xfrm_address_t *)&pkt_dev->cur_daddr, (xfrm_address_t *)&pkt_dev->cur_saddr, AF_INET,XFRM_MODE_TRANSPORT, IPPROTO_ESP);
+			if (x) {
+				pkt_dev->flows[flow].x = x;
+				pkt_dev->pkt_overhead+=x->props.header_len;
+			}
+
+		}
+	}
+
+	/* XXX: Should this be moved into if stmt above? 
+	 * Talk to Monsieur Robert
+	*/
 	pkt_dev->flows[flow].count++;
 }
 
+/* In case of errors we are gonna bail out on the packet ..
+ * Also: We only support transport mode at the moment..
+ * Talk to Herbert/Dave about making the tunnel mode pieces
+ * independent of dst ..
+ **/
+static int pktgen_handle_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
+{
+	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
+	int err = 0;
+
+	if (!x)
+		return 0;
+	/* XXX: we dont support tunnel mode for now until
+	 * we resolve the dst issue */
+	if (x->props.mode) 
+		return 0;
+	/* error injection 
+	return -1;
+	*/ 
+	spin_lock(&x->lock);
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
 static void mpls_push(__be32 *mpls, struct pktgen_dev *pkt_dev)
 {
 	unsigned i;
@@ -2092,9 +2188,7 @@ static struct sk_buff *fill_packet_ipv4(
 	struct pktgen_hdr *pgh = NULL;
 	__be16 protocol = __constant_htons(ETH_P_IP);
 	__be32 *mpls;
-
-	if (pkt_dev->nr_labels)
-		protocol = __constant_htons(ETH_P_MPLS_UC);
+	int nhead;
 
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
@@ -2102,8 +2196,12 @@ static struct sk_buff *fill_packet_ipv4(
 	mod_cur_headers(pkt_dev);
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
+
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen +
-			pkt_dev->nr_labels*sizeof(u32), GFP_ATOMIC);
+			pkt_dev->pkt_overhead, GFP_ATOMIC);
+	/*XXX: We need to check for cases where the MTU maybe
+	 * exceeded
+	*/
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2113,10 +2211,15 @@ static struct sk_buff *fill_packet_ipv4(
 
 	/*  Reserve for ethernet and IP header  */
 	eth = (__u8 *) skb_push(skb, 14);
-	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
-	if (pkt_dev->nr_labels)
+
+	if (pkt_dev->nr_labels) {
+		protocol = __constant_htons(ETH_P_MPLS_UC);
+		mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
 		mpls_push(mpls, pkt_dev);
+	}
+
 	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
+	skb->nh.iph = iph;
 	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
 
 	memcpy(eth, pkt_dev->hh, 12);
@@ -2124,7 +2227,7 @@ static struct sk_buff *fill_packet_ipv4(
 
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
-		  pkt_dev->nr_labels*sizeof(u32);
+		  pkt_dev->pkt_overhead;
 	if (datalen < sizeof(struct pktgen_hdr))
 		datalen = sizeof(struct pktgen_hdr);
 
@@ -2146,10 +2249,11 @@ static struct sk_buff *fill_packet_ipv4(
 	iph->check = 0;
 	iph->check = ip_fast_csum((void *)iph, iph->ihl);
 	skb->protocol = protocol;
-	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->nr_labels*sizeof(u32);
+	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->pkt_overhead;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
+
 	if (pkt_dev->nfrags <= 0)
 		pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
 	else {
@@ -2216,6 +2320,30 @@ static struct sk_buff *fill_packet_ipv4(
 		pgh->tv_sec = htonl(timestamp.tv_sec);
 		pgh->tv_usec = htonl(timestamp.tv_usec);
 	}
+	// Finally let ipsec at it ;->
+	if (pkt_dev->flags & F_IPSEC_ON) {
+		struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
+		if (x) {
+			int ret;
+			nhead = x->props.header_len - skb_headroom(skb);
+			if (nhead >0)
+				pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
+			/* ipsec is not expecting ll header */
+			skb_pull(skb, 14);
+			ret = pktgen_handle_ipsec(skb, pkt_dev);
+			if (ret) {
+				printk("Error creating ipsec packet %d\n",ret);
+				kfree_skb(skb);
+				return NULL;	
+			}
+		 	/* restore ll */
+			eth = (__u8 *) skb_push(skb, 14);
+			memcpy(eth, pkt_dev->hh, 12);
+			*(u16 *) & eth[12] = protocol;
+
+		}
+	}
+
 	pkt_dev->seq_num++;
 
 	return skb;
@@ -3177,8 +3305,9 @@ static int pktgen_add_device(struct pktg
 
 	if (!pktgen_setup_dev(pkt_dev)) {
 		printk("pktgen: ERROR: pktgen_setup_dev failed.\n");
-		if (pkt_dev->flows)
+		if (pkt_dev->flows) {
 			vfree(pkt_dev->flows);
+		}
 		kfree(pkt_dev);
 		return -ENODEV;
 	}
@@ -3187,8 +3316,9 @@ static int pktgen_add_device(struct pktg
 	if (!pe) {
 		printk("pktgen: cannot create %s/%s procfs entry.\n",
 		       PG_PROC_DIR, ifname);
-		if (pkt_dev->flows)
+		if (pkt_dev->flows) {
 			vfree(pkt_dev->flows);
+		}
 		kfree(pkt_dev);
 		return -EINVAL;
 	}
@@ -3312,8 +3442,21 @@ static int pktgen_remove_device(struct p
 
 	remove_proc_entry(pkt_dev->ifname, pg_proc_dir);
 
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
+
 	if (pkt_dev->flows)
 		vfree(pkt_dev->flows);
+
 	kfree(pkt_dev);
 	return 0;
 }

--=-GbFFRGJ1DX1baSTkZl3n--

