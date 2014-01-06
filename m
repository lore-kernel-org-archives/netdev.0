From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/12] netfilter: nfnetlink_queue: enable UID/GID socket
 info retrieval
Date: Mon, 06 Jan 2014 07:32:33 -0800
Message-ID: <1389022353.12212.176.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
	 <1388963586-5049-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Valentina Giusti <valentina.giusti@bmw-carit.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388963586-5049-4-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-06 at 00:12 +0100, Pablo Neira Ayuso wrote:
> From: Valentina Giusti <valentina.giusti@bmw-carit.de>
> 
> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388
> (udp: ipv4: Add udp early demux) it is now possible to parse UID and
> GID socket info also for incoming TCP and UDP connections. Having
> this info available, it is convenient to let NFQUEUE parse it in
> order to improve and refine the traffic analysis in userspace.
> 
> Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  include/uapi/linux/netfilter/nfnetlink_queue.h |    5 +++-
>  net/netfilter/nfnetlink_queue_core.c           |   34 ++++++++++++++++++++++++
>  2 files changed, 38 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
> index 0132bad..8dd819e 100644
> --- a/include/uapi/linux/netfilter/nfnetlink_queue.h
> +++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
> @@ -47,6 +47,8 @@ enum nfqnl_attr_type {
>  	NFQA_CAP_LEN,			/* __u32 length of captured packet */
>  	NFQA_SKB_INFO,			/* __u32 skb meta information */
>  	NFQA_EXP,			/* nf_conntrack_netlink.h */
> +	NFQA_UID,			/* __u32 sk uid */
> +	NFQA_GID,			/* __u32 sk gid */
>  
>  	__NFQA_MAX
>  };
> @@ -99,7 +101,8 @@ enum nfqnl_attr_config {
>  #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
>  #define NFQA_CFG_F_CONNTRACK			(1 << 1)
>  #define NFQA_CFG_F_GSO				(1 << 2)
> -#define NFQA_CFG_F_MAX				(1 << 3)
> +#define NFQA_CFG_F_UID_GID			(1 << 3)
> +#define NFQA_CFG_F_MAX				(1 << 4)
>  
>  /* flags for NFQA_SKB_INFO */
>  /* packet appears to have wrong checksums, but they are ok */
> diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
> index 21258cf..d3cf12b 100644
> --- a/net/netfilter/nfnetlink_queue_core.c
> +++ b/net/netfilter/nfnetlink_queue_core.c
> @@ -297,6 +297,31 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
>  	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
>  }
>  
> +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
> +{
> +	const struct cred *cred;
> +
> +	if (sk->sk_state == TCP_TIME_WAIT)
> +		return 0;
> +

net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in
make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1

Fix is obvious (#include <net/tcp_states.h>), but I have to run...



