From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Remove unused dst_pid field in netlink_skb_parms
Date: Mon, 27 Nov 2006 10:02:38 +0100
Message-ID: <20061127090238.GU8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:27351 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1757476AbWK0JCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 04:02:18 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The destination PID is passed directly to netlink_unicast()
respectively netlink_multicast().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/linux/netlink.h
===================================================================
--- net-2.6.20.orig/include/linux/netlink.h	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/include/linux/netlink.h	2006-11-25 15:59:14.000000000 +0100
@@ -141,7 +141,6 @@
 {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
-	__u32			dst_pid;
 	__u32			dst_group;
 	kernel_cap_t		eff_cap;
 	__u32			loginuid;	/* Login (audit) uid */
Index: net-2.6.20/net/decnet/dn_route.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_route.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/decnet/dn_route.c	2006-11-25 15:59:14.000000000 +0100
@@ -1592,8 +1592,6 @@
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
-
 	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
 
 	if (err == 0)
Index: net-2.6.20/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_frontend.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_frontend.c	2006-11-25 15:59:14.000000000 +0100
@@ -811,7 +811,6 @@
 	
 	pid = nlh->nlmsg_pid;           /*pid of sending process */
 	NETLINK_CB(skb).pid = 0;         /* from kernel */
-	NETLINK_CB(skb).dst_pid = pid;
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
 	netlink_unicast(sk, skb, pid, MSG_DONTWAIT);
 }    
Index: net-2.6.20/net/netfilter/nf_conntrack_netlink.c
===================================================================
--- net-2.6.20.orig/net/netfilter/nf_conntrack_netlink.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/netfilter/nf_conntrack_netlink.c	2006-11-25 15:59:14.000000000 +0100
@@ -751,7 +751,6 @@
 		nf_ct_put(ct);
 		return -ENOMEM;
 	}
-	NETLINK_CB(skb2).dst_pid = NETLINK_CB(skb).pid;
 
 	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 
 				  IPCTNL_MSG_CT_NEW, 1, ct);
@@ -1291,8 +1290,7 @@
 	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb2)
 		goto out;
-	NETLINK_CB(skb2).dst_pid = NETLINK_CB(skb).pid;
-	
+
 	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid, 
 				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW,
 				      1, exp);
Index: net-2.6.20/net/ipv4/netfilter/ip_conntrack_netlink.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/ip_conntrack_netlink.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/ip_conntrack_netlink.c	2006-11-25 15:59:14.000000000 +0100
@@ -742,7 +742,6 @@
 		ip_conntrack_put(ct);
 		return -ENOMEM;
 	}
-	NETLINK_CB(skb2).dst_pid = NETLINK_CB(skb).pid;
 
 	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 
 				  IPCTNL_MSG_CT_NEW, 1, ct);
@@ -1272,8 +1271,7 @@
 	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb2)
 		goto out;
-	NETLINK_CB(skb2).dst_pid = NETLINK_CB(skb).pid;
-	
+
 	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid, 
 				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW,
 				      1, exp);
Index: net-2.6.20/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.20.orig/net/xfrm/xfrm_user.c	2006-11-25 15:35:51.000000000 +0100
+++ net-2.6.20/net/xfrm/xfrm_user.c	2006-11-25 15:59:14.000000000 +0100
@@ -649,7 +649,6 @@
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 	info.in_skb = in_skb;
 	info.out_skb = skb;
 	info.nlmsg_seq = seq;
@@ -1167,7 +1166,6 @@
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 	info.in_skb = in_skb;
 	info.out_skb = skb;
 	info.nlmsg_seq = seq;
Index: net-2.6.20/net/netlink/af_netlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/af_netlink.c	2006-11-25 15:59:23.000000000 +0100
+++ net-2.6.20/net/netlink/af_netlink.c	2006-11-25 15:59:43.000000000 +0100
@@ -1153,7 +1153,6 @@
 		goto out;
 
 	NETLINK_CB(skb).pid	= nlk->pid;
-	NETLINK_CB(skb).dst_pid = dst_pid;
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).loginuid = audit_get_loginuid(current->audit_context);
 	selinux_get_task_sid(current, &(NETLINK_CB(skb).sid));
