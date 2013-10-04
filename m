From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/33] netfilter: ipset: Introduce new operation to get both setname and family
Date: Fri,  4 Oct 2013 10:32:57 +0200
Message-ID: <1380875598-5250-13-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55894 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab3JDIet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:49 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

ip[6]tables set match and SET target need to know the family of the set
in order to reject adding rules which refer to a set with a non-mathcing
family. Currently such rules are silently accepted and then ignored
instead of generating a clear error message to the user, which is not
helpful.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/uapi/linux/netfilter/ipset/ip_set.h |    8 ++++++++
 net/netfilter/ipset/ip_set_core.c           |   17 +++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 8024cdf..2b61ac4 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -250,6 +250,14 @@ struct ip_set_req_get_set {
 #define IP_SET_OP_GET_BYINDEX	0x00000007	/* Get set name by index */
 /* Uses ip_set_req_get_set */
 
+#define IP_SET_OP_GET_FNAME	0x00000008	/* Get set index and family */
+struct ip_set_req_get_set_family {
+	unsigned int op;
+	unsigned int version;
+	unsigned int family;
+	union ip_set_name_index set;
+};
+
 #define IP_SET_OP_VERSION	0x00000100	/* Ask kernel version */
 struct ip_set_req_version {
 	unsigned int op;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index f2e30fb..428c30a 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1788,6 +1788,23 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
+	case IP_SET_OP_GET_FNAME: {
+		struct ip_set_req_get_set_family *req_get = data;
+		ip_set_id_t id;
+
+		if (*len != sizeof(struct ip_set_req_get_set_family)) {
+			ret = -EINVAL;
+			goto done;
+		}
+		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
+		nfnl_lock(NFNL_SUBSYS_IPSET);
+		find_set_and_id(req_get->set.name, &id);
+		req_get->set.index = id;
+		if (id != IPSET_INVALID_ID)
+			req_get->family = nfnl_set(id)->family;
+		nfnl_unlock(NFNL_SUBSYS_IPSET);
+		goto copy;
+	}
 	case IP_SET_OP_GET_BYINDEX: {
 		struct ip_set_req_get_set *req_get = data;
 		struct ip_set *set;
-- 
1.7.10.4
