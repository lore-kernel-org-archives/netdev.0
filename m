From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [net-next (TAKE 2) 3/4] firewire net, ipv4 arp: Extend hardware
	address and remove driver-level packet inspection.
Date: Sun, 10 Feb 2013 15:31:07 +0100
Message-ID: <20130210153107.68a4886d@stein>
References: <51176223.8090305@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51176223.8090305@linux-ipv6.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Feb 10 YOSHIFUJI Hideaki wrote:
> @@ -1339,42 +1236,23 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
>  		ptask->dest_node   = IEEE1394_ALL_NODES;
>  		ptask->speed       = SCODE_100;
>  	} else {
> -		__be64 guid = get_unaligned((__be64 *)hdr_buf.h_dest);
> +		union fwnet_hwaddr *ha = (union fwnet_hwaddr *)hdr_buf.h_dest;
> +		__be64 guid = get_unaligned(&ha->uc.uniq_id);
>  		u8 generation;
>  
>  		peer = fwnet_peer_find_by_guid(dev, be64_to_cpu(guid));
> -		if (!peer || peer->fifo == FWNET_NO_FIFO_ADDR)
> +		if (!peer)
>  			goto fail;
>  
>  		generation         = peer->generation;
>  		dest_node          = peer->node_id;
> -		max_payload        = peer->max_payload;
> +		max_payload        = fwnet_hwaddr_maxpayload(ha);
>  		datagram_label_ptr = &peer->datagram_label;
>  
> -		ptask->fifo_addr   = peer->fifo;
> +		ptask->fifo_addr   = fwnet_hwaddr_fifo(ha);
>  		ptask->generation  = generation;
>  		ptask->dest_node   = dest_node;
> -		ptask->speed       = peer->speed;
> -	}
> -
> -	/* If this is an ARP packet, convert it */
> -	if (proto == htons(ETH_P_ARP)) {
> -		struct arphdr *arp = (struct arphdr *)skb->data;
> -		unsigned char *arp_ptr = (unsigned char *)(arp + 1);
> -		struct rfc2734_arp *arp1394 = (struct rfc2734_arp *)skb->data;
> -		__be32 ipaddr;
> -
> -		ipaddr = get_unaligned((__be32 *)(arp_ptr + FWNET_ALEN));
> -
> -		arp1394->hw_addr_len    = RFC2734_HW_ADDR_LEN;
> -		arp1394->max_rec        = dev->card->max_receive;
> -		arp1394->sspd		= dev->card->link_speed;
> -
> -		put_unaligned_be16(dev->local_fifo >> 32,
> -				   &arp1394->fifo_hi);
> -		put_unaligned_be32(dev->local_fifo & 0xffffffff,
> -				   &arp1394->fifo_lo);
> -		put_unaligned(ipaddr, &arp1394->sip);
> +		ptask->speed       = fwnet_fixup_speed(ha->uc.sspd);
>  	}
>  
>  	ptask->hdr.w0 = 0;
> @@ -1491,13 +1369,9 @@ static int fwnet_add_peer(struct fwnet_device *dev,
>  
>  	peer->dev = dev;
>  	peer->guid = (u64)device->config_rom[3] << 32 | device->config_rom[4];
> -	peer->fifo = FWNET_NO_FIFO_ADDR;
> -	peer->ip = 0;
>  	INIT_LIST_HEAD(&peer->pd_list);
>  	peer->pdg_size = 0;
>  	peer->datagram_label = 0;
> -	peer->speed = device->max_speed;
> -	peer->max_payload = fwnet_max_payload(device->max_rec, peer->speed);
>  
>  	peer->generation = device->generation;
>  	smp_rmb();

As far as I can tell, it would be best to ignore max_rec and sspd from ARP
and NDP but keep using the respective information from firewire-core
instead (handed over by fwnet_probe()).

Why?  As I noted earlier, RFC 2734:1999 and RFC 3146:2001 were apparently
written with a too simplistic notion of IEEE 1394 bus topology, resulting
in max_rec and sspd in ARP-1394 and NDP-1394 to be useless, IMO.

Consider a bus like this:

    A ---- B ==== C

A, B, C are all IP-over-1394 capable nodes.  ---- is an S400 cable hop,
and ==== is an S800 cable hop.

In case of unicasts or multicasts in which node A is involved as
transmitter or receiver, as well as in case of broadcasts, the speeds
S100, S200, S400 work and speed S400 is optimal.

In case of anything else, IOW in case of unicasts or multicasts in which
only nodes B and C are involved, the speeds S100, S200, S400, S800 work
and speed S800 is optimal.

Clearly, node A should indicate sspd = S400 in its ARP or NDP packets.
But which sspd should nodes B and C set there?  Maybe they set S400, which
would work but would waste half of the available bandwidth in the second
case.  Or maybe they set S800, which is OK in the second case but would
prohibit any communication with node A if blindly taken for correct.

On the other hand, firewire-core *always* gives us the correct and optimum
peer-to-peer speed and asynchronous packet payload, no matter how simple
or complex the bus topology is and no matter in which temporal order nodes
join the bus and are discovered.
-- 
Stefan Richter
-=====-===-= --=- -=-=-
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
