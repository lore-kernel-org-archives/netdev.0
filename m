From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 6/6] packet: rollover statistics
Date: Mon, 11 May 2015 13:09:50 -0400 (EDT)
Message-ID: <20150511.130950.1321194163068727654.davem@davemloft.net>
References: <1431206701-5019-1-git-send-email-willemb@google.com>
	<1431206701-5019-7-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	david.laight@aculab.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbEKRJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:09:53 -0400
In-Reply-To: <1431206701-5019-7-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sat,  9 May 2015 17:25:01 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Rollover indicates exceptional conditions. Export a counter to inform
> socket owners of this state.
> 
> If no socket with sufficient room is found, rollover fails. Also count
> these events.
> 
> Finally, also count when flows are rolled over early thanks to huge
> flow detection, to validate its correctness.
> 
> Tested:
>   Read counters in bench_rollover on all other tests in the patchset
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/uapi/linux/if_packet.h |  7 +++++++
>  net/packet/af_packet.c         | 19 ++++++++++++++++++-
>  net/packet/internal.h          |  3 +++
>  3 files changed, 28 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 053bd10..52b6501 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -54,6 +54,7 @@ struct sockaddr_ll {
>  #define PACKET_FANOUT			18
>  #define PACKET_TX_HAS_OFF		19
>  #define PACKET_QDISC_BYPASS		20
> +#define PACKET_ROLLOVER_STATS		21
>  
>  #define PACKET_FANOUT_HASH		0
>  #define PACKET_FANOUT_LB		1
> @@ -75,6 +76,12 @@ struct tpacket_stats_v3 {
>  	unsigned int	tp_freeze_q_cnt;
>  };
>  
> +struct tpacket_rollover_stats {
> +	unsigned long	tp_all;
> +	unsigned long	tp_huge;
> +	unsigned long	tp_failed;
> +};

Please do not use variably sized types, especially "long" for user exported
interfaces.  Otherwise you will need to add a compat layer to translate
the data into userspace for 32-bit tasks running on a 64-bit kernel.

If a 32-bit value really is not sufficient, use __aligned_u64.
