From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] af_packet: Add Queue mapping mode to af_packet fanout
 operation
Date: Wed, 22 Jan 2014 23:00:32 +0100
Message-ID: <52E03F80.8020803@redhat.com>
References: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909AbaAVWL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 17:11:27 -0500
In-Reply-To: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 10:01 PM, Neil Horman wrote:
> This patch adds a queue mapping mode to the fanout operation of af_packet
> sockets.  This allows user space af_packet users to better filter on flows
> ingressing and egressing via a specific hardware queue, and avoids the potential

Maybe I'm missing something, but I currently cannot find where this is
being filled out for ingress path? Egress, ok, this gets filled out
somewhere in protocol layers or elsewhere and is being locally pushed
back through dev_queue_xmit_nit(), but I think main use case is ingress
through packet fanout. In driver layer I can find skb->rxhash filled out
which would then be PACKET_FANOUT_HASH.
(Otherwise patch looks good.)

> packet reordering that can occur when FANOUT_CPU is being used and irq affinity
> varies.
>
> Tested successfully by myself.  applies to net-next
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>   include/uapi/linux/if_packet.h |  1 +
>   net/packet/af_packet.c         | 11 +++++++++++
>   2 files changed, 12 insertions(+)
>
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 1988a02..bac27fa 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -60,6 +60,7 @@ struct sockaddr_ll {
>   #define PACKET_FANOUT_CPU		2
>   #define PACKET_FANOUT_ROLLOVER		3
>   #define PACKET_FANOUT_RND		4
> +#define PACKET_FANOUT_QM		5
>   #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
>   #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index d711ecb..bd90a87 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1313,6 +1313,13 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
>   	return idx;
>   }
>
> +static unsigned int fanout_demux_qm(struct packet_fanout *f,
> +				    struct sk_buff *skb,
> +				    unsigned int num)
> +{
> +	return skb_get_queue_mapping(skb) % num;
> +}
> +
>   static bool fanout_has_flag(struct packet_fanout *f, u16 flag)
>   {
>   	return f->flags & (flag >> 8);
> @@ -1352,6 +1359,9 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
>   	case PACKET_FANOUT_RND:
>   		idx = fanout_demux_rnd(f, skb, num);
>   		break;
> +	case PACKET_FANOUT_QM:
> +		idx = fanout_demux_qm(f, skb, num);
> +		break;
>   	case PACKET_FANOUT_ROLLOVER:
>   		idx = fanout_demux_rollover(f, skb, 0, (unsigned int) -1, num);
>   		break;
> @@ -1422,6 +1432,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>   	case PACKET_FANOUT_LB:
>   	case PACKET_FANOUT_CPU:
>   	case PACKET_FANOUT_RND:
> +	case PACKET_FANOUT_QM:
>   		break;
>   	default:
>   		return -EINVAL;
>
