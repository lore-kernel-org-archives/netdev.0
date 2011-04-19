From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2.6.36 1/1] IPv6: Create temp address based on
 advertised network prefix
Date: Tue, 19 Apr 2011 06:01:12 +0100
Message-ID: <1303189272.3464.51.camel@localhost>
References: <201104182124.18866.glenn@wurster.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbarrera@scs.carleton.ca
To: Glenn Wurster <glenn@wurster.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13041 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab1DSFBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:01:22 -0400
In-Reply-To: <201104182124.18866.glenn@wurster.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-18 at 21:24 -0400, Glenn Wurster wrote:
> As discussed ;Login: Volume 36, number 1,

Either provide a non-paywalled reference or a *much* fuller explanation
in the commit message.

> create a temporary address
> by hashing a random value along with the advertised network
> prefix.  This results on the temporary address changing whenever
> the network prefix changes (i.e., the host changes networks), or
> whenever the random value (which can be set by a user-space
> application with sufficient privilege) changes.
> 
> Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>
> ---
>  Documentation/networking/ip-sysctl.txt |   20 ++++-
>  include/linux/ipv6.h                   |    4 +
>  include/net/if_inet6.h                 |    3 +
>  net/ipv6/Kconfig                       |   22 +++++
>  net/ipv6/addrconf.c                    |  159 
> +++++++++++++++++++++++++-------
>  5 files changed, 175 insertions(+), 33 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt 
> b/Documentation/networking/ip-sysctl.txt
> index f350c69..b366c28 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1128,11 +1128,18 @@ router_solicitations - INTEGER
>  
>  use_tempaddr - INTEGER
>  	Preference for Privacy Extensions (RFC3041).
> +    Bits 0 and 1:
>  	  <= 0 : disable Privacy Extensions
>  	  == 1 : enable Privacy Extensions, but prefer public
>  	         addresses over temporary addresses.
> -	  >  1 : enable Privacy Extensions and prefer temporary
> +	  >= 2 : enable Privacy Extensions and prefer temporary
>  	         addresses over public addresses.
> +    Bit 2:
> +	  == 0 : Use RFC3041 random algorithm for generating
> +             temporary addresses.
> +	  == 1 : Use the output of a hash based on the network prefix
> +	         and random number from temp_random.
> +
>  	Default:  0 (for most devices)
>  		 -1 (for point-to-point devices and loopback devices)

This is pretty awful already, for a sysctl whose name suggests a
boolean.  I think you should add another boolean rather than compounding
it.

> @@ -1144,6 +1151,17 @@ temp_prefered_lft - INTEGER
>  	Preferred lifetime (in seconds) for temporary addresses.
>  	Default: 86400 (1 day)
>  
> +temp_random - INTEGER[4]
> +    Random number used as input to the hash function when
> +	generating temporary addresses also based on the network
> +    prefix.

What's with the
    random
indentation?

> +	 == 0 : Generate a new random value when a temporary address
> +	        is created.  This random value replaces the 0 in
> +			temp_random	
> +      > 0 : A random number used as input to the hash
> +
> +	Default:  0

We have a fairly good random number generator in the kernel; I'm not
sure this setting is really necessary.  We don't do that for e.g. TCP
sequence number generation.

>  max_desync_factor - INTEGER
>  	Maximum value for DESYNC_FACTOR, which is a random value
>  	that ensures that clients don't synchronize with each
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index e62683b..b9bd404 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -172,6 +172,9 @@ struct ipv6_devconf {
>  	__s32		disable_ipv6;
>  	__s32		accept_dad;
>  	__s32		force_tllao;
> +#ifdef CONFIG_IPV6_PRIVACY_HASH
> +	__u32		temp_random[4];
> +#endif
>  	void		*sysctl;
>  };
>  
> @@ -213,6 +216,7 @@ enum {
>  	DEVCONF_DISABLE_IPV6,
>  	DEVCONF_ACCEPT_DAD,
>  	DEVCONF_FORCE_TLLAO,
> +	DEVCONF_TEMP_RANDOM,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index f95ff8d..99428bf 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -183,6 +183,9 @@ struct inet6_dev {
>  
>  #ifdef CONFIG_IPV6_PRIVACY
>  	u8			rndid[8];
> +#ifdef CONFIG_IPV6_PRIVACY_HASH
> +	__u32       rndid_inc;
> +#endif
>  	struct timer_list	regen_timer;
>  	struct list_head	tempaddr_list;
>  #endif
> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
> index 36d7437..c0bc79a 100644
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -39,6 +39,28 @@ config IPV6_PRIVACY
>  
>  	  See <file:Documentation/networking/ip-sysctl.txt> for details.
>  
> +if IPV6_PRIVACY
> +
> +config IPV6_PRIVACY_HASH
> +	bool "IPv6: Privacy Extension Hash Support"
> +	select CRYPTO
> +	select CRYPTO_SHA256
> +	---help---
> +	  Generate the pseudo-random global-scope unicast address(es) based on
> +	  the output of hashing together the broadcast prefix with a random
> +	  value.  The algorithm is discussed in Volume 36, Number 1 of the USENIX
> +	  ;Login: publication.
> +
> +	  To use hash-based temorary addresses, do
> +
> +	         echo 6 >/proc/sys/net/ipv6/conf/all/use_tempaddr
> +
> +	  To modify the input to the hash, do
> +
> +	         echo <random> >/proc/sys/net/ipv6/conf/all/temp_random
> +
> +endif # if IPV6_PRIVACY
> +
>  config IPV6_ROUTER_PREF
>  	bool "IPv6: Router Preference (RFC 4191) support"
>  	---help---
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 89bcb62..4a2eaca 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -118,6 +118,7 @@ static inline void addrconf_sysctl_unregister(struct 
> inet6_dev *idev)
>  #endif
>  
>  #ifdef CONFIG_IPV6_PRIVACY
> +static int __ipv6_is_invalid_rndid(const __u8 * rndid);
>  static int __ipv6_regen_rndid(struct inet6_dev *idev);
>  static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr 
> *tmpaddr);
>  static void ipv6_regen_rndid(unsigned long data);
> @@ -177,6 +178,9 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
>  	.regen_max_retry	= REGEN_MAX_RETRY,
>  	.max_desync_factor	= MAX_DESYNC_FACTOR,
> +#ifdef CONFIG_IPV6_PRIVACY_HASH
> +	.temp_random		= { 0, 0, 0, 0 },
> +#endif
>  #endif
>  	.max_addresses		= IPV6_MAX_ADDRESSES,
>  	.accept_ra_defrtr	= 1,
> @@ -211,6 +215,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly 
> = {

Your mail client is misconfigured; it wrapped the line above and many
others,

>  	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
>  	.regen_max_retry	= REGEN_MAX_RETRY,
>  	.max_desync_factor	= MAX_DESYNC_FACTOR,
> +#ifdef CONFIG_IPV6_PRIVACY_HASH
> +	.temp_random		= { 0, 0, 0, 0 },
> +#endif
>  #endif
>  	.max_addresses		= IPV6_MAX_ADDRESSES,
>  	.accept_ra_defrtr	= 1,
> @@ -849,6 +856,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, 
> struct inet6_ifaddr *i
>  		memcpy(&addr.s6_addr[8], &ift->addr.s6_addr[8], 8);
>  		spin_unlock_bh(&ift->lock);
>  		tmpaddr = &addr;
> +		ift = NULL;
>  	} else {
>  		tmpaddr = NULL;
>  	}
> @@ -875,17 +883,71 @@ retry:
>  	}
>  	in6_ifa_hold(ifp);
>  	memcpy(addr.s6_addr, ifp->addr.s6_addr, 8);
> -	if (__ipv6_try_regen_rndid(idev, tmpaddr) < 0) {
> -		spin_unlock_bh(&ifp->lock);
> -		write_unlock(&idev->lock);
> -		printk(KERN_WARNING
> -			"ipv6_create_tempaddr(): regeneration of randomized 
> interface id failed.\n");
> -		in6_ifa_put(ifp);
> -		in6_dev_put(idev);
> -		ret = -1;
> -		goto out;
> +#ifdef CONFIG_IPV6_PRIVACY_HASH
> +	while (idev->cnf.use_tempaddr > 4) {

Given that you redefined this as a bitfield, you need to mask out bits
3-31.

> +		char hash[32];
> +		__u32 temp_random[4];
> +		int i;
> +
> +		struct hash_desc desc = { .tfm = NULL, .flags = 0 };
> +		struct scatterlist sg;
> +
> +		BUG_ON (sizeof(temp_random) != sizeof(idev->cnf.temp_random));

BUILD_BUG_ON, please.  And no space after the macro name.

> +		for (i = 0; unlikely(idev->cnf.temp_random[i] == 0) && i < 4; i++);

Last semi-colon goes on a separate line.

Run scripts/checkpatch.pl on your patch and fix the style errors it
points out.

> +		if (unlikely(i == 4))
> +			get_random_bytes(idev->cnf.temp_random, sizeof(idev-
> >cnf.temp_random));
> +
> +		desc.tfm = crypto_alloc_hash ("sha256", 0, CRYPTO_ALG_ASYNC);
> +		if (IS_ERR(desc.tfm)) {
> +			idev->cnf.use_tempaddr &= 0x03;
> +			printk (KERN_WARNING
> +					"ipv6_create_tempaddr(): Hash unavailable, 
> reverting use_tempaddr to %d.\n",
> +					idev->cnf.use_tempaddr);
> +			break;
> +		}
> +
> +		BUG_ON (crypto_hash_digestsize(desc.tfm) > sizeof(hash));
> +		BUG_ON (sizeof(idev->rndid) < 8);

Last of those can be a BUILD_BUG_ON.

> +		crypto_hash_init (&desc);
> +
> +		sg_init_one (&sg, (u8 *)addr.s6_addr, 8);
> +		crypto_hash_update (&desc, &sg, 8);
> +
> +		memcpy (temp_random, idev->cnf.temp_random, sizeof(temp_random));
> +		temp_random[3] += idev->rndid_inc;
> +		sg_init_one (&sg, (u8 *)temp_random, sizeof(temp_random));
> +		crypto_hash_update (&desc, &sg, sizeof(temp_random));
> +
> +		crypto_hash_final (&desc, hash);
> +		crypto_free_hash (desc.tfm);
> +
> +		memcpy (&addr.s6_addr[8], hash, 8);
> +		if (__ipv6_is_invalid_rndid(&addr.s6_addr[8])) {
> +			idev->rndid_inc++;
> +			continue;
> +		}
> +
> +		ift = ipv6_get_ifaddr (dev_net(idev->dev), &addr, idev->dev, 0);
> +		break;
> +	}
> +#else
> +	idev->cnf.use_tempaddr &= 0x03;

Broken when use_tempaddr < 0.

Also if use_tempaddr > 4 then this should warn that the alternate
algorithm is not actually being used.

> +#endif
> +	if (idev->cnf.use_tempaddr < 4) {

What if it's equal to 4?

> +		if (__ipv6_try_regen_rndid(idev, tmpaddr) < 0) {
> +			spin_unlock_bh(&ifp->lock);
> +			write_unlock(&idev->lock);
> +			printk(KERN_WARNING
> +				   "ipv6_create_tempaddr(): regeneration of randomized 
> interface id failed.\n");
> +			in6_ifa_put(ifp);
> +			in6_dev_put(idev);
> +			ret = -1;
> +			goto out;
> +		}
> +		memcpy(&addr.s6_addr[8], idev->rndid, 8);
>  	}
> -	memcpy(&addr.s6_addr[8], idev->rndid, 8);
>  	age = (jiffies - ifp->tstamp) / HZ;
>  	tmp_valid_lft = min_t(__u32,
>  			      ifp->valid_lft,
> @@ -922,11 +984,11 @@ retry:
>  	if (ifp->flags & IFA_F_OPTIMISTIC)
>  		addr_flags |= IFA_F_OPTIMISTIC;
>  
> -	ift = !max_addresses ||
> -	      ipv6_count_addresses(idev) < max_addresses ?
> -		ipv6_add_addr(idev, &addr, tmp_plen,
> -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
> -			      addr_flags) : NULL;
> +	if (!ift && (!max_addresses || ipv6_count_addresses(idev) < 
> max_addresses)) {
> +		ift = ipv6_add_addr(idev, &addr, tmp_plen,
> +		                    ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
> +		                    addr_flags);
> +	}
>  	if (!ift || IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);
> @@ -943,9 +1005,11 @@ retry:
>  	ift->prefered_lft = tmp_prefered_lft;
>  	ift->cstamp = tmp_cstamp;
>  	ift->tstamp = tmp_tstamp;
> +	ift->regen_count = 0;
>  	spin_unlock_bh(&ift->lock);
>  
> -	addrconf_dad_start(ift, 0);
> +	if (ift->flags & IFA_F_TENTATIVE)
> +		addrconf_dad_start(ift, 0);
>  	in6_ifa_put(ift);
>  	in6_dev_put(idev);
>  out:
> @@ -1090,7 +1154,7 @@ static int ipv6_get_saddr_eval(struct net *net,
>  		 */
>  		int preftmp = dst->prefs & (IPV6_PREFER_SRC_PUBLIC|
> IPV6_PREFER_SRC_TMP) ?
>  				!!(dst->prefs & IPV6_PREFER_SRC_TMP) :
> -				score->ifa->idev->cnf.use_tempaddr >= 2;
> +				!!(score->ifa->idev->cnf.use_tempaddr & 2);
[...]

Broken when use_tempaddr < 0.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

