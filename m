From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH net 1/3] net: validate variable length ll headers
Date: Sat, 05 Mar 2016 10:22:16 +0100
Message-ID: <56DAA548.9040303@bfs.de>
References: <1457124257-31486-1-git-send-email-willemdebruijn.kernel@gmail.com> <1457124257-31486-2-git-send-email-willemdebruijn.kernel@gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, alan@linux.intel.com,
	hessu@hes.iki.fi, martin.blumenstingl@googlemail.com,
	linux-hams@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1457124257-31486-2-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 04.03.2016 21:44, schrieb Willem de Bruijn:
> From: Willem de Bruijn <willemb@google.com>
> 
> Netdevice parameter hard_header_len is variously interpreted both as
> an upper and lower bound on link layer header length. The field is
> used as upper bound when reserving room at allocation, as lower bound
> when validating user input in PF_PACKET.
> 
> Clarify the definition to be maximum header length. For validation
> of untrusted headers, add an optional validate member to header_ops.
> 
> Allow bypassing of validation by passing CAP_SYS_RAWIO, for instance
> for deliberate testing of corrupt input. In this case, pad trailing
> bytes, as some device drivers expect completely initialized headers.
> 
> See also http://comments.gmane.org/gmane.linux.network/401064
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/linux/netdevice.h | 22 ++++++++++++++++++++--
>  1 file changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5440b7b..6d1d8f4 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -267,6 +267,7 @@ struct header_ops {
>  	void	(*cache_update)(struct hh_cache *hh,
>  				const struct net_device *dev,
>  				const unsigned char *haddr);
> +	bool	(*validate)(const char *ll_header, unsigned int len);
>  };
>  
>  /* These flag bits are private to the generic network queueing
> @@ -1420,8 +1421,7 @@ enum netdev_priv_flags {
>   *	@dma:		DMA channel
>   *	@mtu:		Interface MTU value
>   *	@type:		Interface hardware type
> - *	@hard_header_len: Hardware header length, which means that this is the
> - *			  minimum size of a packet.
> + *	@hard_header_len: Maximum hardware header length.
>   *
>   *	@needed_headroom: Extra headroom the hardware may need, but not in all
>   *			  cases can this be guaranteed
> @@ -2627,6 +2627,24 @@ static inline int dev_parse_header(const struct sk_buff *skb,
>  	return dev->header_ops->parse(skb, haddr);
>  }
>  
> +/* ll_header must have at least hard_header_len allocated */
> +static inline bool dev_validate_header(const struct net_device *dev,
> +				       char *ll_header, int len)
> +{
> +	if (likely(len >= dev->hard_header_len))
> +		return true;
> +
> +	if (capable(CAP_SYS_RAWIO)) {
> +		memset(ll_header + len, 0, dev->hard_header_len - len);
> +		return true;
> +	}
> +
> +	if (dev->header_ops && dev->header_ops->validate)
> +		return dev->header_ops->validate(ll_header, len);
> +
> +	return false;
> +}
> +


you could use

real_len=dev->hard_header_len-len;

if (real_len < 0)
...
if (capable(CAP_SYS_RAWIO))
	memset(ll_header + len, 0,real_len);
..

IMHO that makes the code more clear.

re,
 wh



>  typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
>  int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
>  static inline int unregister_gifconf(unsigned int family)
