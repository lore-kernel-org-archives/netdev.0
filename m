From: Roland Dreier <roland@topspin.com>
Subject: [PATCH] IPv6: Add correct padding to IPoIB link
	addr option
Date: Tue, 18 Jan 2005 09:33:47 -0800
Message-ID: <528y6qej5w.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipoverib@ietf.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: davem@davemloft.net, netdev@oss.sgi.com
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

+++ linux-bk/net/ipv6/ndisc.c	2005-01-14 21:20:55.736745091 -0800
@@ -169,12 +169,33 @@
 
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
-static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
+/*
+ * Return the padding between the option length and the start of the
+ * link addr.  Currently only IP-over-InfiniBand needs this, although
+ * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
+ * also need a pad of 2.
+ */
+static int ndisc_addr_option_pad(unsigned short type)
+{
+	switch (type) {
+	case ARPHRD_INFINIBAND: return 2;
+	default:                return 0;
+	}
+}
+
+static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
+				  unsigned short addr_type)
 {
 	int space = NDISC_OPT_SPACE(data_len);
+	int pad   = ndisc_addr_option_pad(addr_type);
 
 	opt[0] = type;
 	opt[1] = space>>3;
+
+	memset(opt + 2, 0, pad);
+	opt   += pad;
+	space -= pad;
+
 	memcpy(opt+2, data, data_len);
 	data_len += 2;
 	opt += data_len;
@@ -453,7 +474,8 @@
 	ipv6_addr_copy(&msg->target, solicited_addr);
 
 	if (inc_opt)
-		ndisc_fill_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_addr_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr,
+				       dev->addr_len, dev->type);
 
 	/* checksum */
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(src_addr, daddr, len, 
@@ -536,7 +558,8 @@
 	ipv6_addr_copy(&msg->target, solicit);
 
 	if (send_llinfo)
-		ndisc_fill_option(msg->opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_addr_option(msg->opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
+				       dev->addr_len, dev->type);
 
 	/* checksum */
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&skb->nh.ipv6h->saddr,
@@ -610,7 +633,8 @@
 	opt = (u8*) (hdr + 1);
 
 	if (dev->addr_len)
-		ndisc_fill_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
+				       dev->addr_len, dev->type);
 
 	/* checksum */
 	hdr->icmp6_cksum = csum_ipv6_magic(&skb->nh.ipv6h->saddr, daddr, len,
@@ -717,7 +741,8 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1);
+		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1) +
+			ndisc_addr_option_pad(dev->type);
 		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
 			ND_PRINTK2(KERN_WARNING
@@ -874,7 +899,8 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
+		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
+			ndisc_addr_option_pad(dev->type);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
 			ND_PRINTK2(KERN_WARNING
@@ -964,7 +990,8 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1);
+		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1) +
+			ndisc_addr_option_pad(skb->dev->type);
 		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len))
 			goto out;
@@ -1130,7 +1157,8 @@
 		u8 *lladdr = NULL;
 		int lladdrlen;
 		if (ndopts.nd_opts_src_lladdr) {
-			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1);
+			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1) +
+				ndisc_addr_option_pad(skb->dev->type);
 			lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
 			if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
 				ND_PRINTK2(KERN_WARNING
@@ -1250,7 +1278,8 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
+		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1) +
+			ndisc_addr_option_pad(skb->dev->type);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
 			ND_PRINTK2(KERN_WARNING
@@ -1379,7 +1408,8 @@
 	 */
 
 	if (dev->addr_len)
-		opt = ndisc_fill_option(opt, ND_OPT_TARGET_LL_ADDR, neigh->ha, dev->addr_len);
+		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, neigh->ha,
+					     dev->addr_len, dev->type);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
