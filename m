From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH v2] vlan: allow nested vlan_do_receive()
Date: Sat, 29 Oct 2011 18:28:40 +0200
Message-ID: <20111029162839.GC2053@minipsycho.orion>
References: <4E972301.4030004@intel.com>
 <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
 <20111018.234723.1235424375699917420.davem@davemloft.net>
 <1319796053.23112.92.camel@edumazet-laptop>
 <1319799986.23112.101.camel@edumazet-laptop>
 <4EAB62F0.2040101@intel.com>
 <1319883746.2586.33.camel@edumazet-laptop>
 <20111029145900.GA2053@minipsycho.orion>
 <1319904026.2586.42.camel@edumazet-laptop>
 <1319904819.2586.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"hans.schillstrom@ericsson.com" <hans.schillstrom@ericsson.com>,
	"mbizon@freebox.fr" <mbizon@freebox.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933458Ab1J2Q2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Oct 2011 12:28:51 -0400
Content-Disposition: inline
In-Reply-To: <1319904819.2586.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 29, 2011 at 06:13:39PM CEST, eric.dumazet@gmail.com wrote:
>commit 2425717b27eb (net: allow vlan traffic to be received under bond)
>broke ARP processing on vlan on top of bonding.
>
>       +-------+
>eth0 --| bond0 |---bond0.103
>eth1 --|       |
>       +-------+
>
>52870.115435: skb_gro_reset_offset <-napi_gro_receive
>52870.115435: dev_gro_receive <-napi_gro_receive
>52870.115435: napi_skb_finish <-napi_gro_receive
>52870.115435: netif_receive_skb <-napi_skb_finish
>52870.115435: get_rps_cpu <-netif_receive_skb
>52870.115435: __netif_receive_skb <-netif_receive_skb
>52870.115436: vlan_do_receive <-__netif_receive_skb
>52870.115436: bond_handle_frame <-__netif_receive_skb
>52870.115436: vlan_do_receive <-__netif_receive_skb
>52870.115436: arp_rcv <-__netif_receive_skb
>52870.115436: kfree_skb <-arp_rcv
>
>Packet is dropped in arp_rcv() because its pkt_type was set to
>PACKET_OTHERHOST in the first vlan_do_receive() call, since no eth0.103
>exists.
>
>We really need to change pkt_type only if no more rx_handler is about to
>be called for the packet.
>
>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>---
>V2 : change the vlan_do_receive() added argument to be a boolean
>
> include/linux/if_vlan.h |    6 +++---
> net/8021q/vlan_core.c   |    7 +++++--
> net/core/dev.c          |    4 ++--
> 3 files changed, 10 insertions(+), 7 deletions(-)
>
>diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>index 44da482..12d5543 100644
>--- a/include/linux/if_vlan.h
>+++ b/include/linux/if_vlan.h
>@@ -106,7 +106,7 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
> extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
> extern u16 vlan_dev_vlan_id(const struct net_device *dev);
> 
>-extern bool vlan_do_receive(struct sk_buff **skb);
>+extern bool vlan_do_receive(struct sk_buff **skb, bool last_handler);
> extern struct sk_buff *vlan_untag(struct sk_buff *skb);
> 
> #else
>@@ -128,9 +128,9 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
> 	return 0;
> }
> 
>-static inline bool vlan_do_receive(struct sk_buff **skb)
>+static inline bool vlan_do_receive(struct sk_buff **skb, bool last_handler)
> {
>-	if ((*skb)->vlan_tci & VLAN_VID_MASK)
>+	if (((*skb)->vlan_tci & VLAN_VID_MASK) && last_handler)
> 		(*skb)->pkt_type = PACKET_OTHERHOST;
> 	return false;
> }
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index f1f2f7b..163397f 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -4,7 +4,7 @@
> #include <linux/netpoll.h>
> #include "vlan.h"
> 
>-bool vlan_do_receive(struct sk_buff **skbp)
>+bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
> {
> 	struct sk_buff *skb = *skbp;
> 	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
>@@ -13,7 +13,10 @@ bool vlan_do_receive(struct sk_buff **skbp)
> 
> 	vlan_dev = vlan_find_dev(skb->dev, vlan_id);
> 	if (!vlan_dev) {
>-		if (vlan_id)
>+		/* Only the last call to vlan_do_receive() should change
>+		 * pkt_type to PACKET_OTHERHOST
>+		 */
>+		if (vlan_id && last_handler)
> 			skb->pkt_type = PACKET_OTHERHOST;
> 		return false;
> 	}
>diff --git a/net/core/dev.c b/net/core/dev.c
>index edcf019..6ba50a1 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3283,18 +3283,18 @@ another_round:
> ncls:
> #endif
> 
>+	rx_handler = rcu_dereference(skb->dev->rx_handler);
> 	if (vlan_tx_tag_present(skb)) {
> 		if (pt_prev) {
> 			ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = NULL;
> 		}
>-		if (vlan_do_receive(&skb))
>+		if (vlan_do_receive(&skb, !rx_handler))

This I had on mind as well. Looks nicer. I have one another thought how
to resolve this. I will try it and let you know by tomorrow.

Jirka

> 			goto another_round;
> 		else if (unlikely(!skb))
> 			goto out;
> 	}
> 
>-	rx_handler = rcu_dereference(skb->dev->rx_handler);
> 	if (rx_handler) {
> 		if (pt_prev) {
> 			ret = deliver_skb(skb, pt_prev, orig_dev);
>
>
