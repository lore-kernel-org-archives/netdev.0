From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/3] [LLC]: skb allocation size for responses
Date: Sat, 29 Mar 2008 15:06:55 +0900
Message-ID: <20080329060655.GA15023@tp64>
References: <1206691159-10872-1-git-send-email-joonwpark81@gmail.com> <20080328131202.GP14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:11766 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbYC2GHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 02:07:02 -0400
Received: by rv-out-0910.google.com with SMTP id k20so328507rvb.1
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 23:07:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080328131202.GP14945@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 10:12:02AM -0300, Arnaldo Carvalho de Melo wrote:
> 
> > +static int llc_mac_header_len(unsigned short devtype)
> > +{
> > +	switch (devtype) {
> > +	case ARPHRD_ETHER:
> > +	case ARPHRD_LOOPBACK:
> > +		return sizeof(struct ethhdr);
> > +	}
> > +
> > +	return __llc_tr_mac_header_len(devtype);
> > +}
> 
> Nah, just drop __llc_tr_mac_header_len altogether and have another case
> entry for ARPHDR_IEEE802_TR.
> 
> >  /**
> >   *	llc_alloc_frame - allocates sk_buff for frame
> >   *	@dev: network device this skb will be sent over
> > + *	@type: pdu type to allocate
> > + *	@data_size: data size to allocate
> >   *
> >   *	Allocates an sk_buff for frame and initializes sk_buff fields.
> >   *	Returns allocated skb or %NULL when out of memory.
> >   */
> > -struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev)
> > +struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
> > +				u8 type, u32 data_size)
> >  {
> > -	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
> > +	int hlen = type == LLC_PDU_TYPE_U ? 3 : 4;
> > +	struct sk_buff *skb;
> > +
> > +	hlen += llc_mac_header_len(dev->type);
> > +	skb = alloc_skb(hlen + data_size, GFP_ATOMIC);
> >  
> >  	if (skb) {
> >  		skb_reset_mac_header(skb);
> > -		skb_reserve(skb, 50);
> > +		skb_reserve(skb, hlen);
> 
> Well done, now it is better documented (LLC_PDU_TYPE_U passed) and uses
> less memory, no more magic numbers, good.
> 
> - Arnaldo


I've respined the patch, thanks Arnaldo.

---
[LLC]: skb allocation size for responses

Allocate the skb for llc responses with the received packet size by
using the size adjustable llc_frame_alloc.
Don't allocate useless extra payload.
Cleanup magic numbers.

So, this fixes oops.
Reported by Jim Westfall:
kernel: skb_over_panic: text:c0541fc7 len:1000 put:997 head:c166ac00 data:c166ac2f tail:0xc166b017 end:0xc166ac80 dev:eth0
kernel: ------------[ cut here ]------------
kernel: kernel BUG at net/core/skbuff.c:95!

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/net/llc_pdu.h |    4 ++--
 include/net/llc_sap.h |    7 +++++--
 net/llc/llc_c_ac.c    |   47 +++++++++++++++++++++++++----------------------
 net/llc/llc_pdu.c     |    2 +-
 net/llc/llc_s_ac.c    |    9 +++++++--
 net/llc/llc_sap.c     |   27 ++++++++++++++++++++++++---
 net/llc/llc_station.c |   13 ++++++++++---
 7 files changed, 74 insertions(+), 35 deletions(-)

diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index 4a8f58b..75b8e29 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -381,7 +381,7 @@ static inline void llc_pdu_init_as_xid_cmd(struct sk_buff *skb,
 	xid_info->fmt_id = LLC_XID_FMT_ID;	/* 0x81 */
 	xid_info->type	 = svcs_supported;
 	xid_info->rw	 = rx_window << 1;	/* size of receive window */
-	skb_put(skb, 3);
+	skb_put(skb, sizeof(struct llc_xid_info));
 }
 
 /**
@@ -406,7 +406,7 @@ static inline void llc_pdu_init_as_xid_rsp(struct sk_buff *skb,
 	xid_info->fmt_id = LLC_XID_FMT_ID;
 	xid_info->type	 = svcs_supported;
 	xid_info->rw	 = rx_window << 1;
-	skb_put(skb, 3);
+	skb_put(skb, sizeof(struct llc_xid_info));
 }
 
 /* LLC Type 2 FRMR response information field format */
diff --git a/include/net/llc_sap.h b/include/net/llc_sap.h
index 2c56dbe..ed25bec 100644
--- a/include/net/llc_sap.h
+++ b/include/net/llc_sap.h
@@ -1,5 +1,8 @@
 #ifndef LLC_SAP_H
 #define LLC_SAP_H
+
+#include <asm/types.h>
+
 /*
  * Copyright (c) 1997 by Procom Technology,Inc.
  * 		 2001-2003 by Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -19,8 +22,8 @@ struct sock;
 extern void llc_sap_rtn_pdu(struct llc_sap *sap, struct sk_buff *skb);
 extern void llc_save_primitive(struct sock *sk, struct sk_buff* skb,
 			       unsigned char prim);
-extern struct sk_buff *llc_alloc_frame(struct sock *sk,
-				       struct net_device *dev);
+extern struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
+				       u8 type, u32 data_size);
 
 extern void llc_build_and_send_test_pkt(struct llc_sap *sap,
 				        struct sk_buff *skb,
diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index 860140c..71a0022 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -198,7 +198,7 @@ int llc_conn_ac_send_disc_cmd_p_set_x(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -223,7 +223,7 @@ int llc_conn_ac_send_dm_rsp_f_set_p(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -249,7 +249,7 @@ int llc_conn_ac_send_dm_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -282,7 +282,8 @@ int llc_conn_ac_send_frmr_rsp_f_set_x(struct sock *sk, struct sk_buff *skb)
 		llc_pdu_decode_pf_bit(skb, &f_bit);
 	else
 		f_bit = 0;
-	nskb = llc_alloc_frame(sk, llc->dev);
+	nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U,
+			       sizeof(struct llc_frmr_info));
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
 
@@ -306,7 +307,8 @@ int llc_conn_ac_resend_frmr_rsp_f_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U,
+					       sizeof(struct llc_frmr_info));
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -336,7 +338,8 @@ int llc_conn_ac_resend_frmr_rsp_f_set_p(struct sock *sk, struct sk_buff *skb)
 	struct llc_sock *llc = llc_sk(sk);
 
 	llc_pdu_decode_pf_bit(skb, &f_bit);
-	nskb = llc_alloc_frame(sk, llc->dev);
+	nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U,
+			       sizeof(struct llc_frmr_info));
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
 		struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
@@ -424,7 +427,7 @@ int llc_conn_ac_resend_i_xxx_x_set_0_or_send_rr(struct sock *sk,
 	struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -459,7 +462,7 @@ int llc_conn_ac_send_rej_cmd_p_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -483,7 +486,7 @@ int llc_conn_ac_send_rej_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -507,7 +510,7 @@ int llc_conn_ac_send_rej_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -531,7 +534,7 @@ int llc_conn_ac_send_rnr_cmd_p_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -555,7 +558,7 @@ int llc_conn_ac_send_rnr_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -579,7 +582,7 @@ int llc_conn_ac_send_rnr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -615,7 +618,7 @@ int llc_conn_ac_opt_send_rnr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -639,7 +642,7 @@ int llc_conn_ac_send_rr_cmd_p_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -663,7 +666,7 @@ int llc_conn_ac_send_rr_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -688,7 +691,7 @@ int llc_conn_ac_send_ack_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -712,7 +715,7 @@ int llc_conn_ac_send_rr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -736,7 +739,7 @@ int llc_conn_ac_send_ack_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -770,7 +773,7 @@ int llc_conn_ac_send_sabme_cmd_p_set_x(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -799,7 +802,7 @@ int llc_conn_ac_send_ua_rsp_f_set_p(struct sock *sk, struct sk_buff *skb)
 	u8 f_bit;
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_U, 0);
 
 	llc_pdu_decode_pf_bit(skb, &f_bit);
 	if (nskb) {
@@ -956,7 +959,7 @@ static int llc_conn_ac_send_rr_rsp_f_set_ackpf(struct sock *sk,
 {
 	int rc = -ENOBUFS;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
+	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, LLC_PDU_TYPE_S, 0);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
diff --git a/net/llc/llc_pdu.c b/net/llc/llc_pdu.c
index fa83243..2e6cb79 100644
--- a/net/llc/llc_pdu.c
+++ b/net/llc/llc_pdu.c
@@ -241,7 +241,7 @@ void llc_pdu_init_as_frmr_rsp(struct sk_buff *skb, struct llc_pdu_sn *prev_pdu,
 	FRMR_INFO_SET_PDU_INFO_2LONG_IND(frmr_info, vzyxw);
 	FRMR_INFO_SET_PDU_INVALID_Nr_IND(frmr_info, vzyxw);
 	FRMR_INFO_SET_PDU_INVALID_Ns_IND(frmr_info, vzyxw);
-	skb_put(skb, 5);
+	skb_put(skb, sizeof(struct llc_frmr_info));
 }
 
 /**
diff --git a/net/llc/llc_s_ac.c b/net/llc/llc_s_ac.c
index ac3d93b..a94bd56 100644
--- a/net/llc/llc_s_ac.c
+++ b/net/llc/llc_s_ac.c
@@ -103,7 +103,8 @@ int llc_sap_action_send_xid_r(struct llc_sap *sap, struct sk_buff *skb)
 	llc_pdu_decode_sa(skb, mac_da);
 	llc_pdu_decode_da(skb, mac_sa);
 	llc_pdu_decode_ssap(skb, &dsap);
-	nskb = llc_alloc_frame(NULL, skb->dev);
+	nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U,
+			       sizeof(struct llc_xid_info));
 	if (!nskb)
 		goto out;
 	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
@@ -144,11 +145,15 @@ int llc_sap_action_send_test_r(struct llc_sap *sap, struct sk_buff *skb)
 	u8 mac_da[ETH_ALEN], mac_sa[ETH_ALEN], dsap;
 	struct sk_buff *nskb;
 	int rc = 1;
+	u32 data_size;
 
 	llc_pdu_decode_sa(skb, mac_da);
 	llc_pdu_decode_da(skb, mac_sa);
 	llc_pdu_decode_ssap(skb, &dsap);
-	nskb = llc_alloc_frame(NULL, skb->dev);
+
+	/* The test request command is type U (llc_len = 3) */
+	data_size = ntohs(eth_hdr(skb)->h_proto) - 3;
+	nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U, data_size);
 	if (!nskb)
 		goto out;
 	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 2525165..65799b1 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -24,20 +24,41 @@
 #include <net/tcp_states.h>
 #include <linux/llc.h>
 
+static int llc_mac_header_len(unsigned short devtype)
+{
+	switch (devtype) {
+	case ARPHRD_ETHER:
+	case ARPHRD_LOOPBACK:
+		return sizeof(struct ethhdr);
+#ifdef CONFIG_TR
+	case ARPHDR_IEEE802_TR:
+		return sizeof(struct thr_hdr);
+#endif
+	}
+	return 0;
+}
+
 /**
  *	llc_alloc_frame - allocates sk_buff for frame
  *	@dev: network device this skb will be sent over
+ *	@type: pdu type to allocate
+ *	@data_size: data size to allocate
  *
  *	Allocates an sk_buff for frame and initializes sk_buff fields.
  *	Returns allocated skb or %NULL when out of memory.
  */
-struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev)
+struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
+				u8 type, u32 data_size)
 {
-	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
+	int hlen = type == LLC_PDU_TYPE_U ? 3 : 4;
+	struct sk_buff *skb;
+
+	hlen += llc_mac_header_len(dev->type);
+	skb = alloc_skb(hlen + data_size, GFP_ATOMIC);
 
 	if (skb) {
 		skb_reset_mac_header(skb);
-		skb_reserve(skb, 50);
+		skb_reserve(skb, hlen);
 		skb_reset_network_header(skb);
 		skb_reset_transport_header(skb);
 		skb->protocol = htons(ETH_P_802_2);
diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 959e7f3..83da133 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -253,7 +253,8 @@ static int llc_station_ac_inc_xid_r_cnt_by_1(struct sk_buff *skb)
 static int llc_station_ac_send_null_dsap_xid_c(struct sk_buff *skb)
 {
 	int rc = 1;
-	struct sk_buff *nskb = llc_alloc_frame(NULL, skb->dev);
+	struct sk_buff *nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U,
+					       sizeof(struct llc_xid_info));
 
 	if (!nskb)
 		goto out;
@@ -274,7 +275,8 @@ static int llc_station_ac_send_xid_r(struct sk_buff *skb)
 {
 	u8 mac_da[ETH_ALEN], dsap;
 	int rc = 1;
-	struct sk_buff* nskb = llc_alloc_frame(NULL, skb->dev);
+	struct sk_buff *nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U,
+					       sizeof(struct llc_xid_info));
 
 	if (!nskb)
 		goto out;
@@ -298,7 +300,12 @@ static int llc_station_ac_send_test_r(struct sk_buff *skb)
 {
 	u8 mac_da[ETH_ALEN], dsap;
 	int rc = 1;
-	struct sk_buff *nskb = llc_alloc_frame(NULL, skb->dev);
+	u32 data_size;
+	struct sk_buff *nskb;
+
+	/* The test request command is type U (llc_len = 3) */
+	data_size = ntohs(eth_hdr(skb)->h_proto) - 3;
+	nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U, data_size);
 
 	if (!nskb)
 		goto out;
-- 
1.5.4.3
---


