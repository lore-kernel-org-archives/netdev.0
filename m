From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net/atm/: endian annotations
Date: Sat, 20 May 2006 04:46:47 +0400
Message-ID: <20060520004647.GA24082@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:44533 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751453AbWETAsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 20:48:23 -0400
Received: by nf-out-0910.google.com with SMTP id i2so529454nfe
        for <netdev@vger.kernel.org>; Fri, 19 May 2006 17:48:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/atmbr2684.h |    4 ++--
 include/linux/atmmpc.h    |    8 ++++----
 net/atm/br2684.c          |    2 +-
 net/atm/clip.c            |    4 ++--
 net/atm/lec.c             |    2 +-
 net/atm/mpc.c             |   20 ++++++++++----------
 net/atm/mpc.h             |    6 +++---
 net/atm/mpoa_caches.c     |   12 ++++++------
 net/atm/mpoa_caches.h     |   14 +++++++-------
 net/atm/mpoa_proc.c       |    6 +++---
 10 files changed, 39 insertions(+), 39 deletions(-)

--- a/include/linux/atmbr2684.h
+++ b/include/linux/atmbr2684.h
@@ -86,8 +86,8 @@ struct atm_backend_br2684 {
  * efficient per-if in/out filters, this support will be removed
  */
 struct br2684_filter {
-	__u32	prefix;		/* network byte order */
-	__u32	netmask;	/* 0 = disable filter */
+	__be32	prefix;
+	__be32	netmask;	/* 0 = disable filter */
 };
 
 struct br2684_filter_set {
--- a/include/linux/atmmpc.h
+++ b/include/linux/atmmpc.h
@@ -13,7 +13,7 @@
 
 struct atmmpc_ioc {
         int dev_num;
-        uint32_t ipaddr;              /* the IP address of the shortcut    */
+        __be32 ipaddr;                /* the IP address of the shortcut    */
         int type;                     /* ingress or egress                 */
 };
 
@@ -22,7 +22,7 @@ typedef struct in_ctrl_info {
         uint8_t   Last_Q2931_cause_value;     
         uint8_t   eg_MPC_ATM_addr[ATM_ESA_LEN];
         uint32_t  tag;
-        uint32_t  in_dst_ip;      /* IP address this ingress MPC sends packets to */
+        __be32    in_dst_ip;      /* IP address this ingress MPC sends packets to */
         uint16_t  holding_time;
         uint32_t  request_id;
 } in_ctrl_info;
@@ -30,7 +30,7 @@ typedef struct in_ctrl_info {
 typedef struct eg_ctrl_info {
         uint8_t   DLL_header[256];
         uint8_t   DH_length;
-        uint32_t  cache_id;
+        __be32    cache_id;
         uint32_t  tag;
         uint32_t  mps_ip;
         uint32_t  eg_dst_ip;      /* IP address to which ingress MPC sends packets */
@@ -49,7 +49,7 @@ struct mpc_parameters {
 
 struct k_message {
         uint16_t type;
-        uint32_t ip_mask;
+        __be32 ip_mask;
         uint8_t  MPS_ctrl[ATM_ESA_LEN];
         union {
                 in_ctrl_info in_info;
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -373,7 +373,7 @@ static int br2684_setfilt(struct atm_vcc
 
 /* Returns 1 if packet should be dropped */
 static inline int
-packet_fails_filter(u16 type, struct br2684_vcc *brvcc, struct sk_buff *skb)
+packet_fails_filter(__be16 type, struct br2684_vcc *brvcc, struct sk_buff *skb)
 {
 	if (brvcc->filter.netmask == 0)
 		return 0;			/* no filter in place */
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -220,7 +220,7 @@ static void clip_push(struct atm_vcc *vc
 	    || memcmp(skb->data, llc_oui, sizeof (llc_oui)))
 		skb->protocol = htons(ETH_P_IP);
 	else {
-		skb->protocol = ((u16 *) skb->data)[3];
+		skb->protocol = ((__be16 *) skb->data)[3];
 		skb_pull(skb, RFC1483LLC_LEN);
 		if (skb->protocol == htons(ETH_P_ARP)) {
 			PRIV(skb->dev)->stats.rx_packets++;
@@ -430,7 +430,7 @@ static int clip_start_xmit(struct sk_buf
 
 		here = skb_push(skb, RFC1483LLC_LEN);
 		memcpy(here, llc_oui, sizeof(llc_oui));
-		((u16 *) here)[3] = skb->protocol;
+		((__be16 *) here)[3] = skb->protocol;
 	}
 	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -743,7 +743,7 @@ lec_push(struct atm_vcc *vcc, struct sk_
                 unsigned char *src, *dst;
 
                 atm_return(vcc,skb->truesize);
-                if (*(uint16_t *)skb->data == htons(priv->lecid) ||
+                if (*(__be16 *)skb->data == htons(priv->lecid) ||
                     !priv->lecd ||
                     !(dev->flags & IFF_UP)) { 
                         /* Probably looping back, or if lecd is missing,
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -158,7 +158,7 @@ static struct mpoa_client *find_mpc_by_l
 /*
  * Overwrites the old entry or makes a new one.
  */
-struct atm_mpoa_qos *atm_mpoa_add_qos(uint32_t dst_ip, struct atm_qos *qos)
+struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 {
 	struct atm_mpoa_qos *entry;
 
@@ -183,7 +183,7 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(ui
 	return entry;
 }
 
-struct atm_mpoa_qos *atm_mpoa_search_qos(uint32_t dst_ip)
+struct atm_mpoa_qos *atm_mpoa_search_qos(__be32 dst_ip)
 {
 	struct atm_mpoa_qos *qos;
 
@@ -472,7 +472,7 @@ static int send_via_shortcut(struct sk_b
 	in_cache_entry *entry;
 	struct iphdr *iph;
 	char *buff;
-	uint32_t ipaddr = 0;
+	__be32 ipaddr = 0;
 
 	static struct {
 		struct llc_snap_hdr hdr;
@@ -571,7 +571,7 @@ static int atm_mpoa_vcc_attach(struct at
 	struct mpoa_client *mpc;
 	struct atmmpc_ioc ioc_data;
 	in_cache_entry *in_entry;
-	uint32_t  ipaddr;
+	__be32  ipaddr;
 	unsigned char *ip;
 
 	bytes_left = copy_from_user(&ioc_data, arg, sizeof(struct atmmpc_ioc));
@@ -1045,7 +1045,7 @@ static int mpoa_event_listener(struct no
 
 static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 {
-	uint32_t dst_ip = msg->content.in_info.in_dst_ip;
+	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	in_cache_entry *entry;
 
 	entry = mpc->in_ops->get(dst_ip, mpc);
@@ -1082,7 +1082,7 @@ static void MPOA_trigger_rcvd(struct k_m
  */
 static void check_qos_and_open_shortcut(struct k_message *msg, struct mpoa_client *client, in_cache_entry *entry)
 {
-	uint32_t dst_ip = msg->content.in_info.in_dst_ip;
+	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	unsigned char *ip __attribute__ ((unused)) = (unsigned char *)&dst_ip;
 	struct atm_mpoa_qos *qos = atm_mpoa_search_qos(dst_ip);
 	eg_cache_entry *eg_entry = client->eg_ops->get_by_src_ip(dst_ip, client);
@@ -1121,7 +1121,7 @@ static void MPOA_res_reply_rcvd(struct k
 {
 	unsigned char *ip;
 
-	uint32_t dst_ip = msg->content.in_info.in_dst_ip;
+	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	in_cache_entry *entry = mpc->in_ops->get(dst_ip, mpc);
 	ip = (unsigned char *)&dst_ip;
 	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %u.%u.%u.%u\n", mpc->dev->name, NIPQUAD(ip));
@@ -1167,8 +1167,8 @@ static void MPOA_res_reply_rcvd(struct k
 
 static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 {
-	uint32_t dst_ip = msg->content.in_info.in_dst_ip;
-	uint32_t mask = msg->ip_mask;
+	__be32 dst_ip = msg->content.in_info.in_dst_ip;
+	__be32 mask = msg->ip_mask;
 	unsigned char *ip = (unsigned char *)&dst_ip;
 	in_cache_entry *entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
 
@@ -1193,7 +1193,7 @@ static void ingress_purge_rcvd(struct k_
 
 static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 {
-	uint32_t cache_id = msg->content.eg_info.cache_id;
+	__be32 cache_id = msg->content.eg_info.cache_id;
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(cache_id, mpc);
 	
 	if (entry == NULL) {
--- a/net/atm/mpc.h
+++ b/net/atm/mpc.h
@@ -36,14 +36,14 @@ struct mpoa_client {
 
 struct atm_mpoa_qos {
         struct atm_mpoa_qos *next;
-        uint32_t ipaddr;
+        __be32 ipaddr;
         struct atm_qos qos;
 };
 
 
 /* MPOA QoS operations */
-struct atm_mpoa_qos *atm_mpoa_add_qos(uint32_t dst_ip, struct atm_qos *qos);
-struct atm_mpoa_qos *atm_mpoa_search_qos(uint32_t dst_ip);
+struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos);
+struct atm_mpoa_qos *atm_mpoa_search_qos(__be32 dst_ip);
 int atm_mpoa_delete_qos(struct atm_mpoa_qos *qos);
 
 /* Display QoS entries. This is for the procfs */
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -22,7 +22,7 @@
 #define ddprintk(format,args...)
 #endif
 
-static in_cache_entry *in_cache_get(uint32_t dst_ip,
+static in_cache_entry *in_cache_get(__be32 dst_ip,
 				    struct mpoa_client *client)
 {
 	in_cache_entry *entry;
@@ -42,9 +42,9 @@ static in_cache_entry *in_cache_get(uint
 	return NULL;
 }
 
-static in_cache_entry *in_cache_get_with_mask(uint32_t dst_ip,
+static in_cache_entry *in_cache_get_with_mask(__be32 dst_ip,
 					      struct mpoa_client *client,
-					      uint32_t mask)
+					      __be32 mask)
 {
 	in_cache_entry *entry;
 
@@ -84,7 +84,7 @@ static in_cache_entry *in_cache_get_by_v
 	return NULL;
 }
 
-static in_cache_entry *in_cache_add_entry(uint32_t dst_ip,
+static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 					  struct mpoa_client *client)
 {
 	unsigned char *ip __attribute__ ((unused)) = (unsigned char *)&dst_ip;
@@ -327,7 +327,7 @@ static void in_destroy_cache(struct mpoa
 	return;
 }
 
-static eg_cache_entry *eg_cache_get_by_cache_id(uint32_t cache_id, struct mpoa_client *mpc)
+static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id, struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
@@ -388,7 +388,7 @@ static eg_cache_entry *eg_cache_get_by_v
 	return NULL;
 }
 
-static eg_cache_entry *eg_cache_get_by_src_ip(uint32_t ipaddr, struct mpoa_client *mpc)
+static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr, struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
--- a/net/atm/mpoa_caches.h
+++ b/net/atm/mpoa_caches.h
@@ -29,12 +29,12 @@ typedef struct in_cache_entry {
 } in_cache_entry;
 
 struct in_cache_ops{
-        in_cache_entry *(*add_entry)(uint32_t dst_ip,
+        in_cache_entry *(*add_entry)(__be32 dst_ip,
                                       struct mpoa_client *client);
-        in_cache_entry *(*get)(uint32_t dst_ip, struct mpoa_client *client);
-        in_cache_entry *(*get_with_mask)(uint32_t dst_ip, 
+        in_cache_entry *(*get)(__be32 dst_ip, struct mpoa_client *client);
+        in_cache_entry *(*get_with_mask)(__be32 dst_ip, 
 					 struct mpoa_client *client,
-					 uint32_t mask);
+					 __be32 mask);
         in_cache_entry *(*get_by_vcc)(struct atm_vcc *vcc, 
                                       struct mpoa_client *client);
         void            (*put)(in_cache_entry *entry);
@@ -56,17 +56,17 @@ typedef struct eg_cache_entry{
         struct atm_vcc       *shortcut;
         uint32_t             packets_rcvd;
         uint16_t             entry_state;
-        uint32_t             latest_ip_addr;    /* The src IP address of the last packet */
+        __be32               latest_ip_addr;    /* The src IP address of the last packet */
         struct eg_ctrl_info  ctrl_info;
         atomic_t             use;
 } eg_cache_entry;
 
 struct eg_cache_ops{
         eg_cache_entry *(*add_entry)(struct k_message *msg, struct mpoa_client *client);
-        eg_cache_entry *(*get_by_cache_id)(uint32_t cache_id, struct mpoa_client *client);
+        eg_cache_entry *(*get_by_cache_id)(__be32 cache_id, struct mpoa_client *client);
         eg_cache_entry *(*get_by_tag)(uint32_t cache_id, struct mpoa_client *client);
         eg_cache_entry *(*get_by_vcc)(struct atm_vcc *vcc, struct mpoa_client *client);
-        eg_cache_entry *(*get_by_src_ip)(uint32_t ipaddr, struct mpoa_client *client);
+        eg_cache_entry *(*get_by_src_ip)(__be32 ipaddr, struct mpoa_client *client);
         void            (*put)(eg_cache_entry *entry);
         void            (*remove_entry)(eg_cache_entry *entry, struct mpoa_client *client);
         void            (*update)(eg_cache_entry *entry, uint16_t holding_time);
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -232,14 +232,14 @@ static int parse_qos(const char *buff)
          */
         unsigned char ip[4]; 
 	int tx_pcr, tx_sdu, rx_pcr, rx_sdu;
-        uint32_t ipaddr;
+        __be32 ipaddr;
 	struct atm_qos qos; 
         
         memset(&qos, 0, sizeof(struct atm_qos));
 
 	if (sscanf(buff, "del %hhu.%hhu.%hhu.%hhu",
 			ip, ip+1, ip+2, ip+3) == 4) {
-		ipaddr = *(uint32_t *)ip;
+		ipaddr = *(__be32 *)ip;
 		return atm_mpoa_delete_qos(atm_mpoa_search_qos(ipaddr));
 	}
 
@@ -251,7 +251,7 @@ static int parse_qos(const char *buff)
 		ip, ip+1, ip+2, ip+3, &tx_pcr, &tx_sdu, &rx_pcr, &rx_sdu) != 8)
 		return 0;
 
-        ipaddr = *(uint32_t *)ip;
+        ipaddr = *(__be32 *)ip;
 	qos.txtp.traffic_class = ATM_CBR;
 	qos.txtp.max_pcr = tx_pcr;
 	qos.txtp.max_sdu = tx_sdu;

