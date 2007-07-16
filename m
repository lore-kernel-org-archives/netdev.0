From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [**RFC**] [IPV6]: Support RFC3542 IPV6_PKTINFO socket option.
Date: Mon, 16 Jul 2007 23:44:13 +0900 (JST)
Message-ID: <20070716.234413.103263857.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48086 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760573AbXGPOn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:43:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This patch is just a tentative implementation of RFC3542 IPV6_PKTINFO
sticky option, and is NOT intended to be applied so far.

We need to check if this is okay in RFC POV, anyway.

---
[RFC] [IPV6]: Support RFC3542 IPV6_PKTINFO socket option.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 46b9dce..1ff4059 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -542,6 +542,10 @@ extern void			ipv6_packet_cleanup(void);
 extern int			ip6_datagram_connect(struct sock *sk, 
 						     struct sockaddr *addr, int addr_len);
 
+extern int			ip6_datagram_set_pktinfo(struct in6_pktinfo *src_info,
+							 struct in6_addr *saddr,
+							 struct flowi *fl);
+
 extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
 extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
 						u32 info, u8 *payload);
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 409da3a..752a2c0 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -36,7 +36,8 @@ extern int			datagram_recv_ctl(struct sock *sk,
 						  struct msghdr *msg,
 						  struct sk_buff *skb);
 
-extern int			datagram_send_ctl(struct msghdr *msg,
+extern int			datagram_send_ctl(struct sock *sk,
+						  struct msghdr *msg,
 						  struct flowi *fl,
 						  struct ipv6_txoptions *opt,
 						  int *hlimit, int *tclass);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index fe0f490..cc6e480 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -496,7 +496,55 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
+int ip6_datagram_set_pktinfo(struct in6_pktinfo *src_info,
+			     struct in6_addr *saddr,
+			     struct flowi *fl)
+{
+	struct net_device *dev = NULL;
+	int addr_type;
+
+	if (src_info->ipi6_ifindex) {
+		if (fl->oif && src_info->ipi6_ifindex != fl->oif)
+			return -EINVAL;
+		fl->oif = src_info->ipi6_ifindex;
+	}
+
+	addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+
+	if (addr_type == IPV6_ADDR_ANY)
+		return 0;
+
+	if (saddr) {
+		if (!ipv6_addr_any(saddr))
+			return -EINVAL;
+		if (!ipv6_addr_equal(&src_info->ipi6_addr, saddr))
+			return -EINVAL;
+	}
+
+	if (addr_type & IPV6_ADDR_LINKLOCAL) {
+		if (!src_info->ipi6_ifindex)
+			return -EINVAL;
+		else {
+			dev = dev_get_by_index(src_info->ipi6_ifindex);
+			if (!dev)
+				return -ENODEV;
+		}
+	}
+	if (!ipv6_chk_addr(&src_info->ipi6_addr, dev, 0)) {
+		if (dev)
+			dev_put(dev);
+		return -EINVAL;
+	}
+	if (dev)
+		dev_put(dev);
+
+	ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+
+	return 0;
+}
+
+int datagram_send_ctl(struct sock *sk,
+		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass)
 {
@@ -508,8 +556,6 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 	int err = 0;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		int addr_type;
-		struct net_device *dev = NULL;
 
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
@@ -526,39 +572,13 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				err = -EINVAL;
 				goto exit_f;
 			}
-
 			src_info = (struct in6_pktinfo *)CMSG_DATA(cmsg);
 
-			if (src_info->ipi6_ifindex) {
-				if (fl->oif && src_info->ipi6_ifindex != fl->oif)
-					return -EINVAL;
-				fl->oif = src_info->ipi6_ifindex;
-			}
-
-			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
-
-			if (addr_type == IPV6_ADDR_ANY)
-				break;
-
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev = dev_get_by_index(src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
-			}
-			if (!ipv6_chk_addr(&src_info->ipi6_addr, dev, 0)) {
-				if (dev)
-					dev_put(dev);
-				err = -EINVAL;
+			err = ip6_datagram_set_pktinfo(src_info,
+						       sk ? &inet6_sk(sk)->saddr : NULL,
+						       fl);
+			if (err)
 				goto exit_f;
-			}
-			if (dev)
-				dev_put(dev);
-
-			ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			break;
 
 		case IPV6_FLOWINFO:
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 413a4eb..ad8f259 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -311,7 +311,7 @@ fl_create(struct in6_flowlabel_req *freq, char __user *optval, int optlen, int *
 		msg.msg_control = (void*)(fl->opt+1);
 		flowi.oif = 0;
 
-		err = datagram_send_ctl(&msg, &flowi, fl->opt, &junk, &junk);
+		err = datagram_send_ctl(NULL, &msg, &flowi, fl->opt, &junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d684639..ccc28e9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -451,6 +451,28 @@ sticky_done:
 		break;
 	}
 
+	case IPV6_PKTINFO:
+	{
+		struct flowi fl;
+		struct in6_pktinfo pktinfo;
+		int err;
+
+		if (optlen < sizeof(pktinfo))
+			return -EINVAL;
+		if (copy_from_user(&pktinfo, optval, sizeof(pktinfo)))
+			return -EFAULT;
+
+		fl.fl6_flowlabel = 0;
+		fl.oif = sk->sk_bound_dev_if;
+
+		lock_sock(sk);
+		err = ip6_datagram_set_pktinfo(&pktinfo, &fl);
+		if (!err)
+			sk->sk_bound_dev_if = fl.oif;
+		release_sock(sk);
+		break;
+	}
+
 	case IPV6_2292PKTOPTIONS:
 	{
 		struct ipv6_txoptions *opt = NULL;
@@ -485,7 +507,7 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(sk, &msg, &fl, opt, &junk, &junk);
 		if (retv)
 			goto done;
 update:
@@ -928,6 +950,12 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->ipv6only;
 		break;
 
+	case IPV6_PKTINFO:
+		lock_sock(sk);
+		val = sk->sk_bound_dev_if;
+		release_sock(sk);
+		break;
+
 	case IPV6_RECVPKTINFO:
 		val = np->rxopt.bits.rxinfo;
 		break;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e27383d..a0e7346 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -796,7 +796,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sk, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4210951..f6f50f1 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -700,7 +700,7 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sk, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
