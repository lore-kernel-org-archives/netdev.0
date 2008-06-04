From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL 2.6.25] IPv6 Fixes.
Date: Wed, 04 Jun 2008 09:52:45 +0900 (JST)
Message-ID: <20080604.095245.113187917.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58045 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbYFDAwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 20:52:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following fixes on top of 2.6.25.4 tree
available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.25.4-misc-20080604
and push them to -stable team.

I can provide separate patch for -stable team, if needed.

Regards,

--yoshfuji

--

HEADLINES
---------

    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    [IPv6] addrconf: Check range of prefix length
    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    [IPV6]: Fix the return value of get destination options with NULL data pointer
    [IPV6]: Fix the data length of get destination options with short length

DIFFSTAT
--------

 net/ipv4/tunnel4.c       |    2 +-
 net/ipv6/addrconf.c      |   10 ++++++++--
 net/ipv6/ipv6_sockglue.c |    5 ++++-
 net/ipv6/tunnel6.c       |    2 +-
 net/ipv6/udp.c           |    2 ++
 5 files changed, 16 insertions(+), 5 deletions(-)

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

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
