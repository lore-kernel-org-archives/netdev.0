From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 11:14:01 -0400
Message-ID: <8B1EA60E-18F2-4D78-99DC-97B09A212A14@oracle.com>
References: <1250091560.6641.48.camel@fnki-nb00130> <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:49296 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbZHMPOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 11:14:14 -0400
In-Reply-To: <1250174390.6641.89.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 13, 2009, at 10:39 AM, Jens Rosenboom wrote:
> On Wed, 2009-08-12 at 21:33 -0400, Brian Haley wrote:
>> Jens Rosenboom wrote:
>>> Currently the output looks like  
>>> 2001:0db8:0000:0000:0000:0000:0000:0001
>>> which might be compacted to 2001:db8::1. The code to do this could  
>>> be
>>> adapted from inet_ntop in glibc, which would add about 80 lines to
>>> lib/vsprintf.c. How do you guys value the tradeoff between more  
>>> readable
>>> logging and increased kernel size?
>>>
>>> This was already mentioned in
>>> http://kerneltrap.org/mailarchive/linux-netdev/2008/11/25/4231684  
>>> but
>>> noone seems to have taken up on it.
>>
>> I think if any changes are made they should try and follow:
>>
>> http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
>>
>> For one thing, the code today doesn't print things like the v4-mapped
>> address correctly.
>>
>> Anyways, can you try this patch, it's less than 40 new lines :)
>> It might be good enough, but could probably use some help.
>
> For a start, it didn't even compile. ;-) Here is a new version that  
> also
> fixes
>
> - Leave %pi6 alone
> - Don't compress a single :0:
> - Do output 0
>
> The results and also the remaining issues can be seen with the  
> attached
> test program, that also exposes a bug in glibc for v4-mapped addresses
> from 0/16.
>
> To fully conform to the cited draft, we would still have to implement
> v4-mapped and also check whether a second run of zeros would be longer
> than the first one, although the draft also suggests that operators
> should avoid using this kind of addresses, so maybe this second issue
> can be neglected.

If it is at all helpful, I recently proposed adding rpc_ntop() to  
sunrpc.ko to provide proper IPv6 shorthanding without changing %p[iI]6  
at all.  The patch was rejected, but there may be something here you  
can use.  The version of rpc_ntop() accepted for 2.6.32 does not  
provide shorthanding.

See the archived mail at http://www.spinics.net/lists/linux-nfs/msg08363.html

If you get proper IPv6 shorthanding into the kernel, RPC is one more  
consumer for you.

> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 756ccaf..5710c65 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -652,13 +652,53 @@ static char *ip6_addr_string(char *buf, char  
> *end,
> u8 *addr,
> {
> 	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing
> zero */
> 	char *p = ip6_addr;
> -	int i;
> +	int i, needcolon = 0, printhi;
> +	u16 *addr16 = (u16 *)addr;
> +	enum { DC_START, DC_MIDDLE, DC_DONE } colon = DC_START;
> +
> +	/* omit leading zeros and shorten using "::" */
>
> -	for (i = 0; i < 8; i++) {
> -		p = pack_hex_byte(p, addr[2 * i]);
> -		p = pack_hex_byte(p, addr[2 * i + 1]);
> -		if (!(spec.flags & SPECIAL) && i != 7)
> +	if (!(spec.flags & SPECIAL)) {
> +		for (i = 0; i < 8; i++) {
> +			if (addr16[i] == 0 && addr16[i+1] == 0 && colon == DC_START) {
> +				colon = DC_MIDDLE;
> +				continue;
> +			}
> +			if (colon == DC_MIDDLE) {
> +				if (addr16[i] == 0)
> +					continue;
> +				colon = DC_DONE;
> +				*p++ = ':';
> +				*p++ = ':';
> +			}  else if (needcolon)
> +				*p++ = ':';
> +			printhi = 0;
> +			if (addr[2 * i]) {
> +				if (addr[2 * i] > 0x0f)
> +					p = pack_hex_byte(p, addr[2 * i]);
> +				else
> +					*p++ = hex_asc_lo(addr[2 * i]);
> +				printhi++;
> +			}
> +			/*
> +		 	* If we printed the high-order bits we must print the
> +		 	* low-order ones, even if they're all zeros.
> +		 	*/
> +			if (printhi || addr[2 * i + 1] > 0x0f)
> +				p = pack_hex_byte(p, addr[2 * i + 1]);
> +			else
> +				*p++ = hex_asc_lo(addr[2 * i + 1]);
> +			needcolon++;
> +		}
> +		if (colon == DC_MIDDLE) {
> 			*p++ = ':';
> +			*p++ = ':';
> +		}
> +	} else {
> +		for (i = 0; i < 8; i++) {
> +			p = pack_hex_byte(p, addr[2 * i]);
> +			p = pack_hex_byte(p, addr[2 * i + 1]);
> +		}
> 	}
> 	*p = '\0';
> 	spec.flags &= ~SPECIAL;
>
> <test.c>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




