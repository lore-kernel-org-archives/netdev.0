From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] [RFC PATCH] IPoIB: improve IPv4/IPv6 to IB mcast
	mapping functions
Date: Fri, 04 Jan 2008 14:05:29 -0800
Message-ID: <adair29mel2.fsf_-_@cisco.com>
References: <20071210203544.GI30090@obsidianresearch.com>
	<20071210203841.GJ30090@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071210203841.GJ30090@obsidianresearch.com> (Rolf
	Manderscheid's message of "Mon, 10 Dec 2007 13:38:41 -0700")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Any objection to merging the following for 2.6.25?

[Rolf -- I think it makes more sense to delete the overwriting of the
P_Key in ipoib_multicast.c in this patch rather than later in the
series; do you agree?]

Thanks,
  Roland


From: Rolf Manderscheid <rvm@obsidianresearch.com>

An IPoIB subnet on an IB fabric that spans multiple IB subnets can't
use link-local scope in multicast GIDs.  The existing routines that
map IP/IPv6 multicast addresses into IB link-level addresses hard-code
the scope to link-local, and they also leave the partition key field
uninitialised.  This patch adds a parameter (the link-level broadcast
address) to the mapping routines, allowing them to initialise both the
scope and the P_Key appropriately, and fixes up the call sites.

The next step will be to add a way to configure the scope for an IPoIB
interface.

Signed-off-by: Rolf Manderscheid <rvm@obsidianresearch.com>
Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/infiniband/core/cma.c                  |    4 +---
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    4 ----
 include/net/if_inet6.h                         |   11 +++++++----
 include/net/ip.h                               |   10 ++++++----
 net/ipv4/arp.c                                 |    2 +-
 net/ipv6/ndisc.c                               |    2 +-
 6 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 312ec74..982836e 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2610,11 +2610,9 @@ static void cma_set_mgid(struct rdma_id_private *id_priv,
 		/* IPv6 address is an SA assigned MGID. */
 		memcpy(mgid, &sin6->sin6_addr, sizeof *mgid);
 	} else {
-		ip_ib_mc_map(sin->sin_addr.s_addr, mc_map);
+		ip_ib_mc_map(sin->sin_addr.s_addr, dev_addr->broadcast, mc_map);
 		if (id_priv->id.ps == RDMA_PS_UDP)
 			mc_map[7] = 0x01;	/* Use RDMA CM signature */
-		mc_map[8] = ib_addr_get_pkey(dev_addr) >> 8;
-		mc_map[9] = (unsigned char) ib_addr_get_pkey(dev_addr);
 		*mgid = *(union ib_gid *) (mc_map + 4);
 	}
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 858ada1..2628339 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -788,10 +788,6 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 
 		memcpy(mgid.raw, mclist->dmi_addr + 4, sizeof mgid);
 
-		/* Add in the P_Key */
-		mgid.raw[4] = (priv->pkey >> 8) & 0xff;
-		mgid.raw[5] = priv->pkey & 0xff;
-
 		mcast = __ipoib_mcast_find(dev, &mgid);
 		if (!mcast || test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
 			struct ipoib_mcast *nmcast;
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 448eccb..b24508a 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -269,18 +269,21 @@ static inline void ipv6_arcnet_mc_map(const struct in6_addr *addr, char *buf)
 	buf[0] = 0x00;
 }
 
-static inline void ipv6_ib_mc_map(struct in6_addr *addr, char *buf)
+static inline void ipv6_ib_mc_map(const struct in6_addr *addr,
+				  const unsigned char *broadcast, char *buf)
 {
+	unsigned char scope = broadcast[5] & 0xF;
+
 	buf[0]  = 0;		/* Reserved */
 	buf[1]  = 0xff;		/* Multicast QPN */
 	buf[2]  = 0xff;
 	buf[3]  = 0xff;
 	buf[4]  = 0xff;
-	buf[5]  = 0x12;		/* link local scope */
+	buf[5]  = 0x10 | scope;	/* scope from broadcast address */
 	buf[6]  = 0x60;		/* IPv6 signature */
 	buf[7]  = 0x1b;
-	buf[8]  = 0;		/* P_Key */
-	buf[9]  = 0;
+	buf[8]  = broadcast[8];	/* P_Key */
+	buf[9]  = broadcast[9];
 	memcpy(buf + 10, addr->s6_addr + 6, 10);
 }
 #endif
diff --git a/include/net/ip.h b/include/net/ip.h
index 840dd91..50c8889 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -266,20 +266,22 @@ static inline void ip_eth_mc_map(__be32 naddr, char *buf)
  *	Leave P_Key as 0 to be filled in by driver.
  */
 
-static inline void ip_ib_mc_map(__be32 naddr, char *buf)
+static inline void ip_ib_mc_map(__be32 naddr, const unsigned char *broadcast, char *buf)
 {
 	__u32 addr;
+	unsigned char scope = broadcast[5] & 0xF;
+
 	buf[0]  = 0;		/* Reserved */
 	buf[1]  = 0xff;		/* Multicast QPN */
 	buf[2]  = 0xff;
 	buf[3]  = 0xff;
 	addr    = ntohl(naddr);
 	buf[4]  = 0xff;
-	buf[5]  = 0x12;		/* link local scope */
+	buf[5]  = 0x10 | scope;	/* scope from broadcast address */
 	buf[6]  = 0x40;		/* IPv4 signature */
 	buf[7]  = 0x1b;
-	buf[8]  = 0;		/* P_Key */
-	buf[9]  = 0;
+	buf[8]  = broadcast[8];		/* P_Key */
+	buf[9]  = broadcast[9];
 	buf[10] = 0;
 	buf[11] = 0;
 	buf[12] = 0;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 08174a2..54a76b8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -211,7 +211,7 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
 		ip_tr_mc_map(addr, haddr);
 		return 0;
 	case ARPHRD_INFINIBAND:
-		ip_ib_mc_map(addr, haddr);
+		ip_ib_mc_map(addr, dev->broadcast, haddr);
 		return 0;
 	default:
 		if (dir) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 777ed73..85947ea 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -337,7 +337,7 @@ int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int d
 		ipv6_arcnet_mc_map(addr, buf);
 		return 0;
 	case ARPHRD_INFINIBAND:
-		ipv6_ib_mc_map(addr, buf);
+		ipv6_ib_mc_map(addr, dev->broadcast, buf);
 		return 0;
 	default:
 		if (dir) {
-- 
1.5.4.rc2
