From: akpm@osdl.org
Subject: [patch 9/9] secmark: Add new packet controls to SELinux
Date: Thu, 08 Jun 2006 22:20:59 -0700
Message-ID: <200606090520.k595Kx8J032108@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19420 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965169AbWFIFV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:21:29 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: James Morris <jmorris@namei.org>

Add new per-packet access controls to SELinux, replacing the old packet
controls.

Packets are labeled with the iptables SECMARK and CONNSECMARK targets, then
security policy for the packets is enforced with these controls.

To allow for a smooth transition to the new controls, the old code is still
present, but not active by default.  To restore previous behavior, the old
controls may be activated at runtime by writing a '1' to /selinux/compat_net,
and also via the kernel boot parameter selinux_compat_net.  Switching between
the network control models requires the security load_policy permission.  The
old controls will probably eventually be removed and any continued use is
discouraged.

With this patch, the new secmark controls for SElinux are disabled by default,
so existing behavior is entirely preserved, and the user is not affected at
all.

It also provides a config option to enable the secmark controls by default
(which can always be overridden at boot and runtime).  It is also noted in the
kconfig help that the user will need updated userspace if enabling secmark
controls for SELinux and that they'll probably need the SECMARK and CONNMARK
targets, and conntrack protocol helpers, although such decisions are beyond
the scope of kernel configuration.

Signed-off-by: James Morris <jmorris@namei.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 Documentation/kernel-parameters.txt |    9 
 security/selinux/Kconfig            |   29 +++
 security/selinux/hooks.c            |  242 ++++++++++++++------------
 security/selinux/include/xfrm.h     |    2 
 security/selinux/selinuxfs.c        |   66 +++++++
 security/selinux/xfrm.c             |   12 -
 6 files changed, 241 insertions(+), 119 deletions(-)

diff -puN Documentation/kernel-parameters.txt~secmark-add-new-packet-controls-to-selinux Documentation/kernel-parameters.txt
--- devel/Documentation/kernel-parameters.txt~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/Documentation/kernel-parameters.txt	2006-06-01 20:31:50.000000000 -0700
@@ -1405,6 +1405,15 @@ running once the system is up.
 			If enabled at boot time, /selinux/disable can be used
 			later to disable prior to initial policy load.
 
+	selinux_compat_net =
+			[SELINUX] Set initial selinux_compat_net flag value.
+                        Format: { "0" | "1" }
+                        0 -- use new secmark-based packet controls
+                        1 -- use legacy packet controls
+                        Default value is 0 (preferred).
+                        Value can be changed at runtime via
+                        /selinux/compat_net.
+
 	serialnumber	[BUGS=IA-32]
 
 	sg_def_reserved_size=	[SCSI]
diff -puN security/selinux/hooks.c~secmark-add-new-packet-controls-to-selinux security/selinux/hooks.c
--- devel/security/selinux/hooks.c~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/hooks.c	2006-06-01 20:31:50.000000000 -0700
@@ -80,6 +80,7 @@
 
 extern unsigned int policydb_loaded_version;
 extern int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm);
+extern int selinux_compat_net;
 
 #ifdef CONFIG_SECURITY_SELINUX_DEVELOP
 int selinux_enforcing = 0;
@@ -3216,47 +3217,17 @@ static int selinux_socket_unix_may_send(
 	return 0;
 }
 
-static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
+		struct avc_audit_data *ad, u32 sock_sid, u16 sock_class,
+		u16 family, char *addrp, int len)
 {
-	u16 family;
-	char *addrp;
-	int len, err = 0;
+	int err = 0;
 	u32 netif_perm, node_perm, node_sid, if_sid, recv_perm = 0;
-	u32 sock_sid = 0;
-	u16 sock_class = 0;
-	struct socket *sock;
-	struct net_device *dev;
-	struct avc_audit_data ad;
-
-	family = sk->sk_family;
-	if (family != PF_INET && family != PF_INET6)
-		goto out;
-
-	/* Handle mapped IPv4 packets arriving via IPv6 sockets */
-	if (family == PF_INET6 && skb->protocol == htons(ETH_P_IP))
-		family = PF_INET;
-
- 	read_lock_bh(&sk->sk_callback_lock);
- 	sock = sk->sk_socket;
- 	if (sock) {
- 		struct inode *inode;
- 		inode = SOCK_INODE(sock);
- 		if (inode) {
- 			struct inode_security_struct *isec;
- 			isec = inode->i_security;
- 			sock_sid = isec->sid;
- 			sock_class = isec->sclass;
- 		}
- 	}
- 	read_unlock_bh(&sk->sk_callback_lock);
- 	if (!sock_sid)
-  		goto out;
 
-	dev = skb->dev;
-	if (!dev)
+	if (!skb->dev)
 		goto out;
 
-	err = sel_netif_sids(dev, &if_sid, NULL);
+	err = sel_netif_sids(skb->dev, &if_sid, NULL);
 	if (err)
 		goto out;
 
@@ -3279,44 +3250,88 @@ static int selinux_socket_sock_rcv_skb(s
 		break;
 	}
 
-	AVC_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.netif = dev->name;
-	ad.u.net.family = family;
-
-	err = selinux_parse_skb(skb, &ad, &addrp, &len, 1);
-	if (err)
-		goto out;
-
-	err = avc_has_perm(sock_sid, if_sid, SECCLASS_NETIF, netif_perm, &ad);
+	err = avc_has_perm(sock_sid, if_sid, SECCLASS_NETIF, netif_perm, ad);
 	if (err)
 		goto out;
 	
-	/* Fixme: this lookup is inefficient */
 	err = security_node_sid(family, addrp, len, &node_sid);
 	if (err)
 		goto out;
 	
-	err = avc_has_perm(sock_sid, node_sid, SECCLASS_NODE, node_perm, &ad);
+	err = avc_has_perm(sock_sid, node_sid, SECCLASS_NODE, node_perm, ad);
 	if (err)
 		goto out;
 
 	if (recv_perm) {
 		u32 port_sid;
 
-		/* Fixme: make this more efficient */
 		err = security_port_sid(sk->sk_family, sk->sk_type,
-		                        sk->sk_protocol, ntohs(ad.u.net.sport),
+		                        sk->sk_protocol, ntohs(ad->u.net.sport),
 		                        &port_sid);
 		if (err)
 			goto out;
 
 		err = avc_has_perm(sock_sid, port_sid,
-				   sock_class, recv_perm, &ad);
+				   sock_class, recv_perm, ad);
 	}
 
-	if (!err)
-		err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+out:
+	return err;
+}
+
+static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	u16 family;
+	u16 sock_class = 0;
+	char *addrp;
+	int len, err = 0;
+	u32 sock_sid = 0;
+	struct socket *sock;
+	struct avc_audit_data ad;
+
+	family = sk->sk_family;
+	if (family != PF_INET && family != PF_INET6)
+		goto out;
+
+	/* Handle mapped IPv4 packets arriving via IPv6 sockets */
+	if (family == PF_INET6 && skb->protocol == ntohs(ETH_P_IP))
+		family = PF_INET;
+
+ 	read_lock_bh(&sk->sk_callback_lock);
+ 	sock = sk->sk_socket;
+ 	if (sock) {
+ 		struct inode *inode;
+ 		inode = SOCK_INODE(sock);
+ 		if (inode) {
+ 			struct inode_security_struct *isec;
+ 			isec = inode->i_security;
+ 			sock_sid = isec->sid;
+ 			sock_class = isec->sclass;
+ 		}
+ 	}
+ 	read_unlock_bh(&sk->sk_callback_lock);
+ 	if (!sock_sid)
+  		goto out;
+
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = skb->dev ? skb->dev->name : "[unknown]";
+	ad.u.net.family = family;
+
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 1);
+	if (err)
+		goto out;
+
+	if (selinux_compat_net)
+		err = selinux_sock_rcv_skb_compat(sk, skb, &ad, sock_sid,
+						  sock_class, family,
+						  addrp, len);
+	else
+		err = avc_has_perm(sock_sid, skb->secmark, SECCLASS_PACKET,
+				   PACKET__RECV, &ad);
+	if (err)
+		goto out;
 
+	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
 out:	
 	return err;
 }
@@ -3456,42 +3471,18 @@ out:
 
 #ifdef CONFIG_NETFILTER
 
-static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
-                                              struct sk_buff **pskb,
-                                              const struct net_device *in,
-                                              const struct net_device *out,
-                                              int (*okfn)(struct sk_buff *),
-                                              u16 family)
+static int selinux_ip_postroute_last_compat(struct sock *sk, struct net_device *dev,
+					    struct inode_security_struct *isec,
+					    struct avc_audit_data *ad,
+					    u16 family, char *addrp, int len)
 {
-	char *addrp;
-	int len, err = NF_ACCEPT;
+	int err;
 	u32 netif_perm, node_perm, node_sid, if_sid, send_perm = 0;
-	struct sock *sk;
-	struct socket *sock;
-	struct inode *inode;
-	struct sk_buff *skb = *pskb;
-	struct inode_security_struct *isec;
-	struct avc_audit_data ad;
-	struct net_device *dev = (struct net_device *)out;
 	
-	sk = skb->sk;
-	if (!sk)
-		goto out;
-		
-	sock = sk->sk_socket;
-	if (!sock)
-		goto out;
-		
-	inode = SOCK_INODE(sock);
-	if (!inode)
-		goto out;
-
 	err = sel_netif_sids(dev, &if_sid, NULL);
 	if (err)
 		goto out;
 
-	isec = inode->i_security;
-	
 	switch (isec->sclass) {
 	case SECCLASS_UDP_SOCKET:
 		netif_perm = NETIF__UDP_SEND;
@@ -3511,55 +3502,88 @@ static unsigned int selinux_ip_postroute
 		break;
 	}
 
-
-	AVC_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.netif = dev->name;
-	ad.u.net.family = family;
-
-	err = selinux_parse_skb(skb, &ad, &addrp,
-				&len, 0) ? NF_DROP : NF_ACCEPT;
-	if (err != NF_ACCEPT)
-		goto out;
-
-	err = avc_has_perm(isec->sid, if_sid, SECCLASS_NETIF,
-	                   netif_perm, &ad) ? NF_DROP : NF_ACCEPT;
-	if (err != NF_ACCEPT)
+	err = avc_has_perm(isec->sid, if_sid, SECCLASS_NETIF, netif_perm, ad);
+	if (err)
 		goto out;
 		
-	/* Fixme: this lookup is inefficient */
-	err = security_node_sid(family, addrp, len,
-				&node_sid) ? NF_DROP : NF_ACCEPT;
-	if (err != NF_ACCEPT)
+	err = security_node_sid(family, addrp, len, &node_sid);
+	if (err)
 		goto out;
 	
-	err = avc_has_perm(isec->sid, node_sid, SECCLASS_NODE,
-	                   node_perm, &ad) ? NF_DROP : NF_ACCEPT;
-	if (err != NF_ACCEPT)
+	err = avc_has_perm(isec->sid, node_sid, SECCLASS_NODE, node_perm, ad);
+	if (err)
 		goto out;
 
 	if (send_perm) {
 		u32 port_sid;
 		
-		/* Fixme: make this more efficient */
 		err = security_port_sid(sk->sk_family,
 		                        sk->sk_type,
 		                        sk->sk_protocol,
-		                        ntohs(ad.u.net.dport),
-		                        &port_sid) ? NF_DROP : NF_ACCEPT;
-		if (err != NF_ACCEPT)
+		                        ntohs(ad->u.net.dport),
+		                        &port_sid);
+		if (err)
 			goto out;
 
 		err = avc_has_perm(isec->sid, port_sid, isec->sclass,
-		                   send_perm, &ad) ? NF_DROP : NF_ACCEPT;
+				   send_perm, ad);
 	}
+out:
+	return err;
+}
+
+static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
+                                              struct sk_buff **pskb,
+                                              const struct net_device *in,
+                                              const struct net_device *out,
+                                              int (*okfn)(struct sk_buff *),
+                                              u16 family)
+{
+	char *addrp;
+	int len, err = 0;
+	struct sock *sk;
+	struct socket *sock;
+	struct inode *inode;
+	struct sk_buff *skb = *pskb;
+	struct inode_security_struct *isec;
+	struct avc_audit_data ad;
+	struct net_device *dev = (struct net_device *)out;
 
-	if (err != NF_ACCEPT)
+	sk = skb->sk;
+	if (!sk)
 		goto out;
 
-	err = selinux_xfrm_postroute_last(isec->sid, skb);
+	sock = sk->sk_socket;
+	if (!sock)
+		goto out;
+
+	inode = SOCK_INODE(sock);
+	if (!inode)
+		goto out;
+
+	isec = inode->i_security;
+
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = dev->name;
+	ad.u.net.family = family;
+
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 0);
+	if (err)
+		goto out;
+
+	if (selinux_compat_net)
+		err = selinux_ip_postroute_last_compat(sk, dev, isec, &ad,
+						       family, addrp, len);
+	else
+		err = avc_has_perm(isec->sid, skb->secmark, SECCLASS_PACKET,
+				   PACKET__SEND, &ad);
 
+	if (err)
+		goto out;
+
+	err = selinux_xfrm_postroute_last(isec->sid, skb);
 out:
-	return err;
+	return err ? NF_DROP : NF_ACCEPT;
 }
 
 static unsigned int selinux_ipv4_postroute_last(unsigned int hooknum,
diff -puN security/selinux/include/xfrm.h~secmark-add-new-packet-controls-to-selinux security/selinux/include/xfrm.h
--- devel/security/selinux/include/xfrm.h~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/include/xfrm.h	2006-06-01 20:31:50.000000000 -0700
@@ -49,7 +49,7 @@ static inline int selinux_xfrm_sock_rcv_
 
 static inline int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
 {
-	return NF_ACCEPT;
+	return 0;
 }
 
 static inline int selinux_socket_getpeer_stream(struct sock *sk)
diff -puN security/selinux/Kconfig~secmark-add-new-packet-controls-to-selinux security/selinux/Kconfig
--- devel/security/selinux/Kconfig~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/Kconfig	2006-06-01 20:31:50.000000000 -0700
@@ -1,6 +1,7 @@
 config SECURITY_SELINUX
 	bool "NSA SELinux Support"
 	depends on SECURITY_NETWORK && AUDIT && NET && INET
+	select NETWORK_SECMARK
 	default n
 	help
 	  This selects NSA Security-Enhanced Linux (SELinux).
@@ -95,3 +96,31 @@ config SECURITY_SELINUX_CHECKREQPROT_VAL
 	  via /selinux/checkreqprot if authorized by policy.
 
 	  If you are unsure how to answer this question, answer 1.
+
+config SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT
+	bool "NSA SELinux enable new secmark network controls by default"
+	depends on SECURITY_SELINUX
+	default n
+	help
+	  This option determines whether the new secmark-based network
+	  controls will be enabled by default.  If not, the old internal
+	  per-packet controls will be enabled by default, preserving
+	  old behavior.
+
+	  If you enable the new controls, you will need updated
+	  SELinux userspace libraries, tools and policy.  Typically,
+	  your distribution will provide these and enable the new controls
+	  in the kernel they also distribute.
+
+	  Note that this option can be overriden at boot with the
+	  selinux_compat_net parameter, and after boot via
+	  /selinux/compat_net.  See Documentation/kernel-parameters.txt
+	  for details on this parameter.
+
+	  If you enable the new network controls, you will likely
+	  also require the SECMARK and CONNSECMARK targets, as
+	  well as any conntrack helpers for protocols which you
+	  wish to control.
+
+	  If you are unsure what do do here, select N.
+
diff -puN security/selinux/selinuxfs.c~secmark-add-new-packet-controls-to-selinux security/selinux/selinuxfs.c
--- devel/security/selinux/selinuxfs.c~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/selinuxfs.c	2006-06-01 20:31:50.000000000 -0700
@@ -38,6 +38,14 @@
 
 unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
 
+#ifdef CONFIG_SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT
+#define SELINUX_COMPAT_NET_VALUE 0
+#else
+#define SELINUX_COMPAT_NET_VALUE 1
+#endif
+
+int selinux_compat_net = SELINUX_COMPAT_NET_VALUE;
+
 static int __init checkreqprot_setup(char *str)
 {
 	selinux_checkreqprot = simple_strtoul(str,NULL,0) ? 1 : 0;
@@ -45,6 +53,13 @@ static int __init checkreqprot_setup(cha
 }
 __setup("checkreqprot=", checkreqprot_setup);
 
+static int __init selinux_compat_net_setup(char *str)
+{
+	selinux_compat_net = simple_strtoul(str,NULL,0) ? 1 : 0;
+	return 1;
+}
+__setup("selinux_compat_net=", selinux_compat_net_setup);
+
 
 static DEFINE_MUTEX(sel_mutex);
 
@@ -85,6 +100,7 @@ enum sel_inos {
 	SEL_AVC,	/* AVC management directory */
 	SEL_MEMBER,	/* compute polyinstantiation membership decision */
 	SEL_CHECKREQPROT, /* check requested protection, not kernel-applied one */
+	SEL_COMPAT_NET,	/* whether to use old compat network packet controls */
 };
 
 #define TMPBUFLEN	12
@@ -364,6 +380,55 @@ static struct file_operations sel_checkr
 	.write		= sel_write_checkreqprot,
 };
 
+static ssize_t sel_read_compat_net(struct file *filp, char __user *buf,
+				   size_t count, loff_t *ppos)
+{
+	char tmpbuf[TMPBUFLEN];
+	ssize_t length;
+
+	length = scnprintf(tmpbuf, TMPBUFLEN, "%d", selinux_compat_net);
+	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
+}
+
+static ssize_t sel_write_compat_net(struct file * file, const char __user * buf,
+				    size_t count, loff_t *ppos)
+{
+	char *page;
+	ssize_t length;
+	int new_value;
+
+	length = task_has_security(current, SECURITY__LOAD_POLICY);
+	if (length)
+		return length;
+
+	if (count >= PAGE_SIZE)
+		return -ENOMEM;
+	if (*ppos != 0) {
+		/* No partial writes. */
+		return -EINVAL;
+	}
+	page = (char*)get_zeroed_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+	length = -EFAULT;
+	if (copy_from_user(page, buf, count))
+		goto out;
+
+	length = -EINVAL;
+	if (sscanf(page, "%d", &new_value) != 1)
+		goto out;
+
+	selinux_compat_net = new_value ? 1 : 0;
+	length = count;
+out:
+	free_page((unsigned long) page);
+	return length;
+}
+static struct file_operations sel_compat_net_ops = {
+	.read		= sel_read_compat_net,
+	.write		= sel_write_compat_net,
+};
+
 /*
  * Remaining nodes use transaction based IO methods like nfsd/nfsctl.c
  */
@@ -1219,6 +1284,7 @@ static int sel_fill_super(struct super_b
 		[SEL_DISABLE] = {"disable", &sel_disable_ops, S_IWUSR},
 		[SEL_MEMBER] = {"member", &transaction_ops, S_IRUGO|S_IWUGO},
 		[SEL_CHECKREQPROT] = {"checkreqprot", &sel_checkreqprot_ops, S_IRUGO|S_IWUSR},
+		[SEL_COMPAT_NET] = {"compat_net", &sel_compat_net_ops, S_IRUGO|S_IWUSR},
 		/* last one */ {""}
 	};
 	ret = simple_fill_super(sb, SELINUX_MAGIC, selinux_files);
diff -puN security/selinux/xfrm.c~secmark-add-new-packet-controls-to-selinux security/selinux/xfrm.c
--- devel/security/selinux/xfrm.c~secmark-add-new-packet-controls-to-selinux	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/xfrm.c	2006-06-01 20:31:50.000000000 -0700
@@ -356,18 +356,12 @@ int selinux_xfrm_postroute_last(u32 isec
 			struct xfrm_state *x = dst_test->xfrm;
 
 			if (x && selinux_authorizable_xfrm(x))
-				goto accept;
+				goto out;
 		}
 	}
 
 	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__SENDTO, NULL);
-	if (rc)
-		goto drop;
-
-accept:
-	return NF_ACCEPT;
-
-drop:
-	return NF_DROP;
+out:
+	return rc;
 }
_
