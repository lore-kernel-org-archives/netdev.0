From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] XFRM: ICMP{,v6} type/code support (Take 2) (was Re:
 [PATCH][IPSEC] IPsec policy can be matched by ICMP type and code)
Date: Wed, 18 Aug 2004 23:09:36 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818.230936.59708655.yoshfuji@linux-ipv6.org>
References: <20040809175404.301bd60a@localhost>
	<20040809170705.6ab75c5f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040809170705.6ab75c5f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20040809170705.6ab75c5f.davem@redhat.com> (at Mon, 9 Aug 2004 17:07:05 -0700), "David S. Miller" <davem@redhat.com> says:

> On Mon, 9 Aug 2004 17:54:04 +0900
> Masahide Nakamura <nakam@linux-ipv6.org> wrote:
> 
> > Thinking of raw socket (in outbound case), the patch supports only
> > ICMP; it is out of scope such packet as user-land builds non-ICMP data
> > (e.g. TCP/UDP) and sends through raw socket. IMO this behavior is
> > enough, however does anybody have comments?
> 
> Truly %100 RAW sockets should have their packets untouched by
> the kernel.  User wants exactly that packet to be sent onto
> the wire.

Here's the updated version of the patch.
Changesets are available at:
	<bk://bk.skbuff.net:20609/linux-2.6-xfrm-icmp/>.

Thanks.

DIFFSTAT
--------
 include/net/xfrm.h      |   46 ++++++++++++++++++++++++++++++++++++++++----
 net/ipv4/raw.c          |   50 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/xfrm4_policy.c |    9 ++++++++
 net/ipv6/raw.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_policy.c |   10 +++++++++
 5 files changed, 158 insertions(+), 5 deletions(-)

CHANGESET
---------
ChangeSet@1.1838, 2004-08-18 22:39:42+09:00, yoshfuji@linux-ipv6.org
  [XFRM] Fix selector comparison against icmp{,v6} flows.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-08-18 22:58:51 +09:00
+++ b/include/net/xfrm.h	2004-08-18 22:58:51 +09:00
@@ -462,13 +462,51 @@
 	return 1;
 }
 
+static __inline__
+u16 xfrm_flowi_sport(struct flowi *fl)
+{
+	u16 port;
+	switch(fl->proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		port = fl->fl_ip_sport;
+		break;
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		port = htons(fl->fl_icmp_type);
+		break;
+	default:
+		port = 0;	/*XXX*/
+	}
+	return port;
+}
+
+static __inline__
+u16 xfrm_flowi_dport(struct flowi *fl)
+{
+	u16 port;
+	switch(fl->proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		port = fl->fl_ip_dport;
+		break;
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		port = htons(fl->fl_icmp_code);
+		break;
+	default:
+		port = 0;	/*XXX*/
+	}
+	return port;
+}
+
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
-		!((fl->fl_ip_sport^sel->sport)&sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
@@ -478,8 +516,8 @@
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
-		!((fl->fl_ip_sport^sel->sport)&sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }


ChangeSet@1.1839, 2004-08-18 22:42:00+09:00, nakam@linux-ipv6.org
  [IPV6] XFRM: decode icmpv6 session.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2004-08-18 22:58:54 +09:00
+++ b/net/ipv6/xfrm6_policy.c	2004-08-18 22:58:54 +09:00
@@ -213,6 +213,16 @@
 			fl->proto = nexthdr;
 			return;
 
+		case IPPROTO_ICMPV6:
+			if (pskb_may_pull(skb, skb->nh.raw + offset + 2 - skb->data)) {
+				u8 *icmp = (u8 *)exthdr;
+
+				fl->fl_icmp_type = icmp[0];
+				fl->fl_icmp_code = icmp[1];
+			}
+			fl->proto = nexthdr;
+			return;
+
 		/* XXX Why are there these headers? */
 		case IPPROTO_AH:
 		case IPPROTO_ESP:


ChangeSet@1.1840, 2004-08-18 22:43:52+09:00, nakam@linux-ipv6.org
  [IPV6] XFRM: probe icmpv6 type/code when sending packets via raw socket.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-08-18 22:58:57 +09:00
+++ b/net/ipv6/raw.c	2004-08-18 22:58:57 +09:00
@@ -555,6 +555,52 @@
 	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
 	return err; 
 }
+
+static void rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+{
+	struct iovec *iov;
+	u8 *type = NULL;
+	u8 *code = NULL;
+	int probed = 0;
+	int i;
+
+	if (!msg->msg_iov)
+		return;
+
+	for (i = 0; i < msg->msg_iovlen; i++) {
+		iov = &msg->msg_iov[i];
+		if (!iov)
+			continue;
+
+		switch (fl->proto) {
+		case IPPROTO_ICMPV6:
+			/* check if one-byte field is readable or not. */
+			if (iov->iov_base && iov->iov_len < 1)
+				break;
+
+			if (!type) {
+				type = iov->iov_base;
+				/* check if code field is readable or not. */
+				if (iov->iov_len > 1)
+					code = type + 1;
+			} else if (!code)
+				code = iov->iov_base;
+
+			if (type && code) {
+				fl->fl_icmp_type = *type;
+				fl->fl_icmp_code = *code;
+				probed = 1;
+			}
+			break;
+		default:
+			probed = 1;
+			break;
+		}
+		if (probed)
+			break;
+	}
+}
+
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		   struct msghdr *msg, size_t len)
 {
@@ -674,6 +720,8 @@
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
 	fl.proto = proto;
+	rawv6_probe_proto_opt(&fl, msg);
+ 
 	ipv6_addr_copy(&fl.fl6_dst, daddr);
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);


ChangeSet@1.1841, 2004-08-18 22:45:29+09:00, nakam@linux-ipv6.org
  [IPV4] XFRM: decode icmp session.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2004-08-18 22:59:00 +09:00
+++ b/net/ipv4/xfrm4_policy.c	2004-08-18 22:59:00 +09:00
@@ -183,6 +183,15 @@
 			}
 			break;
 
+		case IPPROTO_ICMP:
+			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
+				u8 *icmp = xprth;
+
+				fl->fl_icmp_type = icmp[0];
+				fl->fl_icmp_code = icmp[1];
+			}
+			break;
+
 		case IPPROTO_ESP:
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				u32 *ehdr = (u32 *)xprth;


ChangeSet@1.1842, 2004-08-18 22:51:21+09:00, nakam@linux-ipv6.org
  [IPV4] XFRM: probe icmp type/code when sending packets via raw socket.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-08-18 22:59:03 +09:00
+++ b/net/ipv4/raw.c	2004-08-18 22:59:03 +09:00
@@ -323,6 +323,51 @@
 	return err; 
 }
 
+static void raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+{
+	struct iovec *iov;
+	u8 *type = NULL;
+	u8 *code = NULL;
+	int probed = 0;
+	int i;
+
+	if (!msg->msg_iov)
+		return;
+
+	for (i = 0; i < msg->msg_iovlen; i++) {
+		iov = &msg->msg_iov[i];
+		if (!iov)
+			continue;
+
+		switch (fl->proto) {
+		case IPPROTO_ICMP:
+			/* check if one-byte field is readable or not. */
+			if (iov->iov_base && iov->iov_len < 1)
+				break;
+
+			if (!type) {
+				type = iov->iov_base;
+				/* check if code field is readable or not. */
+				if (iov->iov_len > 1)
+					code = type + 1;
+			} else if (!code)
+				code = iov->iov_base;
+
+			if (type && code) {
+				fl->fl_icmp_type = *type;
+				fl->fl_icmp_code = *code;
+				probed = 1;
+			}
+			break;
+		default:
+			probed = 1;
+			break;
+		}
+		if (probed)
+			break;
+	}
+}
+
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len)
 {
@@ -429,6 +474,8 @@
 				    .proto = inet->hdrincl ? IPPROTO_RAW :
 					    		     sk->sk_protocol,
 				  };
+		raw_probe_proto_opt(&fl, msg);
+
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
 	}
 	if (err)


ChangeSet@1.1843, 2004-08-18 22:56:49+09:00, yoshfuji@linux-ipv6.org
  [IPV4] XFRM: don't probe icmp type/code for hdrincl sockets.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-08-18 22:59:06 +09:00
+++ b/net/ipv4/raw.c	2004-08-18 22:59:06 +09:00
@@ -474,7 +474,8 @@
 				    .proto = inet->hdrincl ? IPPROTO_RAW :
 					    		     sk->sk_protocol,
 				  };
-		raw_probe_proto_opt(&fl, msg);
+		if (!inet->hdrincl)
+			raw_probe_proto_opt(&fl, msg);
 
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
 	}



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
