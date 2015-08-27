From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] udp_offload: Allow device GRO without
 checksum-complete
Date: Thu, 27 Aug 2015 16:12:50 -0700
Message-ID: <5eda08d030f52a933b846a5d9c5ed0e7@imap.linux.ibm.com>
References: <1440444853-614524-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	jay.kidambi@us.ibm.com, mala.anand@us.ibm.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e17.ny.us.ibm.com ([129.33.205.207]:55331 "EHLO
	e17.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbH0XMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:12:54 -0400
Received: from /spool/local
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Thu, 27 Aug 2015 19:12:53 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1CD86C9005A
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 19:03:56 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7RNCpre55836924
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 23:12:51 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7RNCoIb014610
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 19:12:51 -0400
In-Reply-To: <1440444853-614524-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-08-24 12:34, Tom Herbert wrote:
> This patch adds a sysctl which allows GRO for a UDP offload protocol
> to be performed in the device NAPI. This potentially is a performance
> improvement if the savings of doing GRO in device NAPI outweighs the
> cost of performing the checksum. Note that the performing the
> checksum in device NAPI may negatively impact latency or throughput
> of unrelated flows.
> 
> Performance results for VXLAN are below. Allowing GRO in device
> NAPI does show performance improvement over doing GRO at the VXLAN
> interface, however this performance is still less than what we see
> with UDP checksums enabled (or getting checksum complete from the
> device).
> 
> Test results: Running one netperf TCP_STREAM over VXLAN.
> 
> No UDP checksum, enable sysctl to allow GRO at device (this patch)
>   TX CPU: 1.71
>   RX CPU: 1.14
>   6174 Mbps
> 
> UDP checksums and remote checksum offload enabled
>   TX CPU: 1.97%
>   RX CPU: 1.55%
>   7527 Mbps
> 
> UDP checksums enabled
>   TX CPU: 1.22%
>   RX CPU: 1.86%
>   6539 Mbps
> 
> No UDP checksums, GRO enabled on VXLAN interface
>   TX CPU: 0.95%
>   RX CPU: 1.78%
>   4393 Mbps
> 
> No UDP checksum, GRO disabled VXLAN interface
>   TX CPU: 1.31%
>   RX CPU: 2.38%
>   3613 Mbps
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  Documentation/networking/ip-sysctl.txt | 7 +++++++
>  include/net/udp.h                      | 1 +
>  net/ipv4/sysctl_net_ipv4.c             | 7 +++++++
>  net/ipv4/udp.c                         | 3 +++
>  net/ipv4/udp_offload.c                 | 7 ++++---
>  5 files changed, 22 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt
> b/Documentation/networking/ip-sysctl.txt
> index 46e88ed..d8563c08 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -711,6 +711,13 @@ udp_wmem_min - INTEGER
>  	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
>  	Default: 1 page
> 
> +udp_gro_nocsum_ok - BOOLEAN
> +	If set, allow Generic Receive Offload (GRO) to be performed for UDP
> +	offload protocols in the case that packets are being received
> +	without an offloaded checksum. This implies that packets checksums
> +	may be performed in the device NAPI routines which could negatively
> +	impact unrelated flows.
> +
>  CIPSOv4 Variables:
> 
>  cipso_cache_enable - BOOLEAN
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 6d4ed18..48eb6ae 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -103,6 +103,7 @@ extern atomic_long_t udp_memory_allocated;
>  extern long sysctl_udp_mem[3];
>  extern int sysctl_udp_rmem_min;
>  extern int sysctl_udp_wmem_min;
> +extern int sysctl_udp_gro_nocsum_ok;
> 
>  struct sk_buff;
> 
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 0330ab2..65fea78 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -766,6 +766,13 @@ static struct ctl_table ipv4_table[] = {
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &one
>  	},
> +	{
> +		.procname	= "udp_gro_nocsum_ok",
> +		.data		= &sysctl_udp_gro_nocsum_ok,
> +		.maxlen		= sizeof(sysctl_udp_gro_nocsum_ok),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +	},
>  	{ }
>  };
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c0a15e7..1d91227 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -130,6 +130,9 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
>  atomic_long_t udp_memory_allocated;
>  EXPORT_SYMBOL(udp_memory_allocated);
> 
> +int sysctl_udp_gro_nocsum_ok;
> +EXPORT_SYMBOL(sysctl_udp_gro_nocsum_ok);
> +
>  #define MAX_UDP_PORTS 65536
>  #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
> 
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index f938616..1666f44 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -300,9 +300,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff
> **head, struct sk_buff *skb,
>  	int flush = 1;
> 
>  	if (NAPI_GRO_CB(skb)->udp_mark ||
> -	    (skb->ip_summed != CHECKSUM_PARTIAL &&
> -	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
> -	     !NAPI_GRO_CB(skb)->csum_valid))
> +	    ((skb->ip_summed != CHECKSUM_PARTIAL &&
> +	      NAPI_GRO_CB(skb)->csum_cnt == 0 &&
> +	      !NAPI_GRO_CB(skb)->csum_valid) &&
> +	      !sysctl_udp_gro_nocsum_ok))
>  		goto out;
> 
>  	/* mark that this skb passed once through the udp gro layer */

Thanks for making this configurable, It would help with 10G adapters 
including ( intel 82599es , intel br kx4 dual-port)
