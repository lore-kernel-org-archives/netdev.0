From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/2] bridge: Fix inabillity to retrieve
 vlan tags when tx offload is disabled
Date: Thu, 27 Mar 2014 17:33:32 -0400
Message-ID: <5334992C.20903@redhat.com>
References: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

On 03/27/2014 08:46 AM, Toshiaki Makita wrote:
> Bridge vlan code (br_vlan_get_tag()) assumes that all frames have vlan_tci
> if they are tagged, but if vlan tx offload is manually disabled on bridge
> device and frames are sent from vlan device on the bridge device, the tags
> are embedded in skb->data and they break this assumption.
> Extract embedded vlan tags and move them to vlan_tci at ingress.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_device.c |  6 +++---
>  net/bridge/br_vlan.c   | 12 ++++++++++++
>  2 files changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 63f0455..8fe8b71 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -49,14 +49,14 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  	brstats->tx_bytes += skb->len;
>  	u64_stats_update_end(&brstats->syncp);
>  
> -	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
> -		goto out;
> -
>  	BR_INPUT_SKB_CB(skb)->brdev = dev;
>  
>  	skb_reset_mac_header(skb);
>  	skb_pull(skb, ETH_HLEN);
>  
> +	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
> +		goto out;
> +
>  	if (is_broadcast_ether_addr(dest))
>  		br_flood_deliver(br, skb, false);
>  	else if (is_multicast_ether_addr(dest)) {
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 8249ca7..44f31af 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -174,6 +174,18 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>  	if (!v)
>  		return false;
>  
> +	/* If vlan tx offload is disabled on bridge device and frame was
> +	 * sent from vlan device on the bridge device, it does not have
> +	 * HW accelerated vlan tag.
> +	 */
> +	if (unlikely(!vlan_tx_tag_present(skb) &&
> +		     (skb->protocol == htons(ETH_P_8021Q) ||
> +		      skb->protocol == htons(ETH_P_8021AD)))) {
> +		skb = vlan_untag(skb);
> +		if (unlikely(!skb))
> +			return false;
> +	}
> +
>  	err = br_vlan_get_tag(skb, vid);
>  	if (!*vid) {
>  		u16 pvid = br_get_pvid(v);
> 
