From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH V7] netfilter: h323: avoid potential attack
Date: Sun, 21 Feb 2016 00:03:59 +0800
Message-ID: <1455984239-5807-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: eric.dumazet@gmail.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think hackers chould build a malicious h323 packet to overflow
the pointer p which will panic during the memcpy(addr, p, len)
For example, he may fabricate a very large taddr->ipAddress.ip in
function get_h225_addr.

To avoid above, I add buffer boundary checking both in get addr
functions and set addr functions.

Because the temporary h323 buffer is dynamiclly allocated, I remove
the h323 spin lock in my patch.

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
---
 include/linux/netfilter/nf_conntrack_h323.h |  17 +-
 net/ipv4/netfilter/nf_nat_h323.c            |  33 ++-
 net/netfilter/nf_conntrack_h323_main.c      | 328 +++++++++++++++++-----------
 3 files changed, 244 insertions(+), 134 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_h323.h b/include/linux/netfilter/nf_conntrack_h323.h
index 858d9b2..6c6fea1 100644
--- a/include/linux/netfilter/nf_conntrack_h323.h
+++ b/include/linux/netfilter/nf_conntrack_h323.h
@@ -27,11 +27,17 @@ struct nf_ct_h323_master {
 	};
 };
 
+struct h323_ct_state {
+	unsigned char *buf;
+	unsigned char *data;
+	int buflen;
+};
+
 struct nf_conn;
 
 int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		  TransportAddress *taddr, union nf_inet_addr *addr,
-		  __be16 *port);
+		  __be16 *port, struct h323_ct_state *ctstate);
 void nf_conntrack_h245_expect(struct nf_conn *new,
 			      struct nf_conntrack_expect *this);
 void nf_conntrack_q931_expect(struct nf_conn *new,
@@ -50,12 +56,14 @@ extern int (*set_sig_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned int protoff, unsigned char **data,
-				 TransportAddress *taddr, int count);
+				 TransportAddress *taddr, int count,
+				 struct h323_ct_state *ctstate);
 extern int (*set_ras_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned int protoff, unsigned char **data,
-				 TransportAddress *taddr, int count);
+				 TransportAddress *taddr, int count,
+				 struct h323_ct_state *ctstate);
 extern int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
@@ -90,7 +98,8 @@ extern int (*nat_q931_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     unsigned int protoff,
 			     unsigned char **data, TransportAddress *taddr,
 			     int idx, __be16 port,
-			     struct nf_conntrack_expect *exp);
+			     struct nf_conntrack_expect *exp,
+			     struct h323_ct_state *ctstate);
 
 #endif
 
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 574f7eb..5ed2d70 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -33,12 +33,20 @@ static int set_addr(struct sk_buff *skb, unsigned int protoff,
 	} __attribute__ ((__packed__)) buf;
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
+	int datalen;
+	struct iphdr *iph = ip_hdr(skb);
 
 	buf.ip = ip;
 	buf.port = port;
 	addroff += dataoff;
 
 	if (ip_hdr(skb)->protocol == IPPROTO_TCP) {
+		th = (void *)iph + iph->ihl * 4;
+		datalen = skb->len - (iph->ihl * 4 + th->doff * 4);
+		/* check offset overflow */
+		if (addroff > datalen)
+			return  -1;
+
 		if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 					      protoff, addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
@@ -53,6 +61,11 @@ static int set_addr(struct sk_buff *skb, unsigned int protoff,
 			return -1;
 		*data = skb->data + ip_hdrlen(skb) + th->doff * 4 + dataoff;
 	} else {
+		datalen = skb->len - (iph->ihl * 4 + sizeof(struct udphdr));
+		/* check offset overflow */
+		if (addroff > datalen)
+			return  -1;
+
 		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 					      protoff, addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
@@ -93,7 +106,8 @@ static int set_h245_addr(struct sk_buff *skb, unsigned protoff,
 static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned int protoff, unsigned char **data,
-			TransportAddress *taddr, int count)
+			TransportAddress *taddr, int count,
+			struct h323_ct_state *ctstate)
 {
 	const struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -102,7 +116,8 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 
 	for (i = 0; i < count; i++) {
-		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port)) {
+		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port,
+				  ctstate)) {
 			if (addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
 			    port == info->sig_port[dir]) {
 				/* GW->GK */
@@ -110,7 +125,7 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 				/* Fix for Gnomemeeting */
 				if (i > 0 &&
 				    get_h225_addr(ct, *data, &taddr[0],
-						  &addr, &port) &&
+						  &addr, &port, ctstate) &&
 				    (ntohl(addr.ip) & 0xff000000) == 0x7f000000)
 					i = 0;
 
@@ -146,7 +161,8 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned int protoff, unsigned char **data,
-			TransportAddress *taddr, int count)
+			TransportAddress *taddr, int count,
+			struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int i;
@@ -154,7 +170,8 @@ static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 
 	for (i = 0; i < count; i++) {
-		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port) &&
+		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port,
+				  ctstate) &&
 		    addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
 		    port == ct->tuplehash[dir].tuple.src.u.udp.port) {
 			pr_debug("nf_nat_ras: set rasAddress %pI4:%hu->%pI4:%hu\n",
@@ -424,7 +441,8 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
 		    unsigned int protoff, unsigned char **data,
 		    TransportAddress *taddr, int idx,
-		    __be16 port, struct nf_conntrack_expect *exp)
+		    __be16 port, struct nf_conntrack_expect *exp,
+		    struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -469,7 +487,8 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 		/* Fix for Gnomemeeting */
 		if (idx > 0 &&
-		    get_h225_addr(ct, *data, &taddr[0], &addr, &port) &&
+		    get_h225_addr(ct, *data, &taddr[0], &addr, &port,
+				  ctstate) &&
 		    (ntohl(addr.ip) & 0xff000000) == 0x7f000000) {
 			set_h225_addr(skb, protoff, data, 0, &taddr[0],
 				      &ct->tuplehash[!dir].tuple.dst.u3,
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..19e797f 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -64,12 +64,14 @@ int (*set_sig_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
 			  unsigned int protoff, unsigned char **data,
-			  TransportAddress *taddr, int count) __read_mostly;
+			  TransportAddress *taddr, int count,
+			  struct h323_ct_state *ctstate) __read_mostly;
 int (*set_ras_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
 			  unsigned int protoff, unsigned char **data,
-			  TransportAddress *taddr, int count) __read_mostly;
+			  TransportAddress *taddr, int count,
+			  struct h323_ct_state *ctstate) __read_mostly;
 int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
@@ -105,11 +107,10 @@ int (*nat_q931_hook) (struct sk_buff *skb,
 		      enum ip_conntrack_info ctinfo,
 		      unsigned int protoff,
 		      unsigned char **data, TransportAddress *taddr, int idx,
-		      __be16 port, struct nf_conntrack_expect *exp)
+		      __be16 port, struct nf_conntrack_expect *exp,
+		      struct h323_ct_state *ctstate)
 		      __read_mostly;
 
-static DEFINE_SPINLOCK(nf_h323_lock);
-static char *h323_buffer;
 
 static struct nf_conntrack_helper nf_conntrack_helper_h245;
 static struct nf_conntrack_helper nf_conntrack_helper_q931[];
@@ -118,7 +119,8 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[];
 /****************************************************************************/
 static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 			 struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-			 unsigned char **data, int *datalen, int *dataoff)
+			 unsigned char **data, int *datalen, int *dataoff,
+			 struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -145,8 +147,15 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 
 	if (*data == NULL) {	/* first TPKT */
 		/* Get first TPKT pointer */
+		ctstate->buf = kmalloc(tcpdatalen,  GFP_ATOMIC);
+		if (!ctstate->buf)
+			return 0;
+
+		ctstate->buflen = tcpdatalen;
+
 		tpkt = skb_header_pointer(skb, tcpdataoff, tcpdatalen,
-					  h323_buffer);
+					  ctstate->buf);
+		ctstate->data = tpkt;
 		BUG_ON(tpkt == NULL);
 
 		/* Validate TPKT identifier */
@@ -222,7 +231,8 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 /****************************************************************************/
 static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 			 H245_TransportAddress *taddr,
-			 union nf_inet_addr *addr, __be16 *port)
+			 union nf_inet_addr *addr, __be16 *port,
+			 struct h323_ct_state *ctstate)
 {
 	const unsigned char *p;
 	int len;
@@ -247,6 +257,11 @@ static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 		return 0;
 	}
 
+	/*check pointer overflow */
+	if (p < ctstate->data ||
+	    (p + len + sizeof(__be16)) > ctstate->data + ctstate->buflen)
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -259,7 +274,8 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned int protoff,
 			   unsigned char **data, int dataoff,
-			   H245_TransportAddress *taddr)
+			   H245_TransportAddress *taddr,
+			   struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -271,7 +287,7 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	typeof(nat_rtp_rtcp_hook) nat_rtp_rtcp;
 
 	/* Read RTP or RTCP address */
-	if (!get_h245_addr(ct, *data, taddr, &addr, &port) ||
+	if (!get_h245_addr(ct, *data, taddr, &addr, &port, ctstate) ||
 	    memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) ||
 	    port == 0)
 		return 0;
@@ -334,7 +350,8 @@ static int expect_t120(struct sk_buff *skb,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
 		       unsigned char **data, int dataoff,
-		       H245_TransportAddress *taddr)
+		       H245_TransportAddress *taddr,
+		       struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -344,7 +361,7 @@ static int expect_t120(struct sk_buff *skb,
 	typeof(nat_t120_hook) nat_t120;
 
 	/* Read T.120 address */
-	if (!get_h245_addr(ct, *data, taddr, &addr, &port) ||
+	if (!get_h245_addr(ct, *data, taddr, &addr, &port, ctstate) ||
 	    memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) ||
 	    port == 0)
 		return 0;
@@ -386,14 +403,15 @@ static int process_h245_channel(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				unsigned int protoff,
 				unsigned char **data, int dataoff,
-				H2250LogicalChannelParameters *channel)
+				H2250LogicalChannelParameters *channel,
+				struct h323_ct_state *ctstate)
 {
 	int ret;
 
 	if (channel->options & eH2250LogicalChannelParameters_mediaChannel) {
 		/* RTP */
 		ret = expect_rtp_rtcp(skb, ct, ctinfo, protoff, data, dataoff,
-				      &channel->mediaChannel);
+				      &channel->mediaChannel, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -402,7 +420,7 @@ static int process_h245_channel(struct sk_buff *skb,
 	    options & eH2250LogicalChannelParameters_mediaControlChannel) {
 		/* RTCP */
 		ret = expect_rtp_rtcp(skb, ct, ctinfo, protoff, data, dataoff,
-				      &channel->mediaControlChannel);
+				      &channel->mediaControlChannel, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -415,7 +433,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
 		       unsigned char **data, int dataoff,
-		       OpenLogicalChannel *olc)
+		       OpenLogicalChannel *olc,
+		       struct h323_ct_state *ctstate)
 {
 	int ret;
 
@@ -429,7 +448,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 					   &olc->
 					   forwardLogicalChannelParameters.
 					   multiplexParameters.
-					   h2250LogicalChannelParameters);
+					   h2250LogicalChannelParameters,
+					   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -448,7 +468,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 					 &olc->
 					 reverseLogicalChannelParameters.
 					 multiplexParameters.
-					 h2250LogicalChannelParameters);
+					 h2250LogicalChannelParameters,
+					 ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -464,7 +485,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 	    eNetworkAccessParameters_networkAddress_localAreaAddress) {
 		ret = expect_t120(skb, ct, ctinfo, protoff, data, dataoff,
 				  &olc->separateStack.networkAddress.
-				  localAreaAddress);
+				  localAreaAddress,
+				  ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -476,7 +498,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned int protoff, unsigned char **data, int dataoff,
-			OpenLogicalChannelAck *olca)
+			OpenLogicalChannelAck *olca,
+			struct h323_ct_state *ctstate)
 {
 	H2250LogicalChannelAckParameters *ack;
 	int ret;
@@ -496,7 +519,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 					   &olca->
 					   reverseLogicalChannelParameters.
 					   multiplexParameters.
-					   h2250LogicalChannelParameters);
+					   h2250LogicalChannelParameters,
+					   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -513,7 +537,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 			/* RTP */
 			ret = expect_rtp_rtcp(skb, ct, ctinfo,
 					      protoff, data, dataoff,
-					      &ack->mediaChannel);
+					      &ack->mediaChannel,
+					      ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -523,7 +548,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 			/* RTCP */
 			ret = expect_rtp_rtcp(skb, ct, ctinfo,
 					      protoff, data, dataoff,
-					      &ack->mediaControlChannel);
+					      &ack->mediaControlChannel,
+					      ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -534,7 +560,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 		eNetworkAccessParameters_networkAddress_localAreaAddress) {
 		ret = expect_t120(skb, ct, ctinfo, protoff, data, dataoff,
 				  &olca->separateStack.networkAddress.
-				  localAreaAddress);
+				  localAreaAddress,
+				  ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -546,7 +573,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned int protoff, unsigned char **data, int dataoff,
-			MultimediaSystemControlMessage *mscm)
+			MultimediaSystemControlMessage *mscm,
+			struct h323_ct_state *ctstate)
 {
 	switch (mscm->choice) {
 	case eMultimediaSystemControlMessage_request:
@@ -554,7 +582,8 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 		    eRequestMessage_openLogicalChannel) {
 			return process_olc(skb, ct, ctinfo,
 					   protoff, data, dataoff,
-					   &mscm->request.openLogicalChannel);
+					   &mscm->request.openLogicalChannel,
+					   ctstate);
 		}
 		pr_debug("nf_ct_h323: H.245 Request %d\n",
 			 mscm->request.choice);
@@ -565,7 +594,8 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			return process_olca(skb, ct, ctinfo,
 					    protoff, data, dataoff,
 					    &mscm->response.
-					    openLogicalChannelAck);
+					    openLogicalChannelAck,
+					    ctstate);
 		}
 		pr_debug("nf_ct_h323: H.245 Response %d\n",
 			 mscm->response.choice);
@@ -587,6 +617,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 	int datalen;
 	int dataoff;
 	int ret;
+	struct h323_ct_state ctstate = {NULL, NULL, 0};
 
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo != IP_CT_ESTABLISHED && ctinfo != IP_CT_ESTABLISHED_REPLY)
@@ -594,11 +625,10 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 
 	pr_debug("nf_ct_h245: skblen = %u\n", skb->len);
 
-	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
-			     &data, &datalen, &dataoff)) {
+			     &data, &datalen, &dataoff, &ctstate)) {
 		pr_debug("nf_ct_h245: TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
@@ -615,15 +645,15 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 
 		/* Process H.245 signal */
 		if (process_h245(skb, ct, ctinfo, protoff,
-				 &data, dataoff, &mscm) < 0)
+				 &data, dataoff, &mscm, &ctstate) < 0)
 			goto drop;
 	}
 
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
 	return NF_ACCEPT;
 
       drop:
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
 	nf_ct_helper_log(skb, ct, "cannot process H.245 message");
 	return NF_DROP;
 }
@@ -647,7 +677,8 @@ static struct nf_conntrack_helper nf_conntrack_helper_h245 __read_mostly = {
 /****************************************************************************/
 int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		  TransportAddress *taddr,
-		  union nf_inet_addr *addr, __be16 *port)
+		  union nf_inet_addr *addr, __be16 *port,
+		  struct h323_ct_state *ctstate)
 {
 	const unsigned char *p;
 	int len;
@@ -669,6 +700,11 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		return 0;
 	}
 
+		/*check pointer overflow */
+	if (p < ctstate->data ||
+	    (p + len + sizeof(__be16)) > ctstate->data + ctstate->buflen)
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -680,7 +716,8 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff, unsigned char **data, int dataoff,
-		       TransportAddress *taddr)
+		       TransportAddress *taddr,
+		       struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -690,7 +727,7 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 	typeof(nat_h245_hook) nat_h245;
 
 	/* Read h245Address */
-	if (!get_h225_addr(ct, *data, taddr, &addr, &port) ||
+	if (!get_h225_addr(ct, *data, taddr, &addr, &port, ctstate) ||
 	    memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) ||
 	    port == 0)
 		return 0;
@@ -801,7 +838,8 @@ static int expect_callforwarding(struct sk_buff *skb,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned int protoff,
 				 unsigned char **data, int dataoff,
-				 TransportAddress *taddr)
+				 TransportAddress *taddr,
+				 struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -812,7 +850,8 @@ static int expect_callforwarding(struct sk_buff *skb,
 	typeof(nat_callforwarding_hook) nat_callforwarding;
 
 	/* Read alternativeAddress */
-	if (!get_h225_addr(ct, *data, taddr, &addr, &port) || port == 0)
+	if (!get_h225_addr(ct, *data, taddr, &addr, &port, ctstate)
+	    || port == 0)
 		return 0;
 
 	/* If the calling party is on the same side of the forward-to party,
@@ -860,7 +899,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned int protoff,
 			 unsigned char **data, int dataoff,
-			 Setup_UUIE *setup)
+			 Setup_UUIE *setup, struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret;
@@ -873,7 +912,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (setup->options & eSetup_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &setup->h245Address);
+				  &setup->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -883,7 +922,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    (set_h225_addr) && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK &&
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
-			  &addr, &port) &&
+			  &addr, &port, ctstate) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
 		pr_debug("nf_ct_q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
@@ -900,7 +939,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    (set_h225_addr) && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK &&
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
-			  &addr, &port) &&
+			  &addr, &port, ctstate) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
 		pr_debug("nf_ct_q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
@@ -917,7 +956,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < setup->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &setup->fastStart.item[i]);
+					  &setup->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -932,7 +972,8 @@ static int process_callproceeding(struct sk_buff *skb,
 				  enum ip_conntrack_info ctinfo,
 				  unsigned int protoff,
 				  unsigned char **data, int dataoff,
-				  CallProceeding_UUIE *callproc)
+				  CallProceeding_UUIE *callproc,
+				  struct h323_ct_state *ctstate)
 {
 	int ret;
 	int i;
@@ -941,7 +982,7 @@ static int process_callproceeding(struct sk_buff *skb,
 
 	if (callproc->options & eCallProceeding_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &callproc->h245Address);
+				  &callproc->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -950,7 +991,8 @@ static int process_callproceeding(struct sk_buff *skb,
 		for (i = 0; i < callproc->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &callproc->fastStart.item[i]);
+					  &callproc->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -964,7 +1006,8 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned int protoff,
 			   unsigned char **data, int dataoff,
-			   Connect_UUIE *connect)
+			   Connect_UUIE *connect,
+			   struct h323_ct_state *ctstate)
 {
 	int ret;
 	int i;
@@ -973,7 +1016,7 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (connect->options & eConnect_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &connect->h245Address);
+				  &connect->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -982,7 +1025,8 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < connect->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &connect->fastStart.item[i]);
+					  &connect->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -996,7 +1040,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
-			    Alerting_UUIE *alert)
+			    Alerting_UUIE *alert, struct h323_ct_state *ctstate)
 {
 	int ret;
 	int i;
@@ -1005,7 +1049,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (alert->options & eAlerting_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &alert->h245Address);
+				  &alert->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1014,7 +1058,8 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < alert->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &alert->fastStart.item[i]);
+					  &alert->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -1028,7 +1073,8 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
-			    Facility_UUIE *facility)
+			    Facility_UUIE *facility,
+			    struct h323_ct_state *ctstate)
 {
 	int ret;
 	int i;
@@ -1040,13 +1086,14 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 			return expect_callforwarding(skb, ct, ctinfo,
 						     protoff, data, dataoff,
 						     &facility->
-						     alternativeAddress);
+						     alternativeAddress,
+						     ctstate);
 		return 0;
 	}
 
 	if (facility->options & eFacility_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &facility->h245Address);
+				  &facility->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1055,7 +1102,8 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < facility->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &facility->fastStart.item[i]);
+					  &facility->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -1069,7 +1117,8 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
-			    Progress_UUIE *progress)
+			    Progress_UUIE *progress,
+			    struct h323_ct_state *ctstate)
 {
 	int ret;
 	int i;
@@ -1078,7 +1127,7 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (progress->options & eProgress_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
-				  &progress->h245Address);
+				  &progress->h245Address, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1087,7 +1136,8 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < progress->fastStart.count; i++) {
 			ret = process_olc(skb, ct, ctinfo,
 					  protoff, data, dataoff,
-					  &progress->fastStart.item[i]);
+					  &progress->fastStart.item[i],
+					  ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -1100,7 +1150,7 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned int protoff, unsigned char **data, int dataoff,
-			Q931 *q931)
+			Q931 *q931, struct h323_ct_state *ctstate)
 {
 	H323_UU_PDU *pdu = &q931->UUIE.h323_uu_pdu;
 	int i;
@@ -1109,29 +1159,35 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 	switch (pdu->h323_message_body.choice) {
 	case eH323_UU_PDU_h323_message_body_setup:
 		ret = process_setup(skb, ct, ctinfo, protoff, data, dataoff,
-				    &pdu->h323_message_body.setup);
+				    &pdu->h323_message_body.setup,
+				    ctstate);
 		break;
 	case eH323_UU_PDU_h323_message_body_callProceeding:
 		ret = process_callproceeding(skb, ct, ctinfo,
 					     protoff, data, dataoff,
 					     &pdu->h323_message_body.
-					     callProceeding);
+					     callProceeding,
+					     ctstate);
 		break;
 	case eH323_UU_PDU_h323_message_body_connect:
 		ret = process_connect(skb, ct, ctinfo, protoff, data, dataoff,
-				      &pdu->h323_message_body.connect);
+				      &pdu->h323_message_body.connect,
+				      ctstate);
 		break;
 	case eH323_UU_PDU_h323_message_body_alerting:
 		ret = process_alerting(skb, ct, ctinfo, protoff, data, dataoff,
-				       &pdu->h323_message_body.alerting);
+				       &pdu->h323_message_body.alerting,
+				       ctstate);
 		break;
 	case eH323_UU_PDU_h323_message_body_facility:
 		ret = process_facility(skb, ct, ctinfo, protoff, data, dataoff,
-				       &pdu->h323_message_body.facility);
+				       &pdu->h323_message_body.facility,
+				       ctstate);
 		break;
 	case eH323_UU_PDU_h323_message_body_progress:
 		ret = process_progress(skb, ct, ctinfo, protoff, data, dataoff,
-				       &pdu->h323_message_body.progress);
+				       &pdu->h323_message_body.progress,
+				       ctstate);
 		break;
 	default:
 		pr_debug("nf_ct_q931: Q.931 signal %d\n",
@@ -1146,7 +1202,8 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 		for (i = 0; i < pdu->h245Control.count; i++) {
 			ret = process_h245(skb, ct, ctinfo,
 					   protoff, data, dataoff,
-					   &pdu->h245Control.item[i]);
+					   &pdu->h245Control.item[i],
+					   ctstate);
 			if (ret < 0)
 				return -1;
 		}
@@ -1164,6 +1221,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 	int datalen;
 	int dataoff;
 	int ret;
+	struct h323_ct_state ctstate = {NULL, NULL, 0};
 
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo != IP_CT_ESTABLISHED && ctinfo != IP_CT_ESTABLISHED_REPLY)
@@ -1171,11 +1229,10 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 
 	pr_debug("nf_ct_q931: skblen = %u\n", skb->len);
 
-	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
-			     &data, &datalen, &dataoff)) {
+			     &data, &datalen, &dataoff, &ctstate)) {
 		pr_debug("nf_ct_q931: TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
@@ -1191,15 +1248,16 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 
 		/* Process Q.931 signal */
 		if (process_q931(skb, ct, ctinfo, protoff,
-				 &data, dataoff, &q931) < 0)
+				 &data, dataoff, &q931, &ctstate) < 0)
 			goto drop;
 	}
 
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
 	return NF_ACCEPT;
 
       drop:
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
+
 	nf_ct_helper_log(skb, ct, "cannot process Q.931 message");
 	return NF_DROP;
 }
@@ -1235,7 +1293,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[] __read_mostly = {
 
 /****************************************************************************/
 static unsigned char *get_udp_data(struct sk_buff *skb, unsigned int protoff,
-				   int *datalen)
+				   int *datalen, struct h323_ct_state *ctstate)
 {
 	const struct udphdr *uh;
 	struct udphdr _uh;
@@ -1248,7 +1306,15 @@ static unsigned char *get_udp_data(struct sk_buff *skb, unsigned int protoff,
 	if (dataoff >= skb->len)
 		return NULL;
 	*datalen = skb->len - dataoff;
-	return skb_header_pointer(skb, dataoff, *datalen, h323_buffer);
+
+	ctstate->buf = kmalloc(*datalen, GFP_ATOMIC);
+	if (!ctstate->buf)
+		return NULL;
+
+	ctstate->buflen = *datalen;
+	ctstate->data = skb_header_pointer(skb, dataoff, *datalen,
+					   ctstate->buf);
+	return ctstate->data;
 }
 
 /****************************************************************************/
@@ -1289,7 +1355,8 @@ static int set_expect_timeout(struct nf_conntrack_expect *exp,
 static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff, unsigned char **data,
-		       TransportAddress *taddr, int count)
+		       TransportAddress *taddr, int count,
+		       struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -1302,7 +1369,8 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Look for the first related address */
 	for (i = 0; i < count; i++) {
-		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port) &&
+		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port,
+				  ctstate) &&
 		    memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3,
 			   sizeof(addr)) == 0 && port != 0)
 			break;
@@ -1326,7 +1394,7 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 	if (nat_q931 && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {	/* Need NAT */
 		ret = nat_q931(skb, ct, ctinfo, protoff, data,
-			       taddr, i, port, exp);
+			       taddr, i, port, exp, ctstate);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
 			pr_debug("nf_ct_ras: expect Q.931 ");
@@ -1347,7 +1415,8 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, GatekeeperRequest *grq)
+		       unsigned char **data, GatekeeperRequest *grq,
+		       struct h323_ct_state *ctstate)
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
@@ -1357,7 +1426,7 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)	/* NATed */
 		return set_ras_addr(skb, ct, ctinfo, protoff, data,
-				    &grq->rasAddress, 1);
+				    &grq->rasAddress, 1, ctstate);
 	return 0;
 }
 
@@ -1365,7 +1434,8 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, GatekeeperConfirm *gcf)
+		       unsigned char **data, GatekeeperConfirm *gcf,
+		       struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -1375,7 +1445,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 
 	pr_debug("nf_ct_ras: GCF\n");
 
-	if (!get_h225_addr(ct, *data, &gcf->rasAddress, &addr, &port))
+	if (!get_h225_addr(ct, *data, &gcf->rasAddress, &addr, &port, ctstate))
 		return 0;
 
 	/* Registration port is the same as discovery port */
@@ -1410,7 +1480,8 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, RegistrationRequest *rrq)
+		       unsigned char **data, RegistrationRequest *rrq,
+		       struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int ret;
@@ -1420,7 +1491,8 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 
 	ret = expect_q931(skb, ct, ctinfo, protoff, data,
 			  rrq->callSignalAddress.item,
-			  rrq->callSignalAddress.count);
+			  rrq->callSignalAddress.count,
+			  ctstate);
 	if (ret < 0)
 		return -1;
 
@@ -1429,7 +1501,8 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	    ct->status & IPS_NAT_MASK) {
 		ret = set_ras_addr(skb, ct, ctinfo, protoff, data,
 				   rrq->rasAddress.item,
-				   rrq->rasAddress.count);
+				   rrq->rasAddress.count,
+				   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1447,7 +1520,8 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, RegistrationConfirm *rcf)
+		       unsigned char **data, RegistrationConfirm *rcf,
+		       struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -1461,8 +1535,9 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
-					rcf->callSignalAddress.item,
-					rcf->callSignalAddress.count);
+				   rcf->callSignalAddress.item,
+				   rcf->callSignalAddress.count,
+				   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1498,7 +1573,8 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, UnregistrationRequest *urq)
+		       unsigned char **data, UnregistrationRequest *urq,
+		       struct h323_ct_state *ctstate)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -1512,7 +1588,8 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
 				   urq->callSignalAddress.item,
-				   urq->callSignalAddress.count);
+				   urq->callSignalAddress.count,
+				   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1532,7 +1609,8 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, AdmissionRequest *arq)
+		       unsigned char **data, AdmissionRequest *arq,
+		       struct h323_ct_state *ctstate)
 {
 	const struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
@@ -1545,7 +1623,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	set_h225_addr = rcu_dereference(set_h225_addr_hook);
 	if ((arq->options & eAdmissionRequest_destCallSignalAddress) &&
 	    get_h225_addr(ct, *data, &arq->destCallSignalAddress,
-			  &addr, &port) &&
+			  &addr, &port, ctstate) &&
 	    !memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) &&
 	    port == info->sig_port[dir] &&
 	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
@@ -1559,7 +1637,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 
 	if ((arq->options & eAdmissionRequest_srcCallSignalAddress) &&
 	    get_h225_addr(ct, *data, &arq->srcCallSignalAddress,
-			  &addr, &port) &&
+			  &addr, &port, ctstate) &&
 	    !memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) &&
 	    set_h225_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
@@ -1577,7 +1655,8 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, AdmissionConfirm *acf)
+		       unsigned char **data, AdmissionConfirm *acf,
+		       struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -1589,7 +1668,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: ACF\n");
 
 	if (!get_h225_addr(ct, *data, &acf->destCallSignalAddress,
-			   &addr, &port))
+			   &addr, &port, ctstate))
 		return 0;
 
 	if (!memcmp(&addr, &ct->tuplehash[dir].tuple.dst.u3, sizeof(addr))) {
@@ -1598,7 +1677,8 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 		if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 		    ct->status & IPS_NAT_MASK)
 			return set_sig_addr(skb, ct, ctinfo, protoff, data,
-					    &acf->destCallSignalAddress, 1);
+					    &acf->destCallSignalAddress, 1,
+					    ctstate);
 		return 0;
 	}
 
@@ -1626,7 +1706,8 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, LocationRequest *lrq)
+		       unsigned char **data, LocationRequest *lrq,
+		       struct h323_ct_state *ctstate)
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
@@ -1636,7 +1717,8 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)
 		return set_ras_addr(skb, ct, ctinfo, protoff, data,
-				    &lrq->replyAddress, 1);
+				    &lrq->replyAddress, 1,
+				    ctstate);
 	return 0;
 }
 
@@ -1644,7 +1726,8 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, LocationConfirm *lcf)
+		       unsigned char **data, LocationConfirm *lcf,
+		       struct h323_ct_state *ctstate)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
@@ -1655,7 +1738,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: LCF\n");
 
 	if (!get_h225_addr(ct, *data, &lcf->callSignalAddress,
-			   &addr, &port))
+			   &addr, &port, ctstate))
 		return 0;
 
 	/* Need new expect for call signal */
@@ -1684,7 +1767,8 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, InfoRequestResponse *irr)
+		       unsigned char **data, InfoRequestResponse *irr,
+		       struct h323_ct_state *ctstate)
 {
 	int ret;
 	typeof(set_ras_addr_hook) set_ras_addr;
@@ -1696,7 +1780,7 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		ret = set_ras_addr(skb, ct, ctinfo, protoff, data,
-				   &irr->rasAddress, 1);
+				   &irr->rasAddress, 1, ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1705,8 +1789,9 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
-					irr->callSignalAddress.item,
-					irr->callSignalAddress.count);
+				   irr->callSignalAddress.item,
+				   irr->callSignalAddress.count,
+				   ctstate);
 		if (ret < 0)
 			return -1;
 	}
@@ -1718,39 +1803,40 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 static int process_ras(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned int protoff,
-		       unsigned char **data, RasMessage *ras)
+		       unsigned char **data, RasMessage *ras,
+		       struct h323_ct_state *ctstate)
 {
 	switch (ras->choice) {
 	case eRasMessage_gatekeeperRequest:
 		return process_grq(skb, ct, ctinfo, protoff, data,
-				   &ras->gatekeeperRequest);
+				   &ras->gatekeeperRequest, ctstate);
 	case eRasMessage_gatekeeperConfirm:
 		return process_gcf(skb, ct, ctinfo, protoff, data,
-				   &ras->gatekeeperConfirm);
+				   &ras->gatekeeperConfirm, ctstate);
 	case eRasMessage_registrationRequest:
 		return process_rrq(skb, ct, ctinfo, protoff, data,
-				   &ras->registrationRequest);
+				   &ras->registrationRequest, ctstate);
 	case eRasMessage_registrationConfirm:
 		return process_rcf(skb, ct, ctinfo, protoff, data,
-				   &ras->registrationConfirm);
+				   &ras->registrationConfirm, ctstate);
 	case eRasMessage_unregistrationRequest:
 		return process_urq(skb, ct, ctinfo, protoff, data,
-				   &ras->unregistrationRequest);
+				   &ras->unregistrationRequest, ctstate);
 	case eRasMessage_admissionRequest:
 		return process_arq(skb, ct, ctinfo, protoff, data,
-				   &ras->admissionRequest);
+				   &ras->admissionRequest, ctstate);
 	case eRasMessage_admissionConfirm:
 		return process_acf(skb, ct, ctinfo, protoff, data,
-				   &ras->admissionConfirm);
+				   &ras->admissionConfirm, ctstate);
 	case eRasMessage_locationRequest:
 		return process_lrq(skb, ct, ctinfo, protoff, data,
-				   &ras->locationRequest);
+				   &ras->locationRequest, ctstate);
 	case eRasMessage_locationConfirm:
 		return process_lcf(skb, ct, ctinfo, protoff, data,
-				   &ras->locationConfirm);
+				   &ras->locationConfirm, ctstate);
 	case eRasMessage_infoRequestResponse:
 		return process_irr(skb, ct, ctinfo, protoff, data,
-				   &ras->infoRequestResponse);
+				   &ras->infoRequestResponse, ctstate);
 	default:
 		pr_debug("nf_ct_ras: RAS message %d\n", ras->choice);
 		break;
@@ -1767,13 +1853,13 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	unsigned char *data;
 	int datalen = 0;
 	int ret;
+	struct h323_ct_state ctstate = {NULL, NULL, 0};
 
 	pr_debug("nf_ct_ras: skblen = %u\n", skb->len);
 
-	spin_lock_bh(&nf_h323_lock);
 
 	/* Get UDP data */
-	data = get_udp_data(skb, protoff, &datalen);
+	data = get_udp_data(skb, protoff, &datalen, &ctstate);
 	if (data == NULL)
 		goto accept;
 	pr_debug("nf_ct_ras: RAS message len=%d ", datalen);
@@ -1789,15 +1875,16 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	}
 
 	/* Process RAS message */
-	if (process_ras(skb, ct, ctinfo, protoff, &data, &ras) < 0)
+	if (process_ras(skb, ct, ctinfo, protoff, &data, &ras,
+			&ctstate) < 0)
 		goto drop;
 
       accept:
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
 	return NF_ACCEPT;
 
       drop:
-	spin_unlock_bh(&nf_h323_lock);
+	kfree(ctstate.buf);
 	nf_ct_helper_log(skb, ct, "cannot process RAS message");
 	return NF_DROP;
 }
@@ -1839,7 +1926,6 @@ static void __exit nf_conntrack_h323_fini(void)
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[1]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
-	kfree(h323_buffer);
 	pr_debug("nf_ct_h323: fini\n");
 }
 
@@ -1848,9 +1934,6 @@ static int __init nf_conntrack_h323_init(void)
 {
 	int ret;
 
-	h323_buffer = kmalloc(65536, GFP_KERNEL);
-	if (!h323_buffer)
-		return -ENOMEM;
 	ret = nf_conntrack_helper_register(&nf_conntrack_helper_h245);
 	if (ret < 0)
 		goto err1;
@@ -1878,7 +1961,6 @@ err3:
 err2:
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
 err1:
-	kfree(h323_buffer);
 	return ret;
 }
 
-- 
2.5.0


