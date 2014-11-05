From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs
Date: Wed,  5 Nov 2014 01:58:33 +0100
Message-ID: <1415149113-32668-1-git-send-email-dborkman@redhat.com>
Cc: lw1a2.jing@gmail.com, fw@strlen.de, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256AbaKEA6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 19:58:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has been reported that generating an MLD listener report on
devices with large MTUs (e.g. 9000) and a high number of IPv6
addresses can trigger a skb_over_panic():

skbuff: skb_over_panic: text:ffffffff80612a5d len:3776 put:20
head:ffff88046d751000 data:ffff88046d751010 tail:0xed0 end:0xec0
dev:port1
 ------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:100!
invalid opcode: 0000 [#1] SMP
Modules linked in: ixgbe(O)
CPU: 3 PID: 0 Comm: swapper/3 Tainted: G O 3.14.23+ #4
[...]
Call Trace:
 <IRQ>
 [<ffffffff80578226>] ? skb_put+0x3a/0x3b
 [<ffffffff80612a5d>] ? add_grhead+0x45/0x8e
 [<ffffffff80612e3a>] ? add_grec+0x394/0x3d4
 [<ffffffff80613222>] ? mld_ifc_timer_expire+0x195/0x20d
 [<ffffffff8061308d>] ? mld_dad_timer_expire+0x45/0x45
 [<ffffffff80255b5d>] ? call_timer_fn.isra.29+0x12/0x68
 [<ffffffff80255d16>] ? run_timer_softirq+0x163/0x182
 [<ffffffff80250e6f>] ? __do_softirq+0xe0/0x21d
 [<ffffffff8025112b>] ? irq_exit+0x4e/0xd3
 [<ffffffff802214bb>] ? smp_apic_timer_interrupt+0x3b/0x46
 [<ffffffff8063f10a>] ? apic_timer_interrupt+0x6a/0x70

mld_newpack() skb allocations are usually requested with dev->mtu
in size, since commit 72e09ad107e7 ("ipv6: avoid high order allocations")
we have changed the limit in order to be less unreliable to fail.

However, in MLD/IGMP code, we have some rather ugly AVAILABLE(skb)
macros, which determine if we may end up doing an skb_put() for
adding another record. To avoid possible fragmentation, we check
the skb's tailroom as skb->dev->mtu - skb->len, which is a wrong
assumption as the actual max allocation size will be much smaller.

The IGMP case doesn't have this issue as commit 57e1ab6eaddc
("igmp: refine skb allocations") stores the allocation size in the
cb[], but therefore takes the MTU check not into account anymore.
Add and use skb_nofrag_tailroom() for both cases.

Reported-by: lw1a2.jing@gmail.com
Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David L Stevens <david.stevens@oracle.com>
---
 In skb_nofrag_tailroom(), we could actually omit the !skb->dev check,
 but I leave that rather as a possible cleanup item for net-next.

 include/linux/netdevice.h | 15 +++++++++++++++
 net/ipv4/igmp.c           |  6 +-----
 net/ipv6/mcast.c          |  3 +--
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74fd5d3..e4f4cfa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2262,6 +2262,21 @@ do {									\
 					   compute_pseudo(skb, proto));	\
 } while (0)
 
+/**
+ *	skb_nofrag_tailroom - bytes at buffer end still fitting into MTU
+ *	@skb: buffer to check
+ *
+ *	Return the number of bytes of free space at the tail of an sk_buff
+ *	that still fit into the device MTU.
+ */
+static inline int skb_nofrag_tailroom(const struct sk_buff *skb)
+{
+	if (!skb->dev)
+		return skb_tailroom(skb);
+
+	return clamp_t(int, skb->dev->mtu - skb->len, 0, skb_tailroom(skb));
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index fb70e3e..a750dfb 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -318,8 +318,6 @@ igmp_scount(struct ip_mc_list *pmc, int type, int gdeleted, int sdeleted)
 	return scount;
 }
 
-#define igmp_skb_size(skb) (*(unsigned int *)((skb)->cb))
-
 static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 {
 	struct sk_buff *skb;
@@ -341,7 +339,6 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 			return NULL;
 	}
 	skb->priority = TC_PRIO_CONTROL;
-	igmp_skb_size(skb) = size;
 
 	rt = ip_route_output_ports(net, &fl4, NULL, IGMPV3_ALL_MCR, 0,
 				   0, 0,
@@ -423,8 +420,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ip_mc_list *pmc,
 	return skb;
 }
 
-#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? igmp_skb_size(skb) - (skb)->len : \
-	skb_tailroom(skb)) : 0)
+#define AVAILABLE(skb)	((skb) ? skb_nofrag_tailroom(skb) : 0)
 
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 	int type, int gdeleted, int sdeleted)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 9648de2..1bc18f9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1690,8 +1690,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	return skb;
 }
 
-#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? (skb)->dev->mtu - (skb)->len : \
-	skb_tailroom(skb)) : 0)
+#define AVAILABLE(skb)	((skb) ? skb_nofrag_tailroom(skb) : 0)
 
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	int type, int gdeleted, int sdeleted, int crsend)
-- 
1.9.3
