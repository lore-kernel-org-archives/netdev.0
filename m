From: jamal <hadi@cyberus.ca>
Subject: [PKTGEN] Introduce sequential flows
Date: Sat, 09 Jun 2007 10:16:51 -0400
Message-ID: <1181398611.4077.16.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Moo/4NHlUNzaBhnOZ9fg"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:18956 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbXFIOQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 10:16:55 -0400
Received: by py-out-1112.google.com with SMTP id a29so1751713pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 07:16:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Moo/4NHlUNzaBhnOZ9fg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

2 of 4.

cheers,
jamal


--=-Moo/4NHlUNzaBhnOZ9fg
Content-Disposition: attachment; filename=pg-sq1
Content-Type: text/plain; name=pg-sq1; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit d0d2c0c2e5539a54d66f07d2fa99bb52c19cc698
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sat Jun 9 09:12:21 2007 -0400

    [PKTGEN] Introduce sequential flows
    
    By default all flows in pktgen are randomly selected.
    This patch introduces ability to have all defined flows to
    be sent sequentially. It also cleans the small piece of code
    associated with the change for readability.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1352316..2e861d2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -181,6 +181,7 @@
 #define F_MPLS_RND    (1<<8)	/* Random MPLS labels */
 #define F_VID_RND     (1<<9)	/* Random VLAN ID */
 #define F_SVID_RND    (1<<10)	/* Random SVLAN ID */
+#define F_FLOW_RND    (1<<11)	/* Random flows */
 
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
@@ -691,6 +697,11 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_printf(seq,  "MPLS_RND  ");
 
+	if (pkt_dev->flags & F_FLOW_RND)
+		seq_printf(seq,  "FLOW_RND  ");
+	else
+		seq_printf(seq,  "FLOW_SEQ  "); /*in sequence flows*/
+
 	if (pkt_dev->flags & F_MACSRC_RND)
 		seq_printf(seq, "MACSRC_RND  ");
 
@@ -1182,6 +1193,9 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!SVID_RND") == 0)
 			pkt_dev->flags &= ~F_SVID_RND;
 
+		else if (strcmp(f, "FLOW_RND") == 0)
+			pkt_dev->flags |= F_FLOW_RND;
+
 		else if (strcmp(f, "!IPV6") == 0)
 			pkt_dev->flags &= ~F_IPV6;
 
@@ -1190,7 +1204,7 @@ static ssize_t pktgen_if_write(struct file *file,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_RND\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
@@ -2083,6 +2097,37 @@ static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
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
+	if (pkt_dev->flags & F_FLOW_RND) {
+		flow = random32() % pkt_dev->cflows;
+
+		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
+			pkt_dev->flows[flow].count = 0;
+	} else {
+		if (pkt_dev->flows[flow].count >= pkt_dev->lflow) {
+			/* reset time */
+			pkt_dev->flows[flow].count = 0;
+			pkt_dev->curfl += 1;
+			if (pkt_dev->curfl >= pkt_dev->cflows)
+				pkt_dev->curfl = 0; /*reset */
+		}
+	}
+
+	return pkt_dev->curfl;
+}
+
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2092,12 +2137,8 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
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
@@ -2213,7 +2254,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 			pkt_dev->cur_saddr = htonl(t);
 		}
 
-		if (pkt_dev->cflows && pkt_dev->flows[flow].count != 0) {
+		if (pkt_dev->cflows && f_seen(pkt_dev, flow)) {
 			pkt_dev->cur_daddr = pkt_dev->flows[flow].cur_daddr;
 		} else {
 			imn = ntohl(pkt_dev->daddr_min);
@@ -2243,6 +2284,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				}
 			}
 			if (pkt_dev->cflows) {
+				pkt_dev->flows[flow].flags |= F_INIT;
 				pkt_dev->flows[flow].cur_daddr =
 				    pkt_dev->cur_daddr;
 				pkt_dev->nflows++;

--=-Moo/4NHlUNzaBhnOZ9fg--

