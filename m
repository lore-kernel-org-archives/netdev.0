From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 08/14] fou: Support IPv6 in fou
Date: Mon, 16 May 2016 14:33:03 -0700
Message-ID: <1463434389-314297-9-git-send-email-tom@herbertland.com>
References: <1463434389-314297-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48530 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751712AbcEPVdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 17:33:33 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4GLSV8r013103
	for <netdev@vger.kernel.org>; Mon, 16 May 2016 14:33:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22wypaw1cc-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 16 May 2016 14:33:32 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 d4febdd61bad11e6b3ae0002c992ebde-8f5f6c50 for <netdev@vger.kernel.org>;	Mon,
 16 May 2016 14:33:30 -0700
In-Reply-To: <1463434389-314297-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds receive path support for IPv6 with fou.

- Add address family to fou structure for open sockets. This supports
  AF_INET and AF_INET6. Lookups for fou ports are performed on both the
  port number and family.
- In fou and gue receive adjust tot_len in IPv4 header or payload_len
  based on address family.
- Allow AF_INET6 in FOU_ATTR_AF netlink attribute.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 47 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 35 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index f4f2ddd..5f9207c 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -21,6 +21,7 @@ struct fou {
 	u8 protocol;
 	u8 flags;
 	__be16 port;
+	u8 family;
 	u16 type;
 	struct list_head list;
 	struct rcu_head rcu;
@@ -47,14 +48,17 @@ static inline struct fou *fou_from_sock(struct sock *sk)
 	return sk->sk_user_data;
 }
 
-static int fou_recv_pull(struct sk_buff *skb, size_t len)
+static int fou_recv_pull(struct sk_buff *skb, struct fou *fou, size_t len)
 {
-	struct iphdr *iph = ip_hdr(skb);
-
 	/* Remove 'len' bytes from the packet (UDP header and
 	 * FOU header if present).
 	 */
-	iph->tot_len = htons(ntohs(iph->tot_len) - len);
+	if (fou->family == AF_INET)
+		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(skb)->tot_len) - len);
+	else
+		ipv6_hdr(skb)->payload_len =
+		    htons(ntohs(ipv6_hdr(skb)->payload_len) - len);
+
 	__skb_pull(skb, len);
 	skb_postpull_rcsum(skb, udp_hdr(skb), len);
 	skb_reset_transport_header(skb);
@@ -68,7 +72,7 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (!fou)
 		return 1;
 
-	if (fou_recv_pull(skb, sizeof(struct udphdr)))
+	if (fou_recv_pull(skb, fou, sizeof(struct udphdr)))
 		goto drop;
 
 	return -fou->protocol;
@@ -141,7 +145,11 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 
 	hdrlen = sizeof(struct guehdr) + optlen;
 
-	ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(skb)->tot_len) - len);
+	if (fou->family == AF_INET)
+		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(skb)->tot_len) - len);
+	else
+		ipv6_hdr(skb)->payload_len =
+		    htons(ntohs(ipv6_hdr(skb)->payload_len) - len);
 
 	/* Pull csum through the guehdr now . This can be used if
 	 * there is a remote checksum offload.
@@ -426,7 +434,8 @@ static int fou_add_to_port_list(struct net *net, struct fou *fou)
 
 	mutex_lock(&fn->fou_lock);
 	list_for_each_entry(fout, &fn->fou_list, list) {
-		if (fou->port == fout->port) {
+		if (fou->port == fout->port &&
+		    fou->family == fout->family) {
 			mutex_unlock(&fn->fou_lock);
 			return -EALREADY;
 		}
@@ -471,8 +480,9 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk = sock->sk;
 
-	fou->flags = cfg->flags;
 	fou->port = cfg->udp_config.local_udp_port;
+	fou->family = cfg->udp_config.family;
+	fou->flags = cfg->flags;
 	fou->type = cfg->type;
 	fou->sock = sock;
 
@@ -524,12 +534,13 @@ static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 {
 	struct fou_net *fn = net_generic(net, fou_net_id);
 	__be16 port = cfg->udp_config.local_udp_port;
+	u8 family = cfg->udp_config.family;
 	int err = -EINVAL;
 	struct fou *fou;
 
 	mutex_lock(&fn->fou_lock);
 	list_for_each_entry(fou, &fn->fou_list, list) {
-		if (fou->port == port) {
+		if (fou->port == port && fou->family == family) {
 			fou_release(fou);
 			err = 0;
 			break;
@@ -567,8 +578,15 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[FOU_ATTR_AF]) {
 		u8 family = nla_get_u8(info->attrs[FOU_ATTR_AF]);
 
-		if (family != AF_INET)
-			return -EINVAL;
+		switch (family) {
+		case AF_INET:
+			break;
+		case AF_INET6:
+			cfg->udp_config.ipv6_v6only = 1;
+			break;
+		default:
+			return -EAFNOSUPPORT;
+		}
 
 		cfg->udp_config.family = family;
 	}
@@ -659,6 +677,7 @@ static int fou_nl_cmd_get_port(struct sk_buff *skb, struct genl_info *info)
 	struct fou_cfg cfg;
 	struct fou *fout;
 	__be16 port;
+	u8 family;
 	int ret;
 
 	ret = parse_nl_config(info, &cfg);
@@ -668,6 +687,10 @@ static int fou_nl_cmd_get_port(struct sk_buff *skb, struct genl_info *info)
 	if (port == 0)
 		return -EINVAL;
 
+	family = cfg.udp_config.family;
+	if (family != AF_INET && family != AF_INET6)
+		return -EINVAL;
+
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
@@ -675,7 +698,7 @@ static int fou_nl_cmd_get_port(struct sk_buff *skb, struct genl_info *info)
 	ret = -ESRCH;
 	mutex_lock(&fn->fou_lock);
 	list_for_each_entry(fout, &fn->fou_list, list) {
-		if (port == fout->port) {
+		if (port == fout->port && family == fout->family) {
 			ret = fou_dump_info(fout, info->snd_portid,
 					    info->snd_seq, 0, msg,
 					    info->genlhdr->cmd);
-- 
2.8.0.rc2
