From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH]  introduce eth_hdr(skb)
Date: Sat, 02 Oct 2004 13:53:32 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415EDD0C.9080507@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050506010401080500020506"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050506010401080500020506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	I'm chunking that sk_buff cleaning up big patch into very
easily reviewable changesets, starting with the areas that are more
quiet these days, please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there is just this outstanding changeset there, next ones
will deal with skb->mac.raw.

	This is a freshly cloned tree from Linus, that I checked to be
in sync with bk://kernel.bkbits.net/davem/net-2.6

Best Regards,

- Arnaldo

--------------050506010401080500020506
Content-Type: text/plain;
 name="eth_hdr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eth_hdr.patch"

===================================================================


ChangeSet@1.2030, 2004-10-02 13:42:59-03:00, acme@conectiva.com.br
  [SKBUFF] introduce eth_hdr(skb)
  
  This is the start of a series of patches to remove protocol
  specific stuff out of include/linux/skbuff.h and to make the
  struct sk_buff header pointers private, i.e. they will only
  be accessible thru foo_hdr(skb) and some other accessor
  functions.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/isdn/i4l/isdn_net.c                |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c       |    2 +-
 drivers/net/bonding/bond_alb.c             |    2 +-
 drivers/net/ioc3-eth.c                     |    4 ++--
 drivers/net/myri_sbus.c                    |    2 +-
 drivers/net/plip.c                         |    2 +-
 drivers/net/pppoe.c                        |    4 ++--
 drivers/s390/net/qeth_main.c               |    2 +-
 include/linux/if_ether.h                   |   12 ++++++++++--
 include/linux/if_vlan.h                    |   10 ++++++++--
 include/linux/netfilter_bridge/ebt_802_3.h |    9 +++++++++
 include/linux/skbuff.h                     |    1 -
 net/8021q/vlan_dev.c                       |    2 +-
 net/atm/br2684.c                           |    2 +-
 net/bridge/br_input.c                      |   10 +++++-----
 net/bridge/br_netfilter.c                  |   18 ++++++++----------
 net/bridge/netfilter/ebt_802_3.c           |    2 +-
 net/bridge/netfilter/ebt_among.c           |   12 ++++++------
 net/bridge/netfilter/ebt_dnat.c            |    3 +--
 net/bridge/netfilter/ebt_log.c             |   12 ++++++------
 net/bridge/netfilter/ebt_redirect.c        |    7 +++----
 net/bridge/netfilter/ebt_snat.c            |    3 +--
 net/bridge/netfilter/ebtables.c            |    2 +-
 net/core/dv.c                              |    4 ++--
 net/core/netpoll.c                         |    2 +-
 net/decnet/dn_neigh.c                      |    4 ++--
 net/ethernet/eth.c                         |    4 ++--
 net/ipv4/netfilter/ipt_mac.c               |    2 +-
 net/ipv6/netfilter/ip6t_eui64.c            |    6 +++---
 net/ipv6/netfilter/ip6t_mac.c              |    2 +-
 30 files changed, 83 insertions(+), 66 deletions(-)


diff -Nru a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
--- a/drivers/isdn/i4l/isdn_net.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/isdn/i4l/isdn_net.c	2004-10-02 13:44:26 -03:00
@@ -1369,7 +1369,7 @@
 
 	skb->mac.raw = skb->data;
 	skb_pull(skb, ETH_HLEN);
-	eth = skb->mac.ethernet;
+	eth = eth_hdr(skb);
 
 	if (*eth->h_dest & 1) {
 		if (memcmp(eth->h_dest, dev->broadcast, ETH_ALEN) == 0)
diff -Nru a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
--- a/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-02 13:44:26 -03:00
@@ -142,7 +142,7 @@
 	
 	skb->mac.raw=skb->data;
 	skb_pull(skb,dev->hard_header_len);
-	eth= skb->mac.ethernet;
+	eth = eth_hdr(skb);
 	
 	if (*eth->h_dest & 1) {
 		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
diff -Nru a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/net/bonding/bond_alb.c	2004-10-02 13:44:26 -03:00
@@ -1285,7 +1285,7 @@
 	int res = 1;
 
 	skb->mac.raw = (unsigned char *)skb->data;
-	eth_data = (struct ethhdr *)skb->data;
+	eth_data = eth_hdr(skb);
 
 	/* make sure that the curr_active_slave and the slaves list do
 	 * not change during tx
diff -Nru a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
--- a/drivers/net/ioc3-eth.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/net/ioc3-eth.c	2004-10-02 13:44:26 -03:00
@@ -506,7 +506,7 @@
 
 static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 {
-	struct ethhdr *eh = skb->mac.ethernet;
+	struct ethhdr *eh = eth_hdr(skb);
 	uint32_t csum, ehsum;
 	unsigned int proto;
 	struct iphdr *ih;
@@ -1333,7 +1333,7 @@
 		uint32_t csum, ehsum;
 		uint16_t *eh;
 
-		/* The MAC header.  skb->mac.ethernet seem the logic approach
+		/* The MAC header.  skb->mac seem the logic approach
 		   to find the MAC header - except it's a NULL pointer ...  */
 		eh = (uint16_t *) skb->data;
 
diff -Nru a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
--- a/drivers/net/myri_sbus.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/net/myri_sbus.c	2004-10-02 13:44:26 -03:00
@@ -376,7 +376,7 @@
 	
 	skb->mac.raw = (((unsigned char *)skb->data) + MYRI_PAD_LEN);
 	skb_pull(skb, dev->hard_header_len);
-	eth = skb->mac.ethernet;
+	eth = eth_hdr(skb);
 	
 #ifdef DEBUG_HEADER
 	DHDR(("myri_type_trans: "));
diff -Nru a/drivers/net/plip.c b/drivers/net/plip.c
--- a/drivers/net/plip.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/net/plip.c	2004-10-02 13:44:26 -03:00
@@ -547,7 +547,7 @@
 	
 	skb->mac.raw=skb->data;
 	skb_pull(skb,dev->hard_header_len);
-	eth= skb->mac.ethernet;
+	eth = eth_hdr(skb);
 	
 	if(*eth->h_dest&1)
 	{
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/net/pppoe.c	2004-10-02 13:44:26 -03:00
@@ -391,7 +391,7 @@
 
 	ph = (struct pppoe_hdr *) skb->nh.raw;
 
-	po = get_item((unsigned long) ph->sid, skb->mac.ethernet->h_source);
+	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
 	if (!po) 
 		goto drop;
 
@@ -440,7 +440,7 @@
 	if (ph->code != PADT_CODE)
 		goto abort;
 
-	po = get_item((unsigned long) ph->sid, skb->mac.ethernet->h_source);
+	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
 	if (po) {
 		struct sock *sk = po->sk;
 
diff -Nru a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
--- a/drivers/s390/net/qeth_main.c	2004-10-02 13:44:26 -03:00
+++ b/drivers/s390/net/qeth_main.c	2004-10-02 13:44:26 -03:00
@@ -2148,7 +2148,7 @@
 
 	skb->mac.raw = skb->data;
 	skb_pull(skb, ETH_ALEN * 2 + sizeof (short));
-	eth = skb->mac.ethernet;
+	eth = eth_hdr(skb);
 
 	if (*eth->h_dest & 1) {
 		if (memcmp(eth->h_dest, dev->broadcast, ETH_ALEN) == 0)
diff -Nru a/include/linux/if_ether.h b/include/linux/if_ether.h
--- a/include/linux/if_ether.h	2004-10-02 13:44:26 -03:00
+++ b/include/linux/if_ether.h	2004-10-02 13:44:26 -03:00
@@ -96,11 +96,19 @@
  *	This is an Ethernet frame header.
  */
  
-struct ethhdr 
-{
+struct ethhdr {
 	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
 	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
 	unsigned short	h_proto;		/* packet type ID field	*/
 } __attribute__((packed));
+
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+
+static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
+{
+	return (struct ethhdr *)skb->mac.raw;
+}
+#endif
 
 #endif	/* _LINUX_IF_ETHER_H */
diff -Nru a/include/linux/if_vlan.h b/include/linux/if_vlan.h
--- a/include/linux/if_vlan.h	2004-10-02 13:44:26 -03:00
+++ b/include/linux/if_vlan.h	2004-10-02 13:44:26 -03:00
@@ -18,7 +18,6 @@
 /* externally defined structs */
 struct vlan_group;
 struct net_device;
-struct sk_buff;
 struct packet_type;
 struct vlan_collection;
 struct vlan_dev_info;
@@ -48,6 +47,13 @@
    unsigned short	h_vlan_encapsulated_proto; /* packet type ID field (or len) */
 };
 
+#include <linux/skbuff.h>
+
+static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
+{
+	return (struct vlan_ethhdr *)skb->mac.raw;
+}
+
 struct vlan_hdr {
    unsigned short       h_vlan_TCI;                /* Encapsulates priority and VLAN ID */
    unsigned short       h_vlan_encapsulated_proto; /* packet type ID field (or len) */
@@ -180,7 +186,7 @@
 		 * This allows the VLAN to have a different MAC than the underlying
 		 * device, and still route correctly.
 		 */
-		if (!memcmp(skb->mac.ethernet->h_dest, skb->dev->dev_addr, ETH_ALEN))
+		if (!memcmp(eth_hdr(skb)->h_dest, skb->dev->dev_addr, ETH_ALEN))
 			skb->pkt_type = PACKET_HOST;
 		break;
 	};
diff -Nru a/include/linux/netfilter_bridge/ebt_802_3.h b/include/linux/netfilter_bridge/ebt_802_3.h
--- a/include/linux/netfilter_bridge/ebt_802_3.h	2004-10-02 13:44:26 -03:00
+++ b/include/linux/netfilter_bridge/ebt_802_3.h	2004-10-02 13:44:26 -03:00
@@ -49,6 +49,15 @@
 	} llc;
 };
 
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+
+static inline struct ebt_802_3_hdr *ebt_802_3_hdr(const struct sk_buff *skb)
+{
+	return (struct ebt_802_3_hdr *)skb->mac.raw;
+}
+#endif
+
 struct ebt_802_3_info 
 {
 	uint8_t  sap;
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-02 13:44:26 -03:00
+++ b/include/linux/skbuff.h	2004-10-02 13:44:26 -03:00
@@ -219,7 +219,6 @@
 	} nh;
 
 	union {
-	  	struct ethhdr	*ethernet;
 	  	unsigned char 	*raw;
 	} mac;
 
diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	2004-10-02 13:44:26 -03:00
+++ b/net/8021q/vlan_dev.c	2004-10-02 13:44:26 -03:00
@@ -211,7 +211,7 @@
 		 * This allows the VLAN to have a different MAC than the underlying
 		 * device, and still route correctly.
 		 */
-		if (memcmp(skb->mac.ethernet->h_dest, skb->dev->dev_addr, ETH_ALEN) == 0) {
+		if (memcmp(eth_hdr(skb)->h_dest, skb->dev->dev_addr, ETH_ALEN) == 0) {
 			/* It is for our (changed) MAC-address! */
 			skb->pkt_type = PACKET_HOST;
 		}
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	2004-10-02 13:44:26 -03:00
+++ b/net/atm/br2684.c	2004-10-02 13:44:26 -03:00
@@ -294,7 +294,7 @@
 {
 	struct ethhdr *eth;
 	unsigned char *rawp;
-	eth = skb->mac.ethernet;
+	eth = eth_hdr(skb);
 
 	if (*eth->h_dest & 1) {
 		if (memcmp(eth->h_dest, dev->broadcast, ETH_ALEN) == 0)
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/br_input.c	2004-10-02 13:44:26 -03:00
@@ -48,7 +48,7 @@
 /* note: already called with rcu_read_lock (preempt_disabled) */
 int br_handle_frame_finish(struct sk_buff *skb)
 {
-	const unsigned char *dest = skb->mac.ethernet->h_dest;
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = skb->dev->br_port;
 	struct net_bridge *br = p->br;
 	struct net_bridge_fdb_entry *dst;
@@ -100,17 +100,17 @@
 int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	const unsigned char *dest = skb->mac.ethernet->h_dest;
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
 
 	if (p->state == BR_STATE_DISABLED)
 		goto err;
 
-	if (skb->mac.ethernet->h_source[0] & 1)
+	if (eth_hdr(skb)->h_source[0] & 1)
 		goto err;
 
 	if (p->state == BR_STATE_LEARNING ||
 	    p->state == BR_STATE_FORWARDING)
-		br_fdb_insert(p->br, p, skb->mac.ethernet->h_source, 0);
+		br_fdb_insert(p->br, p, eth_hdr(skb)->h_source, 0);
 
 	if (p->br->stp_enabled &&
 	    !memcmp(dest, bridge_ula, 5) &&
@@ -127,7 +127,7 @@
 			if (br_should_route_hook(pskb)) 
 				return 0;
 			skb = *pskb;
-			dest = skb->mac.ethernet->h_dest;
+			dest = eth_hdr(skb)->h_dest;
 		}
 
 		if (!memcmp(p->br->dev->dev_addr, dest, ETH_ALEN))
diff -Nru a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/br_netfilter.c	2004-10-02 13:44:26 -03:00
@@ -255,7 +255,7 @@
 					       1);
 				return 0;
 			}
-			memcpy(skb->mac.ethernet->h_dest, dev->dev_addr,
+			memcpy(eth_hdr(skb)->h_dest, dev->dev_addr,
 			       ETH_ALEN);
 			skb->pkt_type = PACKET_HOST;
 		}
@@ -412,8 +412,7 @@
 	__u32 len;
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)
-				   ((*pskb)->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(*pskb);
 
 	if (skb->protocol == __constant_htons(ETH_P_IPV6) || IS_VLAN_IPV6) {
 #ifdef CONFIG_SYSCTL
@@ -516,7 +515,7 @@
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *in;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_BR_FORWARD);
@@ -551,7 +550,7 @@
 {
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 	int pf;
 
 	if (!skb->nf_bridge)
@@ -591,7 +590,7 @@
    int (*okfn)(struct sk_buff *))
 {
 	struct sk_buff *skb = *pskb;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 	struct net_device **d = (struct net_device **)(skb->cb);
 
 #ifdef CONFIG_SYSCTL
@@ -669,7 +668,7 @@
 	struct net_device *realindev, *realoutdev;
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 	int pf;
 
 	if (!skb->nf_bridge)
@@ -753,7 +752,7 @@
 {
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge = (*pskb)->nf_bridge;
-	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	int pf;
 
@@ -848,8 +847,7 @@
 
 #ifdef CONFIG_SYSCTL
 	if (!skb->nf_bridge) {
-		struct vlan_ethhdr *hdr =
-		   (struct vlan_ethhdr *)(skb->mac.ethernet);
+		struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
 
 		if (skb->protocol == __constant_htons(ETH_P_IP) ||
 		    IS_VLAN_IP) {
diff -Nru a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
--- a/net/bridge/netfilter/ebt_802_3.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_802_3.c	2004-10-02 13:44:26 -03:00
@@ -16,7 +16,7 @@
    const struct net_device *out, const void *data, unsigned int datalen)
 {
 	struct ebt_802_3_info *info = (struct ebt_802_3_info *)data;
-	struct ebt_802_3_hdr *hdr = (struct ebt_802_3_hdr *)skb->mac.ethernet;
+	struct ebt_802_3_hdr *hdr = ebt_802_3_hdr(skb);
 	uint16_t type = hdr->llc.ui.ctrl & IS_UI ? hdr->llc.ui.type : hdr->llc.ni.type;
 
 	if (info->bitmask & EBT_802_3_SAP) {
diff -Nru a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
--- a/net/bridge/netfilter/ebt_among.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_among.c	2004-10-02 13:44:26 -03:00
@@ -72,14 +72,14 @@
 
 static int get_ip_dst(const struct sk_buff *skb, uint32_t *addr)
 {
-	if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_IP)) {
+	if (eth_hdr(skb)->h_proto == htons(ETH_P_IP)) {
 		struct iphdr _iph, *ih;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
 		if (ih == NULL)
 			return -1;
 		*addr = ih->daddr;
-	} else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
+	} else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
 		struct arphdr _arph, *ah;
 		uint32_t buf, *bp;
 
@@ -100,14 +100,14 @@
 
 static int get_ip_src(const struct sk_buff *skb, uint32_t *addr)
 {
-	if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_IP)) {
+	if (eth_hdr(skb)->h_proto == htons(ETH_P_IP)) {
 		struct iphdr _iph, *ih;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
 		if (ih == NULL)
 			return -1;
 		*addr = ih->saddr;
-	} else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
+	} else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
 		struct arphdr _arph, *ah;
 		uint32_t buf, *bp;
 
@@ -139,7 +139,7 @@
 	wh_src = ebt_among_wh_src(info);
 
 	if (wh_src) {
-		smac = skb->mac.ethernet->h_source;
+		smac = eth_hdr(skb)->h_source;
 		if (get_ip_src(skb, &sip))
 			return EBT_NOMATCH;
 		if (!(info->bitmask & EBT_AMONG_SRC_NEG)) {
@@ -154,7 +154,7 @@
 	}
 
 	if (wh_dst) {
-		dmac = skb->mac.ethernet->h_dest;
+		dmac = eth_hdr(skb)->h_dest;
 		if (get_ip_dst(skb, &dip))
 			return EBT_NOMATCH;
 		if (!(info->bitmask & EBT_AMONG_DST_NEG)) {
diff -Nru a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
--- a/net/bridge/netfilter/ebt_dnat.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_dnat.c	2004-10-02 13:44:26 -03:00
@@ -30,8 +30,7 @@
 		kfree_skb(*pskb);
 		*pskb = nskb;
 	}
-	memcpy(((**pskb).mac.ethernet)->h_dest, info->mac,
-	   ETH_ALEN * sizeof(unsigned char));
+	memcpy(eth_hdr(*pskb)->h_dest, info->mac, ETH_ALEN);
 	return info->target;
 }
 
diff -Nru a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
--- a/net/bridge/netfilter/ebt_log.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_log.c	2004-10-02 13:44:26 -03:00
@@ -70,13 +70,13 @@
 	   out ? out->name : "");
 
 	printk("MAC source = ");
-	print_MAC((skb->mac.ethernet)->h_source);
+	print_MAC(eth_hdr(skb)->h_source);
 	printk("MAC dest = ");
-	print_MAC((skb->mac.ethernet)->h_dest);
+	print_MAC(eth_hdr(skb)->h_dest);
 
-	printk("proto = 0x%04x", ntohs(((*skb).mac.ethernet)->h_proto));
+	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
 
-	if ((info->bitmask & EBT_LOG_IP) && skb->mac.ethernet->h_proto ==
+	if ((info->bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
 	   htons(ETH_P_IP)){
 		struct iphdr _iph, *ih;
 
@@ -106,8 +106,8 @@
 	}
 
 	if ((info->bitmask & EBT_LOG_ARP) &&
-	    ((skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) ||
-	    (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_RARP)))) {
+	    ((eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) ||
+	     (eth_hdr(skb)->h_proto == htons(ETH_P_RARP)))) {
 		struct arphdr _arph, *ah;
 
 		ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
diff -Nru a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
--- a/net/bridge/netfilter/ebt_redirect.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_redirect.c	2004-10-02 13:44:26 -03:00
@@ -32,11 +32,10 @@
 		*pskb = nskb;
 	}
 	if (hooknr != NF_BR_BROUTING)
-		memcpy((**pskb).mac.ethernet->h_dest,
-		   in->br_port->br->dev->dev_addr, ETH_ALEN);
+		memcpy(eth_hdr(*pskb)->h_dest,
+		       in->br_port->br->dev->dev_addr, ETH_ALEN);
 	else
-		memcpy((**pskb).mac.ethernet->h_dest,
-		   in->dev_addr, ETH_ALEN);
+		memcpy(eth_hdr(*pskb)->h_dest, in->dev_addr, ETH_ALEN);
 	(*pskb)->pkt_type = PACKET_HOST;
 	return info->target;
 }
diff -Nru a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
--- a/net/bridge/netfilter/ebt_snat.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebt_snat.c	2004-10-02 13:44:26 -03:00
@@ -30,8 +30,7 @@
 		kfree_skb(*pskb);
 		*pskb = nskb;
 	}
-	memcpy(((**pskb).mac.ethernet)->h_source, info->mac,
-	   ETH_ALEN * sizeof(unsigned char));
+	memcpy(eth_hdr(*pskb)->h_source, info->mac, ETH_ALEN);
 	return info->target;
 }
 
diff -Nru a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
--- a/net/bridge/netfilter/ebtables.c	2004-10-02 13:44:26 -03:00
+++ b/net/bridge/netfilter/ebtables.c	2004-10-02 13:44:26 -03:00
@@ -190,7 +190,7 @@
 	base = private->entries;
 	i = 0;
 	while (i < nentries) {
-		if (ebt_basic_match(point, (**pskb).mac.ethernet, in, out))
+		if (ebt_basic_match(point, eth_hdr(*pskb), in, out))
 			goto letscontinue;
 
 		if (EBT_MATCH_ITERATE(point, ebt_do_match, *pskb, in, out) != 0)
diff -Nru a/net/core/dv.c b/net/core/dv.c
--- a/net/core/dv.c	2004-10-02 13:44:26 -03:00
+++ b/net/core/dv.c	2004-10-02 13:44:26 -03:00
@@ -450,12 +450,12 @@
  */
 
 #define	ETH_DIVERT_FRAME(skb) \
-	memcpy(skb->mac.ethernet, skb->dev->dev_addr, ETH_ALEN); \
+	memcpy(eth_hdr(skb), skb->dev->dev_addr, ETH_ALEN); \
 	skb->pkt_type=PACKET_HOST
 		
 void divert_frame(struct sk_buff *skb)
 {
-	struct ethhdr			*eth = skb->mac.ethernet;
+	struct ethhdr			*eth = eth_hdr(skb);
 	struct iphdr			*iph;
 	struct tcphdr			*tcph;
 	struct udphdr			*udph;
diff -Nru a/net/core/netpoll.c b/net/core/netpoll.c
--- a/net/core/netpoll.c	2004-10-02 13:44:26 -03:00
+++ b/net/core/netpoll.c	2004-10-02 13:44:26 -03:00
@@ -378,7 +378,7 @@
 		return 1;
 	}
 
-	proto = ntohs(skb->mac.ethernet->h_proto);
+	proto = ntohs(eth_hdr(skb)->h_proto);
 	if (proto != ETH_P_IP)
 		goto out;
 	if (skb->pkt_type == PACKET_OTHERHOST)
diff -Nru a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	2004-10-02 13:44:26 -03:00
+++ b/net/decnet/dn_neigh.c	2004-10-02 13:44:26 -03:00
@@ -399,7 +399,7 @@
 			neigh->updated = jiffies;
 
 			if (neigh->dev->type == ARPHRD_ETHER)
-				memcpy(neigh->ha, &skb->mac.ethernet->h_source, ETH_ALEN);
+				memcpy(neigh->ha, &eth_hdr(skb)->h_source, ETH_ALEN);
 
 			dn->blksize  = dn_ntohs(msg->blksize);
 			dn->priority = msg->priority;
@@ -455,7 +455,7 @@
 			neigh->updated = jiffies;
 
 			if (neigh->dev->type == ARPHRD_ETHER)
-				memcpy(neigh->ha, &skb->mac.ethernet->h_source, ETH_ALEN);
+				memcpy(neigh->ha, &eth_hdr(skb)->h_source, ETH_ALEN);
 			dn->flags   &= ~(DN_NDFLAG_R1 | DN_NDFLAG_R2);
 			dn->blksize  = dn_ntohs(msg->blksize);
 			dn->priority = 0;
diff -Nru a/net/ethernet/eth.c b/net/ethernet/eth.c
--- a/net/ethernet/eth.c	2004-10-02 13:44:26 -03:00
+++ b/net/ethernet/eth.c	2004-10-02 13:44:26 -03:00
@@ -163,7 +163,7 @@
 	
 	skb->mac.raw=skb->data;
 	skb_pull(skb,ETH_HLEN);
-	eth= skb->mac.ethernet;
+	eth = eth_hdr(skb);
 	skb->input_dev = dev;
 	
 	if(*eth->h_dest&1)
@@ -210,7 +210,7 @@
 
 int eth_header_parse(struct sk_buff *skb, unsigned char *haddr)
 {
-	struct ethhdr *eth = skb->mac.ethernet;
+	struct ethhdr *eth = eth_hdr(skb);
 	memcpy(haddr, eth->h_source, ETH_ALEN);
 	return ETH_ALEN;
 }
diff -Nru a/net/ipv4/netfilter/ipt_mac.c b/net/ipv4/netfilter/ipt_mac.c
--- a/net/ipv4/netfilter/ipt_mac.c	2004-10-02 13:44:26 -03:00
+++ b/net/ipv4/netfilter/ipt_mac.c	2004-10-02 13:44:26 -03:00
@@ -33,7 +33,7 @@
     return (skb->mac.raw >= skb->head
 	    && (skb->mac.raw + ETH_HLEN) <= skb->data
 	    /* If so, compare... */
-	    && ((memcmp(skb->mac.ethernet->h_source, info->srcaddr, ETH_ALEN)
+	    && ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
 		== 0) ^ info->invert));
 }
 
diff -Nru a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
--- a/net/ipv6/netfilter/ip6t_eui64.c	2004-10-02 13:44:26 -03:00
+++ b/net/ipv6/netfilter/ip6t_eui64.c	2004-10-02 13:44:26 -03:00
@@ -41,10 +41,10 @@
     
     memset(eui64, 0, sizeof(eui64));
 
-    if (skb->mac.ethernet->h_proto == ntohs(ETH_P_IPV6)) {
+    if (eth_hdr(skb)->h_proto == ntohs(ETH_P_IPV6)) {
       if (skb->nh.ipv6h->version == 0x6) { 
-         memcpy(eui64, skb->mac.ethernet->h_source, 3);
-         memcpy(eui64 + 5, skb->mac.ethernet->h_source + 3, 3);
+         memcpy(eui64, eth_hdr(skb)->h_source, 3);
+         memcpy(eui64 + 5, eth_hdr(skb)->h_source + 3, 3);
 	 eui64[3]=0xff;
 	 eui64[4]=0xfe;
 	 eui64[0] |= 0x02;
diff -Nru a/net/ipv6/netfilter/ip6t_mac.c b/net/ipv6/netfilter/ip6t_mac.c
--- a/net/ipv6/netfilter/ip6t_mac.c	2004-10-02 13:44:26 -03:00
+++ b/net/ipv6/netfilter/ip6t_mac.c	2004-10-02 13:44:26 -03:00
@@ -35,7 +35,7 @@
     return (skb->mac.raw >= skb->head
 	    && (skb->mac.raw + ETH_HLEN) <= skb->data
 	    /* If so, compare... */
-	    && ((memcmp(skb->mac.ethernet->h_source, info->srcaddr, ETH_ALEN)
+	    && ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
 		== 0) ^ info->invert));
 }
 


--------------050506010401080500020506--
