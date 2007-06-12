From: jamal <hadi@cyberus.ca>
Subject: [PATCH] pktgen IPSEC 2/4: Introduce pktgen sequential flows
Date: Tue, 12 Jun 2007 08:01:55 -0400
Message-ID: <1181649715.4060.56.camel@localhost>
References: <1181649373.4060.50.camel@localhost>
	 <1181649628.4060.54.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Z04iPoEcXEJ4gc9CNSAQ"
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:42178 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbXFLMB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 08:01:59 -0400
Received: by py-out-1112.google.com with SMTP id a29so3195473pyi
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 05:01:58 -0700 (PDT)
In-Reply-To: <1181649628.4060.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z04iPoEcXEJ4gc9CNSAQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

2 of 4

cheers,
jamal

--=-Z04iPoEcXEJ4gc9CNSAQ
Content-Disposition: attachment; filename=pg-seq2
Content-Type: text/plain; name=pg-seq2; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit 882c296bb3f153e1ac770a874c75cfb2bab8481b
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Jun 12 07:24:00 2007 -0400

    [PKTGEN] Introduce sequential flows
    
    By default all flows in pktgen are randomly selected.
    This patch introduces ability to have all defined flows to
    be sent sequentially. Robert defined randomness to be the
    default behavior.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1352316..bc4fb3b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -181,6 +181,7 @@
 #define F_MPLS_RND    (1<<8)	/* Random MPLS labels */
 #define F_VID_RND     (1<<9)	/* Random VLAN ID */
 #define F_SVID_RND    (1<<10)	/* Random SVLAN ID */
+#define F_FLOW_SEQ    (1<<11)	/* Sequential flows */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -207,8 +208,12 @@ static struct proc_dir_entry *pg_proc_dir = NULL;
 struct flow_state {
 	__be32 cur_daddr;
 	int count;
+	__u32 flags;
 };
 
+/* flow flag bits */
+#define F_INIT   (1<<0)		/* flow has been initialized */
+
 struct pktgen_dev {
 	/*
 	 * Try to keep frequent/infrequent used vars. separated.
@@ -342,6 +347,7 @@ struct pktgen_dev {
 	unsigned cflows;	/* Concurrent flows (config) */
 	unsigned lflow;		/* Flow length  (config) */
 	unsigned nflows;	/* accumulated flows (stats) */
+	unsigned curfl;		/* current sequenced flow (state)*/
 
 	char result[512];
 };
@@ -691,6 +697,13 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_printf(seq,  "MPLS_RND  ");
 
+	if (pkt_dev->cflows) {
+		if (pkt_dev->flags & F_FLOW_SEQ)
+			seq_printf(seq,  "FLOW_SEQ  "); /*in sequence flows*/
+		else
+			seq_printf(seq,  "FLOW_RND  ");
+	}
+
 	if (pkt_dev->flags & F_MACSRC_RND)
 		seq_printf(seq, "MACSRC_RND  ");
 
@@ -1182,6 +1195,9 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!SVID_RND") == 0)
 			pkt_dev->flags &= ~F_SVID_RND;
 
+		else if (strcmp(f, "FLOW_SEQ") == 0)
+			pkt_dev->flags |= F_FLOW_SEQ;
+
 		else if (strcmp(f, "!IPV6") == 0)
 			pkt_dev->flags &= ~F_IPV6;
 
@@ -1190,7 +1206,7 @@ static ssize_t pktgen_if_write(struct file *file,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
@@ -2083,6 +2099,37 @@ static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
 	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
 }
 
+static inline int f_seen(struct pktgen_dev *pkt_dev, int flow)
+{
+
+	if (pkt_dev->flows[flow].flags & F_INIT)
+		return 1;
+	else
+		return 0;
+}
+
+static inline int f_pick(struct pktgen_dev *pkt_dev)
+{
+	int flow = pkt_dev->curfl;
+
+	if (pkt_dev->flags & F_FLOW_SEQ) {
+		if (pkt_dev->flows[flow].count >= pkt_dev->lflow) {
+			/* reset time */
+			pkt_dev->flows[flow].count = 0;
+			pkt_dev->curfl += 1;
+			if (pkt_dev->curfl >= pkt_dev->cflows)
+				pkt_dev->curfl = 0; /*reset */
+		}
+	} else {
+		flow = random32() % pkt_dev->cflows;
+
+		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
+			pkt_dev->flows[flow].count = 0;
+	}
+
+	return pkt_dev->curfl;
+}
+
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2092,12 +2139,8 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 	__u32 imx;
 	int flow = 0;
 
-	if (pkt_dev->cflows) {
-		flow = random32() % pkt_dev->cflows;
-
-		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
-			pkt_dev->flows[flow].count = 0;
-	}
+	if (pkt_dev->cflows)
+		flow = f_pick(pkt_dev);
 
 	/*  Deal with source MAC */
 	if (pkt_dev->src_mac_count > 1) {
@@ -2213,7 +2256,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 			pkt_dev->cur_saddr = htonl(t);
 		}
 
-		if (pkt_dev->cflows && pkt_dev->flows[flow].count != 0) {
+		if (pkt_dev->cflows && f_seen(pkt_dev, flow)) {
 			pkt_dev->cur_daddr = pkt_dev->flows[flow].cur_daddr;
 		} else {
 			imn = ntohl(pkt_dev->daddr_min);
@@ -2243,6 +2286,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				}
 			}
 			if (pkt_dev->cflows) {
+				pkt_dev->flows[flow].flags |= F_INIT;
 				pkt_dev->flows[flow].cur_daddr =
 				    pkt_dev->cur_daddr;
 				pkt_dev->nflows++;

--=-Z04iPoEcXEJ4gc9CNSAQ--

