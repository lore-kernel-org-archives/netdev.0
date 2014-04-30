From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net 2/2] Revert "macvlan : fix checksums error when
 we are in bridge mode"
Date: Wed, 30 Apr 2014 10:47:09 +0800
Message-ID: <5360642D.8050008@redhat.com>
References: <1398780591-10644-1-git-send-email-vyasevic@redhat.com> <1398780591-10644-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: daniel.lezcano@free.fr, nightnord@gmail.com, kaber@trash.net,
	eric.dumazet@gmail.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753508AbaD3CrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 22:47:15 -0400
In-Reply-To: <1398780591-10644-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2014 10:09 PM, Vlad Yasevich wrote:
> This reverts commit 12a2856b604476c27d85a5f9a57ae1661fc46019.
> The commit above doesn't appear to be necessary any more as the
> checksums appear to be correctly computed/validated.
>
> Additionally the above commit breaks kvm configurations where
> one VM is using a device that support checksum offload (virtio) and
> the other VM does not.
> In this case, packets leaving virtio device will have CHECKSUM_PARTIAL
> set.  The packets is forwarded to a macvtap that has offload features
> turned off.  Since we use CHECKSUM_UNNECESSARY, the host does does not
> update the checksum and thus a bad checksum is passed up to
> the guest.
>
> CC: Daniel Lezcano <daniel.lezcano@free.fr>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Andrian Nord <nightnord@gmail.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvlan.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 1831fb7..33b6cf8 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -263,11 +263,9 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
>  	const struct macvlan_dev *vlan = netdev_priv(dev);
>  	const struct macvlan_port *port = vlan->port;
>  	const struct macvlan_dev *dest;
> -	__u8 ip_summed = skb->ip_summed;
>  
>  	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
>  		const struct ethhdr *eth = (void *)skb->data;
> -		skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
>  		/* send to other bridge ports directly */
>  		if (is_multicast_ether_addr(eth->h_dest)) {
> @@ -285,7 +283,6 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  xmit_world:
> -	skb->ip_summed = ip_summed;
>  	skb->dev = vlan->lowerdev;
>  	return dev_queue_xmit(skb);
>  }

Acked-by: Jason Wang <jasowang@redhat.com>
