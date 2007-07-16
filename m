From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [**RFC**] [IPV6]: Support RFC3542 IPV6_PKTINFO socket option.
Date: Tue, 17 Jul 2007 01:55:18 +0900 (JST)
Message-ID: <20070717.015518.45418916.yoshfuji@linux-ipv6.org>
References: <20070716.234413.103263857.yoshfuji@linux-ipv6.org>
	<469B8F50.7000906@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48090 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbXGPQyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 12:54:39 -0400
In-Reply-To: <469B8F50.7000906@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <469B8F50.7000906@hp.com> (at Mon, 16 Jul 2007 11:31:28 -0400), Vlad Yasevich <vladislav.yasevich@hp.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Hello.
> > 
> > This patch is just a tentative implementation of RFC3542 IPV6_PKTINFO
> > sticky option, and is NOT intended to be applied so far.
> > 
> > We need to check if this is okay in RFC POV, anyway.
> 
> ok.  comments from just the RFC pov.

Thank you.  Here's take 2.

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 78a0d06..cdc4846 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -546,6 +546,10 @@ extern void			ipv6_packet_cleanup(void);
 extern int			ip6_datagram_connect(struct sock *sk, 
 						     struct sockaddr *addr, int addr_len);
 
+extern int			ip6_datagram_set_pktinfo(struct sock *sk,
+							 struct in6_pktinfo *src_info,
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
index b1fe7ac..119363a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -496,7 +496,58 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
+int ip6_datagram_set_pktinfo(struct sock *sk,
+			     struct in6_pktinfo *src_info,
+			     struct flowi *fl)
+{
+	struct net_device *dev = NULL;
+	int addr_type;
+	int err = 0;
+	struct in6_addr *saddr = sk ? &inet6_sk(sk)->saddr : NULL;
+
+	if (src_info->ipi6_ifindex) {
+		dev = dev_get_by_index(src_info->ipi6_ifindex);
+		if (!dev)
+			return -ENODEV;
+	}
+
+	fl->oif = src_info->ipi6_ifindex;
+
+	addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+	if (addr_type == IPV6_ADDR_ANY)
+		goto out;
+
+	err = -EINVAL;
+
+	if (sk && inet_sk(sk)->is_icsk)
+		goto out;
+
+	if (saddr) {
+		if (!ipv6_addr_any(saddr))
+			goto out;
+		if (!ipv6_addr_equal(&src_info->ipi6_addr, saddr))
+			goto out;
+	}
+
+	if (addr_type & IPV6_ADDR_LINKLOCAL) {
+		if (!src_info->ipi6_ifindex)
+			goto out;
+	}
+	if (!ipv6_chk_addr(&src_info->ipi6_addr, dev, 0)) {
+		err = -EADDRNOTAVAIL;
+		goto out;
+	}
+	err = 0;
+	ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+out:
+	if (dev)
+		dev_put(dev);
+
+	return err;
+}
+
+int datagram_send_ctl(struct sock *sk,
+		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass)
 {
@@ -508,8 +559,6 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 	int err = 0;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		int addr_type;
-		struct net_device *dev = NULL;
 
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
@@ -526,39 +575,11 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
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
+			err = ip6_datagram_set_pktinfo(sk, src_info, fl);
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
index c206a15..22e35fe 100644
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
index aa3d07c..3ebcef8 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -456,6 +456,28 @@ sticky_done:
 		break;
 	}
 
+	case IPV6_PKTINFO:
+	{
+		struct in6_pktinfo pktinfo;
+		struct flowi fl;
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
+		err = ip6_datagram_set_pktinfo(sk, &pktinfo, &fl);
+		if (!err)
+			sk->sk_bound_dev_if = fl.oif;
+		release_sock(sk);
+		break;
+	}
+
 	case IPV6_2292PKTOPTIONS:
 	{
 		struct ipv6_txoptions *opt = NULL;
@@ -490,7 +512,7 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(sk, &msg, &fl, opt, &junk, &junk);
 		if (retv)
 			goto done;
 update:
@@ -933,6 +955,29 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->ipv6only;
 		break;
 
+	case IPV6_PKTINFO:
+	{
+		struct in6_pktinfo pktinfo;
+
+		lock_sock(sk);
+		val = sk->sk_bound_dev_if;
+		release_sock(sk);
+
+		/*
+		 * XXX: we may need to clear pktinfo to avoid
+		 * disclosing stack here.
+		 */
+		pktinfo.ipi6_addr = inet6_sk(sk)->saddr;
+		pktinfo.ipi6_ifindex = val;
+
+		len = min_t(unsigned int, sizeof(pktinfo), len);
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &pktinfo, len))
+			return -EFAULT;
+		return 0;
+	}
+
 	case IPV6_RECVPKTINFO:
 		val = np->rxopt.bits.rxinfo;
 		break;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a58459a..9fd8e93 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -772,7 +772,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(NULL, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4210951..3e8b7cf 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -700,7 +700,7 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(NULL, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
