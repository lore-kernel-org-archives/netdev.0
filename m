From: "Carlos O'Donell" <carlos@systemhalted.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 23:13:56 -0500
Message-ID: <CAE2sS1iaysD8m6vh9egssxAasdmUEhg5JikiBj-sgomOU2dMGA@mail.gmail.com>
References: <50F6B761.8070106@linux-ipv6.org>
	<1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
	<201301161205.04502.vapier@gentoo.org>
	<20130116.135744.697469565804508454.davem@davemloft.net>
	<50F75EA7.4060309@systemhalted.org>
	<50F76E87.6020606@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, vapier@gentoo.org,
	libc-alpha@sourceware.org, bhutchings@solarflare.com,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F76E87.6020606@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2013 10:22 PM, YOSHIFUJI Hideaki wrote:
> Carlos O'Donell wrote:
>> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
>> index f79c372..a2b16a5 100644
>> --- a/include/uapi/linux/in6.h
>> +++ b/include/uapi/linux/in6.h
>> @@ -23,6 +23,13 @@
>>
>>  #include <linux/types.h>
>>
>> +/* If a glibc-based userspace has already included in.h, then we will not
>> + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq. The
>> + * ABI used by the kernel and by glibc match exactly. Neither the kernel
>> + * nor glibc should break this ABI without coordination.
>> + */
>> +#ifndef _NETINET_IN_H
>> +
>>  /*
>>   *	IPv6 address structure
>>   */
>
> This should be
> #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)

Correct. If it's non-glibc we want these defines to be used
even if a non-glibc defined _NETINET_IN_H.

>> @@ -30,12 +37,20 @@
>>  struct in6_addr {
>>  	union {
>>  		__u8		u6_addr8[16];
>> +#if !defined(__GLIBC__) \
>> +    || (defined(__GLIBC__) && (defined(__USE_MISC) || defined(__USE_GNU))) \
>> +    || defined(__KERNEL__)
>>  		__be16		u6_addr16[8];
>>  		__be32		u6_addr32[4];
>> +#endif
>>  	} in6_u;
>> +#if !defined(__GLIBC__) \
>> +    || (defined(__GLIBC__) && (defined(__USE_MISC) || defined(__USE_GNU))) \
>> +    || defined(__KERNEL__)
>>  #define s6_addr			in6_u.u6_addr8
>>  #define s6_addr16		in6_u.u6_addr16
>>  #define s6_addr32		in6_u.u6_addr32
>> +#endif
>>  };
>
> 2nd "if" be after s6_addr?

Correct. We want to unconditinally define s6_addr in this case.

I've fixed both of those cases in the next version of the patch. Thanks.

Cheers,
Carlos.
