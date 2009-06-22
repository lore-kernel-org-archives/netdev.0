From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv6: Use correct data types for ICMPv6 type and code
Date: Mon, 22 Jun 2009 12:20:54 -0400
Message-ID: <4A3FAF66.4060607@hp.com>
References: <4A39A200.20603@hp.com>	<20090617.192039.171958637.davem@davemloft.net>	<4A39BE00.1050506@hp.com> <20090618.002632.18400816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:14270 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbZFVQVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 12:21:23 -0400
In-Reply-To: <20090618.002632.18400816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Thu, 18 Jun 2009 00:09:36 -0400
> 
>> "type" is a u8 too, but both seem to be passed as int's everywhere (rawv6,
>> tcp, sctp and dccp), and in the err_handler() func pointer in the inet6_protocol
>> struct.  I can try and cook something up in the next few days that changes
>> it all to u8's.
> 
> Feel free, thanks a lot.

I compile tested and made sure I could ping and get unreachables back up
the TCP stack.  Also, applying Roel's original patch on top of this
generated the expected compiler warning since it's always >= zero.


Change all the code that deals directly with ICMPv6 type and code values
to use u8 instead of a signed int as that's the actual data type.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 10d701e..b6a8518 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -175,16 +175,16 @@ struct icmp6_filter {
 
 
 extern void				icmpv6_send(struct sk_buff *skb,
-						    int type, int code,
+						    u8 type, u8 code,
 						    __u32 info, 
 						    struct net_device *dev);
 
 extern int				icmpv6_init(void);
-extern int				icmpv6_err_convert(int type, int code,
+extern int				icmpv6_err_convert(u8 type, u8 code,
 							   int *err);
 extern void				icmpv6_cleanup(void);
 extern void				icmpv6_param_prob(struct sk_buff *skb,
-							  int code, int pos);
+							  u8 code, int pos);
 
 struct flowi;
 struct in6_addr;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index ffa5b8b..1089d5a 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -53,7 +53,7 @@ struct inet6_protocol
 
 	void	(*err_handler)(struct sk_buff *skb,
 			       struct inet6_skb_parm *opt,
-			       int type, int code, int offset,
+			       u8 type, u8 code, int offset,
 			       __be32 info);
 
 	int	(*gso_send_check)(struct sk_buff *skb);
diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index 8a22599..f6b9b83 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -6,7 +6,7 @@
 #include <net/protocol.h>
 
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
-		int type, int code, int inner_offset, __be32);
+		u8 type, u8 code, int inner_offset, __be32);
 int raw6_local_deliver(struct sk_buff *, int);
 
 extern int			rawv6_rcv(struct sock *sk,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 736bca4..9e3a3f4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1274,7 +1274,7 @@ struct xfrm_tunnel {
 struct xfrm6_tunnel {
 	int (*handler)(struct sk_buff *skb);
 	int (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			   int type, int code, int offset, __be32 info);
+			   u8 type, u8 code, int offset, __be32 info);
 	struct xfrm6_tunnel *next;
 	int priority;
 };
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 05ea744..3e70faa 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -85,7 +85,7 @@ static inline __u32 dccp_v6_init_sequence(struct sk_buff *skb)
 }
 
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			int type, int code, int offset, __be32 info)
+			u8 type, u8 code, int offset, __be32 info)
 {
 	struct ipv6hdr *hdr = (struct ipv6hdr *)skb->data;
 	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 52449f7..86f42a2 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -405,7 +405,7 @@ out:
 }
 
 static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		    int type, int code, int offset, __be32 info)
+		    u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c2f2501..678bb95 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -354,7 +354,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 }
 
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		     int type, int code, int offset, __be32 info)
+		     u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 36dff88..eab62a7 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -117,7 +117,7 @@ static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
 /*
  * Slightly more convenient version of icmpv6_send.
  */
-void icmpv6_param_prob(struct sk_buff *skb, int code, int pos)
+void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
 {
 	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
 	kfree_skb(skb);
@@ -161,7 +161,7 @@ static int is_ineligible(struct sk_buff *skb)
 /*
  * Check the ICMP output rate limit
  */
-static inline int icmpv6_xrlim_allow(struct sock *sk, int type,
+static inline int icmpv6_xrlim_allow(struct sock *sk, u8 type,
 				     struct flowi *fl)
 {
 	struct dst_entry *dst;
@@ -305,7 +305,7 @@ static inline void mip6_addr_swap(struct sk_buff *skb) {}
 /*
  *	Send an ICMP message in response to a packet in error
  */
-void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
+void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 		 struct net_device *dev)
 {
 	struct net *net = dev_net(skb->dev);
@@ -590,7 +590,7 @@ out:
 	icmpv6_xmit_unlock(sk);
 }
 
-static void icmpv6_notify(struct sk_buff *skb, int type, int code, __be32 info)
+static void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 {
 	struct inet6_protocol *ipprot;
 	int inner_offset;
@@ -643,7 +643,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct in6_addr *saddr, *daddr;
 	struct ipv6hdr *orig_hdr;
 	struct icmp6hdr *hdr;
-	int type;
+	u8 type;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		struct sec_path *sp = skb_sec_path(skb);
@@ -914,7 +914,7 @@ static const struct icmp6_err {
 	},
 };
 
-int icmpv6_err_convert(int type, int code, int *err)
+int icmpv6_err_convert(u8 type, u8 code, int *err)
 {
 	int fatal = 0;
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 404d16a..51f410e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -394,13 +394,13 @@ parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
 
 static int
 ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
-	    int *type, int *code, int *msg, __u32 *info, int offset)
+	    u8 *type, u8 *code, int *msg, __u32 *info, int offset)
 {
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *) skb->data;
 	struct ip6_tnl *t;
 	int rel_msg = 0;
-	int rel_type = ICMPV6_DEST_UNREACH;
-	int rel_code = ICMPV6_ADDR_UNREACH;
+	u8 rel_type = ICMPV6_DEST_UNREACH;
+	u8 rel_code = ICMPV6_ADDR_UNREACH;
 	__u32 rel_info = 0;
 	__u16 len;
 	int err = -ENOENT;
@@ -488,11 +488,11 @@ out:
 
 static int
 ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-	   int type, int code, int offset, __be32 info)
+	   u8 type, u8 code, int offset, __be32 info)
 {
 	int rel_msg = 0;
-	int rel_type = type;
-	int rel_code = code;
+	u8 rel_type = type;
+	u8 rel_code = code;
 	__u32 rel_info = ntohl(info);
 	int err;
 	struct sk_buff *skb2;
@@ -586,11 +586,11 @@ out:
 
 static int
 ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-	   int type, int code, int offset, __be32 info)
+	   u8 type, u8 code, int offset, __be32 info)
 {
 	int rel_msg = 0;
-	int rel_type = type;
-	int rel_code = code;
+	u8 rel_type = type;
+	u8 rel_code = code;
 	__u32 rel_info = ntohl(info);
 	int err;
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 3a0b3be..79c172f 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -51,7 +51,7 @@
 #include <linux/mutex.h>
 
 static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-				int type, int code, int offset, __be32 info)
+				u8 type, u8 code, int offset, __be32 info)
 {
 	__be32 spi;
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index f995e19..f797e8c 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -54,7 +54,7 @@ static inline void *mip6_padn(__u8 *data, __u8 padlen)
 	return data + padlen;
 }
 
-static inline void mip6_param_prob(struct sk_buff *skb, int code, int pos)
+static inline void mip6_param_prob(struct sk_buff *skb, u8 code, int pos)
 {
 	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8b0b6f9..d6c3c1c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -310,7 +310,7 @@ out:
 
 static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 	       struct inet6_skb_parm *opt,
-	       int type, int code, int offset, __be32 info)
+	       u8 type, u8 code, int offset, __be32 info)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -343,7 +343,7 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 }
 
 void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
-		int type, int code, int inner_offset, __be32 info)
+		u8 type, u8 code, int inner_offset, __be32 info)
 {
 	struct sock *sk;
 	int hash;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 658293e..1473ee0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1865,7 +1865,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
  *	Drop the packet on the floor
  */
 
-static int ip6_pkt_drop(struct sk_buff *skb, int code, int ipstats_mib_noroutes)
+static int ip6_pkt_drop(struct sk_buff *skb, u8 code, int ipstats_mib_noroutes)
 {
 	int type;
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 53b6a41..58810c6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -317,7 +317,7 @@ failure:
 }
 
 static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		int type, int code, int offset, __be32 info)
+		u8 type, u8 code, int offset, __be32 info)
 {
 	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
 	const struct tcphdr *th = (struct tcphdr *)(skb->data+offset);
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 669f280..633ad78 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -124,7 +124,7 @@ drop:
 }
 
 static void tunnel6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			int type, int code, int offset, __be32 info)
+			u8 type, u8 code, int offset, __be32 info)
 {
 	struct xfrm6_tunnel *handler;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 023beda..33b59bd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -312,7 +312,7 @@ csum_copy_err:
 }
 
 void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		    int type, int code, int offset, __be32 info,
+		    u8 type, u8 code, int offset, __be32 info,
 		    struct udp_table *udptable)
 {
 	struct ipv6_pinfo *np;
@@ -346,8 +346,8 @@ out:
 }
 
 static __inline__ void udpv6_err(struct sk_buff *skb,
-				 struct inet6_skb_parm *opt, int type,
-				 int code, int offset, __be32 info     )
+				 struct inet6_skb_parm *opt, u8 type,
+				 u8 code, int offset, __be32 info     )
 {
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 2377920..6bb3034 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -9,7 +9,7 @@
 
 extern int  	__udp6_lib_rcv(struct sk_buff *, struct udp_table *, int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
-			       int , int , int , __be32 , struct udp_table *);
+			       u8 , u8 , int , __be32 , struct udp_table *);
 
 extern int	udp_v6_get_port(struct sock *sk, unsigned short snum);
 
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index ba162a8..4818c48 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -20,7 +20,7 @@ static int udplitev6_rcv(struct sk_buff *skb)
 
 static void udplitev6_err(struct sk_buff *skb,
 			  struct inet6_skb_parm *opt,
-			  int type, int code, int offset, __be32 info)
+			  u8 type, u8 code, int offset, __be32 info)
 {
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udplite_table);
 }
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 80193db..81a95c0 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -262,7 +262,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			    int type, int code, int offset, __be32 info)
+			    u8 type, u8 code, int offset, __be32 info)
 {
 	/* xfrm6_tunnel native err handling */
 	switch (type) {
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index a63de3f..6a4b190 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -133,7 +133,7 @@ static struct notifier_block sctp_inet6addr_notifier = {
 
 /* ICMP error handler. */
 SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			     int type, int code, int offset, __be32 info)
+			     u8 type, u8 code, int offset, __be32 info)
 {
 	struct inet6_dev *idev;
 	struct sock *sk;
