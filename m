From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 -next] netfilter: don't use per-destination
 incrementing ports in nat random mode
Date: Sat, 21 Dec 2013 13:17:59 +0100
Message-ID: <20131221121759.GA27158@localhost>
References: <20131219134007.GA24118@order.stressinduktion.org>
 <52B37F6B.9010105@redhat.com>
 <20131220004822.GC32129@order.stressinduktion.org>
 <20131220080118.GA4234@localhost>
 <20131220214029.GB14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131220214029.GB14073@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 10:40:29PM +0100, Hannes Frederic Sowa wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> 
> We currently use prandom_u32() for allocation of ports in tcp bind(0)
> and udp code. In case of plain SNAT we try to keep the ports as is
> or increment on collision.
> 
> SNAT --random mode does use per-destination incrementing port
> allocation. As a recent paper pointed out in [1] that this mode of
> port allocation makes it possible to an attacker to find the randomly
> allocated ports through a timing side-channel in a socket overloading
> attack conducted through an off-path attacker.
> 
> So, NF_NAT_RANGE_PROTO_RANDOM actually weakens the port randomization
> in regard to the attack described in this paper. As we need to keep
> compatibility, add another flag called NF_NAT_RANGE_PROTO_RANDOM_FULLY
> that would replace the NF_NAT_RANGE_PROTO_RANDOM hash-based port
> selection algorithm with a simple prandom_u32() in order to mitigate
> this attack vector. Note that the lfsr113's internal state is
> periodically reseeded by the kernel through a local secure entropy
> source.
> 
> More details can be found in [1], the basic idea is to send bursts
> of packets to a socket to overflow its receive queue and measure
> the latency to detect a possible retransmit when the port is found.
> Because of increasing ports to given destination and port, further
> allocations can be predicted. This information could then be used by
> an attacker for e.g. for cache-poisoning, NS pinning, and degradation
> of service attacks against DNS servers [1]:
> 
>   The best defense against the poisoning attacks is to properly
>   deploy and validate DNSSEC; DNSSEC provides security not only
>   against off-path attacker but even against MitM attacker. We hope
>   that our results will help motivate administrators to adopt DNSSEC.
>   However, full DNSSEC deployment make take significant time, and
>   until that happens, we recommend short-term, non-cryptographic
>   defenses. We recommend to support full port randomisation,
>   according to practices recommended in [2], and to avoid
>   per-destination sequential port allocation, which we show may be
>   vulnerable to derandomisation attacks.
> 
> Joint work between Hannes Frederic Sowa and Daniel Borkmann.
> 
>  [1] https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf
>  [2] http://arxiv.org/pdf/1205.5190v1.pdf
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
> 
> Daniel will follow-up with the user-space changes tomorrow.
> 
>  include/uapi/linux/netfilter/nf_nat.h | 12 ++++++++----
>  net/netfilter/nf_nat_core.c           |  4 ++--
>  net/netfilter/nf_nat_proto_common.c   | 10 ++++++----
>  3 files changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/nf_nat.h b/include/uapi/linux/netfilter/nf_nat.h
> index bf0cc37..1ad3659 100644
> --- a/include/uapi/linux/netfilter/nf_nat.h
> +++ b/include/uapi/linux/netfilter/nf_nat.h

This is exposed to userspace.

> @@ -4,10 +4,14 @@
>  #include <linux/netfilter.h>
>  #include <linux/netfilter/nf_conntrack_tuple_common.h>
>  
> -#define NF_NAT_RANGE_MAP_IPS		1
> -#define NF_NAT_RANGE_PROTO_SPECIFIED	2
> -#define NF_NAT_RANGE_PROTO_RANDOM	4
> -#define NF_NAT_RANGE_PERSISTENT		8
> +#define NF_NAT_RANGE_MAP_IPS			(1 << 0)
> +#define NF_NAT_RANGE_PROTO_SPECIFIED		(1 << 1)
> +#define NF_NAT_RANGE_PROTO_RANDOM		(1 << 2)
> +#define NF_NAT_RANGE_PERSISTENT			(1 << 3)
> +#define NF_NAT_RANGE_PROTO_RANDOM_FULLY		(1 << 4)

So you cannot change it. It would break old iptables binaries.

BTW, please send me the userspace part.

Thanks!
