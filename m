From: Ivan Delalande <colona@arista.com>
Subject: [PATCH net-next] inet_diag: report TCP MD5 signing keys and addresses
Date: Thu, 24 Aug 2017 03:22:11 +0200
Message-ID: <20170824012210.m3b2hsll4avrr42i@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36745 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbdHXBWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 21:22:13 -0400
Received: by mail-wm0-f48.google.com with SMTP id x128so10130762wmg.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 18:22:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
not possible to retrieve these from the kernel once they have been
configured on sockets.

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/uapi/linux/inet_diag.h |   1 +
 net/ipv4/inet_diag.c           | 108 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 105 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 678496897a68..f52ff62bfabe 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -143,6 +143,7 @@ enum {
 	INET_DIAG_MARK,
 	INET_DIAG_BBRINFO,
 	INET_DIAG_CLASS_ID,
+	INET_DIAG_MD5SIG,
 	__INET_DIAG_MAX,
 };
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 67325d5832d7..81bacf1d8da6 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -93,8 +93,27 @@ void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet_diag_msg_common_fill);
 
-static size_t inet_sk_attr_size(void)
+static size_t inet_sk_attr_size(struct sock *sp)
 {
+#ifdef CONFIG_TCP_MD5SIG
+	const struct tcp_md5sig_info *md5sig;
+	const struct tcp_md5sig_key *key;
+	int md5sig_count = 0;
+
+	if (sp->sk_state == TCP_TIME_WAIT) {
+		if (tcp_twsk(sp)->tw_md5_key)
+			md5sig_count = 1;
+	} else {
+		rcu_read_lock();
+		md5sig = rcu_dereference(tcp_sk(sp)->md5sig_info);
+		if (md5sig) {
+			hlist_for_each_entry_rcu(key, &md5sig->head, node)
+				md5sig_count++;
+		}
+		rcu_read_unlock();
+	}
+#endif
+
 	return	  nla_total_size(sizeof(struct tcp_info))
 		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
 		+ nla_total_size(1) /* INET_DIAG_TOS */
@@ -105,6 +124,9 @@ static size_t inet_sk_attr_size(void)
 		+ nla_total_size(SK_MEMINFO_VARS * sizeof(u32))
 		+ nla_total_size(TCP_CA_NAME_MAX)
 		+ nla_total_size(sizeof(struct tcpvegas_info))
+#ifdef CONFIG_TCP_MD5SIG
+		+ nla_total_size(md5sig_count * sizeof(struct tcp_md5sig))
+#endif
 		+ 64;
 }
 
@@ -150,6 +172,58 @@ int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(inet_diag_msg_attrs_fill);
 
+#ifdef CONFIG_TCP_MD5SIG
+static void inet_diag_md5sig_fill(struct tcp_md5sig *info,
+				  const struct tcp_md5sig_key *key)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (key->family == AF_INET6) {
+		struct sockaddr_in6 *sin6 =
+			(struct sockaddr_in6 *)&info->tcpm_addr;
+
+		memcpy(&sin6->sin6_addr, &key->addr.a6,
+		       sizeof(struct in6_addr));
+	} else
+#endif
+	{
+		struct sockaddr_in *sin =
+			(struct sockaddr_in *)&info->tcpm_addr;
+
+		memcpy(&sin->sin_addr, &key->addr.a4, sizeof(struct in_addr));
+	}
+
+	info->tcpm_addr.ss_family = key->family;
+	info->tcpm_prefixlen = key->prefixlen;
+	info->tcpm_keylen = key->keylen;
+	memcpy(info->tcpm_key, key->key, key->keylen);
+}
+
+static int inet_diag_put_md5sig(struct sk_buff *skb,
+				const struct tcp_md5sig_info *md5sig)
+{
+	const struct tcp_md5sig_key *key;
+	struct nlattr *attr;
+	struct tcp_md5sig *info = NULL;
+	int md5sig_count = 0;
+
+	hlist_for_each_entry_rcu(key, &md5sig->head, node)
+		md5sig_count++;
+
+	attr = nla_reserve(skb, INET_DIAG_MD5SIG,
+			   md5sig_count * sizeof(struct tcp_md5sig));
+	if (!attr)
+		return -EMSGSIZE;
+
+	info = nla_data(attr);
+	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
+		inet_diag_md5sig_fill(info, key);
+		info++;
+	}
+
+	return 0;
+}
+#endif
+
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
@@ -260,6 +334,21 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 	handler->idiag_get_info(sk, r, info);
 
+#ifdef CONFIG_TCP_MD5SIG
+	if ((ext & (1 << (INET_DIAG_INFO - 1))) && net_admin) {
+		struct tcp_md5sig_info *md5sig;
+		int err = 0;
+
+		rcu_read_lock();
+		md5sig = rcu_dereference(tcp_sk(sk)->md5sig_info);
+		if (md5sig)
+			err = inet_diag_put_md5sig(skb, md5sig);
+		rcu_read_unlock();
+		if (err < 0)
+			goto errout;
+	}
+#endif
+
 	if (sk->sk_state < TCP_TIME_WAIT) {
 		union tcp_cc_info info;
 		size_t sz = 0;
@@ -310,7 +399,8 @@ static int inet_csk_diag_fill(struct sock *sk,
 static int inet_twsk_diag_fill(struct sock *sk,
 			       struct sk_buff *skb,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
-			       const struct nlmsghdr *unlh)
+			       const struct nlmsghdr *unlh,
+			       bool net_admin)
 {
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct inet_diag_msg *r;
@@ -340,6 +430,16 @@ static int inet_twsk_diag_fill(struct sock *sk,
 	r->idiag_uid	      = 0;
 	r->idiag_inode	      = 0;
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (net_admin && tcp_twsk(sk)->tw_md5_key) {
+		struct nlattr *attr = nla_reserve(skb, INET_DIAG_MD5SIG,
+						  sizeof(struct tcp_md5sig));
+		if (!attr)
+			return -EMSGSIZE;
+		inet_diag_md5sig_fill(nla_data(attr), tcp_twsk(sk)->tw_md5_key);
+	}
+#endif
+
 	nlmsg_end(skb, nlh);
 	return 0;
 }
@@ -390,7 +490,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill(sk, skb, portid, seq,
-					   nlmsg_flags, unlh);
+					   nlmsg_flags, unlh, net_admin);
 
 	if (sk->sk_state == TCP_NEW_SYN_RECV)
 		return inet_req_diag_fill(sk, skb, portid, seq,
@@ -458,7 +558,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 	if (IS_ERR(sk))
 		return PTR_ERR(sk);
 
-	rep = nlmsg_new(inet_sk_attr_size(), GFP_KERNEL);
+	rep = nlmsg_new(inet_sk_attr_size(sk), GFP_KERNEL);
 	if (!rep) {
 		err = -ENOMEM;
 		goto out;
-- 
2.14.1
