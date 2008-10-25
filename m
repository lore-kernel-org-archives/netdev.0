From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Fri, 24 Oct 2008 18:41:45 -0700
Message-ID: <1224898906.6636.74.camel@localhost>
References: <1224892008.3919.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2376 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbYJYBm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 21:42:28 -0400
In-Reply-To: <1224892008.3919.27.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-25 at 01:46 +0200, Johannes Berg wrote:
> This adds a new printf format specifier for the kernel, %pM,
> to be used to print out MAC addresses. This has advantages
> over the current print_mac scheme:
>  * no need for DECLARE_MAC_BUF
>  * can be used safely in statements that might be compiled
>    out without the print_mac call staying.

Good things.

> --- everything.orig/lib/vsprintf.c	2008-10-25 01:21:54.000000000 +0200
> +++ everything/lib/vsprintf.c	2008-10-25 01:24:15.000000000 +0200
> @@ -581,6 +581,22 @@ static char *resource_string(char *buf, 
>  	return string(buf, end, sym, field_width, precision, flags);
>  }
>  
> +static char *mac_address(char *buf, char *end, u8 *addr, int field_width, int precision, int flags)
> +{
> +	/* room for 6 * two hex digits, 5 colons and trailing zero */
> +	char mac[18];
> +	char *p = mac, *pend = mac + sizeof(mac);
> +	int i;
> +
> +	for (i=0; i < 6; i++) {
> +		p = number(p, pend, addr[i], 16, 2, -1, SMALL | ZEROPAD);
> +		*p++ = ':';
> +	}

For consistency, shouldn't the function name be mac_address_string?

I (and perhaps Harvey H) would be happier with:

	char mac[18];
	char *p = mac;
	int i;

	for (i = 0; i < 5; i++) {
		p = pack_hex_byte(p, addr[i]);
		*p++ = ':';
	}
	p = pack_hex_byte(p, addr[5]);
	*p = '\0';

Smaller, faster, etc...

Also, as the number of %p(foo) types increases, perhaps
something like sparse could validate the printf argument
types?

cheers, Joe

