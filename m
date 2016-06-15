From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [PATCHv3 net-next 07/12] addrconf: put prefix address add in an
 own function
Date: Wed, 15 Jun 2016 20:09:28 +0900
Message-ID: <57613768.3010303@miraclelinux.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-8-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160614115239.17788-8-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Alexander Aring wrote:
> This patch moves the functionality to add a RA PIO prefix generated
> address in an own function. This move prepares to add a hook for
> adding a second address for a second link-layer address. E.g. short
> address for 802.15.4 6LoWPAN.
> 
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>


Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>


> ---
>  net/ipv6/addrconf.c | 203 ++++++++++++++++++++++++++++------------------------
>  1 file changed, 109 insertions(+), 94 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index beaad49..0ca31e1 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2333,12 +2333,110 @@ static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
>  	       idev->addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
>  }
>  
> +static int addrconf_prefix_rcv_add_addr(struct net *net,
> +					struct net_device *dev,
> +					const struct prefix_info *pinfo,
> +					struct inet6_dev *in6_dev,
> +					const struct in6_addr *addr,
> +					int addr_type, u32 addr_flags,
> +					bool sllao, bool tokenized,
> +					__u32 valid_lft, u32 prefered_lft)
> +{
> +	struct inet6_ifaddr *ifp = ipv6_get_ifaddr(net, addr, dev, 1);
> +	int create = 0, update_lft = 0;
> +
> +	if (!ifp && valid_lft) {
> +		int max_addresses = in6_dev->cnf.max_addresses;
> +
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +		if (in6_dev->cnf.optimistic_dad &&
> +		    !net->ipv6.devconf_all->forwarding && sllao)
> +			addr_flags |= IFA_F_OPTIMISTIC;
> +#endif
> +
> +		/* Do not allow to create too much of autoconfigured
> +		 * addresses; this would be too easy way to crash kernel.
> +		 */
> +		if (!max_addresses ||
> +		    ipv6_count_addresses(in6_dev) < max_addresses)
> +			ifp = ipv6_add_addr(in6_dev, addr, NULL,
> +					    pinfo->prefix_len,
> +					    addr_type&IPV6_ADDR_SCOPE_MASK,
> +					    addr_flags, valid_lft,
> +					    prefered_lft);
> +
> +		if (IS_ERR_OR_NULL(ifp))
> +			return -1;
> +
> +		update_lft = 0;
> +		create = 1;
> +		spin_lock_bh(&ifp->lock);
> +		ifp->flags |= IFA_F_MANAGETEMPADDR;
> +		ifp->cstamp = jiffies;
> +		ifp->tokenized = tokenized;
> +		spin_unlock_bh(&ifp->lock);
> +		addrconf_dad_start(ifp);
> +	}
> +
> +	if (ifp) {
> +		u32 flags;
> +		unsigned long now;
> +		u32 stored_lft;
> +
> +		/* update lifetime (RFC2462 5.5.3 e) */
> +		spin_lock_bh(&ifp->lock);
> +		now = jiffies;
> +		if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
> +			stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
> +		else
> +			stored_lft = 0;
> +		if (!update_lft && !create && stored_lft) {
> +			const u32 minimum_lft = min_t(u32,
> +				stored_lft, MIN_VALID_LIFETIME);
> +			valid_lft = max(valid_lft, minimum_lft);
> +
> +			/* RFC4862 Section 5.5.3e:
> +			 * "Note that the preferred lifetime of the
> +			 *  corresponding address is always reset to
> +			 *  the Preferred Lifetime in the received
> +			 *  Prefix Information option, regardless of
> +			 *  whether the valid lifetime is also reset or
> +			 *  ignored."
> +			 *
> +			 * So we should always update prefered_lft here.
> +			 */
> +			update_lft = 1;
> +		}
> +
> +		if (update_lft) {
> +			ifp->valid_lft = valid_lft;
> +			ifp->prefered_lft = prefered_lft;
> +			ifp->tstamp = now;
> +			flags = ifp->flags;
> +			ifp->flags &= ~IFA_F_DEPRECATED;
> +			spin_unlock_bh(&ifp->lock);
> +
> +			if (!(flags&IFA_F_TENTATIVE))
> +				ipv6_ifa_notify(0, ifp);
> +		} else
> +			spin_unlock_bh(&ifp->lock);
> +
> +		manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
> +				 create, now);
> +
> +		in6_ifa_put(ifp);
> +		addrconf_verify();
> +	}
> +
> +	return 0;
> +}
> +
>  void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  {
>  	struct prefix_info *pinfo;
>  	__u32 valid_lft;
>  	__u32 prefered_lft;
> -	int addr_type;
> +	int addr_type, err;
>  	u32 addr_flags = 0;
>  	struct inet6_dev *in6_dev;
>  	struct net *net = dev_net(dev);
> @@ -2432,9 +2530,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  	/* Try to figure out our local address for this prefix */
>  
>  	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
> -		struct inet6_ifaddr *ifp;
>  		struct in6_addr addr;
> -		int create = 0, update_lft = 0;
>  		bool tokenized = false;
>  
>  		if (pinfo->prefix_len == 64) {
> @@ -2453,106 +2549,25 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  				goto ok;
>  			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
>  				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
> -				in6_dev_put(in6_dev);
> -				return;
> +				goto put;
>  			}
>  			goto ok;
>  		}
>  		net_dbg_ratelimited("IPv6 addrconf: prefix with wrong length %d\n",
>  				    pinfo->prefix_len);
> -		in6_dev_put(in6_dev);
> -		return;
> +		goto put;
>  
>  ok:
> -
> -		ifp = ipv6_get_ifaddr(net, &addr, dev, 1);
> -
> -		if (!ifp && valid_lft) {
> -			int max_addresses = in6_dev->cnf.max_addresses;
> -
> -#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> -			if (in6_dev->cnf.optimistic_dad &&
> -			    !net->ipv6.devconf_all->forwarding && sllao)
> -				addr_flags |= IFA_F_OPTIMISTIC;
> -#endif
> -
> -			/* Do not allow to create too much of autoconfigured
> -			 * addresses; this would be too easy way to crash kernel.
> -			 */
> -			if (!max_addresses ||
> -			    ipv6_count_addresses(in6_dev) < max_addresses)
> -				ifp = ipv6_add_addr(in6_dev, &addr, NULL,
> -						    pinfo->prefix_len,
> -						    addr_type&IPV6_ADDR_SCOPE_MASK,
> -						    addr_flags, valid_lft,
> -						    prefered_lft);
> -
> -			if (IS_ERR_OR_NULL(ifp)) {
> -				in6_dev_put(in6_dev);
> -				return;
> -			}
> -
> -			update_lft = 0;
> -			create = 1;
> -			spin_lock_bh(&ifp->lock);
> -			ifp->flags |= IFA_F_MANAGETEMPADDR;
> -			ifp->cstamp = jiffies;
> -			ifp->tokenized = tokenized;
> -			spin_unlock_bh(&ifp->lock);
> -			addrconf_dad_start(ifp);
> -		}
> -
> -		if (ifp) {
> -			u32 flags;
> -			unsigned long now;
> -			u32 stored_lft;
> -
> -			/* update lifetime (RFC2462 5.5.3 e) */
> -			spin_lock_bh(&ifp->lock);
> -			now = jiffies;
> -			if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
> -				stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
> -			else
> -				stored_lft = 0;
> -			if (!update_lft && !create && stored_lft) {
> -				const u32 minimum_lft = min_t(u32,
> -					stored_lft, MIN_VALID_LIFETIME);
> -				valid_lft = max(valid_lft, minimum_lft);
> -
> -				/* RFC4862 Section 5.5.3e:
> -				 * "Note that the preferred lifetime of the
> -				 *  corresponding address is always reset to
> -				 *  the Preferred Lifetime in the received
> -				 *  Prefix Information option, regardless of
> -				 *  whether the valid lifetime is also reset or
> -				 *  ignored."
> -				 *
> -				 * So we should always update prefered_lft here.
> -				 */
> -				update_lft = 1;
> -			}
> -
> -			if (update_lft) {
> -				ifp->valid_lft = valid_lft;
> -				ifp->prefered_lft = prefered_lft;
> -				ifp->tstamp = now;
> -				flags = ifp->flags;
> -				ifp->flags &= ~IFA_F_DEPRECATED;
> -				spin_unlock_bh(&ifp->lock);
> -
> -				if (!(flags&IFA_F_TENTATIVE))
> -					ipv6_ifa_notify(0, ifp);
> -			} else
> -				spin_unlock_bh(&ifp->lock);
> -
> -			manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
> -					 create, now);
> -
> -			in6_ifa_put(ifp);
> -			addrconf_verify();
> -		}
> +		err = addrconf_prefix_rcv_add_addr(net, dev, pinfo, in6_dev,
> +						   &addr, addr_type,
> +						   addr_flags, sllao,
> +						   tokenized, valid_lft,
> +						   prefered_lft);
> +		if (err)
> +			goto put;
>  	}
>  	inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
> +put:
>  	in6_dev_put(in6_dev);
>  }
>  
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION
