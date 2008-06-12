From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] net-2.6 fixes.
Date: Thu, 12 Jun 2008 09:58:23 +0900 (JST)
Message-ID: <20080612.095823.51002679.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59284 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbYFLA5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 20:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following changes since commit
513fd370e6832f81ab717df4645f5ce679e44f14
    Merge branch 'davem-fixes' of master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
at:
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-misc-20080611a

Regards,

--yoshfuji

--
HEADLINES
---------

    ipv6 mcast: Check address family of gf_group in getsockopt(MS_FILTER).
    ipv6 route: Fix route lifetime in netlink message.
    ipv6: Check the hop limit setting in ancillary data.
    ipv6: Check IPV6_MULTICAST_LOOP option value.
    ipv6: Fail with appropriate error code when setting not-applicable sockopt.

DIFFSTAT
--------

 net/ipv6/datagram.c      |    5 +++++
 net/ipv6/ipv6_sockglue.c |   12 ++++++++----
 net/ipv6/route.c         |    8 ++++++--
 3 files changed, 19 insertions(+), 6 deletions(-)

CHANGESETS
----------

commit 20c61fbd8deb2ada0ac3acecf6156a986dbfff2d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 14:40:55 2008 +0900

    ipv6 mcast: Check address family of gf_group in getsockopt(MS_FILTER).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 26b83e5..ce794d6 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -874,6 +874,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EINVAL;
 		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0)))
 			return -EFAULT;
+		if (gsf.gf_group.ss_family != AF_INET6)
+			return -EADDRNOTAVAIL;
 		lock_sock(sk);
 		err = ip6_mc_msfget(sk, &gsf,
 			(struct group_filter __user *)optval, optlen);

---
commit 36e3deae8ba84865fd9eb3f2f21bbc00d49b7544
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue May 13 02:52:55 2008 +0900

    ipv6 route: Fix route lifetime in netlink message.
    
    1) We may have route lifetime larger than INT_MAX.
    In that case we had wired value in lifetime.
    Use INT_MAX if lifetime does not fit in s32.
    
    2) Lifetime is valid iif RTF_EXPIRES is set.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 220cffe..d1f3e19 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2196,8 +2196,12 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
 
-	expires = (rt->rt6i_flags & RTF_EXPIRES) ?
-			rt->rt6i_expires - jiffies : 0;
+	if (!(rt->rt6i_flags & RTF_EXPIRES))
+		expires = 0;
+	else if (rt->rt6i_expires - jiffies < INT_MAX)
+		expires = rt->rt6i_expires - jiffies;
+	else
+		expires = INT_MAX;
 
 	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0,
 			       expires, rt->u.dst.error) < 0)

---
commit e8766fc86b34d44a8c55a2f9d71da69e091b1ca4
Author: Shan Wei <shanwei@cn.fujitsu.com>
Date:   Tue Jun 10 15:50:55 2008 +0800

    ipv6: Check the hop limit setting in ancillary data.
    
    When specifing the outgoing hop limit as ancillary data for sendmsg(),
    the kernel doesn't check the integer hop limit value as specified in
    [RFC-3542] section 6.3.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b9c2de8..0f0f94a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -705,6 +705,11 @@ int datagram_send_ctl(struct net *net,
 			}
 
 			*hlimit = *(int *)CMSG_DATA(cmsg);
+			if (*hlimit < -1 || *hlimit > 0xff) {
+				err = -EINVAL;
+				goto exit_f;
+			}
+
 			break;
 
 		case IPV6_TCLASS:

---
commit 28d4488216645cd71402925cffde9528b0cfdb7e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jun 12 03:14:51 2008 +0900

    ipv6: Check IPV6_MULTICAST_LOOP option value.
    
    Only 0 and 1 are valid for IPV6_MULTICAST_LOOP socket option,
    and we should return an error of EINVAL otherwise, per RFC3493.
    
    Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ce794d6..9a36971 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -458,6 +458,8 @@ done:
 	case IPV6_MULTICAST_LOOP:
 		if (optlen < sizeof(int))
 			goto e_inval;
+		if (val != valbool)
+			goto e_inval;
 		np->mc_loop = valbool;
 		retv = 0;
 		break;

---
commit 1717699cd5130009b7cd6756e883d8582c1fe706
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jun 12 03:27:26 2008 +0900

    ipv6: Fail with appropriate error code when setting not-applicable sockopt.
    
    IPV6_MULTICAST_HOPS, for example, is not valid for stream sockets.
    Since they are virtually unavailable for stream sockets,
    we should return ENOPROTOOPT instead of EINVAL.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9a36971..c042ce1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -67,7 +67,7 @@ int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
 
 	/* RA packet may be delivered ONLY to IPPROTO_RAW socket */
 	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->num != IPPROTO_RAW)
-		return -EINVAL;
+		return -ENOPROTOOPT;
 
 	new_ra = (sel>=0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
@@ -446,7 +446,7 @@ done:
 
 	case IPV6_MULTICAST_HOPS:
 		if (sk->sk_type == SOCK_STREAM)
-			goto e_inval;
+			break;
 		if (optlen < sizeof(int))
 			goto e_inval;
 		if (val > 255 || val < -1)
@@ -466,7 +466,7 @@ done:
 
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
-			goto e_inval;
+			break;
 		if (optlen < sizeof(int))
 			goto e_inval;
 
@@ -862,7 +862,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		if (sk->sk_protocol != IPPROTO_UDP &&
 		    sk->sk_protocol != IPPROTO_UDPLITE &&
 		    sk->sk_protocol != IPPROTO_TCP)
-			return -EINVAL;
+			return -ENOPROTOOPT;
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -ENOTCONN;
 		val = sk->sk_family;

---
commit 20c61fbd8deb2ada0ac3acecf6156a986dbfff2d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 14:40:55 2008 +0900

    ipv6 mcast: Check address family of gf_group in getsockopt(MS_FILTER).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 26b83e5..ce794d6 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -874,6 +874,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EINVAL;
 		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0)))
 			return -EFAULT;
+		if (gsf.gf_group.ss_family != AF_INET6)
+			return -EADDRNOTAVAIL;
 		lock_sock(sk);
 		err = ip6_mc_msfget(sk, &gsf,
 			(struct group_filter __user *)optval, optlen);

---
commit 36e3deae8ba84865fd9eb3f2f21bbc00d49b7544
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue May 13 02:52:55 2008 +0900

    ipv6 route: Fix route lifetime in netlink message.
    
    1) We may have route lifetime larger than INT_MAX.
    In that case we had wired value in lifetime.
    Use INT_MAX if lifetime does not fit in s32.
    
    2) Lifetime is valid iif RTF_EXPIRES is set.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 220cffe..d1f3e19 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2196,8 +2196,12 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
 
-	expires = (rt->rt6i_flags & RTF_EXPIRES) ?
-			rt->rt6i_expires - jiffies : 0;
+	if (!(rt->rt6i_flags & RTF_EXPIRES))
+		expires = 0;
+	else if (rt->rt6i_expires - jiffies < INT_MAX)
+		expires = rt->rt6i_expires - jiffies;
+	else
+		expires = INT_MAX;
 
 	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0,
 			       expires, rt->u.dst.error) < 0)

---
commit e8766fc86b34d44a8c55a2f9d71da69e091b1ca4
Author: Shan Wei <shanwei@cn.fujitsu.com>
Date:   Tue Jun 10 15:50:55 2008 +0800

    ipv6: Check the hop limit setting in ancillary data.
    
    When specifing the outgoing hop limit as ancillary data for sendmsg(),
    the kernel doesn't check the integer hop limit value as specified in
    [RFC-3542] section 6.3.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b9c2de8..0f0f94a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -705,6 +705,11 @@ int datagram_send_ctl(struct net *net,
 			}
 
 			*hlimit = *(int *)CMSG_DATA(cmsg);
+			if (*hlimit < -1 || *hlimit > 0xff) {
+				err = -EINVAL;
+				goto exit_f;
+			}
+
 			break;
 
 		case IPV6_TCLASS:

---
commit 28d4488216645cd71402925cffde9528b0cfdb7e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jun 12 03:14:51 2008 +0900

    ipv6: Check IPV6_MULTICAST_LOOP option value.
    
    Only 0 and 1 are valid for IPV6_MULTICAST_LOOP socket option,
    and we should return an error of EINVAL otherwise, per RFC3493.
    
    Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ce794d6..9a36971 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -458,6 +458,8 @@ done:
 	case IPV6_MULTICAST_LOOP:
 		if (optlen < sizeof(int))
 			goto e_inval;
+		if (val != valbool)
+			goto e_inval;
 		np->mc_loop = valbool;
 		retv = 0;
 		break;

---
commit 1717699cd5130009b7cd6756e883d8582c1fe706
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jun 12 03:27:26 2008 +0900

    ipv6: Fail with appropriate error code when setting not-applicable sockopt.
    
    IPV6_MULTICAST_HOPS, for example, is not valid for stream sockets.
    Since they are virtually unavailable for stream sockets,
    we should return ENOPROTOOPT instead of EINVAL.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9a36971..c042ce1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -67,7 +67,7 @@ int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
 
 	/* RA packet may be delivered ONLY to IPPROTO_RAW socket */
 	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->num != IPPROTO_RAW)
-		return -EINVAL;
+		return -ENOPROTOOPT;
 
 	new_ra = (sel>=0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
@@ -446,7 +446,7 @@ done:
 
 	case IPV6_MULTICAST_HOPS:
 		if (sk->sk_type == SOCK_STREAM)
-			goto e_inval;
+			break;
 		if (optlen < sizeof(int))
 			goto e_inval;
 		if (val > 255 || val < -1)
@@ -466,7 +466,7 @@ done:
 
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
-			goto e_inval;
+			break;
 		if (optlen < sizeof(int))
 			goto e_inval;
 
@@ -862,7 +862,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		if (sk->sk_protocol != IPPROTO_UDP &&
 		    sk->sk_protocol != IPPROTO_UDPLITE &&
 		    sk->sk_protocol != IPPROTO_TCP)
-			return -EINVAL;
+			return -ENOPROTOOPT;
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -ENOTCONN;
 		val = sk->sk_family;

---
