From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: Fix memory leak in br_dev_xmit
Date: Fri, 28 Mar 2014 09:34:57 -0700
Message-ID: <20140328093457.5d25b9a3@samsung-9>
References: <1395987680-8151-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S . Miller" <davem@davemloft.net>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395987680-8151-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

On Fri, 28 Mar 2014 15:21:19 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> When a frame is rejected by br_allowed_ingress(), the skb is not freed.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_device.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 8fe8b71..b152fb6 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -55,7 +55,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  	skb_pull(skb, ETH_HLEN);
>  
>  	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
> -		goto out;
> +		goto drop;
>  
>  	if (is_broadcast_ether_addr(dest))
>  		br_flood_deliver(br, skb, false);
> @@ -64,10 +64,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  			br_flood_deliver(br, skb, false);
>  			goto out;
>  		}
> -		if (br_multicast_rcv(br, NULL, skb, vid)) {
> -			kfree_skb(skb);
> -			goto out;
> -		}
> +		if (br_multicast_rcv(br, NULL, skb, vid))
> +			goto drop;
>  
>  		mdst = br_mdb_get(br, skb, vid);
>  		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
> @@ -83,6 +81,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  out:
>  	rcu_read_unlock();
>  	return NETDEV_TX_OK;
> +drop:
> +	kfree_skb(skb);
> +	goto out;
>  }

Increment dev->tx_dropped?
