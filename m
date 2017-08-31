From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: drop packets where gso_size is too big for
 hardware
Date: Wed, 30 Aug 2017 23:02:21 -0700
Message-ID: <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831054642.13721-1-dja@axtens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, jay.vosburgh@canonical.com
To: Daniel Axtens <dja@axtens.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32876 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdHaGCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 02:02:25 -0400
Received: by mail-io0-f193.google.com with SMTP id f99so296757ioi.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 23:02:25 -0700 (PDT)
In-Reply-To: <20170831054642.13721-1-dja@axtens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 15:46 +1000, Daniel Axtens wrote:
> If a bnx2x card is passed a GSO packet with a gso_size larger than
> ~9700 bytes, it will cause a firmware error that will bring the card
> down:
> 
> bnx2x: [bnx2x_attn_int_deasserted3:4323(enP24p1s0f0)]MC assert!
> bnx2x: [bnx2x_mc_assert:720(enP24p1s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
> bnx2x: [bnx2x_mc_assert:736(enP24p1s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
> bnx2x: [bnx2x_mc_assert:750(enP24p1s0f0)]Chip Revision: everest3, FW Version: 7_13_1
> ... (dump of values continues) ...
> 
> Detect when gso_size + header length is greater than the maximum
> packet size (9700 bytes) and drop the packet.
> 
> This raises the obvious question - how do we end up with a packet with
> a gso_size that's greater than 9700? This has been observed on an
> powerpc system when Open vSwitch is forwarding a packet from an
> ibmveth device.
> 
> ibmveth is a bit special. It's the driver for communication between
> virtual machines (aka 'partitions'/LPARs) running under IBM's
> proprietary hypervisor on ppc machines. It allows sending very large
> packets (up to 64kB) between LPARs. This involves some quite
> 'interesting' things: for example, when talking TCP, the MSS is stored
> the checksum field (see ibmveth_rx_mss_helper() in ibmveth.c).
> 
> Normally on a box like this, there would be a Virtual I/O Server
> (VIOS) partition that owns the physical network card. VIOS lets the
> AIX partitions know when they're talking to a real network and that
> they should drop their MSS. This works fine if VIOS owns the physical
> network card.
> 
> However, in this case, a Linux partition owns the card (this is known
> as a NovaLink setup). The negotiation between VIOS and AIX uses a
> non-standard TCP option, so Linux has never supported that.  Instead,
> Linux just supports receiving large packets. It doesn't support any
> form of messaging/MSS negotiation back to other LPARs.
> 
> To get some clarity about where the large MSS was coming from, I asked
> Thomas Falcon, the maintainer of ibmveth, for some background:
> 
> "In most cases, large segments are an aggregation of smaller packets
> by the Virtual I/O Server (VIOS) partition and then are forwarded to
> the Linux LPAR / ibmveth driver. These segments can be as large as
> 64KB. In this case, since the customer is using Novalink, I believe
> what is happening is pretty straightforward: the large segments are
> created by the AIX partition and then forwarded to the Linux
> partition, ... The ibmveth driver doesn't do any aggregation itself
> but just ensures the proper bits are set before sending the frame up
> to avoid giving the upper layers indigestion."
> 
> It is possible to stop AIX from sending these large segments, but it
> requires configuration on each LPAR. While ibmveth's behaviour is
> admittedly weird, we should fix this here: it shouldn't be possible
> for it to cause a firmware panic on another card.
> 



This is so weird :/

> Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com> # ibmveth
> Cc: Yuval Mintz <Yuval.Mintz@cavium.com> # bnx2x
> Thanks-to: Jay Vosburgh <jay.vosburgh@canonical.com> # veth info
> Signed-off-by: Daniel Axtens <dja@axtens.net>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 33 +++++++++++++++---------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  1 -
>  3 files changed, 23 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index 352beff796ae..b36d54737d70 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -2517,4 +2517,6 @@ void bnx2x_set_rx_ts(struct bnx2x *bp, struct sk_buff *skb);
>   */
>  int bnx2x_vlan_reconfigure_vid(struct bnx2x *bp);
>  
> +#define MAX_PACKET_SIZE	(9700)
> +
>  #endif /* bnx2x.h */
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 1216c1f1e052..1c5517a9348c 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3742,6 +3742,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	__le16 pkt_size = 0;
>  	struct ethhdr *eth;
>  	u8 mac_type = UNICAST_ADDRESS;
> +	unsigned int pkts_compl = 0, bytes_compl = 0;
>  
>  #ifdef BNX2X_STOP_ON_ERROR
>  	if (unlikely(bp->panic))
> @@ -4029,6 +4030,14 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		   skb->len, hlen, skb_headlen(skb),
>  		   skb_shinfo(skb)->gso_size);
>  
> +		if (unlikely(skb_shinfo(skb)->gso_size + hlen > MAX_PACKET_SIZE)) {
> +			BNX2X_ERR("reported gso segment size plus headers "
> +				  "(%d + %d) > MAX_PACKET_SIZE; dropping pkt!",
> +				  skb_shinfo(skb)->gso_size, hlen);
> +
> +			goto free_and_drop;
> +		}
> +


If you had this test in bnx2x_features_check(), packet could be
segmented by core networking stack before reaching bnx2x_start_xmit() by
clearing NETIF_F_GSO_MASK

-> No drop would be involved.

check i40evf_features_check() for similar logic.
