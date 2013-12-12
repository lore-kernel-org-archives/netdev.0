From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 1/2] macvtap: Add support of packet capture on
 macvtap device.
Date: Thu, 12 Dec 2013 11:45:02 +0800
Message-ID: <52A9313E.6040602@redhat.com>
References: <1386786431-22592-1-git-send-email-vyasevic@redhat.com> <1386786431-22592-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, kaber@trash.net
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab3LLDp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 22:45:28 -0500
In-Reply-To: <1386786431-22592-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2013 02:27 AM, Vlad Yasevich wrote:
> Macvtap device currently doesn not allow a user to capture
> traffic on due to the fact that it steals the packets
> from the network stack before the skb->dev is set correctly
> on the receive side, and that use uses macvlan transmit
> path directly on the send side.  As a result, we never
> get a change to give traffic to the taps while the correct
> device is set in the skb.
>
> This patch makes macvtap device behave almost exaclty like
> macvlan.  On the send side, we switch to using dev_queue_xmit().
> On the receive side, to deliver packets to macvtap, we now
> use netif_rx and dev_forward_skb just like macvlan.  The only
> differnce now is that macvtap has its own rx_handler which is
> attached to the macvtap netdev.  It is here that we now steal
> the packet and provide it to the socket.
>
> As a result, we can now capture traffic on the macvtap device:
>    tcpdump -i macvtap0
>
> It also gives us the abilit to add tc actions to the macvtap
> device and actually utilize different bandwidth management
> queues on output.
>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 59 ++++++++++++++++++++++++++++-----------------------
>  1 file changed, 32 insertions(+), 27 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 4c6f84c..f9847da 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -70,6 +70,11 @@ static const struct proto_ops macvtap_socket_ops;
>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
>  #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
>  
[...]
>  
>  static void macvtap_dellink(struct net_device *dev,
>  			    struct list_head *head)
>  {
> +	netdev_rx_handler_unregister(dev);
>  	macvtap_del_queues(dev);
>  	macvlan_dellink(dev, head);
>  }
> @@ -725,9 +731,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
>  	}
>  	if (vlan) {
> -		local_bh_disable();
> -		macvlan_start_xmit(skb, vlan->dev);
> -		local_bh_enable();
> +		skb->dev = vlan->dev;
> +		dev_queue_xmit(skb);
>  	} else {
>  		kfree_skb(skb);
>  	}

An issue here: macvlan is a NETIF_F_LLTX device with only one transmit
queue, we may get contention on qdisc lock of macvtap when transmitting
through multiple tx queues.
