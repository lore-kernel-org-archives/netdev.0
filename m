From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 2/4] bridge: Handle priority-tagged frames properly
Date: Tue, 10 Sep 2013 10:03:31 -0400
Message-ID: <522F26B3.60709@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita> <1378809280.3988.8.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3IJODr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 10:03:47 -0400
In-Reply-To: <1378809280.3988.8.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 06:34 AM, Toshiaki Makita wrote:
> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
> use the PVID for the port as its VID.
> (See IEEE 802.1Q-2005 6.7.1 and Table 9-2)
>
> Apply the PVID to not only untagged frames but also priority-tagged frames.
>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>   net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
>   1 file changed, 20 insertions(+), 7 deletions(-)
>
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 21b6d21..5a9c44a 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -189,6 +189,8 @@ out:
>   bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>   			struct sk_buff *skb, u16 *vid)
>   {
> +	int err;
> +
>   	/* If VLAN filtering is disabled on the bridge, all packets are
>   	 * permitted.
>   	 */
> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>   	if (!v)
>   		return false;
>
> -	if (br_vlan_get_tag(skb, vid)) {
> +	err = br_vlan_get_tag(skb, vid);
> +	if (!*vid) {
>   		u16 pvid = br_get_pvid(v);
>
> -		/* Frame did not have a tag.  See if pvid is set
> -		 * on this port.  That tells us which vlan untagged
> -		 * traffic belongs to.
> +		/* Frame had a tag with VID 0 or did not have a tag.
> +		 * See if pvid is set on this port.  That tells us which
> +		 * vlan untagged or priority-tagged traffic belongs to.
>   		 */
>   		if (pvid == VLAN_N_VID)
>   			return false;
>
> -		/* PVID is set on this port.  Any untagged ingress
> -		 * frame is considered to belong to this vlan.
> +		/* PVID is set on this port.  Any untagged or priority-tagged
> +		 * ingress frame is considered to belong to this vlan.
>   		 */
> -		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
> +		if (likely(err))
> +			/* Untagged Frame. */
> +			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
> +		else
> +			/* Priority-tagged Frame.
> +			 * At this point, We know that skb->vlan_tci had
> +			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
> +			 * We update only VID field and preserve PCP field.
> +			 */
> +			skb->vlan_tci |= pvid;
> +

In the case of a priority tagged frame, we should unroll the 
modification above and restore the VID field to 0.  Otherwise, you
may end up either stripping the vlan header completely or forwarding
with pvid of the ingress port.

-vlad
>   		return true;
>   	}
>
>
