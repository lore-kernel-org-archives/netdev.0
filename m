From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH v5 6/6] 6lowpan: Fix IID format for Bluetooth
Date: Fri, 24 Feb 2017 15:00:12 +0100
Message-ID: <204e938d-c73b-8572-baca-ee2e99f1e40a@osg.samsung.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
 <20170224121440.32269-7-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224121440.32269-7-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
> Accourding to RFC 7668 U/L bit shall not be used:
>
> https://wiki.tools.ietf.org/html/rfc7668#section-3.2.2 [Page 10]:
>
>    In the figure, letter 'b' represents a bit from the
>    Bluetooth device address, copied as is without any changes on any
>    bit.  This means that no bit in the IID indicates whether the
>    underlying Bluetooth device address is public or random.
>
>    |0              1|1              3|3              4|4              6|
>    |0              5|6              1|2              7|8              3|
>    +----------------+----------------+----------------+----------------+
>    |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
>    +----------------+----------------+----------------+----------------+
>
> Because of this the code cannot figure out the address type from the IP
> address anymore thus it makes no sense to use peer_lookup_ba as it needs
> the peer address type.
>
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/6lowpan.h   |  4 ---
>  net/bluetooth/6lowpan.c | 79 ++++++++-----------------------------------------
>  2 files changed, 12 insertions(+), 71 deletions(-)
>
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index c5792cb..a713780 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -211,10 +211,6 @@ static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
>  	ipaddr->s6_addr[11] = 0xFF;
>  	ipaddr->s6_addr[12] = 0xFE;
>  	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
> -	/* second bit-flip (Universe/Local)
> -	 * is done according RFC2464
> -	 */
> -	ipaddr->s6_addr[8] ^= 0x02;
>  }
>
>  #ifdef DEBUG
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 0b68cfc..ec89c55 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -398,37 +398,6 @@ static int chan_recv_cb(struct l2cap_chan *chan, struct sk_buff *skb)
>  	return err;
>  }
>
> -static u8 get_addr_type_from_eui64(u8 byte)
> -{
> -	/* Is universal(0) or local(1) bit */
> -	return ((byte & 0x02) ? BDADDR_LE_RANDOM : BDADDR_LE_PUBLIC);
> -}
> -
> -static void copy_to_bdaddr(struct in6_addr *ip6_daddr, bdaddr_t *addr)
> -{
> -	u8 *eui64 = ip6_daddr->s6_addr + 8;
> -
> -	addr->b[0] = eui64[7];
> -	addr->b[1] = eui64[6];
> -	addr->b[2] = eui64[5];
> -	addr->b[3] = eui64[2];
> -	addr->b[4] = eui64[1];
> -	addr->b[5] = eui64[0];
> -}
> -
> -static void convert_dest_bdaddr(struct in6_addr *ip6_daddr,
> -				bdaddr_t *addr, u8 *addr_type)
> -{
> -	copy_to_bdaddr(ip6_daddr, addr);
> -
> -	/* We need to toggle the U/L bit that we got from IPv6 address
> -	 * so that we get the proper address and type of the BD address.
> -	 */
> -	addr->b[5] ^= 0x02;
> -
> -	*addr_type = get_addr_type_from_eui64(addr->b[5]);
> -}
> -
>  static int setup_header(struct sk_buff *skb, struct net_device *netdev,
>  			bdaddr_t *peer_addr, u8 *peer_addr_type)
>  {
> @@ -436,8 +405,7 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
>  	struct ipv6hdr *hdr;
>  	struct lowpan_btle_dev *dev;
>  	struct lowpan_peer *peer;
> -	bdaddr_t addr, *any = BDADDR_ANY;
> -	u8 *daddr = any->b;
> +	u8 *daddr;
>  	int err, status = 0;
>
>  	hdr = ipv6_hdr(skb);
> @@ -448,34 +416,24 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
>
>  	if (ipv6_addr_is_multicast(&ipv6_daddr)) {
>  		lowpan_cb(skb)->chan = NULL;
> +		daddr = NULL;
>  	} else {
> -		u8 addr_type;
> +		BT_DBG("dest IP %pI6c", &ipv6_daddr);
>
> -		/* Get destination BT device from skb.
> -		 * If there is no such peer then discard the packet.
> +		/* The packet might be sent to 6lowpan interface
> +		 * because of routing (either via default route
> +		 * or user set route) so get peer according to
> +		 * the destination address.
>  		 */
> -		convert_dest_bdaddr(&ipv6_daddr, &addr, &addr_type);
> -
> -		BT_DBG("dest addr %pMR type %d IP %pI6c", &addr,
> -		       addr_type, &ipv6_daddr);
> -
> -		peer = peer_lookup_ba(dev, &addr, addr_type);
> +		peer = peer_lookup_dst(dev, &ipv6_daddr, skb);
>  		if (!peer) {
> -			/* The packet might be sent to 6lowpan interface
> -			 * because of routing (either via default route
> -			 * or user set route) so get peer according to
> -			 * the destination address.
> -			 */
> -			peer = peer_lookup_dst(dev, &ipv6_daddr, skb);
> -			if (!peer) {
> -				BT_DBG("no such peer %pMR found", &addr);
> -				return -ENOENT;
> -			}
> +			BT_DBG("no such peer");
> +			return -ENOENT;
>  		}
>
>  		daddr = peer->lladdr;
> -		*peer_addr = addr;
> -		*peer_addr_type = addr_type;
> +		peer_addr = &peer->chan->dst;
> +		*peer_addr_type = peer->chan->dst_type;
>  		lowpan_cb(skb)->chan = peer->chan;
>
>  		status = 1;
> @@ -717,14 +675,6 @@ static struct l2cap_chan *chan_create(void)
>  	return chan;
>  }
>
> -static void set_ip_addr_bits(u8 addr_type, u8 *addr)
> -{
> -	if (addr_type == BDADDR_LE_PUBLIC)
> -		*addr |= 0x02;
> -	else
> -		*addr &= ~0x02;
> -}
> -
>  static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
>  					struct lowpan_btle_dev *dev)
>  {
> @@ -741,11 +691,6 @@ static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
>
>  	lowpan_iphc_uncompress_eui48_lladdr(&peer->peer_addr, peer->lladdr);
>
> -	/* IPv6 address needs to have the U/L bit set properly so toggle
> -	 * it back here.
> -	 */
> -	set_ip_addr_bits(chan->dst_type, (u8 *)&peer->peer_addr.s6_addr + 8);
> -
>  	spin_lock(&devices_lock);
>  	INIT_LIST_HEAD(&peer->list);
>  	peer_add(dev, peer);
>

Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

regards
Stefan Schmidt
