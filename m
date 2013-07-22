From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 7/7] selinux: use generic union inet_addr
Date: Mon, 22 Jul 2013 15:05:13 +0800
Message-ID: <1374476713-8838-8-git-send-email-amwang@redhat.com>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	James Morris <james.l.morris@oracle.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	Paul Moore <pmoore@redhat.com>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>

selinux has some similar definition like union inet_addr,
it can re-use the generic union inet_addr too.

Cc: James Morris <james.l.morris@oracle.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Eric Paris <eparis@parisplace.org>
Cc: Paul Moore <pmoore@redhat.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/lsm_audit.h          |   16 +-----
 security/lsm_audit.c               |   16 +++---
 security/selinux/hooks.c           |   73 ++++++++++----------------
 security/selinux/include/netnode.h |    4 +-
 security/selinux/include/objsec.h  |    7 +--
 security/selinux/netnode.c         |  102 +++++++++++-------------------------
 6 files changed, 74 insertions(+), 144 deletions(-)

diff --git a/include/linux/lsm_audit.h b/include/linux/lsm_audit.h
index 1cc89e9..db7c0d6 100644
--- a/include/linux/lsm_audit.h
+++ b/include/linux/lsm_audit.h
@@ -21,6 +21,7 @@
 #include <linux/path.h>
 #include <linux/key.h>
 #include <linux/skbuff.h>
+#include <net/inet_addr.h>
 
 struct lsm_network_audit {
 	int netif;
@@ -28,16 +29,8 @@ struct lsm_network_audit {
 	u16 family;
 	__be16 dport;
 	__be16 sport;
-	union {
-		struct {
-			__be32 daddr;
-			__be32 saddr;
-		} v4;
-		struct {
-			struct in6_addr daddr;
-			struct in6_addr saddr;
-		} v6;
-	} fam;
+	union inet_addr saddr;
+	union inet_addr daddr;
 };
 
 /* Auxiliary data to use in generating the audit record. */
@@ -83,9 +76,6 @@ struct common_audit_data {
 	}; /* per LSM data pointer union */
 };
 
-#define v4info fam.v4
-#define v6info fam.v6
-
 int ipv4_skb_to_auditdata(struct sk_buff *skb,
 		struct common_audit_data *ad, u8 *proto);
 
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 8d8d97d..f30862b 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -49,8 +49,8 @@ int ipv4_skb_to_auditdata(struct sk_buff *skb,
 	if (ih == NULL)
 		return -EINVAL;
 
-	ad->u.net->v4info.saddr = ih->saddr;
-	ad->u.net->v4info.daddr = ih->daddr;
+	ad->u.net->saddr.sin.sin_addr.s_addr = ih->saddr;
+	ad->u.net->daddr.sin.sin_addr.s_addr = ih->daddr;
 
 	if (proto)
 		*proto = ih->protocol;
@@ -119,8 +119,8 @@ int ipv6_skb_to_auditdata(struct sk_buff *skb,
 	ip6 = ipv6_hdr(skb);
 	if (ip6 == NULL)
 		return -EINVAL;
-	ad->u.net->v6info.saddr = ip6->saddr;
-	ad->u.net->v6info.daddr = ip6->daddr;
+	ad->u.net->saddr.sin6.sin6_addr = ip6->saddr;
+	ad->u.net->daddr.sin6.sin6_addr = ip6->daddr;
 	ret = 0;
 	/* IPv6 can have several extension header before the Transport header
 	 * skip them */
@@ -335,18 +335,18 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 
 		switch (a->u.net->family) {
 		case AF_INET:
-			print_ipv4_addr(ab, a->u.net->v4info.saddr,
+			print_ipv4_addr(ab, a->u.net->saddr.sin.sin_addr.s_addr,
 					a->u.net->sport,
 					"saddr", "src");
-			print_ipv4_addr(ab, a->u.net->v4info.daddr,
+			print_ipv4_addr(ab, a->u.net->daddr.sin.sin_addr.s_addr,
 					a->u.net->dport,
 					"daddr", "dest");
 			break;
 		case AF_INET6:
-			print_ipv6_addr(ab, &a->u.net->v6info.saddr,
+			print_ipv6_addr(ab, &a->u.net->saddr.sin6.sin6_addr,
 					a->u.net->sport,
 					"saddr", "src");
-			print_ipv6_addr(ab, &a->u.net->v6info.daddr,
+			print_ipv6_addr(ab, &a->u.net->daddr.sin6.sin6_addr,
 					a->u.net->dport,
 					"daddr", "dest");
 			break;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c956390..6b17c8d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3595,8 +3595,8 @@ static int selinux_parse_skb_ipv4(struct sk_buff *skb,
 	if (ihlen < sizeof(_iph))
 		goto out;
 
-	ad->u.net->v4info.saddr = ih->saddr;
-	ad->u.net->v4info.daddr = ih->daddr;
+	ad->u.net->saddr.sin.sin_addr.s_addr = ih->saddr;
+	ad->u.net->daddr.sin.sin_addr.s_addr = ih->daddr;
 	ret = 0;
 
 	if (proto)
@@ -3674,8 +3674,8 @@ static int selinux_parse_skb_ipv6(struct sk_buff *skb,
 	if (ip6 == NULL)
 		goto out;
 
-	ad->u.net->v6info.saddr = ip6->saddr;
-	ad->u.net->v6info.daddr = ip6->daddr;
+	ad->u.net->saddr.sin6.sin6_addr = ip6->saddr;
+	ad->u.net->daddr.sin6.sin6_addr = ip6->daddr;
 	ret = 0;
 
 	nexthdr = ip6->nexthdr;
@@ -3735,9 +3735,9 @@ out:
 #endif /* IPV6 */
 
 static int selinux_parse_skb(struct sk_buff *skb, struct common_audit_data *ad,
-			     char **_addrp, int src, u8 *proto)
+			     union inet_addr **_addrp, int src, u8 *proto)
 {
-	char *addrp;
+	union inet_addr *addrp;
 	int ret;
 
 	switch (ad->u.net->family) {
@@ -3745,8 +3745,6 @@ static int selinux_parse_skb(struct sk_buff *skb, struct common_audit_data *ad,
 		ret = selinux_parse_skb_ipv4(skb, ad, proto);
 		if (ret)
 			goto parse_error;
-		addrp = (char *)(src ? &ad->u.net->v4info.saddr :
-				       &ad->u.net->v4info.daddr);
 		goto okay;
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -3754,13 +3752,11 @@ static int selinux_parse_skb(struct sk_buff *skb, struct common_audit_data *ad,
 		ret = selinux_parse_skb_ipv6(skb, ad, proto);
 		if (ret)
 			goto parse_error;
-		addrp = (char *)(src ? &ad->u.net->v6info.saddr :
-				       &ad->u.net->v6info.daddr);
 		goto okay;
 #endif	/* IPV6 */
 	default:
 		addrp = NULL;
-		goto okay;
+		goto save;
 	}
 
 parse_error:
@@ -3770,6 +3766,8 @@ parse_error:
 	return ret;
 
 okay:
+	addrp = src ? &ad->u.net->saddr : &ad->u.net->daddr;
+save:
 	if (_addrp)
 		*_addrp = addrp;
 	return 0;
@@ -3912,25 +3910,15 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 	 */
 	family = sk->sk_family;
 	if (family == PF_INET || family == PF_INET6) {
-		char *addrp;
+		union inet_addr *addrp = (union inet_addr *)address;
 		struct sk_security_struct *sksec = sk->sk_security;
 		struct common_audit_data ad;
 		struct lsm_network_audit net = {0,};
-		struct sockaddr_in *addr4 = NULL;
-		struct sockaddr_in6 *addr6 = NULL;
 		unsigned short snum;
 		u32 sid, node_perm;
 
-		if (family == PF_INET) {
-			addr4 = (struct sockaddr_in *)address;
-			snum = ntohs(addr4->sin_port);
-			addrp = (char *)&addr4->sin_addr.s_addr;
-		} else {
-			addr6 = (struct sockaddr_in6 *)address;
-			snum = ntohs(addr6->sin6_port);
-			addrp = (char *)&addr6->sin6_addr.s6_addr;
-		}
-
+		addrp->sa.sa_family = family;
+		snum = inet_addr_get_port(addrp);
 		if (snum) {
 			int low, high;
 
@@ -3971,7 +3959,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 			break;
 		}
 
-		err = sel_netnode_sid(addrp, family, &sid);
+		err = sel_netnode_sid(addrp, &sid);
 		if (err)
 			goto out;
 
@@ -3980,10 +3968,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 		ad.u.net->sport = htons(snum);
 		ad.u.net->family = family;
 
-		if (family == PF_INET)
-			ad.u.net->v4info.saddr = addr4->sin_addr.s_addr;
-		else
-			ad.u.net->v6info.saddr = addr6->sin6_addr;
+		ad.u.net->saddr = *addrp;
 
 		err = avc_has_perm(sksec->sid, sid,
 				   sksec->sclass, node_perm, &ad);
@@ -4011,22 +3996,18 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 	    sksec->sclass == SECCLASS_DCCP_SOCKET) {
 		struct common_audit_data ad;
 		struct lsm_network_audit net = {0,};
-		struct sockaddr_in *addr4 = NULL;
-		struct sockaddr_in6 *addr6 = NULL;
+		union inet_addr *addrp = (union inet_addr *)address;
 		unsigned short snum;
 		u32 sid, perm;
 
 		if (sk->sk_family == PF_INET) {
-			addr4 = (struct sockaddr_in *)address;
 			if (addrlen < sizeof(struct sockaddr_in))
 				return -EINVAL;
-			snum = ntohs(addr4->sin_port);
 		} else {
-			addr6 = (struct sockaddr_in6 *)address;
 			if (addrlen < SIN6_LEN_RFC2133)
 				return -EINVAL;
-			snum = ntohs(addr6->sin6_port);
 		}
+		snum = inet_addr_get_port(addrp);
 
 		err = sel_netport_sid(sk->sk_protocol, snum, &sid);
 		if (err)
@@ -4169,7 +4150,7 @@ static int selinux_socket_unix_may_send(struct socket *sock,
 			    &ad);
 }
 
-static int selinux_inet_sys_rcv_skb(int ifindex, char *addrp, u16 family,
+static int selinux_inet_sys_rcv_skb(int ifindex, union inet_addr *addrp,
 				    u32 peer_sid,
 				    struct common_audit_data *ad)
 {
@@ -4185,7 +4166,7 @@ static int selinux_inet_sys_rcv_skb(int ifindex, char *addrp, u16 family,
 	if (err)
 		return err;
 
-	err = sel_netnode_sid(addrp, family, &node_sid);
+	err = sel_netnode_sid(addrp, &node_sid);
 	if (err)
 		return err;
 	return avc_has_perm(peer_sid, node_sid,
@@ -4200,7 +4181,7 @@ static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 	u32 sk_sid = sksec->sid;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
-	char *addrp;
+	union inet_addr *addrp;
 
 	ad.type = LSM_AUDIT_DATA_NET;
 	ad.u.net = &net;
@@ -4233,7 +4214,7 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	u32 sk_sid = sksec->sid;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
-	char *addrp;
+	union inet_addr *addrp;
 	u8 secmark_active;
 	u8 peerlbl_active;
 
@@ -4270,7 +4251,8 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		err = selinux_skb_peerlbl_sid(skb, family, &peer_sid);
 		if (err)
 			return err;
-		err = selinux_inet_sys_rcv_skb(skb->skb_iif, addrp, family,
+		addrp->sa.sa_family = family;
+		err = selinux_inet_sys_rcv_skb(skb->skb_iif, addrp,
 					       peer_sid, &ad);
 		if (err) {
 			selinux_netlbl_err(skb, err, 0);
@@ -4621,7 +4603,7 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 				       u16 family)
 {
 	int err;
-	char *addrp;
+	union inet_addr *addrp;
 	u32 peer_sid;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
@@ -4649,7 +4631,8 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 		return NF_DROP;
 
 	if (peerlbl_active) {
-		err = selinux_inet_sys_rcv_skb(ifindex, addrp, family,
+		addrp->sa.sa_family = family;
+		err = selinux_inet_sys_rcv_skb(ifindex, addrp,
 					       peer_sid, &ad);
 		if (err) {
 			selinux_netlbl_err(skb, err, 1);
@@ -4732,7 +4715,7 @@ static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 	struct sk_security_struct *sksec;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
-	char *addrp;
+	union inet_addr *addrp;
 	u8 proto;
 
 	if (sk == NULL)
@@ -4765,7 +4748,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	struct sock *sk;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
-	char *addrp;
+	union inet_addr *addrp;
 	u8 secmark_active;
 	u8 peerlbl_active;
 
@@ -4832,7 +4815,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 				 SECCLASS_NETIF, NETIF__EGRESS, &ad))
 			return NF_DROP_ERR(-ECONNREFUSED);
 
-		if (sel_netnode_sid(addrp, family, &node_sid))
+		if (sel_netnode_sid(addrp, &node_sid))
 			return NF_DROP;
 		if (avc_has_perm(peer_sid, node_sid,
 				 SECCLASS_NODE, NODE__SENDTO, &ad))
diff --git a/security/selinux/include/netnode.h b/security/selinux/include/netnode.h
index df7a5ed..f32c909 100644
--- a/security/selinux/include/netnode.h
+++ b/security/selinux/include/netnode.h
@@ -27,6 +27,8 @@
 #ifndef _SELINUX_NETNODE_H
 #define _SELINUX_NETNODE_H
 
-int sel_netnode_sid(void *addr, u16 family, u32 *sid);
+#include <net/inet_addr.h>
+
+int sel_netnode_sid(union inet_addr *addr, u32 *sid);
 
 #endif
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index aa47bca..a46caaf 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -24,6 +24,7 @@
 #include <linux/binfmts.h>
 #include <linux/in.h>
 #include <linux/spinlock.h>
+#include <net/inet_addr.h>
 #include "flask.h"
 #include "avc.h"
 
@@ -80,12 +81,8 @@ struct netif_security_struct {
 };
 
 struct netnode_security_struct {
-	union {
-		__be32 ipv4;		/* IPv4 node address */
-		struct in6_addr ipv6;	/* IPv6 node address */
-	} addr;
+	union inet_addr addr;
 	u32 sid;			/* SID for this node */
-	u16 family;			/* address family */
 };
 
 struct netport_security_struct {
diff --git a/security/selinux/netnode.c b/security/selinux/netnode.c
index c5454c0..713f14e 100644
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -68,79 +68,49 @@ static LIST_HEAD(sel_netnode_list);
 static DEFINE_SPINLOCK(sel_netnode_lock);
 static struct sel_netnode_bkt sel_netnode_hash[SEL_NETNODE_HASH_SIZE];
 
-/**
- * sel_netnode_hashfn_ipv4 - IPv4 hashing function for the node table
- * @addr: IPv4 address
- *
- * Description:
- * This is the IPv4 hashing function for the node interface table, it returns
- * the bucket number for the given IP address.
- *
- */
-static unsigned int sel_netnode_hashfn_ipv4(__be32 addr)
-{
-	/* at some point we should determine if the mismatch in byte order
-	 * affects the hash function dramatically */
-	return (addr & (SEL_NETNODE_HASH_SIZE - 1));
-}
 
 /**
- * sel_netnode_hashfn_ipv6 - IPv6 hashing function for the node table
- * @addr: IPv6 address
+ * sel_netnode_hashfn - IPv4/IPv6 hashing function for the node table
+ * @addr: generic IP address
  *
  * Description:
- * This is the IPv6 hashing function for the node interface table, it returns
+ * This is the IP hashing function for the node interface table, it returns
  * the bucket number for the given IP address.
  *
  */
-static unsigned int sel_netnode_hashfn_ipv6(const struct in6_addr *addr)
+static unsigned int sel_netnode_hashfn(const union inet_addr *addr)
 {
-	/* just hash the least significant 32 bits to keep things fast (they
-	 * are the most likely to be different anyway), we can revisit this
-	 * later if needed */
-	return (addr->s6_addr32[3] & (SEL_NETNODE_HASH_SIZE - 1));
+	if (addr->sa.sa_family == PF_INET)
+		/* at some point we should determine if the mismatch in byte order
+		 * affects the hash function dramatically */
+		return (addr->sin.sin_addr.s_addr & (SEL_NETNODE_HASH_SIZE - 1));
+	else if (addr->sa.sa_family == PF_INET6)
+		/* just hash the least significant 32 bits to keep things fast (they
+		 * are the most likely to be different anyway), we can revisit this
+		 * later if needed */
+		return (addr->sin6.sin6_addr.s6_addr32[3] & (SEL_NETNODE_HASH_SIZE - 1));
+	else
+		BUG();
 }
 
 /**
  * sel_netnode_find - Search for a node record
  * @addr: IP address
- * @family: address family
  *
  * Description:
  * Search the network node table and return the record matching @addr.  If an
  * entry can not be found in the table return NULL.
  *
  */
-static struct sel_netnode *sel_netnode_find(const void *addr, u16 family)
+static struct sel_netnode *sel_netnode_find(const union inet_addr *addr)
 {
 	unsigned int idx;
 	struct sel_netnode *node;
 
-	switch (family) {
-	case PF_INET:
-		idx = sel_netnode_hashfn_ipv4(*(__be32 *)addr);
-		break;
-	case PF_INET6:
-		idx = sel_netnode_hashfn_ipv6(addr);
-		break;
-	default:
-		BUG();
-		return NULL;
-	}
-
+	idx = sel_netnode_hashfn(addr);
 	list_for_each_entry_rcu(node, &sel_netnode_hash[idx].list, list)
-		if (node->nsec.family == family)
-			switch (family) {
-			case PF_INET:
-				if (node->nsec.addr.ipv4 == *(__be32 *)addr)
-					return node;
-				break;
-			case PF_INET6:
-				if (ipv6_addr_equal(&node->nsec.addr.ipv6,
-						    addr))
-					return node;
-				break;
-			}
+		if (inet_addr_equal(&node->nsec.addr, addr))
+			return node;
 
 	return NULL;
 }
@@ -156,18 +126,9 @@ static struct sel_netnode *sel_netnode_find(const void *addr, u16 family)
 static void sel_netnode_insert(struct sel_netnode *node)
 {
 	unsigned int idx;
+	union inet_addr *addr = &node->nsec.addr;
 
-	switch (node->nsec.family) {
-	case PF_INET:
-		idx = sel_netnode_hashfn_ipv4(node->nsec.addr.ipv4);
-		break;
-	case PF_INET6:
-		idx = sel_netnode_hashfn_ipv6(&node->nsec.addr.ipv6);
-		break;
-	default:
-		BUG();
-	}
-
+	idx = sel_netnode_hashfn(addr);
 	/* we need to impose a limit on the growth of the hash table so check
 	 * this bucket to make sure it is within the specified bounds */
 	list_add_rcu(&node->list, &sel_netnode_hash[idx].list);
@@ -186,7 +147,6 @@ static void sel_netnode_insert(struct sel_netnode *node)
 /**
  * sel_netnode_sid_slow - Lookup the SID of a network address using the policy
  * @addr: the IP address
- * @family: the address family
  * @sid: node SID
  *
  * Description:
@@ -196,14 +156,14 @@ static void sel_netnode_insert(struct sel_netnode *node)
  * failure.
  *
  */
-static int sel_netnode_sid_slow(void *addr, u16 family, u32 *sid)
+static int sel_netnode_sid_slow(union inet_addr *addr, u32 *sid)
 {
 	int ret = -ENOMEM;
 	struct sel_netnode *node;
 	struct sel_netnode *new = NULL;
 
 	spin_lock_bh(&sel_netnode_lock);
-	node = sel_netnode_find(addr, family);
+	node = sel_netnode_find(addr);
 	if (node != NULL) {
 		*sid = node->nsec.sid;
 		spin_unlock_bh(&sel_netnode_lock);
@@ -212,16 +172,16 @@ static int sel_netnode_sid_slow(void *addr, u16 family, u32 *sid)
 	new = kzalloc(sizeof(*new), GFP_ATOMIC);
 	if (new == NULL)
 		goto out;
-	switch (family) {
+	switch (addr->sa.sa_family) {
 	case PF_INET:
 		ret = security_node_sid(PF_INET,
 					addr, sizeof(struct in_addr), sid);
-		new->nsec.addr.ipv4 = *(__be32 *)addr;
+		new->nsec.addr = *addr;
 		break;
 	case PF_INET6:
 		ret = security_node_sid(PF_INET6,
 					addr, sizeof(struct in6_addr), sid);
-		new->nsec.addr.ipv6 = *(struct in6_addr *)addr;
+		new->nsec.addr = *addr;
 		break;
 	default:
 		BUG();
@@ -229,7 +189,6 @@ static int sel_netnode_sid_slow(void *addr, u16 family, u32 *sid)
 	if (ret != 0)
 		goto out;
 
-	new->nsec.family = family;
 	new->nsec.sid = *sid;
 	sel_netnode_insert(new);
 
@@ -246,8 +205,7 @@ out:
 
 /**
  * sel_netnode_sid - Lookup the SID of a network address
- * @addr: the IP address
- * @family: the address family
+ * @addr: the generic IP address
  * @sid: node SID
  *
  * Description:
@@ -258,12 +216,12 @@ out:
  * on failure.
  *
  */
-int sel_netnode_sid(void *addr, u16 family, u32 *sid)
+int sel_netnode_sid(union inet_addr *addr, u32 *sid)
 {
 	struct sel_netnode *node;
 
 	rcu_read_lock();
-	node = sel_netnode_find(addr, family);
+	node = sel_netnode_find(addr);
 	if (node != NULL) {
 		*sid = node->nsec.sid;
 		rcu_read_unlock();
@@ -271,7 +229,7 @@ int sel_netnode_sid(void *addr, u16 family, u32 *sid)
 	}
 	rcu_read_unlock();
 
-	return sel_netnode_sid_slow(addr, family, sid);
+	return sel_netnode_sid_slow(addr, sid);
 }
 
 /**
-- 
1.7.7.6

