From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH V2] lib/vsprintf.c: Add struct sockaddr * "%pN<foo>" output
Date: Wed, 19 Aug 2009 18:20:42 -0400
Message-ID: <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com>
References: <1250230925.6641.92.camel@fnki-nb00130> <20090814.001519.40499255.davem@davemloft.net> <1250237739.16632.12.camel@fnki-nb00130> <20090814.131218.139318801.davem@davemloft.net> <1250349894.4620.5.camel@Joe-Laptop.home> <1250395818.4625.15.camel@Joe-Laptop.home> <2D3306C4-4DF4-4E3E-BBC2-2032058FA673@oracle.com> <1250714657.3407.77.camel@Joe-Laptop.home>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jens@mcbone.net, brian.haley@hp.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39220 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbZHSWVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 18:21:23 -0400
In-Reply-To: <1250714657.3407.77.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 19, 2009, at 4:44 PM, Joe Perches wrote:
> On Wed, 2009-08-19 at 10:26 -0400, Chuck Lever wrote:
>> On Aug 16, 2009, at 12:10 AM, Joe Perches wrote:
>
>> I think having at least a generic socket address formatter would be
>> very helpful.  The kernel RPC code can use that immediately for
>> generating debugging messages, generating "universal
>> addresses" (patches already accepted for 2.6.32) and for generating
>> presentation addresses to pass to user space (lockd does this now).
>
>>> Use style:
>>> * - 'N' For network socket (sockaddr) pointers
>>> *       if sa_family is IPv4, output is %pI4; if IPv6, output is  
>>> %pI6c
>>> *       May be used with any combination of additional specifiers
>>> below
>>> *       'p' decimal socket port number for IPv[46]: ":12345"
>>> *       'f' decimal flowinfo for IPv6: "/123456789"
>>> *       's' decimal scope_id number for IPv6: "%1234567890"
>>> *       so %pNp will print if IPv4 "1.2.3.4:1234", if IPv6:
>>> "1::c0a8:a:1234"
>>>
>>> I think using ":" as the separator for the port number, while  
>>> common,
>>> and already frequently used in kernel source (see bullet 2 in):
>>> http://www.ietf.org/id/draft-kawamura-ipv6-text- 
>>> representation-03.txt
>>> "Section 6: Notes on Combining IPv6 Addresses with Port Numbers".
>>> is not good for readability.
>>>
>>> Perhaps this style should be changed to the "[ipv6]:port" described
>>> in the draft above.
>>
>> I agree that the port number convention is tricky, and some kernel
>> areas handle it differently than others. Perhaps having a separate
>> family-agnostic formatter for printing the port number (or scope ID,
>> etc.) might allow greatest flexibility.
>
> I'm not too sure there's much value in ever more formatters for
> relatively simple things or in printing something like port or
> scope without the ip address.
>
> %hu ntohs(sa6->sin6_port)
> or
> %d or 0x%x ntohl(sa6->sin6_flowinfo)
>
> seem pretty straightforward to me.

It's the same issue for port numbers as it is for addresses: though  
the port field is the same size in each, it's at different offsets in  
AF_INET and AF_INET6 addresses, so extra logic is still needed to sort  
that at each call site.

As an example, an rpcbind query cares about the port number result,  
but usually not the address.  A human-readable message could show the  
returned port number, but leave out the address.  Without a separate  
formatter, you would still need extra logic around each debugging  
message (for example) to choose how to print the port number.

You could probably argue, though, that this is a less common need than  
printing addresses.

>> The RPC code, for example, displays port numbers in decimal and in
>> "hi.lo" format (the high byte is printed in decimal, then the low  
>> byte
>> is printed in decimal.  The two values are separated by a dot.  For
>> example, port 2049 is displayed as "8.1").
>
> Here's another tentative patch that does both using square
> brackets around IPv6 addresses with a port number and
> allows selection of the port number style ":dddd" or ":hi.lo"

The "hi.lo" form is always separated from the address by a dot, not by  
a colon, and square brackets are never used in that case.  The hi.lo  
format is probably enough of a special case that a separate specifier  
for that one is unnecessary.  Having a hexadecimal port number option  
might be more useful.  The hexadecimal form is also used by the  
kernel's RPC implementation, fwiw.

> It also adds a "pI6n" form for IPv6 addresses with 7 colons
> and no leading 0's.

What would the 7 colons form be used for?

> lib/vsprintf.c: Add '%pN' print formatted struct sock_addr *
>
> Use styles:
> * - 'N' For network socket (sockaddr) pointers
> *       if sa_family is IPv4, output is %pI4; if IPv6, output is %pI6c
> *       May be used with any combination of additional specifiers  
> below
> *       'p' decimal socket port number for IPv[46]: ":12345"
> *       'P' decimal socket port number for IPv6: ":1.255" (hi.lo)
> *           if IPv6 and port number is selected, square brackets
> *           will surround the IPv6 address for 'p' and 'P'
> *       'f' decimal flowinfo for IPv6: "/123456789"
> *       's' decimal scope_id number for IPv6: "%1234567890"
> *       %pNp will print IPv4: "1.2.3.4:1234"
> *                       IPv6: "[1::c0a8:a]:1234"
> *       %pNP will print IPv4: "1.2.3.4:1.255
> *                       IPv6: "[1::c0a8:a]:1.255"
>
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index cb8a112..139f310 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -647,22 +647,73 @@ static char *mac_address_string(char *buf,  
> char *end, u8 *addr,
> 	return string(buf, end, mac_addr, spec);
> }
>
> -static char *ip4_string(char *p, const u8 *addr, bool leading_zeros)
> +static char *u8_to_dec(char *p, u8 val, bool leadingzeros)
> +{
> +	char temp[3];			/* holds val in reverse order */
> +	int digits = put_dec_trunc(temp, val) - temp;
> +
> +	if (leadingzeros) {
> +		if (digits < 3)
> +			*p++ = '0';
> +		if (digits < 2)
> +			*p++ = '0';
> +	}
> +	/* reverse the digits */
> +	while (digits--)
> +		*p++ = temp[digits];
> +
> +	return p;
> +}
> +
> +static char *u16_to_hex(char *p, u16 word, bool leadingzeros)
> +{
> +	u8 hi = word >> 8;
> +	u8 lo = word & 0xff;
> +	if (leadingzeros) {
> +		p = pack_hex_byte(p, hi);
> +		p = pack_hex_byte(p, lo);
> +	} else {
> +		if (hi) {
> +			if (hi > 0x0f)
> +				p = pack_hex_byte(p, hi);
> +			else
> +				*p++ = hex_asc_lo(hi);
> +		}
> +		if (hi || lo > 0x0f)
> +			p = pack_hex_byte(p, lo);
> +		else
> +			*p++ = hex_asc_lo(lo);
> +	}
> +
> +	return p;
> +}
> +
> +static char *u32_dec_val(char *p, u32 val)
> +{
> +	char temp[9];			/* holds val in reverse order */
> +	int digits;
> +	char *pos;
> +
> +	if (val < 100000)
> +		pos = put_dec_trunc(temp, val);
> +	else {
> +		pos = put_dec_trunc(temp, val % 100000);
> +		pos = put_dec_trunc(pos, val / 100000);
> +	}
> +	digits = pos - temp;
> +	/* reverse the digits */
> +	while (digits--)
> +		*p++ = temp[digits];
> +
> +	return p;
> +}
> +
> +static char *ip4_string(char *p, const u8 *addr, bool leadingzeros)
> {
> 	int i;
>
> 	for (i = 0; i < 4; i++) {
> -		char temp[3];	/* hold each IP quad in reverse order */
> -		int digits = put_dec_trunc(temp, addr[i]) - temp;
> -		if (leading_zeros) {
> -			if (digits < 3)
> -				*p++ = '0';
> -			if (digits < 2)
> -				*p++ = '0';
> -		}
> -		/* reverse the digits in the quad */
> -		while (digits--)
> -			*p++ = temp[digits];
> +		p = u8_to_dec(p, addr[i], leadingzeros);
> 		if (i < 3)
> 			*p++ = '.';
> 	}
> @@ -679,9 +730,6 @@ static char *ip6_compressed_string(char *p,  
> const struct in6_addr *addr)
> 	unsigned char zerolength[8];
> 	int longest = 1;
> 	int colonpos = -1;
> -	u16 word;
> -	u8 hi;
> -	u8 lo;
> 	bool needcolon = false;
> 	bool useIPv4 = ipv6_addr_v4mapped(addr) || ipv6_addr_is_isatap(addr);
>
> @@ -721,20 +769,7 @@ static char *ip6_compressed_string(char *p,  
> const struct in6_addr *addr)
> 			*p++ = ':';
> 			needcolon = false;
> 		}
> -		/* hex u16 without leading 0s */
> -		word = ntohs(addr->s6_addr16[i]);
> -		hi = word >> 8;
> -		lo = word & 0xff;
> -		if (hi) {
> -			if (hi > 0x0f)
> -				p = pack_hex_byte(p, hi);
> -			else
> -				*p++ = hex_asc_lo(hi);
> -		}
> -		if (hi || lo > 0x0f)
> -			p = pack_hex_byte(p, lo);
> -		else
> -			*p++ = hex_asc_lo(lo);
> +		p = u16_to_hex(p, ntohs(addr->s6_addr16[i]), false);
> 		needcolon = true;
> 	}
>
> @@ -751,9 +786,10 @@ static char *ip6_compressed_string(char *p,  
> const struct in6_addr *addr)
> static char *ip6_string(char *p, const struct in6_addr *addr, const  
> char *fmt)
> {
> 	int i;
> +	bool leadingzeros = !(fmt[0] == 'I' && fmt[2] == 'n');
> +
> 	for (i = 0; i < 8; i++) {
> -		p = pack_hex_byte(p, addr->s6_addr[2 * i]);
> -		p = pack_hex_byte(p, addr->s6_addr[2 * i + 1]);
> +		p = u16_to_hex(p, ntohs(addr->s6_addr16[i]), leadingzeros);
> 		if (fmt[0] == 'I' && i != 7)
> 			*p++ = ':';
> 	}
> @@ -785,6 +821,102 @@ static char *ip4_addr_string(char *buf, char  
> *end, const u8 *addr,
> 	return string(buf, end, ip4_addr, spec);
> }
>
> +static char *port_string(char *p, u16 port, const char *fmt)
> +{
> +	if (*fmt == 'p')
> +		p = u32_dec_val(p, port);
> +	else {
> +		p = u8_to_dec(p, port >> 8, false);
> +		*p++ = '.';
> +		p = u8_to_dec(p, port & 0xff, false);
> +	}
> +
> +	return p;
> +}
> +
> +static char *socket_addr_string(char *buf, char *end,
> +				const struct sockaddr *sa,
> +				struct printf_spec spec, const char *fmt)
> +{
> +	char baddress[sizeof("[xxxx:xxxx:xxxx:xxxx:xxxx:xxxx: 
> 255.255.255.255]"
> +			     ":255.255"		/* port # or :12345 */
> +			     "%1234567890"	/* IPv6 scope id */
> +			     "/123456789")];	/* IPv6 flow mask */
> +	char *p;
> +	char *addr;
> +	struct sockaddr_in *sa4 = (struct sockaddr_in *)sa;
> +	struct sockaddr_in6 *sa6 = (struct sockaddr_in6 *)sa;
> +
> +	/* Start with a bracket in case the address is IPv6 with a port # */
> +	baddress[0] = '[';
> +	addr = &baddress[1];		/* address without leading '[' */
> +	p = addr;
> +
> +	switch (sa->sa_family) {
> +	case AF_INET:
> +		p = ip4_string(addr, (const u8 *)&sa4->sin_addr.s_addr, false);
> +		break;
> +	case AF_INET6:
> +		p = ip6_compressed_string(addr, &sa6->sin6_addr);
> +		break;
> +	default: {
> +		struct printf_spec num_spec = {
> +			.base = 16,
> +			.precision = -1,
> +			.field_width = 2 * sizeof(void *),
> +			.flags = SPECIAL | SMALL | ZEROPAD,
> +		};
> +		size_t msglen;
> +
> +		p = strcpy(baddress, "Bad socket address: ");
> +		msglen = strlen(p);
> +		p = number(p + msglen, p + sizeof(baddress) - msglen,
> +			   (unsigned long)sa, num_spec);
> +		break;
> +	}
> +	}
> +
> +	while (isalpha(*++fmt)) {
> +		switch (*fmt) {
> +		case 'p':
> +		case 'P':
> +			switch (sa->sa_family) {
> +			case AF_INET:
> +				*p++ = ':';
> +				p = port_string(p, ntohs(sa4->sin_port), fmt);
> +				break;
> +			case AF_INET6:
> +				/* Use the initial bracket */
> +				if (addr > baddress)
> +					addr--;
> +				*p++ = ']';
> +				*p++ = ':';
> +				p = port_string(p, ntohs(sa6->sin6_port), fmt);
> +				break;
> +			}
> +			break;
> +		case 's':
> +			switch (sa->sa_family) {
> +			case AF_INET6:
> +				*p++ = '%';
> +				p = u32_dec_val(p, sa6->sin6_scope_id);
> +			}
> +			break;
> +		case 'f':
> +			switch (sa->sa_family) {
> +			case AF_INET6:
> +				*p++ = '/';
> +				p = u32_dec_val(p, ntohl(sa6->sin6_flowinfo &
> +							 IPV6_FLOWINFO_MASK));
> +			}
> +			break;
> +		}
> +	}
> +
> +	*p = '\0';
> +	return string(buf, end, addr, spec);
> +}
> +
> /*
>  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
>  * by an extra set of alphanumeric characters that are extended format
> @@ -808,6 +940,15 @@ static char *ip4_addr_string(char *buf, char  
> *end, const u8 *addr,
>  *       IPv4 uses dot-separated decimal with leading 0's  
> (010.123.045.006)
>  * - 'I6c' for IPv6 addresses printed as specified by
>  *       http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
> + * - 'I6n' IPv6: colon separated network-order 16 bit hex without  
> leading 0's
> + * - 'N' For network socket (sockaddr) pointers
> + *       if sa_family is IPv4, output is %pI4; if IPv6, output is  
> %pI6c
> + *       May be used with any combination of additional specifiers  
> below
> + *       'p' decimal socket port number for IPv[46]: ":12345"
> + *       'P' decimal socket port numbers using hi/lo u8: ":0.255"
> + *       's' decimal scope_id number for IPv6: "%123456789"
> + *       'f' decimal flowinfo for IPv6: "/123456789"
> + *       so %pNp will print if IPv4 "1.2.3.4:1234", if IPv6:  
> "[1::c0a8:a]:1234"
>  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
>  * function pointers are really function descriptors, which contain a
>  * pointer to the real address.
> @@ -834,6 +975,7 @@ static char *pointer(const char *fmt, char *buf,  
> char *end, void *ptr,
> 					 * 4:	1.2.3.4
> 					 * 6:	0001:0203:...:0708
> 					 * 6c:	1::708 or 1::1.2.3.4
> +					 * 6n:  1:2:3:0:0:0:789:abcd
> 					 */
> 	case 'i':			/* Contiguous:
> 					 * 4:	001.002.003.004
> @@ -846,7 +988,10 @@ static char *pointer(const char *fmt, char  
> *buf, char *end, void *ptr,
> 			return ip4_addr_string(buf, end, ptr, spec, fmt);
> 		}
> 		break;
> +	case 'N':
> +		return socket_addr_string(buf, end, ptr, spec, fmt);
> 	}
> +
> 	spec.flags |= SMALL;
> 	if (spec.field_width == -1) {
> 		spec.field_width = 2*sizeof(void *);
>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



