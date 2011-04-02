From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 2 Apr 2011 20:27:12 +0200
Message-ID: <20110402182711.GA11885@psychotron.redhat.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <20110402085524.6692131a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com,
	jesse@nicira.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756212Ab1DBS11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 14:27:27 -0400
Content-Disposition: inline
In-Reply-To: <20110402085524.6692131a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 02, 2011 at 05:55:24PM CEST, shemminger@linux-foundation.org wrote:
>On Sat,  2 Apr 2011 12:26:06 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
>> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets into
>> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>> 
>> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
>> __netif_receive_skb, it's untagged in ptype_base hander and reinjected
>> 
>> This incosistency is fixed by this patch. Vlan untagging happens early in
>> __netif_receive_skb so the rest of code (ptype_all handlers, rx_handlers)
>> see the skb like it was untagged by hw.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  include/linux/if_vlan.h |   10 ++-
>>  net/8021q/vlan.c        |    8 --
>>  net/8021q/vlan.h        |    2 -
>>  net/8021q/vlan_core.c   |   86 +++++++++++++++++++++++-
>>  net/8021q/vlan_dev.c    |  173 -----------------------------------------------
>>  net/core/dev.c          |    8 ++-
>>  6 files changed, 100 insertions(+), 187 deletions(-)
>> 
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 635e1fa..998b299 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -132,7 +132,8 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
>>  
>>  extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>>  			     u16 vlan_tci, int polling);
>> -extern bool vlan_hwaccel_do_receive(struct sk_buff **skb);
>> +extern bool vlan_do_receive(struct sk_buff **skb);
>> +extern struct sk_buff *vlan_untag(struct sk_buff *skb);
>>  extern gro_result_t
>>  vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
>>  		 unsigned int vlan_tci, struct sk_buff *skb);
>> @@ -166,13 +167,18 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>>  	return NET_XMIT_SUCCESS;
>>  }
>>  
>> -static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
>> +static inline bool vlan_do_receive(struct sk_buff **skb)
>>  {
>>  	if ((*skb)->vlan_tci & VLAN_VID_MASK)
>>  		(*skb)->pkt_type = PACKET_OTHERHOST;
>>  	return false;
>>  }
>
>Why the added unnecessary indirection

I do not understand what do you mean.

>
>
>> +inline struct sk_buff *vlan_untag(struct sk_buff *skb)
>> +{
>> +	return skb;
>> +}
>
>This adds no value.

Nod, it should not. That's why this is in else of:
#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)

>
>>  static inline gro_result_t
>>  vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
>>  		 unsigned int vlan_tci, struct sk_buff *skb)
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index 7850412..59f0a9d 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -49,11 +49,6 @@ const char vlan_version[] = DRV_VERSION;
>>  static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
>>  static const char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
>>  
>> -static struct packet_type vlan_packet_type __read_mostly = {
>> -	.type = cpu_to_be16(ETH_P_8021Q),
>> -	.func = vlan_skb_recv, /* VLAN receive method */
>> -};
>> -
>>  /* End of global variables definitions. */
>>  
>>  static void vlan_group_free(struct vlan_group *grp)
>> @@ -688,7 +683,6 @@ static int __init vlan_proto_init(void)
>>  	if (err < 0)
>>  		goto err4;
>>  
>> -	dev_add_pack(&vlan_packet_type);
>>  	vlan_ioctl_set(vlan_ioctl_handler);
>>  	return 0;
>>  
>> @@ -709,8 +703,6 @@ static void __exit vlan_cleanup_module(void)
>>  
>>  	unregister_netdevice_notifier(&vlan_notifier_block);
>>  
>> -	dev_remove_pack(&vlan_packet_type);
>> -
>>  	unregister_pernet_subsys(&vlan_net_ops);
>>  	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>>  
>> diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
>> index 5687c9b..c3408de 100644
>> --- a/net/8021q/vlan.h
>> +++ b/net/8021q/vlan.h
>> @@ -75,8 +75,6 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
>>  }
>>  
>>  /* found in vlan_dev.c */
>> -int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
>> -		  struct packet_type *ptype, struct net_device *orig_dev);
>>  void vlan_dev_set_ingress_priority(const struct net_device *dev,
>>  				   u32 skb_prio, u16 vlan_prio);
>>  int vlan_dev_set_egress_priority(const struct net_device *dev,
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index ce8e3ab..bc83ecc 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -4,7 +4,7 @@
>>  #include <linux/netpoll.h>
>>  #include "vlan.h"
>>  
>> -bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
>> +bool vlan_do_receive(struct sk_buff **skbp)
>>  {
>>  	struct sk_buff *skb = *skbp;
>>  	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
>> @@ -88,3 +88,87 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
>>  	return napi_gro_frags(napi);
>>  }
>>  EXPORT_SYMBOL(vlan_gro_frags);
>> +
>> +static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
>> +{
>> +	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
>> +		if (skb_cow(skb, skb_headroom(skb)) < 0)
>> +			skb = NULL;
>> +		if (skb) {
>> +			/* Lifted from Gleb's VLAN code... */
>> +			memmove(skb->data - ETH_HLEN,
>> +				skb->data - VLAN_ETH_HLEN, 12);
>> +			skb->mac_header += VLAN_HLEN;
>> +		}
>> +	}
>> +	return skb;
>> +}
>
>Do not mark code as 'static inline' let compiler decide.

I just moved this function from vlan_dev.c as it is. No problem to
change this.

>
>> +static inline void vlan_set_encap_proto(struct sk_buff *skb,
>> +					struct vlan_hdr *vhdr)
>> +{
>> +	__be16 proto;
>> +	unsigned char *rawp;
>> +
>> +	/*
>> +	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
>> +	 * three protocols care about.
>> +	 */
>> +
>> +	proto = vhdr->h_vlan_encapsulated_proto;
>> +	if (ntohs(proto) >= 1536) {
>> +		skb->protocol = proto;
>> +		return;
>> +	}
>> +
>> +	rawp = skb->data;
>> +	if (*(unsigned short *) rawp == 0xFFFF)
>> +		/*
>> +		 * This is a magic hack to spot IPX packets. Older Novell
>> +		 * breaks the protocol design and runs IPX over 802.3 without
>> +		 * an 802.2 LLC layer. We look for FFFF which isn't a used
>> +		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
>> +		 * but does for the rest.
>> +		 */
>> +		skb->protocol = htons(ETH_P_802_3);
>> +	else
>> +		/*
>> +		 * Real 802.2 LLC
>> +		 */
>> +		skb->protocol = htons(ETH_P_802_2);
>> +}
>
>What about doublely tagged packets?

No problem. Once they are untagged and reinjected they are untagged
again and reinjected again:

-> __netif_reveive_skb
vlan_untag
vlan_do_receive
-> __netif_receive_skb
vlan_untag
vlan_do_receive


>
>> +struct sk_buff *vlan_untag(struct sk_buff *skb)
>> +{
>> +	struct vlan_hdr *vhdr;
>> +	u16 vlan_tci;
>> +
>> +	if (unlikely(vlan_tx_tag_present(skb))) {
>> +		/* vlan_tci is already set-up so leave this for another time */
>> +		return skb;
>> +	}
>> +
>> +	skb = skb_share_check(skb, GFP_ATOMIC);
>> +	if (unlikely(!skb))
>> +		goto err_free;
>> +
>> +	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
>> +		goto err_free;
>> +
>> +	vhdr = (struct vlan_hdr *) skb->data;
>> +	vlan_tci = ntohs(vhdr->h_vlan_TCI);
>> +	__vlan_hwaccel_put_tag(skb, vlan_tci);
>> +
>> +	skb_pull_rcsum(skb, VLAN_HLEN);
>> +	vlan_set_encap_proto(skb, vhdr);
>> +
>> +	skb = vlan_check_reorder_header(skb);
>> +	if (unlikely(!skb))
>> +		goto err_free;
>> +
>> +	return skb;
>> +
>> +err_free:
>> +	kfree_skb(skb);
>> +	return NULL;
>> +}
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index e34ea9e..b4f061f 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -65,179 +65,6 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
>>  	return 0;
>>  }
>>  
>> -static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
>> -{
>> -	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
>> -		if (skb_cow(skb, skb_headroom(skb)) < 0)
>> -			skb = NULL;
>> -		if (skb) {
>> -			/* Lifted from Gleb's VLAN code... */
>> -			memmove(skb->data - ETH_HLEN,
>> -				skb->data - VLAN_ETH_HLEN, 12);
>> -			skb->mac_header += VLAN_HLEN;
>> -		}
>> -	}
>> -
>> -	return skb;
>> -}
>> -
>> -static inline void vlan_set_encap_proto(struct sk_buff *skb,
>> -		struct vlan_hdr *vhdr)
>> -{
>> -	__be16 proto;
>> -	unsigned char *rawp;
>> -
>> -	/*
>> -	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
>> -	 * three protocols care about.
>> -	 */
>> -
>> -	proto = vhdr->h_vlan_encapsulated_proto;
>> -	if (ntohs(proto) >= 1536) {
>> -		skb->protocol = proto;
>> -		return;
>> -	}
>> -
>> -	rawp = skb->data;
>> -	if (*(unsigned short *)rawp == 0xFFFF)
>> -		/*
>> -		 * This is a magic hack to spot IPX packets. Older Novell
>> -		 * breaks the protocol design and runs IPX over 802.3 without
>> -		 * an 802.2 LLC layer. We look for FFFF which isn't a used
>> -		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
>> -		 * but does for the rest.
>> -		 */
>> -		skb->protocol = htons(ETH_P_802_3);
>> -	else
>> -		/*
>> -		 * Real 802.2 LLC
>> -		 */
>> -		skb->protocol = htons(ETH_P_802_2);
>> -}
>> -
>> -/*
>> - *	Determine the packet's protocol ID. The rule here is that we
>> - *	assume 802.3 if the type field is short enough to be a length.
>> - *	This is normal practice and works for any 'now in use' protocol.
>> - *
>> - *  Also, at this point we assume that we ARE dealing exclusively with
>> - *  VLAN packets, or packets that should be made into VLAN packets based
>> - *  on a default VLAN ID.
>> - *
>> - *  NOTE:  Should be similar to ethernet/eth.c.
>> - *
>> - *  SANITY NOTE:  This method is called when a packet is moving up the stack
>> - *                towards userland.  To get here, it would have already passed
>> - *                through the ethernet/eth.c eth_type_trans() method.
>> - *  SANITY NOTE 2: We are referencing to the VLAN_HDR frields, which MAY be
>> - *                 stored UNALIGNED in the memory.  RISC systems don't like
>> - *                 such cases very much...
>> - *  SANITY NOTE 2a: According to Dave Miller & Alexey, it will always be
>> - *  		    aligned, so there doesn't need to be any of the unaligned
>> - *  		    stuff.  It has been commented out now...  --Ben
>> - *
>> - */
>> -int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
>> -		  struct packet_type *ptype, struct net_device *orig_dev)
>> -{
>> -	struct vlan_hdr *vhdr;
>> -	struct vlan_pcpu_stats *rx_stats;
>> -	struct net_device *vlan_dev;
>> -	u16 vlan_id;
>> -	u16 vlan_tci;
>> -
>> -	skb = skb_share_check(skb, GFP_ATOMIC);
>> -	if (skb == NULL)
>> -		goto err_free;
>> -
>> -	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
>> -		goto err_free;
>> -
>> -	vhdr = (struct vlan_hdr *)skb->data;
>> -	vlan_tci = ntohs(vhdr->h_vlan_TCI);
>> -	vlan_id = vlan_tci & VLAN_VID_MASK;
>> -
>> -	rcu_read_lock();
>> -	vlan_dev = vlan_find_dev(dev, vlan_id);
>> -
>> -	/* If the VLAN device is defined, we use it.
>> -	 * If not, and the VID is 0, it is a 802.1p packet (not
>> -	 * really a VLAN), so we will just netif_rx it later to the
>> -	 * original interface, but with the skb->proto set to the
>> -	 * wrapped proto: we do nothing here.
>> -	 */
>> -
>> -	if (!vlan_dev) {
>> -		if (vlan_id) {
>> -			pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
>> -				 __func__, vlan_id, dev->name);
>> -			goto err_unlock;
>> -		}
>> -		rx_stats = NULL;
>> -	} else {
>> -		skb->dev = vlan_dev;
>> -
>> -		rx_stats = this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_pcpu_stats);
>> -
>> -		u64_stats_update_begin(&rx_stats->syncp);
>> -		rx_stats->rx_packets++;
>> -		rx_stats->rx_bytes += skb->len;
>> -
>> -		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
>> -
>> -		pr_debug("%s: priority: %u for TCI: %hu\n",
>> -			 __func__, skb->priority, vlan_tci);
>> -
>> -		switch (skb->pkt_type) {
>> -		case PACKET_BROADCAST:
>> -			/* Yeah, stats collect these together.. */
>> -			/* stats->broadcast ++; // no such counter :-( */
>> -			break;
>> -
>> -		case PACKET_MULTICAST:
>> -			rx_stats->rx_multicast++;
>> -			break;
>> -
>> -		case PACKET_OTHERHOST:
>> -			/* Our lower layer thinks this is not local, let's make
>> -			 * sure.
>> -			 * This allows the VLAN to have a different MAC than the
>> -			 * underlying device, and still route correctly.
>> -			 */
>> -			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
>> -						skb->dev->dev_addr))
>> -				skb->pkt_type = PACKET_HOST;
>> -			break;
>> -		default:
>> -			break;
>> -		}
>> -		u64_stats_update_end(&rx_stats->syncp);
>> -	}
>> -
>> -	skb_pull_rcsum(skb, VLAN_HLEN);
>> -	vlan_set_encap_proto(skb, vhdr);
>> -
>> -	if (vlan_dev) {
>> -		skb = vlan_check_reorder_header(skb);
>> -		if (!skb) {
>> -			rx_stats->rx_errors++;
>> -			goto err_unlock;
>> -		}
>> -	}
>> -
>> -	netif_rx(skb);
>> -
>> -	rcu_read_unlock();
>> -	return NET_RX_SUCCESS;
>> -
>> -err_unlock:
>> -	rcu_read_unlock();
>> -err_free:
>> -	atomic_long_inc(&dev->rx_dropped);
>> -	kfree_skb(skb);
>> -	return NET_RX_DROP;
>> -}
>> -
>>  static inline u16
>>  vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
>>  {
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 3da9fb0..bfe9fce 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3130,6 +3130,12 @@ another_round:
>>  
>>  	__this_cpu_inc(softnet_data.processed);
>>  
>> +	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
>> +		skb = vlan_untag(skb);
>> +		if (unlikely(!skb))
>> +			goto out;
>> +	}
>
>This becomes a NOP, why is it here?

Sorry but I probably do not understand what you mean. This piece of code
does untagging for non-hw-accel + multiply tagged frames.

>
>
>>  #ifdef CONFIG_NET_CLS_ACT
>>  	if (skb->tc_verd & TC_NCLS) {
>>  		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
>> @@ -3177,7 +3183,7 @@ ncls:
>>  			ret = deliver_skb(skb, pt_prev, orig_dev);
>>  			pt_prev = NULL;
>>  		}
>> -		if (vlan_hwaccel_do_receive(&skb)) {
>> +		if (vlan_do_receive(&skb)) {
>>  			ret = __netif_receive_skb(skb);
>>  			goto out;
>>  		} else if (unlikely(!skb))
>
>
>Why rename the function?

I this it is correct because this function is no longer hwaccel-specific
since non-hw-accel path is using it as well.

Regards,

Jirka

>
>
