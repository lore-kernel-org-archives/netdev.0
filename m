From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/5] sock_diag: allow to dump bpf filters
Date: Tue, 23 Apr 2013 16:27:55 +0200
Message-ID: <1366727277-19522-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52754 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929Ab3DWO3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 10:29:04 -0400
In-Reply-To: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to dump BPF filters attached to a socket. For now, only packet
sockets use this feature.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/sock_diag.h        |  2 ++
 include/uapi/linux/packet_diag.h |  2 ++
 net/core/sock_diag.c             | 27 +++++++++++++++++++++++++++
 net/packet/diag.c                |  4 ++++
 4 files changed, 35 insertions(+)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index e8d702e..3957c14 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -22,5 +22,7 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
+int sock_diag_put_filterinfo(struct sock *sk, struct sk_buff *skb,
+			     int attrtype);
 
 #endif
diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index c0802c1..b2cc0cd 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -17,6 +17,7 @@ struct packet_diag_req {
 #define PACKET_SHOW_RING_CFG	0x00000004 /* Rings configuration parameters */
 #define PACKET_SHOW_FANOUT	0x00000008
 #define PACKET_SHOW_MEMINFO	0x00000010
+#define PACKET_SHOW_FILTER	0x00000020
 
 struct packet_diag_msg {
 	__u8	pdiag_family;
@@ -35,6 +36,7 @@ enum {
 	PACKET_DIAG_FANOUT,
 	PACKET_DIAG_UID,
 	PACKET_DIAG_MEMINFO,
+	PACKET_DIAG_FILTER,
 
 	__PACKET_DIAG_MAX,
 };
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a29e90c..51e75f4 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -49,6 +49,33 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
+int sock_diag_put_filterinfo(struct sock *sk, struct sk_buff *skb, int attrtype)
+{
+	struct nlattr *attr;
+	struct sk_filter *filter;
+	unsigned int len;
+	int err = 0;
+
+	rcu_read_lock();
+
+	filter = rcu_dereference(sk->sk_filter);
+	len = filter ? filter->len * sizeof(struct sock_filter) : 0;
+
+	attr = nla_reserve(skb, attrtype, len);
+	if (attr == NULL) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+
+	if (filter)
+		memcpy(nla_data(attr), filter->insns, len);
+
+out:
+	rcu_read_unlock();
+	return err;
+}
+EXPORT_SYMBOL(sock_diag_put_filterinfo);
+
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
 {
 	mutex_lock(&sock_diag_table_mutex);
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 822fe9b..ec8b6e8 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -170,6 +170,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	    sock_diag_put_meminfo(sk, skb, PACKET_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_FILTER) &&
+	    sock_diag_put_filterinfo(sk, skb, PACKET_DIAG_FILTER))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.8.2.1
