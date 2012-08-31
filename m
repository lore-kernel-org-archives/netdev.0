From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] 6lowpan: Make a copy of skb's delivered to
 6lowpan
Date: Fri, 31 Aug 2012 00:01:25 -0700
Message-ID: <1346396485.2586.307.camel@edumazet-glaptop>
References: <1346294341-26808-1-git-send-email-alan@signal11.us>
	 <1346294341-26808-2-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Cheneau <tony.cheneau@amnesiak.org>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346294341-26808-2-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-29 at 22:39 -0400, Alan Ott wrote:
> Since lowpan_process_data() modifies the skb (by calling skb_pull()), we
> need our own copy so that it doesn't affect the data received by other
> protcols (in this case, af_ieee802154).
> 
> Signed-off-by: Alan Ott <alan@signal11.us>
> ---
>  net/ieee802154/6lowpan.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 6a09522..ce33b02 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -1133,6 +1133,8 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
>  static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
>  	struct packet_type *pt, struct net_device *orig_dev)
>  {
> +	struct sk_buff *local_skb;
> +
>  	if (!netif_running(dev))
>  		goto drop;
>  
> @@ -1144,7 +1146,12 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
>  	case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
>  	case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
>  	case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
> -		lowpan_process_data(skb);
> +		local_skb = skb_copy(skb, GFP_ATOMIC);
> +		if (!local_skb)
> +			goto drop;
> +		lowpan_process_data(local_skb);
> +
> +		kfree_skb(skb);
>  		break;
>  	default:
>  		break;

Its not clear to me why skb_copy() is needed here.

>From patch description, I would say skb_clone() would be enough (and
faster) ?
