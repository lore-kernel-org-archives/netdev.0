From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Thu, 31 Jul 2014 22:28:04 -0700 (PDT)
Message-ID: <20140731.222804.1403723639172562683.davem@davemloft.net>
References: <1406837476-13776-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHAF2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:28:05 -0400
In-Reply-To: <1406837476-13776-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 31 Jul 2014 22:11:16 +0200

> -		for (j = 0; j < sizeof(u32); j++) {
> -			p[i + j] = random;
> -			random >>= BITS_PER_BYTE;
> -		}
> +	while (bytes > sizeof(u32)) {
> +		put_unaligned(prandom_u32_state(state), (u32 *) ptr);
> +		ptr += sizeof(u32);
> +		bytes -= sizeof(u32);
>  	}
> -	if (i < bytes) {
> -		u32 random = prandom_u32_state(state);
>  
> -		for (; i < bytes; i++) {
> -			p[i] = random;
> -			random >>= BITS_PER_BYTE;
> -		}
> +	if (bytes > 0) {
> +		u32 rem = prandom_u32_state(state);
> +		do {
> +			*ptr++ = (u8) rem;
> +			bytes--;
> +			rem >>= BITS_PER_BYTE;
> +		} while (bytes > 0);
>  	}

This conversion to put_unaligned() is not an equivalent depending
upon the endianness of the cpu.

And this means the random value gets distributed differently into
full words than it will into trailing bytes.

Let's just not mess around with this, ok?

Thanks.
