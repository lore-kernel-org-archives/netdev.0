From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] add compare_ether_addr_unaligned
Date: Thu, 22 Nov 2007 20:11:55 -0800
Message-ID: <20071122201155.24e13955@shemminger-laptop>
References: <20071123000922.C44009D4A1F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60674 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255AbXKWEMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 23:12:06 -0500
In-Reply-To: <20071123000922.C44009D4A1F@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Nov 2007 00:09:22 +0000 (GMT)
Daniel Drake <dsd@gentoo.org> wrote:

> David Miller found a problem in a wireless driver where I was using
> compare_ether_addr() on potentially unaligned data. Document that
> compare_ether_addr() is not safe for use everywhere, and add an equivalent
> function that works regardless of alignment.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 
> Index: linux-2.6.24-rc3-git1/include/linux/etherdevice.h
> ===================================================================
> --- linux-2.6.24-rc3-git1.orig/include/linux/etherdevice.h
> +++ linux-2.6.24-rc3-git1/include/linux/etherdevice.h
> @@ -123,11 +123,13 @@ static inline void random_ether_addr(u8 
>  }
>  
>  /**
> - * compare_ether_addr - Compare two Ethernet addresses
> + * compare_ether_addr - Compare two 16-bit-aligned Ethernet addresses
>   * @addr1: Pointer to a six-byte array containing the Ethernet address
>   * @addr2: Pointer other six-byte array containing the Ethernet address
>   *
> - * Compare two ethernet addresses, returns 0 if equal
> + * Compare two ethernet addresses, returns 0 if equal. Both addresses must
> + * be 16-bit aligned. For unaligned or potentially unaligned address
> + * comparisons, use compare_ether_addr_unaligned() instead.
>   */
>  static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
>  {
> @@ -137,6 +139,21 @@ static inline unsigned compare_ether_add
>  	BUILD_BUG_ON(ETH_ALEN != 6);
>  	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
>  }
> +
> +/**
> + * compare_ether_addr_unaligned - Compare two Ethernet addresses
> + * @addr1: Pointer to a six-byte array containing the Ethernet address
> + * @addr2: Pointer other six-byte array containing the Ethernet address
> + *
> + * Compare two ethernet addresses, returns 0 if equal. compare_ether_addr()
> + * is faster than this function, but unless you can ensure alignment you
> + * must use this function instead.
> + */
> +static inline unsigned compare_ether_addr_unaligned(const u8 *addr1,
> +						    const u8 *addr2)
> +{
> +	return memcmp(addr1, addr2, ETH_ALEN);
> +}
>  #endif	/* __KERNEL__ */


You could probably get the similar speedup by doing xor by byte, rather
than falling back to memcmp.
