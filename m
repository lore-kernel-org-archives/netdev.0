From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Tue, 19 Sep 2006 00:08:00 +0900 (JST)
Message-ID: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44818 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965278AbWIRPFv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 11:05:51 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changesets available at:
	git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060918-net/

HEADLINES
---------

    [XFRM]: Do not add a state whose SPI is zero to the SPI hash.
    [NET]: Move netlink interface bits to linux/if_link.h.
    [NET]: Include linux/if_link.h directly from the source file.
    [NET]: Include new rtnetlink headers for userspace backward compatibility.
    [NET]: Put {IFLA,IFA,NDA,NDTA}_{RTA,PAYLOAD}() macro back.
    [NET] KBUILD: Add missing entries for new net headers.

DIFFSTAT
--------

 include/linux/Kbuild      |   10 ++-
 include/linux/if.h        |  130 ------------------------------------------
 include/linux/if_addr.h   |    3 +
 include/linux/if_link.h   |  139 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/neighbour.h |    7 ++
 include/linux/rtnetlink.h |    7 ++
 net/bridge/br_netlink.c   |    1 
 net/core/rtnetlink.c      |    1 
 net/core/wireless.c       |    1 
 net/ipv6/addrconf.c       |    1 
 net/xfrm/xfrm_state.c     |   11 ++--
 11 files changed, 172 insertions(+), 139 deletions(-)

CHANGESETS
----------

commit 04b3eac83cccb7da663bd11a2b569f197bb3170e
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 17 13:54:53 2006 +0900

    [XFRM]: Do not add a state whose SPI is zero to the SPI hash.
    
    SPI=0 is used for acquired IPsec SA and MIPv6 RO state.
    Such state should not be added to the SPI hash
    because we do not care about it on deleting path.
    
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9f63edd..5f4a50e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -96,9 +96,12 @@ static void xfrm_hash_transfer(struct hl
 				    nhashmask);
 		hlist_add_head(&x->bysrc, nsrctable+h);
 
-		h = __xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
-				    x->props.family, nhashmask);
-		hlist_add_head(&x->byspi, nspitable+h);
+		if (x->id.spi) {
+			h = __xfrm_spi_hash(&x->id.daddr, x->id.spi,
+					    x->id.proto, x->props.family,
+					    nhashmask);
+			hlist_add_head(&x->byspi, nspitable+h);
+		}
 	}
 }
 
@@ -622,7 +625,7 @@ static void __xfrm_state_insert(struct x
 	h = xfrm_src_hash(&x->props.saddr, x->props.family);
 	hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
 
-	if (xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY)) {
+	if (x->id.spi) {
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
 				  x->props.family);
 

---
commit 44ad787528719604896754d1d05895d2dcfff88b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:54:55 2006 +0900

    [NET]: Move netlink interface bits to linux/if_link.h.
    
    Moving netlink interface bits to linux/if.h is rather troublesome for
    applications including both linux/if.h (which was changed to be included
    from linux/rtnetlink.h automatically) and net/if.h.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if.h b/include/linux/if.h
index cd080d7..ab85ed0 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -212,134 +212,4 @@ struct ifconf 
 #define	ifc_buf	ifc_ifcu.ifcu_buf		/* buffer address	*/
 #define	ifc_req	ifc_ifcu.ifcu_req		/* array of structures	*/
 
-/* The struct should be in sync with struct net_device_stats */
-struct rtnl_link_stats
-{
-	__u32	rx_packets;		/* total packets received	*/
-	__u32	tx_packets;		/* total packets transmitted	*/
-	__u32	rx_bytes;		/* total bytes received 	*/
-	__u32	tx_bytes;		/* total bytes transmitted	*/
-	__u32	rx_errors;		/* bad packets received		*/
-	__u32	tx_errors;		/* packet transmit problems	*/
-	__u32	rx_dropped;		/* no space in linux buffers	*/
-	__u32	tx_dropped;		/* no space available in linux	*/
-	__u32	multicast;		/* multicast packets received	*/
-	__u32	collisions;
-
-	/* detailed rx_errors: */
-	__u32	rx_length_errors;
-	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
-	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
-	__u32	rx_frame_errors;	/* recv'd frame alignment error */
-	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
-	__u32	rx_missed_errors;	/* receiver missed packet	*/
-
-	/* detailed tx_errors */
-	__u32	tx_aborted_errors;
-	__u32	tx_carrier_errors;
-	__u32	tx_fifo_errors;
-	__u32	tx_heartbeat_errors;
-	__u32	tx_window_errors;
-
-	/* for cslip etc */
-	__u32	rx_compressed;
-	__u32	tx_compressed;
-};
-
-/* The struct should be in sync with struct ifmap */
-struct rtnl_link_ifmap
-{
-	__u64	mem_start;
-	__u64	mem_end;
-	__u64	base_addr;
-	__u16	irq;
-	__u8	dma;
-	__u8	port;
-};
-
-enum
-{
-	IFLA_UNSPEC,
-	IFLA_ADDRESS,
-	IFLA_BROADCAST,
-	IFLA_IFNAME,
-	IFLA_MTU,
-	IFLA_LINK,
-	IFLA_QDISC,
-	IFLA_STATS,
-	IFLA_COST,
-#define IFLA_COST IFLA_COST
-	IFLA_PRIORITY,
-#define IFLA_PRIORITY IFLA_PRIORITY
-	IFLA_MASTER,
-#define IFLA_MASTER IFLA_MASTER
-	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
-#define IFLA_WIRELESS IFLA_WIRELESS
-	IFLA_PROTINFO,		/* Protocol specific information for a link */
-#define IFLA_PROTINFO IFLA_PROTINFO
-	IFLA_TXQLEN,
-#define IFLA_TXQLEN IFLA_TXQLEN
-	IFLA_MAP,
-#define IFLA_MAP IFLA_MAP
-	IFLA_WEIGHT,
-#define IFLA_WEIGHT IFLA_WEIGHT
-	IFLA_OPERSTATE,
-	IFLA_LINKMODE,
-	__IFLA_MAX
-};
-
-
-#define IFLA_MAX (__IFLA_MAX - 1)
-
-/* ifi_flags.
-
-   IFF_* flags.
-
-   The only change is:
-   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
-   more not changeable by user. They describe link media
-   characteristics and set by device driver.
-
-   Comments:
-   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
-   - If neither of these three flags are set;
-     the interface is NBMA.
-
-   - IFF_MULTICAST does not mean anything special:
-   multicasts can be used on all not-NBMA links.
-   IFF_MULTICAST means that this media uses special encapsulation
-   for multicast frames. Apparently, all IFF_POINTOPOINT and
-   IFF_BROADCAST devices are able to use multicasts too.
- */
-
-/* IFLA_LINK.
-   For usual devices it is equal ifi_index.
-   If it is a "virtual interface" (f.e. tunnel), ifi_link
-   can point to real physical interface (f.e. for bandwidth calculations),
-   or maybe 0, what means, that real media is unknown (usual
-   for IPIP tunnels, when route to endpoint is allowed to change)
- */
-
-/* Subtype attributes for IFLA_PROTINFO */
-enum
-{
-	IFLA_INET6_UNSPEC,
-	IFLA_INET6_FLAGS,	/* link flags			*/
-	IFLA_INET6_CONF,	/* sysctl parameters		*/
-	IFLA_INET6_STATS,	/* statistics			*/
-	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
-	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
-	__IFLA_INET6_MAX
-};
-
-#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
-
-struct ifla_cacheinfo
-{
-	__u32	max_reasm_len;
-	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
-	__u32	reachable_time;
-	__u32	retrans_time;
-};
-
 #endif /* _LINUX_IF_H */
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
new file mode 100644
index 0000000..e963a07
--- /dev/null
+++ b/include/linux/if_link.h
@@ -0,0 +1,136 @@
+#ifndef _LINUX_IF_LINK_H
+#define _LINUX_IF_LINK_H
+
+#include <linux/netlink.h>
+
+/* The struct should be in sync with struct net_device_stats */
+struct rtnl_link_stats
+{
+	__u32	rx_packets;		/* total packets received	*/
+	__u32	tx_packets;		/* total packets transmitted	*/
+	__u32	rx_bytes;		/* total bytes received 	*/
+	__u32	tx_bytes;		/* total bytes transmitted	*/
+	__u32	rx_errors;		/* bad packets received		*/
+	__u32	tx_errors;		/* packet transmit problems	*/
+	__u32	rx_dropped;		/* no space in linux buffers	*/
+	__u32	tx_dropped;		/* no space available in linux	*/
+	__u32	multicast;		/* multicast packets received	*/
+	__u32	collisions;
+
+	/* detailed rx_errors: */
+	__u32	rx_length_errors;
+	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
+	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
+	__u32	rx_frame_errors;	/* recv'd frame alignment error */
+	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
+	__u32	rx_missed_errors;	/* receiver missed packet	*/
+
+	/* detailed tx_errors */
+	__u32	tx_aborted_errors;
+	__u32	tx_carrier_errors;
+	__u32	tx_fifo_errors;
+	__u32	tx_heartbeat_errors;
+	__u32	tx_window_errors;
+
+	/* for cslip etc */
+	__u32	rx_compressed;
+	__u32	tx_compressed;
+};
+
+/* The struct should be in sync with struct ifmap */
+struct rtnl_link_ifmap
+{
+	__u64	mem_start;
+	__u64	mem_end;
+	__u64	base_addr;
+	__u16	irq;
+	__u8	dma;
+	__u8	port;
+};
+
+enum
+{
+	IFLA_UNSPEC,
+	IFLA_ADDRESS,
+	IFLA_BROADCAST,
+	IFLA_IFNAME,
+	IFLA_MTU,
+	IFLA_LINK,
+	IFLA_QDISC,
+	IFLA_STATS,
+	IFLA_COST,
+#define IFLA_COST IFLA_COST
+	IFLA_PRIORITY,
+#define IFLA_PRIORITY IFLA_PRIORITY
+	IFLA_MASTER,
+#define IFLA_MASTER IFLA_MASTER
+	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
+#define IFLA_WIRELESS IFLA_WIRELESS
+	IFLA_PROTINFO,		/* Protocol specific information for a link */
+#define IFLA_PROTINFO IFLA_PROTINFO
+	IFLA_TXQLEN,
+#define IFLA_TXQLEN IFLA_TXQLEN
+	IFLA_MAP,
+#define IFLA_MAP IFLA_MAP
+	IFLA_WEIGHT,
+#define IFLA_WEIGHT IFLA_WEIGHT
+	IFLA_OPERSTATE,
+	IFLA_LINKMODE,
+	__IFLA_MAX
+};
+
+
+#define IFLA_MAX (__IFLA_MAX - 1)
+
+/* ifi_flags.
+
+   IFF_* flags.
+
+   The only change is:
+   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
+   more not changeable by user. They describe link media
+   characteristics and set by device driver.
+
+   Comments:
+   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
+   - If neither of these three flags are set;
+     the interface is NBMA.
+
+   - IFF_MULTICAST does not mean anything special:
+   multicasts can be used on all not-NBMA links.
+   IFF_MULTICAST means that this media uses special encapsulation
+   for multicast frames. Apparently, all IFF_POINTOPOINT and
+   IFF_BROADCAST devices are able to use multicasts too.
+ */
+
+/* IFLA_LINK.
+   For usual devices it is equal ifi_index.
+   If it is a "virtual interface" (f.e. tunnel), ifi_link
+   can point to real physical interface (f.e. for bandwidth calculations),
+   or maybe 0, what means, that real media is unknown (usual
+   for IPIP tunnels, when route to endpoint is allowed to change)
+ */
+
+/* Subtype attributes for IFLA_PROTINFO */
+enum
+{
+	IFLA_INET6_UNSPEC,
+	IFLA_INET6_FLAGS,	/* link flags			*/
+	IFLA_INET6_CONF,	/* sysctl parameters		*/
+	IFLA_INET6_STATS,	/* statistics			*/
+	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
+	__IFLA_INET6_MAX
+};
+
+#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
+
+struct ifla_cacheinfo
+{
+	__u32	max_reasm_len;
+	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
+	__u32	reachable_time;
+	__u32	retrans_time;
+};
+
+#endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 9c92dc8..3a18add 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -2,7 +2,7 @@ #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
 
 #include <linux/netlink.h>
-#include <linux/if.h>
+#include <linux/if_link.h>
 
 /****
  *		Routing/neighbour discovery messages.

---
commit 41515f19f24841876c5e82eef940cf18f3c82455
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:54:58 2006 +0900

    [NET]: Include linux/if_link.h directly from the source file.
    
    For consistent use of other netlink bits, include new
    linux/if_link.h directly from the source file, not through
    linux/rtnetlink.h.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8f66119..f55c8d3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -12,6 +12,7 @@
 
 #include <linux/kernel.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_link.h>
 #include <net/netlink.h>
 #include "br_private.h"
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8e25e0..9969cfd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -35,6 +35,7 @@ #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/security.h>
 #include <linux/mutex.h>
+#include <linux/if_link.h>
 #include <linux/if_addr.h>
 
 #include <asm/uaccess.h>
diff --git a/net/core/wireless.c b/net/core/wireless.c
index 3168fca..3be6457 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -79,6 +79,7 @@ #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>		/* rtnetlink stuff */
 #include <linux/seq_file.h>
 #include <linux/init.h>			/* for __init */
+#include <linux/if_link.h>		/* IFLA_WIRELESS */
 #include <linux/if_arp.h>		/* ARPHRD_ETHER */
 #include <linux/etherdevice.h>		/* compare_ether_addr */
 #include <linux/interrupt.h>
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fc9cff3..5cf5253 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -48,6 +48,7 @@ #include <linux/sched.h>
 #include <linux/net.h>
 #include <linux/in6.h>
 #include <linux/netdevice.h>
+#include <linux/if_link.h>
 #include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/if_arcnet.h>

---
commit c9b734ff1d4ec9f264d7157d343a90240a188aae
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:55:00 2006 +0900

    [NET]: Include new rtnetlink headers for userspace backward compatibility.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3a18add..8ec375c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -2,7 +2,12 @@ #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
 
 #include <linux/netlink.h>
+#ifndef __KERNEL__
+/* Backward compatibility */
 #include <linux/if_link.h>
+#include <linux/if_addr.h>
+#include <linux/neighbour.h>
+#endif
 
 /****
  *		Routing/neighbour discovery messages.

---
commit 55a08a9078b243a06223222735580df9e11a5fa6
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:55:02 2006 +0900

    [NET]: Put {IFLA,IFA,NDA,NDTA}_{RTA,PAYLOAD}() macro back.
    
    These macros are still used by userspace applications.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index e159045..a51b2d3 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -50,4 +50,7 @@ struct ifa_cacheinfo
 	__u32	tstamp; /* updated timestamp, hundredths of seconds */
 };
 
+#define IFA_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#define IFA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+
 #endif
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e963a07..bce8b98 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -133,4 +133,7 @@ struct ifla_cacheinfo
 	__u32	retrans_time;
 };
 
+#define IFLA_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#define IFLA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index bd3bbf6..7476739 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -26,6 +26,9 @@ enum
 
 #define NDA_MAX (__NDA_MAX - 1)
 
+#define NDA_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
+#define NDA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
+
 /*
  *	Neighbor Cache Entry Flags
  */
@@ -156,4 +159,8 @@ enum {
 };
 #define NDTA_MAX (__NDTA_MAX - 1)
 
+#define NDTA_RTA(r) ((struct rtattr*)(((char*)(r)) + \
+		     NLMSG_ALIGN(sizeof(struct ndtmsg))))
+#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
+
 #endif

---
commit 1afcf9543d447ab3622ff4ecaacfa6baf83870b8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:55:04 2006 +0900

    [NET] KBUILD: Add missing entries for new net headers.
    
    Add the following for userspace export by the 'headers_include'
    make target: linux/fib_rules.h, linux/if_addr.h, linux/if_link.h,
    linux/neighbour.h.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 2b8a7d6..83375cd 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -10,16 +10,18 @@ header-y += affs_fs.h affs_hardblocks.h 
 	bpqether.h cdk.h chio.h coda_psdev.h coff.h comstats.h		\
 	consolemap.h cycx_cfm.h dm-ioctl.h dn.h dqblk_v1.h		\
 	dqblk_v2.h dqblk_xfs.h efs_fs_sb.h elf-fdpic.h elf.h elf-em.h	\
-	fadvise.h fd.h fdreg.h ftape-header-segment.h ftape-vendors.h	\
+	fadvise.h fd.h fdreg.h fib_rules.h 				\
+	ftape-header-segment.h ftape-vendors.h				\
 	fuse.h futex.h genetlink.h gen_stats.h gigaset_dev.h hdsmart.h	\
-	hpfs_fs.h hysdn_if.h i2c-dev.h i8k.h icmp.h			\
+	hpfs_fs.h hysdn_if.h i2c-dev.h i8k.h icmp.h if_addr.h		\
 	if_arcnet.h if_arp.h if_bonding.h if_cablemodem.h if_fc.h	\
-	if_fddi.h if.h if_hippi.h if_infiniband.h if_packet.h		\
+	if_fddi.h if.h if_hippi.h if_infiniband.h if_link.h if_packet.h	\
 	if_plip.h if_ppp.h if_slip.h if_strip.h if_tunnel.h in6.h	\
 	in_route.h ioctl.h ip.h ipmi_msgdefs.h ip_mp_alg.h ipsec.h	\
 	ipx.h irda.h isdn_divertif.h iso_fs.h ite_gpio.h ixjuser.h	\
 	jffs2.h keyctl.h limits.h major.h matroxfb.h meye.h minix_fs.h	\
-	mmtimer.h mqueue.h mtio.h ncp_no.h netfilter_arp.h netrom.h	\
+	mmtimer.h mqueue.h mtio.h ncp_no.h neighbour.h			\
+	netfilter_arp.h netrom.h					\
 	nfs2.h nfs4_mount.h nfs_mount.h openprom_fs.h param.h		\
 	pci_ids.h pci_regs.h personality.h pfkeyv2.h pg.h pkt_cls.h	\
 	pkt_sched.h posix_types.h ppdev.h prctl.h ps2esdi.h qic117.h	\

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
