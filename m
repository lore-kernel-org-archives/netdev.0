From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 3/6] selinux: Remove the "compat_net" compatibility code
Date: Fri, 27 Mar 2009 17:10:41 -0400
Message-ID: <20090327211041.17777.95398.stgit@flek.lan>
References: <20090327205520.17777.32557.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, casey@schaufler-ca.com,
	etienne.basset@numericable.fr
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:44719 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436AbZC0VKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 17:10:47 -0400
In-Reply-To: <20090327205520.17777.32557.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SELinux "compat_net" is marked as deprecated, the time has come to
finally remove it from the kernel.  Further code simplifications are
likely in the future, but this patch was intended to be a simple,
straight-up removal of the compat_net code.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 Documentation/feature-removal-schedule.txt |   11 --
 Documentation/kernel-parameters.txt        |    9 --
 security/selinux/hooks.c                   |  153 +---------------------------
 security/selinux/selinuxfs.c               |   68 ------------
 4 files changed, 7 insertions(+), 234 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index e47c0ff..9b2cd68 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -328,17 +328,6 @@ Who:	Hans de Goede <hdegoede@redhat.com>
 
 ---------------------------
 
-What:	SELinux "compat_net" functionality
-When:	2.6.30 at the earliest
-Why:	In 2.6.18 the Secmark concept was introduced to replace the "compat_net"
-	network access control functionality of SELinux.  Secmark offers both
-	better performance and greater flexibility than the "compat_net"
-	mechanism.  Now that the major Linux distributions have moved to
-	Secmark, it is time to deprecate the older mechanism and start the
-	process of removing the old code.
-Who:	Paul Moore <paul.moore@hp.com>
----------------------------
-
 What:	sysfs ui for changing p4-clockmod parameters
 When:	September 2009
 Why:	See commits 129f8ae9b1b5be94517da76009ea956e89104ce8 and
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index fa4e123..d1b0827 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2019,15 +2019,6 @@ and is between 256 and 4096 characters. It is defined in the file
 			If enabled at boot time, /selinux/disable can be used
 			later to disable prior to initial policy load.
 
-	selinux_compat_net =
-			[SELINUX] Set initial selinux_compat_net flag value.
-                        Format: { "0" | "1" }
-                        0 -- use new secmark-based packet controls
-                        1 -- use legacy packet controls
-                        Default value is 0 (preferred).
-                        Value can be changed at runtime via
-                        /selinux/compat_net.
-
 	serialnumber	[BUGS=X86-32]
 
 	shapers=	[NET]
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index ee2e781..ba808ef 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -93,7 +93,6 @@
 
 extern unsigned int policydb_loaded_version;
 extern int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm);
-extern int selinux_compat_net;
 extern struct security_operations *security_ops;
 
 /* SECMARK reference count */
@@ -4019,72 +4018,6 @@ static int selinux_inet_sys_rcv_skb(int ifindex, char *addrp, u16 family,
 			    SECCLASS_NODE, NODE__RECVFROM, ad);
 }
 
-static int selinux_sock_rcv_skb_iptables_compat(struct sock *sk,
-						struct sk_buff *skb,
-						struct avc_audit_data *ad,
-						u16 family,
-						char *addrp)
-{
-	int err;
-	struct sk_security_struct *sksec = sk->sk_security;
-	u16 sk_class;
-	u32 netif_perm, node_perm, recv_perm;
-	u32 port_sid, node_sid, if_sid, sk_sid;
-
-	sk_sid = sksec->sid;
-	sk_class = sksec->sclass;
-
-	switch (sk_class) {
-	case SECCLASS_UDP_SOCKET:
-		netif_perm = NETIF__UDP_RECV;
-		node_perm = NODE__UDP_RECV;
-		recv_perm = UDP_SOCKET__RECV_MSG;
-		break;
-	case SECCLASS_TCP_SOCKET:
-		netif_perm = NETIF__TCP_RECV;
-		node_perm = NODE__TCP_RECV;
-		recv_perm = TCP_SOCKET__RECV_MSG;
-		break;
-	case SECCLASS_DCCP_SOCKET:
-		netif_perm = NETIF__DCCP_RECV;
-		node_perm = NODE__DCCP_RECV;
-		recv_perm = DCCP_SOCKET__RECV_MSG;
-		break;
-	default:
-		netif_perm = NETIF__RAWIP_RECV;
-		node_perm = NODE__RAWIP_RECV;
-		recv_perm = 0;
-		break;
-	}
-
-	err = sel_netif_sid(skb->iif, &if_sid);
-	if (err)
-		return err;
-	err = avc_has_perm(sk_sid, if_sid, SECCLASS_NETIF, netif_perm, ad);
-	if (err)
-		return err;
-
-	err = sel_netnode_sid(addrp, family, &node_sid);
-	if (err)
-		return err;
-	err = avc_has_perm(sk_sid, node_sid, SECCLASS_NODE, node_perm, ad);
-	if (err)
-		return err;
-
-	if (!recv_perm)
-		return 0;
-	err = sel_netport_sid(sk->sk_protocol,
-			      ntohs(ad->u.net.sport), &port_sid);
-	if (unlikely(err)) {
-		printk(KERN_WARNING
-		       "SELinux: failure in"
-		       " selinux_sock_rcv_skb_iptables_compat(),"
-		       " network port label not found\n");
-		return err;
-	}
-	return avc_has_perm(sk_sid, port_sid, sk_class, recv_perm, ad);
-}
-
 static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 				       u16 family)
 {
@@ -4102,14 +4035,12 @@ static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 	if (err)
 		return err;
 
-	if (selinux_compat_net)
-		err = selinux_sock_rcv_skb_iptables_compat(sk, skb, &ad,
-							   family, addrp);
-	else if (selinux_secmark_enabled())
+	if (selinux_secmark_enabled()) {
 		err = avc_has_perm(sk_sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
-	if (err)
-		return err;
+		if (err)
+			return err;
+	}
 
 	if (selinux_policycap_netpeer) {
 		err = selinux_skb_peerlbl_sid(skb, family, &peer_sid);
@@ -4151,7 +4082,7 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 * to the selinux_sock_rcv_skb_compat() function to deal with the
 	 * special handling.  We do this in an attempt to keep this function
 	 * as fast and as clean as possible. */
-	if (selinux_compat_net || !selinux_policycap_netpeer)
+	if (!selinux_policycap_netpeer)
 		return selinux_sock_rcv_skb_compat(sk, skb, family);
 
 	secmark_active = selinux_secmark_enabled();
@@ -4516,71 +4447,6 @@ static unsigned int selinux_ipv4_output(unsigned int hooknum,
 	return selinux_ip_output(skb, PF_INET);
 }
 
-static int selinux_ip_postroute_iptables_compat(struct sock *sk,
-						int ifindex,
-						struct avc_audit_data *ad,
-						u16 family, char *addrp)
-{
-	int err;
-	struct sk_security_struct *sksec = sk->sk_security;
-	u16 sk_class;
-	u32 netif_perm, node_perm, send_perm;
-	u32 port_sid, node_sid, if_sid, sk_sid;
-
-	sk_sid = sksec->sid;
-	sk_class = sksec->sclass;
-
-	switch (sk_class) {
-	case SECCLASS_UDP_SOCKET:
-		netif_perm = NETIF__UDP_SEND;
-		node_perm = NODE__UDP_SEND;
-		send_perm = UDP_SOCKET__SEND_MSG;
-		break;
-	case SECCLASS_TCP_SOCKET:
-		netif_perm = NETIF__TCP_SEND;
-		node_perm = NODE__TCP_SEND;
-		send_perm = TCP_SOCKET__SEND_MSG;
-		break;
-	case SECCLASS_DCCP_SOCKET:
-		netif_perm = NETIF__DCCP_SEND;
-		node_perm = NODE__DCCP_SEND;
-		send_perm = DCCP_SOCKET__SEND_MSG;
-		break;
-	default:
-		netif_perm = NETIF__RAWIP_SEND;
-		node_perm = NODE__RAWIP_SEND;
-		send_perm = 0;
-		break;
-	}
-
-	err = sel_netif_sid(ifindex, &if_sid);
-	if (err)
-		return err;
-	err = avc_has_perm(sk_sid, if_sid, SECCLASS_NETIF, netif_perm, ad);
-		return err;
-
-	err = sel_netnode_sid(addrp, family, &node_sid);
-	if (err)
-		return err;
-	err = avc_has_perm(sk_sid, node_sid, SECCLASS_NODE, node_perm, ad);
-	if (err)
-		return err;
-
-	if (send_perm != 0)
-		return 0;
-
-	err = sel_netport_sid(sk->sk_protocol,
-			      ntohs(ad->u.net.dport), &port_sid);
-	if (unlikely(err)) {
-		printk(KERN_WARNING
-		       "SELinux: failure in"
-		       " selinux_ip_postroute_iptables_compat(),"
-		       " network port label not found\n");
-		return err;
-	}
-	return avc_has_perm(sk_sid, port_sid, sk_class, send_perm, ad);
-}
-
 static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 						int ifindex,
 						u16 family)
@@ -4601,15 +4467,10 @@ static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 	if (selinux_parse_skb(skb, &ad, &addrp, 0, &proto))
 		return NF_DROP;
 
-	if (selinux_compat_net) {
-		if (selinux_ip_postroute_iptables_compat(skb->sk, ifindex,
-							 &ad, family, addrp))
-			return NF_DROP;
-	} else if (selinux_secmark_enabled()) {
+	if (selinux_secmark_enabled())
 		if (avc_has_perm(sksec->sid, skb->secmark,
 				 SECCLASS_PACKET, PACKET__SEND, &ad))
 			return NF_DROP;
-	}
 
 	if (selinux_policycap_netpeer)
 		if (selinux_xfrm_postroute_last(sksec->sid, skb, &ad, proto))
@@ -4633,7 +4494,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	 * to the selinux_ip_postroute_compat() function to deal with the
 	 * special handling.  We do this in an attempt to keep this function
 	 * as fast and as clean as possible. */
-	if (selinux_compat_net || !selinux_policycap_netpeer)
+	if (!selinux_policycap_netpeer)
 		return selinux_ip_postroute_compat(skb, ifindex, family);
 #ifdef CONFIG_XFRM
 	/* If skb->dst->xfrm is non-NULL then the packet is undergoing an IPsec
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index d3c8b98..2d5136e 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -47,8 +47,6 @@ static char *policycap_names[] = {
 
 unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
 
-int selinux_compat_net = 0;
-
 static int __init checkreqprot_setup(char *str)
 {
 	unsigned long checkreqprot;
@@ -58,16 +56,6 @@ static int __init checkreqprot_setup(char *str)
 }
 __setup("checkreqprot=", checkreqprot_setup);
 
-static int __init selinux_compat_net_setup(char *str)
-{
-	unsigned long compat_net;
-	if (!strict_strtoul(str, 0, &compat_net))
-		selinux_compat_net = compat_net ? 1 : 0;
-	return 1;
-}
-__setup("selinux_compat_net=", selinux_compat_net_setup);
-
-
 static DEFINE_MUTEX(sel_mutex);
 
 /* global data for booleans */
@@ -450,61 +438,6 @@ static const struct file_operations sel_checkreqprot_ops = {
 	.write		= sel_write_checkreqprot,
 };
 
-static ssize_t sel_read_compat_net(struct file *filp, char __user *buf,
-				   size_t count, loff_t *ppos)
-{
-	char tmpbuf[TMPBUFLEN];
-	ssize_t length;
-
-	length = scnprintf(tmpbuf, TMPBUFLEN, "%d", selinux_compat_net);
-	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
-}
-
-static ssize_t sel_write_compat_net(struct file *file, const char __user *buf,
-				    size_t count, loff_t *ppos)
-{
-	char *page;
-	ssize_t length;
-	int new_value;
-
-	length = task_has_security(current, SECURITY__LOAD_POLICY);
-	if (length)
-		return length;
-
-	if (count >= PAGE_SIZE)
-		return -ENOMEM;
-	if (*ppos != 0) {
-		/* No partial writes. */
-		return -EINVAL;
-	}
-	page = (char *)get_zeroed_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-	length = -EFAULT;
-	if (copy_from_user(page, buf, count))
-		goto out;
-
-	length = -EINVAL;
-	if (sscanf(page, "%d", &new_value) != 1)
-		goto out;
-
-	if (new_value) {
-		printk(KERN_NOTICE
-		       "SELinux: compat_net is deprecated, please use secmark"
-		       " instead\n");
-		selinux_compat_net = 1;
-	} else
-		selinux_compat_net = 0;
-	length = count;
-out:
-	free_page((unsigned long) page);
-	return length;
-}
-static const struct file_operations sel_compat_net_ops = {
-	.read		= sel_read_compat_net,
-	.write		= sel_write_compat_net,
-};
-
 /*
  * Remaining nodes use transaction based IO methods like nfsd/nfsctl.c
  */
@@ -1665,7 +1598,6 @@ static int sel_fill_super(struct super_block *sb, void *data, int silent)
 		[SEL_DISABLE] = {"disable", &sel_disable_ops, S_IWUSR},
 		[SEL_MEMBER] = {"member", &transaction_ops, S_IRUGO|S_IWUGO},
 		[SEL_CHECKREQPROT] = {"checkreqprot", &sel_checkreqprot_ops, S_IRUGO|S_IWUSR},
-		[SEL_COMPAT_NET] = {"compat_net", &sel_compat_net_ops, S_IRUGO|S_IWUSR},
 		[SEL_REJECT_UNKNOWN] = {"reject_unknown", &sel_handle_unknown_ops, S_IRUGO},
 		[SEL_DENY_UNKNOWN] = {"deny_unknown", &sel_handle_unknown_ops, S_IRUGO},
 		/* last one */ {""}

