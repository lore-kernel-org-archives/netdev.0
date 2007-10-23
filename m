From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 17:35:45 -0700 (PDT)
Message-ID: <20071022.173545.74561992.davem@davemloft.net>
References: <1193081779.5132.24.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750715AbXJWAfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 20:35:24 -0400
In-Reply-To: <1193081779.5132.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Oct 2007 12:36:19 -0700

> It's a bit after 2.6.1 now...
> 
> Removes unnecessary if, uses 16 bit rotate left.
> Performance improves ~30%
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I'm not sure your transformation is equivalent.  Did you
actually test this with appletalk traffic to make sure
the sum is computed correctly?  Or more simply, did you
write a test program to send some test data through the
old and new functions?

Here is what I think the problem is:

>  static unsigned long atalk_sum_partial(const unsigned char *data,
>  				       int len, unsigned long sum)
>  {
> -	/* This ought to be unwrapped neatly. I'll trust gcc for now */
>  	while (len--) {
> -		sum += *data;
> -		sum <<= 1;
> -		if (sum & 0x10000) {
> -			sum++;
> -			sum &= 0xffff;
> -		}
> -		data++;
> +		sum += *data++;
> +		sum = ((sum & 0x8000)>>15) | ((sum & 0x7fff)<<1);
>  	}
>  	return sum;
>  }

The old code is handling overflow, so that when bit 16 gets set by and
addition, that overflow bit gets cleared and then added back into the
sum.

Your code is rotating bit 15 down by one bit and bits 0-14 up by one
bit, my remedial math knowledge tell me that's likely not the same
thing. :-)
