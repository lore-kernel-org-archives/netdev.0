From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH v2 net-next 4/6] udp: flow dissector offload
Date: Wed, 30 Aug 2017 12:36:12 +0200
Message-ID: <1504089372.2480.55.camel@redhat.com>
References: <20170829232711.1465-1-tom@quantonium.net>
         <20170829232711.1465-5-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <tom@quantonium.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42286 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdH3KgO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 06:36:14 -0400
In-Reply-To: <20170829232711.1465-5-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 16:27 -0700, Tom Herbert wrote:
> Add support to perform UDP specific flow dissection. This is
> primarily intended for dissecting encapsulated packets in UDP
> encapsulation.
> 
> This patch adds a flow_dissect offload for UDP4 and UDP6. The backend
> function performs a socket lookup and calls the flow_dissect function
> if a socket is found.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  include/linux/udp.h      |  8 ++++++++
>  include/net/udp.h        |  8 ++++++++
>  include/net/udp_tunnel.h |  8 ++++++++
>  net/ipv4/udp_offload.c   | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/udp_tunnel.c    |  1 +
>  net/ipv6/udp_offload.c   | 13 +++++++++++++
>  6 files changed, 83 insertions(+)
> 
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index eaea63bc79bb..2e90b189ef6a 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -79,6 +79,14 @@ struct udp_sock {
>  	int			(*gro_complete)(struct sock *sk,
>  						struct sk_buff *skb,
>  						int nhoff);
> +	/* Flow dissector function for a UDP socket */
> +	enum flow_dissect_ret (*flow_dissect)(struct sock *sk,
> +			const struct sk_buff *skb,
> +			struct flow_dissector_key_control *key_control,
> +			struct flow_dissector *flow_dissector,
> +			void *target_container, void *data,
> +			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
> +			int *p_hlen, unsigned int flags);
>  
>  	/* udp_recvmsg try to use this before splicing sk_receive_queue */
>  	struct sk_buff_head	reader_queue ____cacheline_aligned_in_smp;
> diff --git a/include/net/udp.h b/include/net/udp.h
> index f3d1de6f0983..499e4faf8b14 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -174,6 +174,14 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>  				 struct udphdr *uh, udp_lookup_t lookup);
>  int udp_gro_complete(struct sk_buff *skb, int nhoff, udp_lookup_t lookup);
>  
> +enum flow_dissect_ret udp_flow_dissect(const struct sk_buff *skb,
> +			udp_lookup_t lookup,
> +			struct flow_dissector_key_control *key_control,
> +			struct flow_dissector *flow_dissector,
> +			void *target_container, void *data,
> +			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
> +			int *p_hlen, unsigned int flags);
> +
>  static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
>  {
>  	struct udphdr *uh;
> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index 10cce0dd4450..b7102e0f41a9 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -69,6 +69,13 @@ typedef struct sk_buff **(*udp_tunnel_gro_receive_t)(struct sock *sk,
>  						     struct sk_buff *skb);
>  typedef int (*udp_tunnel_gro_complete_t)(struct sock *sk, struct sk_buff *skb,
>  					 int nhoff);
> +typedef enum flow_dissect_ret (*udp_tunnel_flow_dissect_t)(struct sock *sk,
> +			const struct sk_buff *skb,
> +			struct flow_dissector_key_control *key_control,
> +			struct flow_dissector *flow_dissector,
> +			void *target_container, void *data,
> +			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
> +			int *p_hlen, unsigned int flags);
>  
>  struct udp_tunnel_sock_cfg {
>  	void *sk_user_data;     /* user data used by encap_rcv call back */
> @@ -78,6 +85,7 @@ struct udp_tunnel_sock_cfg {
>  	udp_tunnel_encap_destroy_t encap_destroy;
>  	udp_tunnel_gro_receive_t gro_receive;
>  	udp_tunnel_gro_complete_t gro_complete;
> +	udp_tunnel_flow_dissect_t flow_dissect;
>  };
>  
>  /* Setup the given (UDP) sock to receive UDP encapsulated packets */
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 97658bfc1b58..7f0a7ed4a6f7 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -328,11 +328,56 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
>  	return udp_gro_complete(skb, nhoff, udp4_lib_lookup_skb);
>  }
>  
> +enum flow_dissect_ret udp_flow_dissect(const struct sk_buff *skb,
> +			udp_lookup_t lookup,
> +			struct flow_dissector_key_control *key_control,
> +			struct flow_dissector *flow_dissector,
> +			void *target_container, void *data,
> +			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
> +			int *p_hlen, unsigned int flags)
> +{
> +	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
> +	struct udphdr *uh, _uh;
> +	struct sock *sk;
> +
> +	uh = __skb_header_pointer(skb, *p_nhoff, sizeof(_uh), data,
> +				  *p_hlen, &_uh);
> +	if (!uh)
> +		return FLOW_DISSECT_RET_OUT_BAD;
> +
> +	rcu_read_lock();
> +
> +	sk = (*lookup)(skb, uh->source, uh->dest);
> +
> +	if (sk && udp_sk(sk)->flow_dissect)
> +		ret = udp_sk(sk)->flow_dissect(sk, skb, key_control,
> +					       flow_dissector, target_container,
> +					       data, p_proto, p_ip_proto,
> +					       p_nhoff, p_hlen, flags);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(udp_flow_dissect);

If I read the above correctly, this is going to add another full UDP
lookup per UDP packet, can we avoid it with some static key enabled by
vxlan/fou/etc. ?

Thanks,

Paolo
