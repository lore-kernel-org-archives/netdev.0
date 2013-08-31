From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] etherdevice: Optimize compare_ether_addr/ether_addr_equal
Date: Sat, 31 Aug 2013 23:41:49 +0400
Message-ID: <522246FD.3080403@cogentembedded.com>
References: <1377939256.2054.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:62613 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659Ab3HaTlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 15:41:45 -0400
Received: by mail-lb0-f180.google.com with SMTP id q8so2766644lbi.25
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 12:41:44 -0700 (PDT)
In-Reply-To: <1377939256.2054.11.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/31/2013 12:54 PM, Joe Perches wrote:

> When CONFIG_HAS_EFFICIENT_UNALIGNED_ACCESS is set,
> optimize compare_ether_addr a little by removing an
> xor and or by using a u32 and u16 comparison
> instead of 3 separate u16 comparisons.

> Make the ether_addr_equal_64bits code a bit simpler
> by adding a test for CONFIG_64BIT and calling
> ether_addr_equal otherwise.

> This also slightly improves ether_addr_equal_64bits
> by removing the zap_last_2bytes shifts in the !64bit
> case.

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>   include/linux/etherdevice.h | 17 ++++++++++-------
>   1 file changed, 10 insertions(+), 7 deletions(-)

> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index c623861..2514d17 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -208,11 +208,19 @@ static inline void eth_hw_addr_random(struct net_device *dev)
>    */
>   static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
>   {
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> +	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2));

    Could you keep the same style as before and insert empty line after 
declaration?

> +	fold |= ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
> +
> +	BUILD_BUG_ON(ETH_ALEN != 6);
> +	return fold != 0;
> +#else
>   	const u16 *a = (const u16 *) addr1;
>   	const u16 *b = (const u16 *) addr2;
>
>   	BUILD_BUG_ON(ETH_ALEN != 6);
>   	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
> +#endif
>   }
>
>   /**

WBR, Sergei
