From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/4] macvlan: cleanup rx statistics
Date: Tue, 24 Nov 2009 11:41:38 +0100
Message-ID: <4B0BB862.6070101@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932723AbZKXKlg@vger.kernel.org>
In-Reply-To: <1259024166-28158-3-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index ae2b5c7..a0dea23 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -116,42 +116,53 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
>  	return 0;
>  }
>  
> +static inline void macvlan_count_rx(const struct macvlan_dev *vlan, int length,

Please use unsigned int for length values.

Regarding Eric's comments, I also think it would be more readable to use
if (success) {
	...
} else {
	...
}

> +			     int success, int multicast)
> +{
> +	struct macvlan_rx_stats *rx_stats;
> +
> +	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
> +	rx_stats->rx_packets += success != 0;
> +	rx_stats->rx_bytes   += success ? length : 0;
> +	rx_stats->multicast  += success && multicast;
> +	rx_stats->rx_errors  += !success;
> +}
> +
> +static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
> +				 const struct ethhdr *eth)
> +{
> +	if (!skb)
> +		return NET_RX_DROP;
> +
> +	skb->dev = dev;
> +	if (!compare_ether_addr_64bits(eth->h_dest,
> +				       dev->broadcast))

This would fit on one line without reducing readability.

> +		skb->pkt_type = PACKET_BROADCAST;
> +	else
> +		skb->pkt_type = PACKET_MULTICAST;
> +
> +	return netif_rx(skb);
> +}
