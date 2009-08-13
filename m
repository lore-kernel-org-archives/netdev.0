From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 16:24:09 -0400
Message-ID: <4A847669.7050508@hp.com>
References: <1250091560.6641.48.camel@fnki-nb00130>	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:38716 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755781AbZHMUYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:24:13 -0400
In-Reply-To: <1250187034.28285.93.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Thu, 2009-08-13 at 12:27 -0400, Brian Haley wrote:
>> Jens Rosenboom wrote:
>>> Here is a new version that also
>>> fixes
>>>
>>> - Leave %pi6 alone
>>> - Don't compress a single :0:
>>> - Do output 0
>>> The results and also the remaining issues can be seen with the attached
>>> test program, that also exposes a bug in glibc for v4-mapped addresses
>>> from 0/16.
>>> To fully conform to the cited draft, we would still have to implement
>>> v4-mapped and also check whether a second run of zeros would be longer
>>> than the first one, although the draft also suggests that operators
>>> should avoid using this kind of addresses, so maybe this second issue
>>> can be neglected.
>> Yes, the "compress the most zeros" would be harder, and require two
>> passes over the address.  I had to cut corners somewhere :)
> 
> 2 things.
> 
> First a question, then a compilable but untested patch.
> 
> The patch allows "%p6ic" for compressed and "%p6ic4" for compressed
> with ipv4 last u32.
> 
> Can somebody tell me what I'm doing wrong when I link Jens' test?
> 
> cc -o test test_ipv6.c lib/vsprintf.o lib/ctype.o
> lib/vsprintf.o: In function `global constructors keyed to
> 65535_0_simple_strtoul':
> /home/joe/linux/linux-2.6/lib/vsprintf.c:1972: undefined reference to
> `__gcov_init'
> lib/vsprintf.o:(.data+0x28): undefined reference to `__gcov_merge_add'
> collect2: ld returned 1 exit status

Is your arch "um"?  Seems like those are only defined there, I'm building
a straight x86 kernel.

> Now for the patch.  Perhaps something like this (compiled, untested)

This core dumps when running "test", I'm still trying to track down why.

I think we're thinking too hard about this, I would think we'd always
want to print the shortened IPv6 address in debugging messages with %pI6.
The %pi6 places need to stay since they're an API to userspace.  I don't
think we need the extra "c" and "c4" support.

One comment on a quick scan of the code:

>  static char *ip6_addr_string(char *buf, char *end, u8 *addr,
> -				struct printf_spec spec)
> +			     struct printf_spec spec, const char *fmt)
>  {
> -	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
> +	char ip6_addr[7 * 4 + 7 + 4 * 4]; /* (7 * 4 hex digits) + 7 colons +
> +					   * ipv4 address, and trailing zero */

ip6_addr[8 * 5] is fine here, we won't ever have all eight plus an IPv4 address.

-Brian
