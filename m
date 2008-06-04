From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL 2.6.25.4] IPv6 Updates (Take 2)
Date: Thu, 05 Jun 2008 02:38:17 +0900 (JST)
Message-ID: <20080605.023817.59532180.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58109 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbYFDRhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 13:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following fixes on top of 2.6.25.4
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.25.4-misc-20080605

Regards,

--yoshfuji
HEADLINES
---------

    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    [IPv6] addrconf: Check range of prefix length
    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    [IPV6]: Fix the return value of get destination options with NULL data pointer
    [IPV6]: Fix the data length of get destination options with short length
    [IPV6]: Check outgoing interface even if source address is unspecified.
    [IPV6] NETNS: Handle ancillary data in appropriate namespace.
    [IPV6]: Do not change protocol for raw IPv6 sockets.
    [IPV6]: inet_sk(sk)->cork.opt leak
    [IPV6]: Do not change protocol for UDPv6 sockets with pending sent data.

DIFFSTAT
--------

 include/net/transp_v6.h  |    3 ++-
 include/net/udp.h        |    1 +
 net/ipv4/tunnel4.c       |    2 +-
 net/ipv4/udp.c           |    3 ++-
 net/ipv6/addrconf.c      |   10 ++++++++--
 net/ipv6/datagram.c      |   45 ++++++++++++++++++++++++---------------------
 net/ipv6/ip6_flowlabel.c |    7 ++++---
 net/ipv6/ipv6_sockglue.c |   21 ++++++++++++++++-----
 net/ipv6/raw.c           |    2 +-
 net/ipv6/tunnel6.c       |    2 +-
 net/ipv6/udp.c           |    8 ++++++--
 11 files changed, 66 insertions(+), 38 deletions(-)

CHANGESETS
----------

commit 3db452604d2ea451bc7702ac413373bcfebbc946
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 4 01:30:25 2008 +0900

    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    
    ip6_sk_dst_lookup returns held dst entry. It should be released
    on all paths beyond this point. Add missed release when up->pending
    is set.
    
    Bug report and initial patch by Denis V. Lunev <den@openvz.org>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
    Acked-by: Denis V. Lunev <den@openvz.org>

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 53739de..1e13ed3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -844,12 +844,14 @@ do_append_data:
 		} else {
 			dst_release(dst);
 		}
+		dst = NULL;
 	}
 
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
 out:
+	dst_release(dst);
 	fl6_sock_release(flowlabel);
 	if (!err)
 		return len;

---
commit dc2a825415d08d61e07c9166c8fe7bc89a48abf4
Author: Thomas Graf <tgraf@suug.ch>
Date:   Wed May 28 16:54:22 2008 +0200

    [IPv6] addrconf: Check range of prefix length
    
    As of now, the prefix length is not vaildated when adding or deleting
    addresses. The value is passed directly into the inet6_ifaddr structure
    and later passed on to memcmp() as length indicator which relies on
    the value never to exceed 128 (bits).
    
    Due to the missing check, the currently code allows for any 8 bit
    value to be passed on as prefix length while using the netlink
    interface, and any 32 bit value while using the ioctl interface.
    
    [Use unsigned int instead to generate better code - yoshfuji]
    
    Signed-off-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e08955b..5e1c4e8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1946,7 +1946,7 @@ err_exit:
 /*
  *	Manual configuration of address on an interface
  */
-static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
+static int inet6_addr_add(int ifindex, struct in6_addr *pfx, unsigned int plen,
 			  __u8 ifa_flags, __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
@@ -1957,6 +1957,9 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 
 	ASSERT_RTNL();
 
+	if (plen > 128)
+		return -EINVAL;
+
 	/* check the lifetime */
 	if (!valid_lft || prefered_lft > valid_lft)
 		return -EINVAL;
@@ -2006,12 +2009,15 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 	return PTR_ERR(ifp);
 }
 
-static int inet6_addr_del(int ifindex, struct in6_addr *pfx, int plen)
+static int inet6_addr_del(int ifindex, struct in6_addr *pfx, unsigned int plen)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
 
+	if (plen > 128)
+		return -EINVAL;
+
 	if ((dev = __dev_get_by_index(&init_net, ifindex)) == NULL)
 		return -ENODEV;
 

---
commit 7970c227e48aa8f049dc8800c70e7ee81d406352
Author: Colin <colins@sjtu.edu.cn>
Date:   Tue May 27 00:04:43 2008 +0800

    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    
    I discover a strange behavior in [ipv4 in ipv6] tunnel. When IPv6 tunnel
    payload is less than 40(0x28), packet can be sent to network, received in
    physical interface, but not seen in IP tunnel interface. No counter increase
    in tunnel interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 6323921..669f280 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -109,7 +109,7 @@ static int tunnel46_rcv(struct sk_buff *skb)
 {
 	struct xfrm6_tunnel *handler;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto drop;
 
 	for (handler = tunnel46_handlers; handler; handler = handler->next)

---
commit a5d525a9d3918310ab17c0ab86278ddf025e7656
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri May 30 11:35:03 2008 +0900

    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 978b3fd..cd5a921 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -97,7 +97,7 @@ static int tunnel64_rcv(struct sk_buff *skb)
 {
 	struct xfrm_tunnel *handler;
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto drop;
 
 	for (handler = tunnel64_handlers; handler; handler = handler->next)

---
commit afaacea56e29898df10b8ea229897bdfd6237815
Author: Yang Hongyang <yanghy@cn.fujitsu.com>
Date:   Wed May 28 16:23:47 2008 +0800

    [IPV6]: Fix the return value of get destination options with NULL data pointer
    
    If we pass NULL data buffer to getsockopt(), it will return 0,
    and the option length is set to -EFAULT:
        getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS, NULL, &len);
    
    This is because ipv6_getsockopt_sticky() will return -EFAULT or
    -EINVAL if some error occur.
    
    This patch fix this problem.
    
    Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bf2a686..145b530 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -969,6 +969,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		len = ipv6_getsockopt_sticky(sk, np->opt,
 					     optname, optval, len);
 		release_sock(sk);
+		/* check if ipv6_getsockopt_sticky() returns err code */
+		if (len < 0)
+			return len;
 		return put_user(len, optlen);
 	}
 

---
commit 56cca8c540c73223da16cda637dec238fc75a46c
Author: Yang Hongyang <yanghy@cn.fujitsu.com>
Date:   Wed May 28 16:27:28 2008 +0800

    [IPV6]: Fix the data length of get destination options with short length
    
     If get destination options with length which is not enough for that
    option,getsockopt() will still return the real length of the option,
    which is larger then the buffer space.
     This is because ipv6_getsockopt_sticky() returns the real length of
    the option.
    
    This patch fix this problem.
    
    Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 145b530..3ab9d8f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -829,7 +829,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
-	return ipv6_optlen(hdr);
+	return len;
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,

---
commit 77b41523f597205550768f8ed8c9790a8cb5694f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 4 13:46:13 2008 +0900

    [IPV6]: Check outgoing interface even if source address is unspecified.
    
    The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
    ancillary data, is not checked if the source address (ipi6_addr)
    is unspecified.  If the ipi6_ifindex is the not-exist interface,
    it should be fail and the errno should be set ENODEV.
    
    Based on patch from Shan Wei <shanwei@cn.fujitsu.com> and
    Brian Haley <brian.haley@hp.com>.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: Brian Haley <brian.haley@hp.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..53e3883 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -509,7 +509,6 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		int addr_type;
-		struct net_device *dev = NULL;
 
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
@@ -522,6 +521,9 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 		switch (cmsg->cmsg_type) {
 		case IPV6_PKTINFO:
 		case IPV6_2292PKTINFO:
+		    {
+			struct net_device *dev = NULL;
+
 			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_pktinfo))) {
 				err = -EINVAL;
 				goto exit_f;
@@ -535,32 +537,32 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				fl->oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
 
-			if (addr_type == IPV6_ADDR_ANY)
-				break;
+			if (fl->oif) {
+				dev = dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
+				return -EINVAL;
 
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
-			}
-			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
-					   dev, 0)) {
-				if (dev)
-					dev_put(dev);
-				err = -EINVAL;
-				goto exit_f;
+			if (addr_type != IPV6_ADDR_ANY) {
+				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
+				if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+						   strict ? dev : NULL, 0))
+					err = -EINVAL;
+				else
+					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			}
+
 			if (dev)
 				dev_put(dev);
 
-			ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+			if (err)
+				goto exit_f;
+
 			break;
+		    }
 
 		case IPV6_FLOWINFO:
 			if (cmsg->cmsg_len < CMSG_LEN(4)) {

---
commit 302d90c0b04a4b2f0c6485351c99737474e92053
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 4 13:47:42 2008 +0900

    [IPV6] NETNS: Handle ancillary data in appropriate namespace.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 27394e0..112934a 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -40,7 +40,8 @@ extern int			datagram_recv_ctl(struct sock *sk,
 						  struct msghdr *msg,
 						  struct sk_buff *skb);
 
-extern int			datagram_send_ctl(struct msghdr *msg,
+extern int			datagram_send_ctl(struct net *net,
+						  struct msghdr *msg,
 						  struct flowi *fl,
 						  struct ipv6_txoptions *opt,
 						  int *hlimit, int *tclass);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 53e3883..b9c2de8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -496,7 +496,8 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
+int datagram_send_ctl(struct net *net,
+		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass)
 {
@@ -540,7 +541,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
 
 			if (fl->oif) {
-				dev = dev_get_by_index(&init_net, fl->oif);
+				dev = dev_get_by_index(net, fl->oif);
 				if (!dev)
 					return -ENODEV;
 			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
@@ -548,7 +549,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
-				if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+				if (!ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
 					err = -EINVAL;
 				else
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 2b7d9ee..f1622be 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -298,7 +298,8 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned lo
 }
 
 static struct ip6_flowlabel *
-fl_create(struct in6_flowlabel_req *freq, char __user *optval, int optlen, int *err_p)
+fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
+	  int optlen, int *err_p)
 {
 	struct ip6_flowlabel *fl;
 	int olen;
@@ -331,7 +332,7 @@ fl_create(struct in6_flowlabel_req *freq, char __user *optval, int optlen, int *
 		msg.msg_control = (void*)(fl->opt+1);
 		flowi.oif = 0;
 
-		err = datagram_send_ctl(&msg, &flowi, fl->opt, &junk, &junk);
+		err = datagram_send_ctl(&init_net, &msg, &flowi, fl->opt, &junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
@@ -496,7 +497,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		if (freq.flr_label & ~IPV6_FLOWLABEL_MASK)
 			return -EINVAL;
 
-		fl = fl_create(&freq, optval, optlen, &err);
+		fl = fl_create(sk->sk_net, &freq, optval, optlen, &err);
 		if (fl == NULL)
 			return err;
 		sfl1 = kmalloc(sizeof(*sfl1), GFP_KERNEL);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 3ab9d8f..ae6eeff 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -485,7 +485,7 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(sk->sk_net, &msg, &fl, opt, &junk, &junk);
 		if (retv)
 			goto done;
 update:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0a6fbc1..853dcfe 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -839,7 +839,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sk->sk_net, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e13ed3..50be7e6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -728,7 +728,7 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sk->sk_net, msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;

---
commit e319baa3faf4c7a6f4740669941136ac2a13518b
Author: Denis V. Lunev <den@openvz.org>
Date:   Wed Jun 4 15:49:06 2008 +0400

    [IPV6]: Do not change protocol for raw IPv6 sockets.
    
    It is not allowed to change underlying protocol for
       int fd = socket(PF_INET6, SOCK_RAW, IPPROTO_UDP);
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ae6eeff..e024cc3 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -238,6 +238,9 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			struct ipv6_txoptions *opt;
 			struct sk_buff *pktopt;
 
+			if (sk->sk_type == SOCK_RAW)
+				break;
+
 			if (sk->sk_protocol != IPPROTO_UDP &&
 			    sk->sk_protocol != IPPROTO_UDPLITE &&
 			    sk->sk_protocol != IPPROTO_TCP)

---
commit e62de0ba98ad6f2ec89be34dc0e1b2eb52aef110
Author: Denis V. Lunev <den@openvz.org>
Date:   Wed Jun 4 15:49:07 2008 +0400

    [IPV6]: inet_sk(sk)->cork.opt leak
    
    IPv6 UDP sockets wth IPv4 mapped address use udp_sendmsg to send the data
    actually. In this case ip_flush_pending_frames should be called instead
    of ip6_flush_pending_frames.
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/udp.h b/include/net/udp.h
index c6669c0..6b5a81b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -133,6 +133,7 @@ extern void	udp_err(struct sk_buff *, u32);
 
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len);
+extern void	udp_flush_pending_frames(struct sock *sk);
 
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1704c14..954827f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -427,7 +427,7 @@ void udp_err(struct sk_buff *skb, u32 info)
 /*
  * Throw away all pending data and cancel the corking. Socket is locked.
  */
-static void udp_flush_pending_frames(struct sock *sk)
+void udp_flush_pending_frames(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
 
@@ -437,6 +437,7 @@ static void udp_flush_pending_frames(struct sock *sk)
 		ip_flush_pending_frames(sk);
 	}
 }
+EXPORT_SYMBOL(udp_flush_pending_frames);
 
 /**
  * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 50be7e6..19baa4b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -531,7 +531,9 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
 
-	if (up->pending) {
+	if (up->pending == AF_INET)
+		udp_flush_pending_frames(sk);
+	else if (up->pending) {
 		up->len = 0;
 		up->pending = 0;
 		ip6_flush_pending_frames(sk);

---
commit 3af323a74c27e911e20019b5fc4e1dfe8fad8f43
Author: Denis V. Lunev <den@openvz.org>
Date:   Wed Jun 4 15:49:08 2008 +0400

    [IPV6]: Do not change protocol for UDPv6 sockets with pending sent data.
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index e024cc3..38ac995 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -241,9 +241,14 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			if (sk->sk_type == SOCK_RAW)
 				break;
 
-			if (sk->sk_protocol != IPPROTO_UDP &&
-			    sk->sk_protocol != IPPROTO_UDPLITE &&
-			    sk->sk_protocol != IPPROTO_TCP)
+			if (sk->sk_protocol == IPPROTO_UDP ||
+			    sk->sk_protocol == IPPROTO_UDPLITE) {
+				struct udp_sock *up = udp_sk(sk);
+				if (up->pending == AF_INET6) {
+					retv = -EBUSY;
+					break;
+				}
+			} else if (sk->sk_protocol != IPPROTO_TCP)
 				break;
 
 			if (sk->sk_state != TCP_ESTABLISHED) {

---
