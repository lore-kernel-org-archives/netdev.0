From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sun, 06 Oct 2002 03:33:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021006.033351.33728380.yoshfuji@linux-ipv6.org>
References: <20021004.015045.96199793.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210040902010.16205-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210040902010.16205-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you for your comments.

In article <Pine.LNX.4.44.0210040902010.16205-100000@netcore.fi> (at Fri, 4 Oct 2002 09:32:33 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> Are IPv4 addresses represented as mapped addresses (as they should by the 
> spec at least)?

see below.


> There seem to be some points at section 4 of the draft (e.g. for multicast
> destinations, MUST only pick addresses on the outgoing interface) that may
> be missing?

fixed.


> > +#ifndef IPV6_ADDR_MC_SCOPE
> > +#define IPV6_ADDR_MC_SCOPE(a)	\
> > +	((a)->s6_addr[1] & 0x0f)	/* XXX nonstandard */
:

> Aren't these definitions header file material, perhaps (I'd guess they 
> might be useful in other .c files too).

I thought that we would do it later, but anyway,
moved to include/net/ipv6.h.


> > +int ipv6_addrselect_scope(const struct in6_addr *addr)
:
> Something similar to this is done in addrconf.c:ipv6_addr_type, could 
> there be more reuse?

integrated core of the code to ipv6_addr_type().


> > +			if (addr->s6_addr32[3] == __constant_htonl(0x00000001))
> > +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.4 */
> > +
> > +			return IPV6_ADDR_SCOPE_GLOBAL;			/* section 2.3 */
> > +		}
> 
> You're referring to sections 3.4 and 3.3, I think (similar in other 
> comments)

fixed.


> > +		if (addr->s6_addr32[2] == __constant_htonl(0x0000FFFF)) {
> > +			if (addr->s6_addr32[3] == __constant_htonl(0xA9FF0000))
> > +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.2 */
> 
> Shouldn't that be 0xA9FE0000 if you mean IPv4 zeroconf 169.254.0.0/16 ?
> (that could be spelt out in a comment.)
> 
> > +			if (addr->s6_addr32[3] == __constant_htonl(0xAC000000)) {
> > +				if (addr->s6_addr32[3] == __constant_htonl(0xAC100000))
> > +					return IPV6_ADDR_SCOPE_SITELOCAL;	/* section 2.2 */
> 
> 172.16.00 -- 172.31.255.255, not just 172.16.*.*
> 
> > +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.2 */
> > +			}
> 
> I don't understand this, this was possibly supposed to be the case for 
> 127.0.0.0/8 which should be treated as link-local?

How stupid code I wrote... And,.. I reread the spec and found that 
ipv4-mapped addresses are global scope for source address selection.
So..., I removed above codes.

Well,

Following patch is against linux-2.4.19.

BTW, "IPv6: Miscellaneous clean-ups" (FIX_2_4_19_MISC_CLEANUPS-20020912) and 
this patch conflics.  What kind of patch do you prefer?
 1. patch on top of plain kernel
 2. patch on top of other-patched kernel
 3. patch with other patch (which conflicts) on top of plain kernel

Thank you in advance.

Index: include/net/addrconf.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/include/net/addrconf.h,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.6.1
diff -u -r1.1.1.1 -r1.1.1.1.6.1
--- include/net/addrconf.h	2002/08/20 09:46:45	1.1.1.1
+++ include/net/addrconf.h	2002/09/26 19:15:15	1.1.1.1.6.1
@@ -55,6 +55,9 @@
 					      struct net_device *dev);
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
 						struct net_device *dev);
+extern int			ipv6_dev_get_saddr(struct net_device *ddev,
+						   struct in6_addr *daddr,
+						   struct in6_addr *saddr);
 extern int			ipv6_get_saddr(struct dst_entry *dst, 
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
Index: include/net/ipv6.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/include/net/ipv6.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 ipv6.h
--- include/net/ipv6.h	2002/08/20 09:46:45	1.1.1.1
+++ include/net/ipv6.h	2002/10/05 17:43:48
@@ -74,6 +74,20 @@
 #define IPV6_ADDR_RESERVED	0x2000U	/* reserved address space */
 
 /*
+ * 	Addr scopes
+ */
+#ifdef __KERNEL__
+#define IPV6_ADDR_MC_SCOPE(a)   \
+        ((a)->s6_addr[1] & 0x0f)        /* XXX nonstandard */
+#define __IPV6_ADDR_SCOPE_INVALID	-1
+#endif
+#define IPV6_ADDR_SCOPE_NODELOCAL       0x01
+#define IPV6_ADDR_SCOPE_LINKLOCAL       0x02
+#define IPV6_ADDR_SCOPE_SITELOCAL       0x05
+#define IPV6_ADDR_SCOPE_ORGLOCAL        0x08
+#define IPV6_ADDR_SCOPE_GLOBAL          0x0e
+
+/*
  *	fragmentation header
  */
 
@@ -203,12 +217,28 @@
 					   char *,
 					   unsigned int, unsigned int);
 
-
-extern int		ipv6_addr_type(struct in6_addr *addr);
+/*
+ *	Address manipulation functions
+ */
+extern int		__ipv6_addr_type(struct in6_addr *addr);
+static inline		int ipv6_addr_type(struct in6_addr *addr)
+{
+	return __ipv6_addr_type(addr) & 0xffff;
+}
 
 static inline int ipv6_addr_scope(struct in6_addr *addr)
+{
+	return __ipv6_addr_type(addr) & IPV6_ADDR_SCOPE_MASK;
+}
+
+static inline int __ipv6_addr_src_scope(int type)
+{
+	return type == IPV6_ADDR_ANY ? __IPV6_ADDR_SCOPE_INVALID : type>>16;
+}
+
+static inline int ipv6_addr_src_scope(struct in6_addr *addr)
 {
-	return ipv6_addr_type(addr) & IPV6_ADDR_SCOPE_MASK;
+	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
 }
 
 static inline int ipv6_addr_cmp(struct in6_addr *a1, struct in6_addr *a2)
Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.6.16
diff -u -r1.1.1.1 -r1.1.1.1.6.16
--- net/ipv6/addrconf.c	2002/08/20 09:47:02	1.1.1.1
+++ net/ipv6/addrconf.c	2002/10/05 17:26:27	1.1.1.1.6.16
@@ -26,6 +26,10 @@
  *						packets.
  *	yoshfuji@USAGI			:       Fixed interval between DAD
  *						packets.
+ *	YOSHIFUJI Hideaki @USAGI	:	improved source address
+ *						selection; consider scope,
+ *						status etc.
+ *
  */
 
 #include <linux/config.h>
@@ -104,6 +108,8 @@
 
 static struct notifier_block *inet6addr_chain;
 
+static u32 ipv6_addrselect_label_lookup(const struct in6_addr *addr, int ifindex);
+
 struct ipv6_devconf ipv6_devconf =
 {
 	0,				/* forwarding		*/
@@ -132,7 +138,7 @@
 	MAX_RTR_SOLICITATION_DELAY,	/* rtr solicit delay	*/
 };
 
-int ipv6_addr_type(struct in6_addr *addr)
+int __ipv6_addr_type(struct in6_addr *addr)
 {
 	u32 st;
 
@@ -143,32 +149,38 @@
 	 */
 	if ((st & __constant_htonl(0xE0000000)) != __constant_htonl(0x00000000) &&
 	    (st & __constant_htonl(0xE0000000)) != __constant_htonl(0xE0000000))
-		return IPV6_ADDR_UNICAST;
+		return (IPV6_ADDR_UNICAST | 
+			IPV6_ADDR_SCOPE_GLOBAL<<16);
 
 	if ((st & __constant_htonl(0xFF000000)) == __constant_htonl(0xFF000000)) {
-		int type = IPV6_ADDR_MULTICAST;
+		/* multicast */
+		/* addr-select 3.1 */
+		int type = IPV6_ADDR_MC_SCOPE(addr)<<16;
 
-		switch((st & __constant_htonl(0x00FF0000))) {
-			case __constant_htonl(0x00010000):
+		switch(type) {
+			case IPV6_ADDR_SCOPE_NODELOCAL<<16:
 				type |= IPV6_ADDR_LOOPBACK;
 				break;
 
-			case __constant_htonl(0x00020000):
+			case IPV6_ADDR_SCOPE_LINKLOCAL<<16:
 				type |= IPV6_ADDR_LINKLOCAL;
 				break;
 
-			case __constant_htonl(0x00050000):
+			case IPV6_ADDR_SCOPE_SITELOCAL<<16:
 				type |= IPV6_ADDR_SITELOCAL;
 				break;
 		};
+		type |= IPV6_ADDR_MULTICAST;
 		return type;
 	}
 	
 	if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFE800000))
-		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST);
+		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST | 
+			IPV6_ADDR_SCOPE_LINKLOCAL<<16);		/* addr-select 3.1 */
 
 	if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFEC00000))
-		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST);
+		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
+			IPV6_ADDR_SCOPE_SITELOCAL<<16);		/* addr-select 3.1 */
 
 	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
 		if (addr->s6_addr32[2] == 0) {
@@ -176,18 +188,52 @@
 				return IPV6_ADDR_ANY;
 
 			if (addr->s6_addr32[3] == __constant_htonl(0x00000001))
-				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST);
+				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
+					IPV6_ADDR_SCOPE_LINKLOCAL<<16);	/* addr-select 3.4 */
 
-			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST);
+			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
+				IPV6_ADDR_SCOPE_GLOBAL<<16);	/* addr-select 3.3 */
 		}
 
 		if (addr->s6_addr32[2] == __constant_htonl(0x0000ffff))
-			return IPV6_ADDR_MAPPED;
+			return (IPV6_ADDR_MAPPED | 
+				IPV6_ADDR_SCOPE_GLOBAL<<16);	/* addr-select 3.3 */
 	}
 
-	return IPV6_ADDR_RESERVED;
+	return (IPV6_ADDR_RESERVED | 
+		IPV6_ADDR_SCOPE_GLOBAL<<16);	/* addr-select 3.4 */
 }
 
+/* find 1st bit in difference between the 2 addrs */
+static inline int addr_diff(const void *__a1, const void *__a2, int addrlen)
+{
+	/* find 1st bit in difference between the 2 addrs.
+	 * bit may be an invalid value,
+	 * but if it is >= plen, the value is ignored in any case.
+	 */
+	const u32 *a1 = __a1;
+	const u32 *a2 = __a2;
+	int i;
+
+	addrlen >>= 2;
+	for (i = 0; i < addrlen; i++) {
+		u32 xb = a1[i] ^ a2[i];
+		if (xb) {
+			int j = 31;
+			xb = ntohl(xb);
+			while ((xb & (1 << j)) == 0)
+				j--;
+			return (i * 32 + 31 - j);
+		}
+	}
+	return addrlen<<5;
+}
+
+static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_addr *a2)
+{
+	 return addr_diff(a1->s6_addr, a2->s6_addr, sizeof(struct in6_addr));
+}
+
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
 {
 	if (del_timer(&ifp->timer))
@@ -449,122 +495,189 @@
 
 /*
  *	Choose an apropriate source address
- *	should do:
- *	i)	get an address with an apropriate scope
- *	ii)	see if there is a specific route for the destination and use
- *		an address of the attached interface 
- *	iii)	don't use deprecated addresses
+ *	draft-ietf-ipv6-default-addr-select-09.txt
  */
-int ipv6_get_saddr(struct dst_entry *dst,
-		   struct in6_addr *daddr, struct in6_addr *saddr)
+#define IPV6_SADDRSELECT_SELF		0x01
+#define IPV6_SADDRSELECT_PREFERRED	0x02
+#define IPV6_SADDRSELECT_HOME		0x04
+#define IPV6_SADDRSELECT_PUBLIC		0x08
+#define IPV6_SADDRSELECT_INTERFACE	0x10
+#define IPV6_SADDRSELECT_LABEL		0x20
+
+struct addrselect_attrs {
+	struct inet6_ifaddr *ifp;
+	u16	flags;
+	s16	matchlen;
+	u8	scope;
+};
+
+int ipv6_dev_get_saddr(struct net_device *daddr_dev,
+		       struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	int scope;
-	struct inet6_ifaddr *ifp = NULL;
-	struct inet6_ifaddr *match = NULL;
-	struct net_device *dev = NULL;
+	int daddr_type, daddr_scope;
+	u32 daddr_label;
+	struct inet6_ifaddr *ifp0, *ifp = NULL;
+	struct net_device *dev;
 	struct inet6_dev *idev;
-	struct rt6_info *rt;
+
 	int err;
+	int update;
+	struct addrselect_attrs candidate = {NULL,0,0};
 
-	rt = (struct rt6_info *) dst;
-	if (rt)
-		dev = rt->rt6i_dev;
-
-	scope = ipv6_addr_scope(daddr);
-	if (rt && (rt->rt6i_flags & RTF_ALLONLINK)) {
-		/*
-		 *	route for the "all destinations on link" rule
-		 *	when no routers are present
-		 */
-		scope = IFA_LINK;
-	}
+	daddr_type = __ipv6_addr_type(daddr);
+	daddr_scope = __ipv6_addr_src_scope(daddr_type);
+	daddr_label = ipv6_addrselect_label_lookup(daddr, 
+						   daddr_dev?daddr_dev->ifindex:0);
 
-	/*
-	 *	known dev
-	 *	search dev and walk through dev addresses
-	 */
+	read_lock(&dev_base_lock);
+	read_lock(&addrconf_lock);
+	for (dev = dev_base; dev; dev=dev->next) {
+		idev = __in6_dev_get(dev);
 
-	if (dev) {
-		if (dev->flags & IFF_LOOPBACK)
-			scope = IFA_HOST;
+		if (!idev)
+			continue;
 
-		read_lock(&addrconf_lock);
-		idev = __in6_dev_get(dev);
-		if (idev) {
-			read_lock_bh(&idev->lock);
-			for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-				if (ifp->scope == scope) {
-					if (!(ifp->flags & (IFA_F_DEPRECATED|IFA_F_TENTATIVE))) {
-						in6_ifa_hold(ifp);
-						read_unlock_bh(&idev->lock);
-						read_unlock(&addrconf_lock);
-						goto out;
-					}
-
-					if (!match && !(ifp->flags & IFA_F_TENTATIVE)) {
-						match = ifp;
-						in6_ifa_hold(ifp);
-					}
+		/* Rule 0: Candidate Source Address (section 4)
+		 *  - multicast and link-local destination address,
+		 *    the set of candidate source address MUST only
+		 *    include addresses assigned to interfaces
+		 *    belonging to the same link as the outgoing
+		 *    interface.
+		 * (- For site-local destination addresses, the
+		 *    set of candidate source addresses MUST only
+		 *    include addresses assigned to interfaces
+		 *    belonging to the same site as the outgoing
+		 *    interface.)
+		 */
+		if ((daddr_type&IPV6_ADDR_MULTICAST ||
+		     daddr_scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
+		    daddr_dev && dev != daddr_dev)
+			continue;
+
+		read_lock_bh(&idev->lock);
+		ifp0 = idev->addr_list;
+		for (ifp=ifp0; ifp; ifp=ifp->if_next) {
+			struct addrselect_attrs temp = {NULL,0,0};
+			int addr_type;
+			update = 0;
+
+			/* Rule 0: Candidate Source Address (section 4)
+			 *  - In any case, anycast addresses, multicast
+			 *    addresses, and the unspecified address MUST
+			 *    NOT be included in a candidate set.
+			 */
+			addr_type = __ipv6_addr_type(&ifp->addr);
+			if (addr_type == IPV6_ADDR_ANY ||
+			    addr_type&IPV6_ADDR_MULTICAST)
+				continue;
+
+			/* Rule 1: Prefer same address */
+			if (ipv6_addr_cmp(&ifp->addr, daddr) == 0)
+				temp.flags |= IPV6_SADDRSELECT_SELF;
+			else
+				temp.flags &= ~IPV6_SADDRSELECT_SELF;
+				update = (temp.flags&IPV6_SADDRSELECT_SELF) -
+					 (candidate.flags&IPV6_SADDRSELECT_SELF);
+			if (update < 0) {
+				continue;
+			}
+
+			/* Rule 2: Prefer appropriate scope */
+			temp.scope = __ipv6_addr_src_scope(addr_type);
+			if (!update) {
+				update = temp.scope - candidate.scope;
+				if (update > 0) {
+					update = candidate.scope < daddr_scope ? 1 : -1;
+				} else if (update < 0) {
+					update = temp.scope < daddr_scope ? -1 : 1;
 				}
 			}
-			read_unlock_bh(&idev->lock);
-		}
-		read_unlock(&addrconf_lock);
-	}
+			if (update < 0) {
+				continue;
+			}
 
-	if (scope == IFA_LINK)
-		goto out;
+			/* Rule 3: Avoid deprecated address */
+			if (!(ifp->flags & IFA_F_DEPRECATED))
+				temp.flags |= IPV6_SADDRSELECT_PREFERRED;
+			else
+				temp.flags &= ~IPV6_SADDRSELECT_PREFERRED;
+			if (!update)
+				update = (temp.flags&IPV6_SADDRSELECT_PREFERRED) -
+					 (candidate.flags&IPV6_SADDRSELECT_PREFERRED);
+			if (update < 0) {
+				continue;
+			}
 
-	/*
-	 *	dev == NULL or search failed for specified dev
-	 */
+			/* XXX: Rule 4: Prefer home address */
 
-	read_lock(&dev_base_lock);
-	read_lock(&addrconf_lock);
-	for (dev = dev_base; dev; dev=dev->next) {
-		idev = __in6_dev_get(dev);
-		if (idev) {
-			read_lock_bh(&idev->lock);
-			for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-				if (ifp->scope == scope) {
-					if (!(ifp->flags&(IFA_F_DEPRECATED|IFA_F_TENTATIVE))) {
-						in6_ifa_hold(ifp);
-						read_unlock_bh(&idev->lock);
-						goto out_unlock_base;
-					}
-
-					if (!match && !(ifp->flags&IFA_F_TENTATIVE)) {
-						match = ifp;
-						in6_ifa_hold(ifp);
-					}
-				}
+			/* Rule 5: Prefer outgoing interface */
+			if (daddr_dev == NULL || ifp->idev == NULL ||
+			    daddr_dev == ifp->idev->dev)
+				temp.flags |= IPV6_SADDRSELECT_INTERFACE;
+			else
+				temp.flags &= ~IPV6_SADDRSELECT_INTERFACE;
+			if (!update)
+				update = (temp.flags&IPV6_SADDRSELECT_INTERFACE) -
+					 (candidate.flags&IPV6_SADDRSELECT_INTERFACE);
+			if (update < 0) {
+				continue;
+			}
+
+			/* XXX: Rule 6: Prefer matching label */
+			if (ipv6_addrselect_label_lookup(&ifp->addr, dev->ifindex) == daddr_label)
+				temp.flags |= IPV6_SADDRSELECT_LABEL;
+			else
+				temp.flags &= ~IPV6_SADDRSELECT_LABEL;
+			if (!update)
+				update = (temp.flags&IPV6_SADDRSELECT_LABEL) -
+					 (candidate.flags&IPV6_SADDRSELECT_LABEL);
+			if (update < 0) {
+				continue;
+			}
+
+			/* XXX: Rule 7: Prefer public address */
+
+			/* Rule 8: Use longest matching prefix */
+			temp.matchlen = ipv6_addr_diff(&ifp->addr, daddr);
+			if (!update)
+				update = temp.matchlen - candidate.matchlen;
+			if (update < 0) {
+				continue;
 			}
-			read_unlock_bh(&idev->lock);
+
+			/* Final Rule */
+			if (update <= 0)
+				continue;
+
+			/* update candidate */
+			temp.ifp = ifp;
+			in6_ifa_hold(ifp);
+			if (candidate.ifp)
+				in6_ifa_put(candidate.ifp);
+			candidate = temp;
 		}
+		read_unlock_bh(&idev->lock);
 	}
-
-out_unlock_base:
 	read_unlock(&addrconf_lock);
 	read_unlock(&dev_base_lock);
-
-out:
-	if (ifp == NULL) {
-		ifp = match;
-		match = NULL;
-	}
 
-	err = -EADDRNOTAVAIL;
-	if (ifp) {
-		ipv6_addr_copy(saddr, &ifp->addr);
+	if (candidate.ifp) {
+		ipv6_addr_copy(saddr, &candidate.ifp->addr);
+		in6_ifa_put(candidate.ifp);
 		err = 0;
-		in6_ifa_put(ifp);
+	} else {
+		err = -EADDRNOTAVAIL;
 	}
-	if (match)
-		in6_ifa_put(match);
-
 	return err;
 }
 
+int ipv6_get_saddr(struct dst_entry *dst,
+		   struct in6_addr *daddr, struct in6_addr *saddr)
+{
+	return ipv6_dev_get_saddr(dst ? ((struct rt6_info *)dst)->rt6i_dev : NULL,
+				  daddr, saddr);
+}
+
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
@@ -636,6 +749,69 @@
 	read_unlock_bh(&addrconf_hash_lock);
 
 	return ifp;
+}
+
+/* address selection: default policy label */
+/* XXX: user level configuration */
+static struct ipv6_addrselect_label {
+	struct in6_addr addr;
+	u16	plen;
+	u32	ifindex;
+	u32	label;
+} ipv6_addrselect_label_table[] = {
+	/* ::1/128, label = 0 */
+	{
+		.addr = {{{ [15] = 1 }}},
+		.plen = 128,
+		.label = 0,
+	},
+	/* ::/0, label = 1 */
+	{
+		.plen = 0,
+		.label = 1,
+	},
+	/* 2002::/16, label = 2 */
+	{
+		.addr = {{{ 0x20, 0x02 }}},
+		.plen = 16,
+		.label = 2,
+	},
+	/* ::/96, label = 3 */
+	{
+		.plen = 96,
+		.label = 3,
+	},
+	/* ::ffff:0:0/96, label = 4 */
+	{
+		.addr = {{{ [10] = 0xff, [11] = 0xff }}},
+		.plen = 96,
+		.label = 4,
+	},
+	/* sentinel */
+	{
+		.label = 0xffffffff,
+	}
+};
+
+static u32 ipv6_addrselect_label_lookup(const struct in6_addr *addr, 
+					int ifindex)
+{
+	struct ipv6_addrselect_label *p;
+	int plen, matchlen = -1;
+	u32 label = 0xffffffff;
+
+	for (p = ipv6_addrselect_label_table;
+	     p->label != 0xffffffff;
+	     p++) {
+		if (ifindex && p->ifindex && ifindex != p->ifindex)
+			continue;
+		plen = ipv6_addr_diff(addr, &p->addr);
+		if (plen < p->plen || plen < matchlen)
+			continue;
+		matchlen = plen;
+		label = p->label;
+	}
+	return label;
 }
 
 /* Gets referenced address, destroys ifaddr */
