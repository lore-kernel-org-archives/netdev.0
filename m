From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] etherdevice: Optimize
 compare_ether_addr/ether_addr_equal
Date: Sat, 31 Aug 2013 09:43:08 -0700
Message-ID: <20130831094308.5a629f5a@nehalam.linuxnetplumber.net>
References: <1377939256.2054.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:54428 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab3HaQnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 12:43:11 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so3083659pdi.19
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 09:43:11 -0700 (PDT)
In-Reply-To: <1377939256.2054.11.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Aug 2013 01:54:16 -0700
Joe Perches <joe@perches.com> wrote:

> When CONFIG_HAS_EFFICIENT_UNALIGNED_ACCESS is set,
> optimize compare_ether_addr a little by removing an
> xor and or by using a u32 and u16 comparison
> instead of 3 separate u16 comparisons.
> 
> Make the ether_addr_equal_64bits code a bit simpler
> by adding a test for CONFIG_64BIT and calling
> ether_addr_equal otherwise.
> 
> This also slightly improves ether_addr_equal_64bits
> by removing the zap_last_2bytes shifts in the !64bit
> case.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/linux/etherdevice.h | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index c623861..2514d17 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -208,11 +208,19 @@ static inline void eth_hw_addr_random(struct net_device *dev)
>   */
>  static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
>  {
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> +	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2));
> +	fold |= ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
> +
> +	BUILD_BUG_ON(ETH_ALEN != 6);
> +	return fold != 0;
> +#else
>  	const u16 *a = (const u16 *) addr1;
>  	const u16 *b = (const u16 *) addr2;
>  
>  	BUILD_BUG_ON(ETH_ALEN != 6);
>  	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
> +#endif
>  }
>  

If you really want to be efficient do it as one 64 bit mask and compare.
