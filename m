From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] be2net: Allow GRE to work concurrently while a VxLAN
 tunnel is configured
Date: Wed, 14 Jan 2015 15:55:42 +0300
Message-ID: <54B6674E.8010301@cogentembedded.com>
References: <1421293069-30518-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:38953 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbANMzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 07:55:45 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so7907479lab.12
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 04:55:43 -0800 (PST)
In-Reply-To: <1421293069-30518-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/15/2015 6:37 AM, Sriharsha Basavapatna wrote:

> Other tunnels like GRE break while VxLAN offloads are enabled in Skyhawk-R. To
> avoid this, we should restrict offload features on a per-packet basis in such
> conditions.

> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_main.c |   41 +++++++++++++++++++++++++--
>   1 file changed, 38 insertions(+), 3 deletions(-)

    Some nitpicking, mostly grammatical...

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 41a0a54..726a4a4 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
[...]
> @@ -4463,7 +4464,41 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
>   					   struct net_device *dev,
>   					   netdev_features_t features)
>   {
> -	return vxlan_features_check(skb, features);
> +	struct be_adapter *adapter = netdev_priv(dev);
> +	u8 l4_hdr = 0;
> +
> +	/* The code below restricts offload features for some tunneled packets.
> +	 * Offload features for normal(non tunnel) packets are unchanged.

    You forgot space before (.

> +	 */
> +	if (!skb->encapsulation ||
> +	    !(adapter->flags & BE_FLAGS_VXLAN_OFFLOADS))
> +		return features;
> +
> +	/* It's an encapsulated packet and VxLAN offloads are enabled. We
> +	 * should disable tunnel offload features if it's not a VxLAN packet,
> +	 * as tunnel offloads have been enabled only for VxLAN. This is done to
> +	 * allow other tunneled trafffic like GRE work fine while VxLAN

    Just "traffic", too many f's.

> +	 * offloads are configured in Skyhawk-R.
> +	 */
> +	switch (vlan_get_protocol(skb)) {
> +	case htons(ETH_P_IP):
> +		l4_hdr = ip_hdr(skb)->protocol;
> +		break;
> +	case htons(ETH_P_IPV6):
> +		l4_hdr = ipv6_hdr(skb)->nexthdr;
> +		break;
> +	default:
> +		return features;
> +	}
> +
> +	if (l4_hdr != IPPROTO_UDP ||
> +	    skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +	    skb->inner_protocol != htons(ETH_P_TEB) ||
> +	    (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
> +	    sizeof(struct udphdr) + sizeof(struct vxlanhdr)))

    () not needed around !=.

[...]

WBR, Sergei
