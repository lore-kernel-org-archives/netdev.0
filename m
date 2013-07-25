From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next v2] pktgen: Add UDPCSUM flag to support UDP checksums
Date: Thu, 25 Jul 2013 07:01:49 -0700
Message-ID: <51F12FCD.8080604@candelatech.com>
References: <8e168d7f8b1d82be3d33f1790f3bf435a0ba1390.1374753898.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46212 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab3GYOCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 10:02:21 -0400
In-Reply-To: <8e168d7f8b1d82be3d33f1790f3bf435a0ba1390.1374753898.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 05:07 AM, Thomas Graf wrote:
> UDP checksums are optional, hence pktgen has been omitting them in
> favour of performance. The optional flag UDPCSUM enables UDP
> checksumming. If the output device supports hardware checksumming
> the skb is prepared and marked CHECKSUM_PARTIAL, otherwise the
> checksum is generated in software.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> CC: Eric Dumazet <edumazet@google.com>
> ---
> v2: - Add IPv6 support
>
>   include/net/udp.h |  1 +
>   net/core/pktgen.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>   net/ipv4/udp.c    |  3 ++-
>   3 files changed, 52 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 74c10ec..ef2e0b7 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -183,6 +183,7 @@ extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
>   			    struct msghdr *msg, size_t len);
>   extern int udp_push_pending_frames(struct sock *sk);
>   extern void udp_flush_pending_frames(struct sock *sk);
> +extern void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
>   extern int udp_rcv(struct sk_buff *skb);
>   extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
>   extern int udp_disconnect(struct sock *sk, int flags);
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 9640972..929eb7b 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -160,6 +160,7 @@
>   #include <net/net_namespace.h>
>   #include <net/checksum.h>
>   #include <net/ipv6.h>
> +#include <net/udp.h>
>   #include <net/addrconf.h>
>   #ifdef CONFIG_XFRM
>   #include <net/xfrm.h>
> @@ -198,6 +199,7 @@
>   #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
>   #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
>   #define F_NODE          (1<<15)	/* Node memory alloc*/
> +#define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
>
>   /* Thread control flag bits */
>   #define T_STOP        (1<<0)	/* Stop run */
> @@ -631,6 +633,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>   	if (pkt_dev->flags & F_UDPDST_RND)
>   		seq_printf(seq, "UDPDST_RND  ");
>
> +	if (pkt_dev->flags & F_UDPCSUM)
> +		seq_printf(seq, "UDPCSUM  ");
> +
>   	if (pkt_dev->flags & F_MPLS_RND)
>   		seq_printf(seq,  "MPLS_RND  ");
>
> @@ -1228,6 +1233,9 @@ static ssize_t pktgen_if_write(struct file *file,
>   		else if (strcmp(f, "!NODE_ALLOC") == 0)
>   			pkt_dev->flags &= ~F_NODE;
>
> +		else if (strcmp(f, "UDPCSUM") == 0)
> +			pkt_dev->flags |= F_UDPCSUM;
> +

Looks like we need a way to turn it back off again too??

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
