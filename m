From: Henrik Petander <lpetande@tml.hut.fi>
Subject: RFC: Mechanism for adding MIPv6 extension headers
Date: Thu, 05 Jun 2003 17:35:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDF552D.3060003@tml.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080703090805070306090804"
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>,
   yoshfuji@linux-ipv6.org, Venkata Jagana <jagana@us.ibm.com>,
   Krishna Kumar <krkumar@us.ibm.com>, Antti Tuominen <ajtuomin@tml.hut.fi>,
   Ville Nuorvala <vnuorval@tml.hut.fi>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080703090805070306090804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello all,

Attached is a patch which includes the relevant functionality for adding 
mipv6 extension headers to data packets. It probably does not compile, 
as I included only the files which are directly involved in the adding 
mechanism to minimize the size of the patch. If you want to try out the 
mechanism I can prepare a full patch.

The patch is against bk changeset 1.1325 and is meant as a basis for 
discussion about the extension header addition mechanism. The code is 
still work in progress and lacks a proper interface. The mechanism has 
been tested with tcp and raw sockets and with tcp+ipsec.

An overview of the system:

User inserts the mipv6 information into the kernel. Based on this 
information ip6_add_miproute adds a new cached route. This cached route 
contains mip6_output as output function for adding the extension 
headers, a decreased pmtu and mipv6 binding information. The route also 
contains a pointer (u.dst->child) to a new route which contains correct 
forwarding information for mipv6 intermediate hops and the raw pmtu.

Adding of extension headers in mip6_output is done as in esp6_output.

The mechanism is fairly close to xfrm, except for storing the mipv6 
information only in a cached route. Thus the state for a mipv6 binding 
is soft. This is a tradeoff between keeping the overhead of mipv6 small 
and having persistent state. If routes change, the mipv6 state can be 
easily reinserted into the kernel, since the userspace daemon needs to 
keep track of it for signaling purposes anyhow.

I will not go more into details here, but I am happy to answer any 
questions about the design. Your comments are much appreciated.

Regards,

Henrik

--------------080703090805070306090804
Content-Type: text/plain;
 name="mip6-exthdr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mip6-exthdr.patch"

--- net/ipv6/mip6.c	1969-12-31 22:00:00.000000000 -0200
+++ ../mipv6-kernel/net/ipv6/mip6.c	2003-06-05 04:57:00.000000000 -0200
@@ -0,0 +1,341 @@
+#include <linux/types.h>
+#include <linux/in6.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/ipv6.h>
+#include <net/checksum.h>
+#include <net/protocol.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_route.h>
+#include <net/mipv6.h>
+
+#define IPPROTO_MOBILITY  62 
+
+
+struct mipv6_be
+{
+	u8	payload;		/* Payload Protocol */
+	u8	length;			/* MH Length 	    */
+	u8	type;			/* MH Type	    */
+	u8	reserved;		/* Reserved	    */
+	u16	checksum;		/* Checksum	    */
+	u8	status;                 /* Error code       */
+	u8	reserved_2;
+	struct in6_addr	home_addr;
+} __attribute__ ((packed));
+
+struct socket *mipv6_mh_socket = NULL;
+
+static int dstopts_getfrag(const void *data, struct in6_addr *addr,
+			   char *buff, unsigned int offset, unsigned int len)
+{
+	memcpy(buff, data + offset, len);
+	return 0;
+}
+static __inline__ void mip6_xmit_lock(void)
+{
+
+
+	local_bh_disable();
+	if (unlikely(!spin_trylock(&mipv6_mh_socket->sk->lock.slock)))
+		BUG();
+}
+
+static __inline__ void mip6_xmit_unlock(void)
+{
+	spin_unlock_bh(&mipv6_mh_socket->sk->lock.slock);
+}
+
+
+void mip6_send_be(struct in6_addr *daddr, 
+		  struct in6_addr *saddr, 
+		  struct in6_addr *hao_addr)
+{
+	struct flowi fl;
+	struct mipv6_be be; 
+	struct sock *sk = mipv6_mh_socket->sk;
+	
+	memset(&fl, 0, sizeof(fl)); 
+	fl.proto = IPPROTO_MOBILITY;
+	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	ipv6_addr_copy(&fl.fl6_src, saddr);
+	fl.fl6_flowlabel = 0;
+	fl.oif = sk->bound_dev_if;
+
+	memset(&be, 0, sizeof(be));
+	be.payload = NEXTHDR_NONE;
+	be.length = 2;
+	be.type = 7;
+	ipv6_addr_copy(&be.home_addr, hao_addr);
+	be.status = 1; /* Home address option without binding */
+
+	mip6_xmit_lock();
+	ip6_build_xmit(sk, dstopts_getfrag, &be, &fl, sizeof(be), NULL, 255,
+		       MSG_DONTWAIT);
+	mip6_xmit_unlock();
+}
+/* TODO: Move the home address option / BCE check to tcp/udp/raw 
+ * processing so cached route in socket can be used 
+ * to avoid route lookup
+ */
+int mip6_hao_check(struct sk_buff *skb, u8 nexthdr)
+{
+	struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
+	struct in6_addr *coaddr;
+	struct rt6_info *rt;
+	/* Home address option in mobility header messages is checked
+	   by userspace mipv6 daemon */
+
+	if (!opt || !opt->dst_nofrag || nexthdr == IPPROTO_MOBILITY)
+		return 0;
+	if (opt && opt->dst_nofrag) {
+		rt = rt6_lookup(&skb->nh.ipv6h->saddr, &skb->nh.ipv6h->daddr, 0, 0);
+		if (rt) {
+			if (rt->binding.flags & MIPV6_F_BCE) {
+				dst_release(&rt->u.dst);
+				return 0;
+			}
+			else
+				dst_release(&rt->u.dst);
+		}
+		coaddr = (struct in6_addr *)((u8 *)skb->nh.raw + opt->dst_nofrag);
+		mip6_send_be(coaddr, &skb->nh.ipv6h->daddr,  &skb->nh.ipv6h->saddr);
+		return -1; 
+	}
+}
+
+/**
+ * mipv6_append_rt2hdr - Add Type 2 Routing Header
+ * @rt: buffer for new routing header
+ * @addr: intermediate hop address
+ *
+ * Adds a Routing Header Type 2 in a packet.  Stores newly created
+ * routing header in buffer @rt.  Type 2 RT only carries one address,
+ * so there is no need to process old routing header.  @rt must have
+ * allocated space for 24 bytes.
+ **/
+void mipv6_append_rt2hdr(struct rt2_hdr *rt, struct in6_addr *addr)
+{
+	struct rt2_hdr *rt2 = (struct rt2_hdr *)rt;
+
+	memset(rt2, 0, sizeof(*rt2));
+	rt2->rt_hdr.type = 2;
+	rt2->rt_hdr.hdrlen = 2;
+	rt2->rt_hdr.segments_left = 1;
+	ipv6_addr_copy(&rt2->addr, addr);
+}
+
+struct mipv6_padn
+{
+	__u8		type;
+	__u8		length;
+	__u8		data[0];
+} __attribute__ ((packed));
+
+/*
+ * Add Pad1 or PadN option to data
+ */
+int mipv6_add_pad(u8 *data, int n)
+{
+	struct mipv6_padn *padn;
+	
+	if (n <= 0) return 0;
+	if (n == 1) {
+		*data = MIPV6_OPT_PAD1;
+		return 1;
+	}
+	padn = (struct mipv6_padn *)data;
+	padn->type = MIPV6_OPT_PADN;
+	padn->length = n - 2;
+	memset(padn->data, 0, n - 2);
+	return n;
+}
+
+/**
+ * mipv6_append_home_addr - Add Home Address Option
+ * @opt: buffer for Home Address Option
+ * @offset: offset from beginning of @opt
+ * @addr: address for HAO
+ *
+ * Adds a Home Address Option to a packet.  Option is stored in
+ * @offset from beginning of @opt.  The option is created but the
+ * original source address in IPv6 header is left intact.  The source
+ * address will be changed from home address to CoA after the checksum
+ * has been calculated in getfrag.  Padding is done automatically, and
+ * @opt must have allocated space for both actual option and pad.
+ * Returns offset from @opt to end of options.
+ **/
+int mipv6_append_home_addr(u8 *opt, struct in6_addr *addr)
+{
+        int pad;
+        struct ipv6_dstopt_homeaddr *ho;
+	int offset = sizeof(struct ipv6_opt_hdr);
+	
+        pad = (6 - offset) & 7;
+        mipv6_add_pad(opt + offset, pad);
+
+        ho = (struct ipv6_dstopt_homeaddr *)(opt + offset + pad);
+        ho->type = IPV6_TLV_HOMEADDR;
+        ho->length = sizeof(*ho) - 2;
+        ipv6_addr_copy(&ho->addr, addr);
+
+        return offset + pad + sizeof(*ho);
+}
+
+
+static int get_offset(u8 *packet, u32 packet_len, u8 *nexthdr, int *offset_prevhdr)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(packet + offset);
+	u8 nextnexthdr;
+
+	*nexthdr = ((struct ipv6hdr*)packet)->nexthdr;
+
+	while (offset + 1 < packet_len) {
+		
+		switch (*nexthdr) {
+
+		case NEXTHDR_HOP:
+		case NEXTHDR_ROUTING:
+			*offset_prevhdr = offset;
+			offset += ipv6_optlen(exthdr);
+			*nexthdr = exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(packet + offset);
+			break;
+			
+		case NEXTHDR_DEST:
+			nextnexthdr =
+				((struct ipv6_opt_hdr*)(packet + offset + ipv6_optlen(exthdr)))->nexthdr;
+			/* XXX We know the option is inner dest opt
+			   with next next header check. */
+			if (nextnexthdr != NEXTHDR_HOP &&
+		    	    nextnexthdr != NEXTHDR_ROUTING &&
+			    nextnexthdr != NEXTHDR_DEST) {
+				return offset;
+			}
+			*offset_prevhdr = offset;
+			offset += ipv6_optlen(exthdr);
+			*nexthdr = exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(packet + offset);
+			break;
+
+		default :
+			return offset;
+		}
+	}
+
+	return offset;
+}
+
+
+int mip6_output(struct sk_buff *skb)
+
+{
+	struct ipv6hdr *iph = NULL, *top_iph;
+	struct dst_entry *dst = skb->dst;
+	struct ipv6_opt_hdr *prevhdr = NULL;
+	struct rt6_info *rt = (struct rt6_info *)skb->dst;
+	u8 nexthdr;
+	int offset_prevhdr = 0;
+	int hdr_len = get_offset(skb->nh.raw, skb->len, &nexthdr, &offset_prevhdr);
+	int len, err = 0;
+
+	if (nexthdr == IPPROTO_MOBILITY) /* No exthdrs for MH */
+		  goto out;
+
+	/* First, if the skb is not checksummed, complete checksum. */
+	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
+		err = -EINVAL;
+		goto error;
+	}
+	iph = kmalloc(hdr_len, GFP_ATOMIC);
+
+	if (!iph) {
+		err = -ENOMEM;
+		goto error;
+	}
+	
+	memcpy(iph, skb->nh.raw, hdr_len);
+	__skb_pull(skb, hdr_len);
+	
+	/* TODO: Is this correct ? */
+	if ((err = skb_cow(skb, mip6_hdrlen(rt->binding.flags)) != 0))
+		goto error;
+	if (rt->binding.flags & MIPV6_F_BULE) {
+		struct ipv6_opt_hdr *dstopt;
+		dstopt = (struct ipv6_opt_hdr *)skb_push(skb, sizeof(struct ipv6_dstopt_homeaddr) + 6);
+		dstopt->nexthdr = nexthdr;
+		len = mipv6_append_home_addr((u8 *)dstopt, &iph->saddr);
+		dstopt->hdrlen = (len >> 3) - 1;
+		ipv6_addr_copy(&iph->saddr, &rt->binding.lcoa);
+		skb->h.raw = (unsigned char *)dstopt;
+		nexthdr = IPPROTO_DSTOPTS;
+		
+	}
+	if (rt->binding.flags & MIPV6_F_BCE) {
+		struct rt2_hdr *rt2;
+		rt2 = (struct rt2_hdr *)skb_push(skb, sizeof(struct rt2_hdr));
+		skb->h.raw = (unsigned char *)rt2;
+		mipv6_append_rt2hdr(rt2, &iph->daddr);
+		ipv6_addr_copy(&iph->daddr, &rt->binding.rcoa);
+		rt2->rt_hdr.nexthdr = nexthdr;
+		nexthdr = IPPROTO_ROUTING;
+	}
+	
+	top_iph = (struct ipv6hdr *)skb_push(skb, hdr_len);
+	memcpy(top_iph, iph, hdr_len);
+	skb->nh.raw = skb->data;
+	kfree(iph);
+	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	if (offset_prevhdr) {
+		prevhdr = (struct ipv6_opt_hdr *)((int *)top_iph + offset_prevhdr);
+		prevhdr->nexthdr = nexthdr;
+		
+	} else {
+		top_iph->nexthdr = nexthdr;
+	}
+
+ out:
+	if ((skb->dst = dst_pop(dst)) == NULL) {
+		err = -EHOSTUNREACH;
+		goto error;
+	}
+	
+	return NET_XMIT_BYPASS;
+ error:
+	kfree_skb(skb);
+	return err;
+}
+
+int mip6_init(void)
+{
+	mipv6_mh_socket = sock_alloc();
+	mipv6_mh_socket->type = SOCK_RAW;
+	struct sock *sk;
+	int err;
+
+	if ((err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_MOBILITY, 
+			       &mipv6_mh_socket)) < 0) {
+		printk(KERN_ERR
+		       "Failed to initialize the MIP6 MH control socket (err %d).\n",
+		       err);
+		sock_release(mipv6_mh_socket);
+		mipv6_mh_socket = NULL; /* for safety */
+		return err;
+	}
+
+	sk = mipv6_mh_socket->sk;
+	sk->allocation = GFP_ATOMIC;
+	sk->sndbuf = SK_WMEM_MAX;
+	sk->prot->unhash(sk);
+	return 0;
+}
+
+void mip6_cleanup(void)
+{
+	if (mipv6_mh_socket) sock_release(mipv6_mh_socket);
+	mipv6_mh_socket = NULL; /* For safety. */
+}
+
+
+MODULE_LICENSE("GPL");
--- net/ipv6/route.c	2003-06-05 08:48:57.000000000 -0200
+++ ../mipv6-kernel/net/ipv6/route.c	2003-06-05 06:37:59.000000000 -0200
@@ -52,7 +52,7 @@
 #include <linux/rtnetlink.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
-
+#include <net/mipv6.h>
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_SYSCTL
@@ -336,7 +336,7 @@
 	return err;
 }
 
-/* No rt6_lock! If COW failed, the function returns dead route entry
+/* No rt6_lock! If COW faild, the function returns dead route entry
    with dst->error set to errno value.
  */
 
@@ -363,12 +363,8 @@
 		rt->u.dst.flags |= DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
-		if (rt->rt6i_src.plen && saddr) {
-			ipv6_addr_copy(&rt->rt6i_src.addr, saddr);
-			rt->rt6i_src.plen = 128;
-		}
+		rt->rt6i_src.plen = ort->rt6i_src.plen;
 #endif
-
 		rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
 
 		dst_hold(&rt->u.dst);
@@ -885,7 +881,7 @@
 	struct rt6_info *rt, *nrt;
 
 	/* Locate old route to this destination. */
-	rt = rt6_lookup(dest, NULL, neigh->dev->ifindex, 1);
+	rt = rt6_lookup(dest, saddr, neigh->dev->ifindex, 1);
 
 	if (rt == NULL)
 		return;
@@ -1052,6 +1048,9 @@
 		nrt = ip6_rt_copy(rt);
 		if (nrt == NULL)
 			goto out;
+#ifdef CONFIG_IPV6_SUBTREES
+		nrt->rt6i_src.plen = rt->rt6i_src.plen;
+#endif
 		ipv6_addr_copy(&nrt->rt6i_dst.addr, daddr);
 		nrt->rt6i_dst.plen = 128;
 		nrt->u.dst.flags |= DST_HOST;
@@ -1162,7 +1161,107 @@
 	}
 	read_unlock_bh(&rt6_lock);
 }
+/* TODO: Move struct definition 
+ * to a header file under include/linux 
+*/
+struct mipv6_info_user
+{
+	struct mip6_info bind;
+	unsigned long expires;
+	struct in6_addr src;
+	struct in6_addr dst;
+};
+
+/* Adds mip6 related info and a stacked dst entry to the new cached route.
+ */
+static void fill_mip6_rt(struct rt6_info *mip6rt, struct rt6_info *coart, struct mip6_info *bind)
+{
+	mip6rt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
+	mip6rt->u.dst.flags = DST_HOST;
+	mip6rt->u.dst.header_len = mip6_hdrlen(mip6rt->binding.flags);
+	mip6rt->u.dst.metrics[RTAX_MTU-1] = coart->u.dst.metrics[RTAX_MTU-1] - 
+		mip6rt->u.dst.header_len;
+	mip6rt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, dst_pmtu(&mip6rt->u.dst) - 60, ip6_rt_min_advmss);
+	if (mip6rt->u.dst.metrics[RTAX_ADVMSS-1] > 65535-20)
+		mip6rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535;
+	mip6rt->u.dst.child = dst_clone(&coart->u.dst); /* Is this correct ? */
+	memcpy(&mip6rt->binding, bind, sizeof(bind));
+	mip6rt->u.dst.output = mip6_output;
+}
+/* Add mipv6 information to a new cache route entry. 
+ * Mostly copied code from rt6_pmtu_discovery 
+ */
+int ip6_add_miproute(struct mipv6_info_user *mipinfo)
+{
+	/* First look up the coa route */
+	struct rt6_info  *rt, *mip6rt, *coart = NULL;
+	int err = 0;
+
+	if ((rt = (struct rt6_info *)rt6_lookup(&mipinfo->dst, &mipinfo->src, 0, 0)) == NULL) {
+		return -ENOENT;
+	}
+
+	/* 
+	 * Delete old host route before adding new one. TODO: Could we just modify the existing cache 
+	 * route after locking the routing table ?
+	 */
+	if (rt->rt6i_flags & RTF_CACHE) {
+		ip6_del_rt(rt, NULL, NULL);
+		rt = NULL;
+	}
+
+	if ((coart = rt6_lookup(&mipinfo->bind.rcoa, &mipinfo->bind.lcoa, 0, 0)) == NULL) {
+		err = -NOENT;
+		goto out;
+	}
+	/* Network route.
+	   Two cases are possible:
+	   1. It is connected route. Action: COW
+	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
+	 */
+	if (!coart->rt6i_nexthop && !(coart->rt6i_flags & RTF_NONEXTHOP)) {
+		mip6rt = rt6_cow(coart, &mipinfo->dst, &mipinfo->src);
+		if (!mip6rt->u.dst.error) {
+			mip6rt->u.dst.metrics[RTAX_MTU-1] = coart->u.dst.metrics[RTAX_MTU-1];
+			dst_set_expires(&mip6rt->u.dst, HZ*mipinfo->expires);
+			fill_mip6_rt(mip6rt, coart, &mipinfo->bind);
+			dst_release(&mip6rt->u.dst);
+		} 
+	} else {
+		
+		mip6rt = ip6_rt_copy(coart);
+		ipv6_addr_copy(&mip6rt->rt6i_dst.addr, &mipinfo->dst);
+		
+#ifdef CONFIG_IPV6_SUBTREES
+		ipv6_addr_copy(&mip6rt->rt6i_src.addr, &mipinfo->src);
+		mip6rt->rt6i_src.plen = 128;
+#endif
+		mip6rt->rt6i_dst.plen = 128;
+		mip6rt->u.dst.flags |= DST_HOST;
+		mip6rt->rt6i_nexthop = neigh_clone(coart->rt6i_nexthop);
+		dst_set_expires(&mip6rt->u.dst, HZ*mipinfo->expires);
+		mip6rt->rt6i_flags |= RTF_DYNAMIC|RTF_CACHE|RTF_EXPIRES;
+		mip6rt->u.dst.metrics[RTAX_MTU-1] = coart->u.dst.metrics[RTAX_MTU-1];
+		fill_mip6_rt(mip6rt, coart, &mipinfo->bind);
+		rt6_ins(mip6rt, NULL, NULL);
+	}
+ out:
+	if (coart) dst_release(&coart->u.dst);
+	if (rt) dst_release(&rt->u.dst);
+	return err;
+}
+
+static int add_mip6_binding(void *arg)
+{
+
+	struct mipv6_info_user mip; 
 
+	if (copy_from_user(&mip, arg, sizeof(mip))) {
+		return -EINVAL;
+	}
+
+	return ip6_add_miproute(&mip);
+}
 int ipv6_route_ioctl(unsigned int cmd, void *arg)
 {
 	struct in6_rtmsg rtmsg;
@@ -1192,9 +1291,18 @@
 		rtnl_unlock();
 
 		return err;
+	case SIOCADDMIPINFO:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		rtnl_lock();
+		err = add_mip6_binding(arg);
+		rtnl_unlock();
+		return err;
 	};
 
-	return -EINVAL;
+
+
+	 return -EINVAL;
 }
 
 /*
@@ -1786,12 +1894,11 @@
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
-	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
+	seq_printf(seq, "%04x %04x %04x %04x %04x %04x\n",
 		      rt6_stats.fib_nodes, rt6_stats.fib_route_nodes,
 		      rt6_stats.fib_rt_alloc, rt6_stats.fib_rt_entries,
 		      rt6_stats.fib_rt_cache,
-		      atomic_read(&ip6_dst_ops.entries),
-		      rt6_stats.fib_discarded_routes);
+		      atomic_read(&ip6_dst_ops.entries));
 
 	return 0;
 }
--- net/ipv6/af_inet6.c	2003-06-05 08:48:57.000000000 -0200
+++ ../mipv6-kernel/net/ipv6/af_inet6.c	2003-06-03 10:11:38.000000000 -0200
@@ -57,6 +57,7 @@
 #include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
+#include <net/mipv6.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -310,7 +311,7 @@
 	} else {
 		if (addr_type != IPV6_ADDR_ANY) {
 			/* ipv4 addr of the socket is invalid.  Only the
-			 * unspecified and mapped address have a v4 equivalent.
+			 * unpecified and mapped address have a v4 equivalent.
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
@@ -475,7 +476,7 @@
 
 	case SIOCADDRT:
 	case SIOCDELRT:
-	  
+	case SIOCADDMIPINFO:  
 		return(ipv6_route_ioctl(cmd,(void *)arg));
 
 	case SIOCSIFADDR:
@@ -780,6 +781,14 @@
 	err = ndisc_init(&inet6_family_ops);
 	if (err)
 		goto ndisc_fail;
+#ifdef CONFIG_IPV6_TUNNEL
+	err = ip6_tunnel_init();
+	if (err)
+		goto ip6_tunnel_fail;
+#endif
+	err = mip6_init();
+	if (err)
+		goto mip6_fail;
 	err = igmp6_init(&inet6_family_ops);
 	if (err)
 		goto igmp_fail;
@@ -816,7 +825,6 @@
 	/* Init v6 transport protocols. */
 	udpv6_init();
 	tcpv6_init();
-
 	return 0;
 
 #ifdef CONFIG_PROC_FS
@@ -834,6 +842,12 @@
 	igmp6_cleanup();
 #endif
 igmp_fail:
+	mip6_cleanup();
+mip6_fail:
+#ifdef CONFIG_IPV6_TUNNEL
+	ip6_tunnel_cleanup();
+ip6_tunnel_fail:
+#endif
 	ndisc_cleanup();
 ndisc_fail:
 	icmpv6_cleanup();
@@ -869,6 +883,10 @@
 	ip6_route_cleanup();
 	ipv6_packet_cleanup();
 	igmp6_cleanup();
+	mip6_cleanup();
+#ifdef CONFIG_IPV6_TUNNEL
+	ip6_tunnel_cleanup();
+#endif
 	ndisc_cleanup();
 	icmpv6_cleanup();
 #ifdef CONFIG_SYSCTL
--- include/net/mipv6.h	1969-12-31 22:00:00.000000000 -0200
+++ ../mipv6-kernel/include/net/mipv6.h	2003-06-05 06:21:37.000000000 -0200
@@ -0,0 +1,53 @@
+/* mipv6.h - Mobile IPv6 kernel support */
+
+#ifndef _NET_MIPV6_H
+#define _NET_MIPV6_H
+
+#define MIPV6_F_BULE                    0x1
+#define MIPV6_F_BCE                     0x2
+#define MIPV6_OPT_PAD1			0x00
+#define MIPV6_OPT_PADN			0x01
+/**
+ * NIPV6ADDR - macro for IPv6 addresses
+ * @addr: Network byte order IPv6 address
+ *
+ * Macro for printing IPv6 addresses.  Used in conjunction with
+ * printk() or derivatives (such as DEBUG macro).
+ **/
+#define NIPV6ADDR(addr) \
+        ntohs(((u16 *)addr)[0]), \
+        ntohs(((u16 *)addr)[1]), \
+        ntohs(((u16 *)addr)[2]), \
+        ntohs(((u16 *)addr)[3]), \
+        ntohs(((u16 *)addr)[4]), \
+        ntohs(((u16 *)addr)[5]), \
+        ntohs(((u16 *)addr)[6]), \
+        ntohs(((u16 *)addr)[7])
+
+struct ipv6_dstopt_homeaddr
+{
+	__u8		type;		/* type-code for option 	*/
+	__u8		length;		/* option length 		*/
+	struct in6_addr	addr;		/* home address 		*/
+} __attribute__ ((packed));
+static inline int mip6_hdrlen(int flags)
+{
+	int miphdrlen = 0;
+
+	if (flags & MIPV6_F_BULE)
+		miphdrlen = sizeof(struct ipv6_dstopt_homeaddr) + 6;
+	if (flags & MIPV6_F_BCE)
+		miphdrlen += sizeof(struct rt2_hdr);
+	return miphdrlen;
+}
+int mip6_output(struct sk_buff *skb);
+struct ipv6_txoptions *
+mipv6_modify_txoptions(struct sock *sk,  
+		       struct ipv6_txoptions *old_opt, struct flowi *fl, 
+		       struct dst_entry **dst);
+
+int mip6_hao_check(struct sk_buff *skb, u8 nexthdr);
+int mip6_init(void);
+void mip6_cleanup(void);
+
+#endif /* _NET_MIPV6_H */
--- include/net/ip6_fib.h	2003-06-05 08:48:46.000000000 -0200
+++ ../mipv6-kernel/include/net/ip6_fib.h	2003-06-03 10:11:19.000000000 -0200
@@ -50,6 +50,13 @@
 	int		plen;
 };
 
+struct mip6_info
+{
+	struct in6_addr lcoa;
+	struct in6_addr rcoa;
+	u32             flags;
+};
+
 struct rt6_info
 {
 	union {
@@ -71,8 +78,9 @@
 
 	struct rt6key			rt6i_dst;
 	struct rt6key			rt6i_src;
-
+	
 	u8				rt6i_protocol;
+	struct mip6_info                binding;
 };
 
 struct fib6_walker_t
@@ -111,10 +119,9 @@
 struct rt6_statistics {
 	__u32		fib_nodes;
 	__u32		fib_route_nodes;
-	__u32		fib_rt_alloc;		/* permanent routes	*/
+	__u32		fib_rt_alloc;		/* permanet routes	*/
 	__u32		fib_rt_entries;		/* rt entries in table	*/
 	__u32		fib_rt_cache;		/* cache routes		*/
-	__u32		fib_discarded_routes;
 };
 
 #define RTN_TL_ROOT	0x0001

--------------080703090805070306090804--
