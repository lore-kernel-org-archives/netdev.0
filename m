From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] Ndisc updates
Date: Fri, 21 Jan 2005 01:53:26 +0900 (JST)
Message-ID: <20050121.015326.41280602.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull following changesets available at
  <bk://bk.skbuff.net:20611/linux-2.6-ndisc-20050121/>.

Note: Roland already reviewd ipoib changeset.

Thank you.

HEADLINES
---------
ChangeSet@1.2344, 2005-01-21 01:26:45+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: save space for ndisc_options{}.
ChangeSet@1.2345, 2005-01-21 01:26:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: make ndisc_opt_lladdr_data() and check length inside.
ChangeSet@1.2346, 2005-01-21 01:27:09+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_len() to calculate ND option length.
ChangeSet@1.2347, 2005-01-21 01:27:21+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_data() to get ND option data.
ChangeSet@1.2348, 2005-01-21 01:27:34+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_lladdr_space() to calculate ND option length for device.
ChangeSet@1.2349, 2005-01-21 01:32:39+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: prepend correct padding to IPoIB link-layer address option.


DIFFSTATS
---------
 include/net/ndisc.h |   14 +++---
 net/ipv6/ndisc.c    |  121 +++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 91 insertions(+), 44 deletions(-)


CHANGESETS
----------
ChangeSet@1.2344, 2005-01-21 01:26:45+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: save space for ndisc_options{}.
 
 Pointed out by Krishna Kumar <kumarkr@us.ibm.com>.
 
 Also, size of structure is now adjusted automatically.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ndisc.h b/include/net/ndisc.h
--- a/include/net/ndisc.h	2005-01-21 01:45:48 +09:00
+++ b/include/net/ndisc.h	2005-01-21 01:45:48 +09:00
@@ -15,11 +15,15 @@
  *	ndisc options
  */
 
-#define ND_OPT_SOURCE_LL_ADDR		1
-#define ND_OPT_TARGET_LL_ADDR		2
-#define ND_OPT_PREFIX_INFO		3
-#define ND_OPT_REDIRECT_HDR		4
-#define ND_OPT_MTU			5
+enum {
+	__ND_OPT_PREFIX_INFO_END = 0,
+	ND_OPT_SOURCE_LL_ADDR = 1,	/* RFC2461 */
+	ND_OPT_TARGET_LL_ADDR = 2,	/* RFC2461 */
+	ND_OPT_PREFIX_INFO = 3,		/* RFC2461 */
+	ND_OPT_REDIRECT_HDR = 4,	/* RFC2461 */
+	ND_OPT_MTU = 5,			/* RFC2461 */
+	__ND_OPT_MAX
+};
 
 #define MAX_RTR_SOLICITATION_DELAY	HZ
 
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:45:48 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:45:48 +09:00
@@ -156,14 +156,13 @@
 
 /* ND options */
 struct ndisc_options {
-	struct nd_opt_hdr *nd_opt_array[7];
-	struct nd_opt_hdr *nd_opt_piend;
+	struct nd_opt_hdr *nd_opt_array[__ND_OPT_MAX];
 };
 
 #define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
 #define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
 #define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
-#define nd_opts_pi_end		nd_opt_piend
+#define nd_opts_pi_end		nd_opt_array[__ND_OPT_PREFIX_INFO_END]
 #define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
 #define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
 

ChangeSet@1.2345, 2005-01-21 01:26:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: make ndisc_opt_lladdr_data() and check length inside.
 
 What we should do is to check lladdrlen and get pointer
 for link-layer address option.
 Since we know lladdrlen == dev->addr_len, we can check inside.
 
 Singned-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:45:52 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:45:52 +09:00
@@ -245,6 +245,15 @@
 	return ndopts;
 }
 
+static inline u8 *ndisc_opt_lladdr_data(struct nd_opt_hdr *p, struct net_device *dev)
+{
+	u8 *lladdr = (u8 *)(p + 1);
+	int lladdrlen = p->nd_opt_len << 3;
+	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len))
+		return NULL;
+	return lladdr;
+}
+
 int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
 {
 	switch (dev->type) {
@@ -679,7 +688,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct in6_addr *daddr = &skb->nh.ipv6h->daddr;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 	u32 ndoptlen = skb->tail - msg->opt;
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -716,9 +724,8 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1);
-		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
+		lladdr = ndisc_opt_lladdr_data(ndopts.nd_opts_src_lladdr, dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NS: invalid link-layer address length\n");
 			return;
@@ -841,7 +848,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct in6_addr *daddr = &skb->nh.ipv6h->daddr;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 	u32 ndoptlen = skb->tail - msg->opt;
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -873,9 +879,8 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
-		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
+		lladdr = ndisc_opt_lladdr_data(ndopts.nd_opts_tgt_lladdr, dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 NA: invalid link-layer address length\n");
 			return;
@@ -932,7 +937,6 @@
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
 	struct ndisc_options ndopts;
 	u8 *lladdr = NULL;
-	int lladdrlen = 0;
 
 	if (skb->len < sizeof(*rs_msg))
 		return;
@@ -963,9 +967,8 @@
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1);
-		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len))
+		lladdr = ndisc_opt_lladdr_data(ndopts.nd_opts_src_lladdr, skb->dev);
+		if (!lladdr)
 			goto out;
 	}
 
@@ -1127,11 +1130,9 @@
 
 	if (rt && (neigh = rt->rt6i_nexthop) != NULL) {
 		u8 *lladdr = NULL;
-		int lladdrlen;
 		if (ndopts.nd_opts_src_lladdr) {
-			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1);
-			lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
-			if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
+			lladdr = ndisc_opt_lladdr_data(ndopts.nd_opts_src_lladdr, skb->dev);
+			if (!lladdr) {
 				ND_PRINTK2(KERN_WARNING
 					   "ICMPv6 RA: invalid link-layer address length\n");
 				goto out;
@@ -1194,7 +1195,6 @@
 	struct ndisc_options ndopts;
 	int optlen;
 	u8 *lladdr = NULL;
-	int lladdrlen;
 
 	if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
@@ -1249,9 +1249,8 @@
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
-		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
-		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
+		lladdr = ndisc_opt_lladdr_data(ndopts.nd_opts_tgt_lladdr, skb->dev);
+		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 Redirect: invalid link-layer address length\n");
 			in6_dev_put(in6_dev);

ChangeSet@1.2346, 2005-01-21 01:27:09+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_len() to calculate ND option length.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:45:57 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:45:57 +09:00
@@ -168,6 +168,11 @@
 
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
+static inline int ndisc_opt_len(struct nd_opt_hdr *opt)
+{
+	return (opt->nd_opt_len << 3);
+}
+
 static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
 {
 	int space = NDISC_OPT_SPACE(data_len);
@@ -190,7 +195,7 @@
 		return NULL;
 	type = cur->nd_opt_type;
 	do {
-		cur = ((void *)cur) + (cur->nd_opt_len << 3);
+		cur = ((void *)cur) + ndisc_opt_len(cur);
 	} while(cur < end && cur->nd_opt_type != type);
 	return (cur <= end && cur->nd_opt_type == type ? cur : NULL);
 }
@@ -207,7 +212,7 @@
 		int l;
 		if (opt_len < sizeof(struct nd_opt_hdr))
 			return NULL;
-		l = nd_opt->nd_opt_len << 3;
+		l = ndisc_opt_len(nd_opt);
 		if (opt_len < l || l == 0)
 			return NULL;
 		switch (nd_opt->nd_opt_type) {
@@ -248,7 +253,7 @@
 static inline u8 *ndisc_opt_lladdr_data(struct nd_opt_hdr *p, struct net_device *dev)
 {
 	u8 *lladdr = (u8 *)(p + 1);
-	int lladdrlen = p->nd_opt_len << 3;
+	int lladdrlen = ndisc_opt_len(p);
 	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len))
 		return NULL;
 	return lladdr;
@@ -1150,7 +1155,7 @@
 		for (p = ndopts.nd_opts_pi;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
-			addrconf_prefix_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3);
+			addrconf_prefix_rcv(skb->dev, (u8*)p, ndisc_opt_len(p));
 		}
 	}
 

ChangeSet@1.2347, 2005-01-21 01:27:21+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_data() to get ND option data.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:46:02 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:46:02 +09:00
@@ -173,6 +173,11 @@
 	return (opt->nd_opt_len << 3);
 }
 
+static inline u8 *ndisc_opt_data(struct nd_opt_hdr *opt)
+{
+	return ((u8 *)(opt + 1));
+}
+
 static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
 {
 	int space = NDISC_OPT_SPACE(data_len);
@@ -252,7 +257,7 @@
 
 static inline u8 *ndisc_opt_lladdr_data(struct nd_opt_hdr *p, struct net_device *dev)
 {
-	u8 *lladdr = (u8 *)(p + 1);
+	u8 *lladdr = ndisc_opt_data(p);
 	int lladdrlen = ndisc_opt_len(p);
 	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len))
 		return NULL;
@@ -1162,7 +1167,7 @@
 	if (ndopts.nd_opts_mtu) {
 		u32 mtu;
 
-		memcpy(&mtu, ((u8*)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
+		memcpy(&mtu, ndisc_opt_data(ndopts.nd_opts_mtu) + 2, sizeof(mtu));
 		mtu = ntohl(mtu);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {

ChangeSet@1.2348, 2005-01-21 01:27:34+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: ndisc_opt_lladdr_space() to calculate ND option length for device.
 
 Signed-off-by: Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:46:06 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:46:06 +09:00
@@ -255,6 +255,11 @@
 	return ndopts;
 }
 
+static inline int ndisc_opt_lladdr_space(struct net_device *dev)
+{
+	return NDISC_OPT_SPACE(dev->addr_len);
+}
+
 static inline u8 *ndisc_opt_lladdr_data(struct nd_opt_hdr *p, struct net_device *dev)
 {
 	u8 *lladdr = ndisc_opt_data(p);
@@ -436,7 +441,7 @@
 
 	if (inc_opt) {
 		if (dev->addr_len)
-			len += NDISC_OPT_SPACE(dev->addr_len);
+			len += ndisc_opt_lladdr_space(dev);
 		else
 			inc_opt = 0;
 	}
@@ -528,7 +533,7 @@
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
 	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
 	if (send_llinfo)
-		len += NDISC_OPT_SPACE(dev->addr_len);
+		len += ndisc_opt_lladdr_space(dev);
 
 	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
@@ -603,7 +608,7 @@
 
 	len = sizeof(struct icmp6hdr);
 	if (dev->addr_len)
-		len += NDISC_OPT_SPACE(dev->addr_len);
+		len += ndisc_opt_lladdr_space(dev);
 
         skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
@@ -1333,7 +1338,7 @@
 
 	if (dev->addr_len) {
 		if (neigh->nud_state&NUD_VALID) {
-			len  += NDISC_OPT_SPACE(dev->addr_len);
+			len  += ndisc_opt_lladdr_space(dev);
 		} else {
 			/* If nexthop is not valid, do not redirect!
 			   We will make it later, when will be sure,

ChangeSet@1.2349, 2005-01-21 01:32:39+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: prepend correct padding to IPoIB link-layer address option.
 
 Based on patch from Roland Dreier <roland@topspin.com>.
 
 Signed-off-by: Roland Dreier <roland@topspin.com>
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-21 01:46:11 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-21 01:46:11 +09:00
@@ -178,14 +178,17 @@
 	return ((u8 *)(opt + 1));
 }
 
-static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
+static u8 *ndisc_fill_option(u8 *opt, int type, int prepad,
+			     void *data, int data_len)
 {
-	int space = NDISC_OPT_SPACE(data_len);
+	int space = NDISC_OPT_SPACE(prepad + data_len);
 
 	opt[0] = type;
 	opt[1] = space>>3;
-	memcpy(opt+2, data, data_len);
-	data_len += 2;
+	if (prepad)
+		memset(opt + 2, 0, prepad);
+	memcpy(opt + prepad + 2, data, data_len);
+	data_len += prepad + 2;
 	opt += data_len;
 	if ((space -= data_len) > 0)
 		memset(opt, 0, space);
@@ -255,18 +258,45 @@
 	return ndopts;
 }
 
+/*
+ * Return the padding between the option length and the start of the
+ * link addr.  Currently only IP-over-InfiniBand needs this, although
+ * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
+ * also need a pad of 2.
+ */
+static inline int ndisc_opt_lladdr_prepad(unsigned short type)
+{
+	switch (type) {
+#ifdef CONFIG_INFINIBAND_IPOIB
+	case ARPHRD_INFINIBAND:
+		return 2;
+#endif
+	default:
+		return 0;
+	}
+}
+
 static inline int ndisc_opt_lladdr_space(struct net_device *dev)
 {
-	return NDISC_OPT_SPACE(dev->addr_len);
+	return NDISC_OPT_SPACE(dev->addr_len + ndisc_opt_lladdr_prepad(dev->type));
 }
 
 static inline u8 *ndisc_opt_lladdr_data(struct nd_opt_hdr *p, struct net_device *dev)
 {
 	u8 *lladdr = ndisc_opt_data(p);
 	int lladdrlen = ndisc_opt_len(p);
-	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len))
+	int prepad = ndisc_opt_lladdr_prepad(dev->type);
+	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
 		return NULL;
-	return lladdr;
+	return (lladdr + prepad);
+}
+
+static inline u8 *ndisc_fill_lladdr_option(u8 *opt, int type, u8 *data,
+					   struct net_device *dev)
+{
+	return ndisc_fill_option(opt, type,
+				 ndisc_opt_lladdr_prepad(dev->type),
+				 data, dev->addr_len);
 }
 
 int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
@@ -476,7 +506,7 @@
 	ipv6_addr_copy(&msg->target, solicited_addr);
 
 	if (inc_opt)
-		ndisc_fill_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_lladdr_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr, dev);
 
 	/* checksum */
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(src_addr, daddr, len, 
@@ -559,7 +589,7 @@
 	ipv6_addr_copy(&msg->target, solicit);
 
 	if (send_llinfo)
-		ndisc_fill_option(msg->opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_lladdr_option(msg->opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev);
 
 	/* checksum */
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&skb->nh.ipv6h->saddr,
@@ -633,7 +663,7 @@
 	opt = (u8*) (hdr + 1);
 
 	if (dev->addr_len)
-		ndisc_fill_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev->addr_len);
+		ndisc_fill_lladdr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr, dev);
 
 	/* checksum */
 	hdr->icmp6_cksum = csum_ipv6_magic(&skb->nh.ipv6h->saddr, daddr, len,
@@ -1392,7 +1422,7 @@
 	 */
 
 	if (dev->addr_len)
-		opt = ndisc_fill_option(opt, ND_OPT_TARGET_LL_ADDR, neigh->ha, dev->addr_len);
+		opt = ndisc_fill_lladdr_option(opt, ND_OPT_TARGET_LL_ADDR, neigh->ha, dev);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
