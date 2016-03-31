From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] net: skbuff: don't use union for napi_id
 and sender_cpu
Date: Thu, 31 Mar 2016 03:32:21 -0700
Message-ID: <1459420341.6473.225.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
	 <1459403439-6011-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459403439-6011-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-31 at 13:50 +0800, Jason Wang wrote:
> We use a union for napi_id and send_cpu, this is ok for most of the
> cases except when we want to support busy polling for tun which needs
> napi_id to be stored and passed to socket during tun_net_xmit(). In
> this case, napi_id was overridden with sender_cpu before tun_net_xmit()
> was called if XPS was enabled. Fixing by not using union for napi_id
> and sender_cpu.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  include/linux/skbuff.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 15d0df9..8aee891 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -743,11 +743,11 @@ struct sk_buff {
>  	__u32			hash;
>  	__be16			vlan_proto;
>  	__u16			vlan_tci;
> -#if defined(CONFIG_NET_RX_BUSY_POLL) || defined(CONFIG_XPS)
> -	union {
> -		unsigned int	napi_id;
> -		unsigned int	sender_cpu;
> -	};
> +#if defined(CONFIG_NET_RX_BUSY_POLL)
> +	unsigned int		napi_id;
> +#endif
> +#if defined(CONFIG_XPS)
> +	unsigned int		sender_cpu;
>  #endif
>  	union {
>  #ifdef CONFIG_NETWORK_SECMARK

Hmmm...

This is a serious problem.

Making skb bigger (8 bytes because of alignment) was not considered
valid for sender_cpu introduction. We worked quite hard to avoid this,
if you take a look at git history :(

Can you describe more precisely the problem and code path ?
