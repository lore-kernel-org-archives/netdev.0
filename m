From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Wed, 12 Nov 2003 16:14:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112151444.GA9727@wsx.ksp.sk>
References: <20031109122844.GA14241@wsx.ksp.sk> <20031110214603.0057e365.davem@redhat.com> <20031111222611.GA1239@wsx.ksp.sk> <20031111151340.3d129bc7.davem@redhat.com> <20031112012641.00018cb8.davem@redhat.com>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031112012641.00018cb8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> All of the __skb_{push,pull}() modifications made by icmpv6_send()
> are illegal.  The SKB could be cloned and being inspected by other
> entities in the networking, therefore moving the pointers around
> could cause problems.
> 
> Therefore what we do instead is propagate the:
> 
> 	skb->nh.raw - skb->data
> 
> offset into the skb_copy_and_csum_bits() calls.  This is what
> the pre-IPSEC version of the icmpv6 code did.
> 
> When you pass a negative offset into skb_copy_and_csum_bits()
> this means start that many bytes before skb->data

OK, I like your patch more.

You have forgot to decrease 'len' by msg.offset here:


> -	plen = skb->nh.raw - skb->data;
> -	__skb_pull(skb, plen);
> +	msg.skb = skb;
> +	msg.offset = skb->nh.raw - skb->data;
> +
>  	len = skb->len;


I've fixed that and tested, here is a working patch:

--- linux/net/ipv6/icmp.c.orig	2003-11-12 16:02:23.000000000 +0100
+++ linux/net/ipv6/icmp.c	2003-11-12 16:03:59.000000000 +0100
@@ -86,15 +86,6 @@
 	.flags		=	INET6_PROTO_FINAL,
 };
 
-struct icmpv6_msg {
-	struct icmp6hdr		icmph;
-	struct sk_buff		*skb;
-	int			offset;
-	struct in6_addr		*daddr;
-	int			len;
-	__u32			csum;
-};
-
 static __inline__ int icmpv6_xmit_lock(void)
 {
 	local_bh_disable();
@@ -258,11 +249,19 @@
 	return err;
 }
 
+struct icmpv6_msg {
+	struct sk_buff	*skb;
+	int		offset;
+};
+
 static int icmpv6_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
 {
-	struct sk_buff *org_skb = (struct sk_buff *)from;
+	struct icmpv6_msg *msg = (struct icmpv6_msg *) from;
+	struct sk_buff *org_skb = msg->skb;
 	__u32 csum = 0;
-	csum = skb_copy_and_csum_bits(org_skb, offset, to, len, csum);
+
+	csum = skb_copy_and_csum_bits(org_skb, msg->offset + offset,
+				      to, len, csum);
 	skb->csum = csum_block_add(skb->csum, csum, odd);
 	return 0;
 }
@@ -281,9 +280,10 @@
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
+	struct icmpv6_msg msg;
 	int iif = 0;
 	int addr_type = 0;
-	int len, plen;
+	int len;
 	int hlimit = -1;
 	int err = 0;
 
@@ -379,27 +379,29 @@
 			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
 	}
 
-	plen = skb->nh.raw - skb->data;
-	__skb_pull(skb, plen);
-	len = skb->len;
+	msg.skb = skb;
+	msg.offset = skb->nh.raw - skb->data;
+
+	len = skb->len - msg.offset;
 	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
 	if (len < 0) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "icmp: len problem\n");
-		__skb_push(skb, plen);
 		goto out_dst_release;
 	}
 
 	idev = in6_dev_get(skb->dev);
 
-	err = ip6_append_data(sk, icmpv6_getfrag, skb, len + sizeof(struct icmp6hdr), sizeof(struct icmp6hdr),
-				hlimit, NULL, &fl, (struct rt6_info*)dst, MSG_DONTWAIT);
+	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
+			      len + sizeof(struct icmp6hdr),
+			      sizeof(struct icmp6hdr),
+			      hlimit, NULL, &fl, (struct rt6_info*)dst,
+			      MSG_DONTWAIT);
 	if (err) {
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
 	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
-	__skb_push(skb, plen);
 
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
 		ICMP6_INC_STATS_OFFSET_BH(idev, Icmp6OutDestUnreachs, type - ICMPV6_DEST_UNREACH);
@@ -423,6 +425,7 @@
 	struct icmp6hdr *icmph = (struct icmp6hdr *) skb->h.raw;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
+	struct icmpv6_msg msg;
 	struct dst_entry *dst;
 	int err = 0;
 	int hlimit = -1;
@@ -464,7 +467,10 @@
 
 	idev = in6_dev_get(skb->dev);
 
-	err = ip6_append_data(sk, icmpv6_getfrag, skb, skb->len + sizeof(struct icmp6hdr),
+	msg.skb = skb;
+	msg.offset = 0;
+
+	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
 				sizeof(struct icmp6hdr), hlimit, NULL, &fl,
 				(struct rt6_info*)dst, MSG_DONTWAIT);
 


Jan
