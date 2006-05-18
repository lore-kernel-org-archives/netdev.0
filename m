From: James Morris <jmorris@namei.org>
Subject: [PATCH 07/07] secmark: Add new packet controls to SELinux
Date: Thu, 18 May 2006 05:29:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180528240.569@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:44716 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751088AbWERJ3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:29:41 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds new per-packet access controls to SELinux, replacing the 
old packet controls.

Packets are labeled with the iptables SECMARK and CONNSECMARK targets, 
then security policy for the packets is enforced with these controls.

To allow for a smooth transition to the new controls, the old code is 
still present, but not active by default.  To restore previous behavior, 
the old controls may be activated at runtime by writing a '1' to 
/selinux/compat_net, and also via the kernel boot parameter 
selinux_compat_net.  Switching between the network control models requires 
the security load_policy permission.  The old controls will probably 
eventually be removed and any continued use is discouraged.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 Documentation/kernel-parameters.txt |    9 +
 security/selinux/Kconfig            |    2 
 security/selinux/hooks.c            |  241 +++++++++++++++++++-----------------
 security/selinux/include/xfrm.h     |    2 
 security/selinux/selinuxfs.c        |   59 ++++++++
 security/selinux/xfrm.c             |   12 -
 6 files changed, 205 insertions(+), 120 deletions(-)


diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/Documentation/kernel-parameters.txt linux-2.6.17-rc4-mm1.w/Documentation/kernel-parameters.txt
--- linux-2.6.17-rc4-mm1.p/Documentation/kernel-parameters.txt	2006-05-18 03:07:47.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/Documentation/kernel-parameters.txt	2006-05-17 23:45:13.000000000 -0400
@@ -1414,6 +1414,15 @@ running once the system is up.
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
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/hooks.c linux-2.6.17-rc4-mm1.w/security/selinux/hooks.c
--- linux-2.6.17-rc4-mm1.p/security/selinux/hooks.c	2006-05-18 03:07:47.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/hooks.c	2006-05-17 21:01:07.000000000 -0400
@@ -80,6 +80,7 @@
 
 extern unsigned int policydb_loaded_version;
 extern int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm);
+extern int selinux_compat_net;
 
 #ifdef CONFIG_SECURITY_SELINUX_DEVELOP
 int selinux_enforcing = 0;
@@ -3216,47 +3217,16 @@ static int selinux_socket_unix_may_send(
 	return 0;
 }
 
-static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb, struct avc_audit_data *ad,
+				       u32 sock_sid, u16 sock_class, u16 family, char *addrp, int len)
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
 
-	family = sk->sk_family;
-	if (family != PF_INET && family != PF_INET6)
+	if (!skb->dev)
 		goto out;
 
-	/* Handle mapped IPv4 packets arriving via IPv6 sockets */
-	if (family == PF_INET6 && skb->protocol == ntohs(ETH_P_IP))
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
-
-	dev = skb->dev;
-	if (!dev)
-		goto out;
-
-	err = sel_netif_sids(dev, &if_sid, NULL);
+	err = sel_netif_sids(skb->dev, &if_sid, NULL);
 	if (err)
 		goto out;
 
@@ -3279,44 +3249,88 @@ static int selinux_socket_sock_rcv_skb(s
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
@@ -3456,42 +3470,18 @@ out:
 
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
@@ -3511,55 +3501,88 @@ static unsigned int selinux_ip_postroute
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
+	
+	sk = skb->sk;
+	if (!sk)
+		goto out;
+		
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
 
-	if (err != NF_ACCEPT)
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 0);
+	if (err)
 		goto out;
 
-	err = selinux_xfrm_postroute_last(isec->sid, skb);
+	if (selinux_compat_net)
+		err = selinux_ip_postroute_last_compat(sk, dev, isec, &ad,
+						       family, addrp, len);
+	else
+		err = avc_has_perm(isec->sid, skb->secmark, SECCLASS_PACKET, 
+				   PACKET__SEND, &ad);
+	
+	if (err)
+		goto out;
 
+	err = selinux_xfrm_postroute_last(isec->sid, skb);
 out:
-	return err;
+	return err ? NF_DROP : NF_ACCEPT;
 }
 
 static unsigned int selinux_ipv4_postroute_last(unsigned int hooknum,
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/include/xfrm.h linux-2.6.17-rc4-mm1.w/security/selinux/include/xfrm.h
--- linux-2.6.17-rc4-mm1.p/security/selinux/include/xfrm.h	2006-05-18 03:07:47.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/include/xfrm.h	2006-05-17 21:01:07.000000000 -0400
@@ -49,7 +49,7 @@ static inline int selinux_xfrm_sock_rcv_
 
 static inline int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
 {
-	return NF_ACCEPT;
+	return 0;
 }
 
 static inline int selinux_socket_getpeer_stream(struct sock *sk)
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/Kconfig linux-2.6.17-rc4-mm1.w/security/selinux/Kconfig
--- linux-2.6.17-rc4-mm1.p/security/selinux/Kconfig	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc4-mm1.w/security/selinux/Kconfig	2006-05-18 03:10:02.000000000 -0400
@@ -1,6 +1,6 @@
 config SECURITY_SELINUX
 	bool "NSA SELinux Support"
-	depends on SECURITY_NETWORK && AUDIT && NET && INET
+	depends on SECURITY_NETWORK && AUDIT && NET && INET && NETWORK_SECMARK
 	default n
 	help
 	  This selects NSA Security-Enhanced Linux (SELinux).
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/selinuxfs.c linux-2.6.17-rc4-mm1.w/security/selinux/selinuxfs.c
--- linux-2.6.17-rc4-mm1.p/security/selinux/selinuxfs.c	2006-05-18 03:07:47.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/selinuxfs.c	2006-05-17 21:01:07.000000000 -0400
@@ -37,6 +37,7 @@
 #include "conditional.h"
 
 unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
+int selinux_compat_net;
 
 static int __init checkreqprot_setup(char *str)
 {
@@ -45,6 +46,13 @@ static int __init checkreqprot_setup(cha
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
 
@@ -85,6 +93,7 @@ enum sel_inos {
 	SEL_AVC,	/* AVC management directory */
 	SEL_MEMBER,	/* compute polyinstantiation membership decision */
 	SEL_CHECKREQPROT, /* check requested protection, not kernel-applied one */
+	SEL_COMPAT_NET,	/* whether to use old compat network packet controls */
 };
 
 #define TMPBUFLEN	12
@@ -364,6 +373,55 @@ static struct file_operations sel_checkr
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
@@ -1219,6 +1277,7 @@ static int sel_fill_super(struct super_b
 		[SEL_DISABLE] = {"disable", &sel_disable_ops, S_IWUSR},
 		[SEL_MEMBER] = {"member", &transaction_ops, S_IRUGO|S_IWUGO},
 		[SEL_CHECKREQPROT] = {"checkreqprot", &sel_checkreqprot_ops, S_IRUGO|S_IWUSR},
+		[SEL_COMPAT_NET] = {"compat_net", &sel_compat_net_ops, S_IRUGO|S_IWUSR},
 		/* last one */ {""}
 	};
 	ret = simple_fill_super(sb, SELINUX_MAGIC, selinux_files);
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/xfrm.c linux-2.6.17-rc4-mm1.w/security/selinux/xfrm.c
--- linux-2.6.17-rc4-mm1.p/security/selinux/xfrm.c	2006-05-18 03:07:47.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/xfrm.c	2006-05-17 21:01:07.000000000 -0400
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
