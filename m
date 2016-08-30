From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/2] net: bridge: change unicast
 boolean to exact pkt_type
Date: Tue, 30 Aug 2016 07:59:53 -0700
Message-ID: <20160830075953.739291e1@xeon-e3>
References: <1472562539-23247-1-git-send-email-nikolay@cumulusnetworks.com>
	<1472562539-23247-2-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1472562539-23247-2-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Aug 2016 15:08:58 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> -	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
> -	    br_multicast_rcv(br, p, skb, vid))
> -		goto drop;
> +	local_rcv = !!(br->dev->flags & IFF_PROMISC);
local_rcv is needlessly initialized in existing code. Pls remove that.

> +	if (is_multicast_ether_addr(dest)) {
> +		/* by definition the broadcast is also a multicast address */
> +		if (is_broadcast_ether_addr(dest)) {
> +			pkt_type = BR_PKT_BROADCAST;
> +			local_rcv = true;
> +		} else {
> +			pkt_type = BR_PKT_MULTICAST;
> +			if (br_multicast_rcv(br, p, skb, vid))
> +				goto drop;
> +		}
> +	}
>


These could go after the BR_STATE_LEARNING check

>  	if (p->state == BR_STATE_LEARNING)
>  		goto drop;
>  
>  	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
>  
> -	local_rcv = !!(br->dev->flags & IFF_PROMISC);
> -
>  	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
>  		br_do_proxy_arp(skb, br, vid, p);
>

can't proxy_arp change what was a broadcast packet into a unicast packet?
