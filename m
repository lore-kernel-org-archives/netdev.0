From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/8] skb: api to report errors for zero copy
 skbs
Date: Tue, 30 Oct 2012 11:44:16 -0400
Message-ID: <508FF5D0.6080107@redhat.com>
References: <cover.1351524501.git.mst@redhat.com> <ee85ad5053a929c90e0347b6ba33778d96690e9b.1351524501.git.mst@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ee85ad5053a929c90e0347b6ba33778d96690e9b.1351524501.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2012 11:49 AM, Michael S. Tsirkin wrote:
> Orphaning frags for zero copy skbs needs to allocate data in atomic
> context so is has a chance to fail. If it does we currently discard
> the skb which is safe, but we don't report anything to the caller,
> so it can not recover by e.g. disabling zero copy.
>
> Add an API to free skb reporting such errors: this is used
> by tun in case orphaning frags fails.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>   include/linux/skbuff.h |  1 +
>   net/core/skbuff.c      | 19 +++++++++++++++++++
>   2 files changed, 20 insertions(+)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 8bac11b..0644432 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -568,6 +568,7 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
>   }
>
>   extern void kfree_skb(struct sk_buff *skb);
> +extern void skb_tx_error(struct sk_buff *skb, int err);
>   extern void consume_skb(struct sk_buff *skb);
>   extern void	       __kfree_skb(struct sk_buff *skb);
>   extern struct kmem_cache *skbuff_head_cache;
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index eb31f6e..ad99c64 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -635,6 +635,25 @@ void kfree_skb(struct sk_buff *skb)
>   EXPORT_SYMBOL(kfree_skb);
>
>   /**
> + *	kfree_skb_on_error - report an sk_buff xmit error
> + *	@skb: buffer that triggered an error
> + *
> + *	Report xmit error if a device callback is tracking this skb.
> + */

Nit:  Comment doesn't match new function.

-vlad

> +void skb_tx_error(struct sk_buff *skb, int err)
> +{
> +	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +		struct ubuf_info *uarg;
> +
> +		uarg = skb_shinfo(skb)->destructor_arg;
> +		if (uarg->callback)
> +			uarg->callback(uarg, err);
> +		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> +	}
> +}
> +EXPORT_SYMBOL(skb_tx_error);
> +
> +/**
>    *	consume_skb - free an skbuff
>    *	@skb: buffer to free
>    *
>
