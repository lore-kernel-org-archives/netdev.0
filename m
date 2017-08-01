From: Florian Lehner <dev@der-flo.net>
Subject: Re: [PATCH v3] ss: Enclose IPv6 address in brackets
Date: Tue, 1 Aug 2017 18:07:57 +0200
Message-ID: <8e1c5122-39ea-9e26-4fa2-8a6706d6015e@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
 <17aba498-3d75-2659-5fdc-4c95b0d214fa@der-flo.net>
 <20170801141112.GZ16375@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:45927 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751794AbdHAQIA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:08:00 -0400
In-Reply-To: <20170801141112.GZ16375@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/01/2017 04:11 PM, Phil Sutter wrote:
> On Tue, Aug 01, 2017 at 12:05:13PM +0200, Florian Lehner wrote:
> [...]
>> @@ -114,9 +114,13 @@ int addr64_n2a(__u64 addr, char *buff, size_t len);
>>  int af_bit_len(int af);
>>  int af_byte_len(int af);
>>
>> -const char *format_host_r(int af, int len, const void *addr,
>> -			       char *buf, int buflen);
>> -const char *format_host(int af, int lne, const void *addr);
>> +const char *format_host_rb(int af, int len, const void *addr,
>> +			       char *buf, int buflen, bool *resolved);
>> +#define format_host_r(af, len, addr, buf, buflen) \
>> +	format_host_rb(af, len, addr, buf, buflen, NULL)
>> +const char *format_host_b(int af, int lne, const void *addr, bool
>> *resolved);
>> +#define format_host(af, lne, addr) \
>> +	format_host_b(af, lne, addr, NULL)
>>  #define format_host_rta(af, rta) \
>>  	format_host(af, RTA_PAYLOAD(rta), RTA_DATA(rta))
>>  const char *rt_addr_n2a_r(int af, int len, const void *addr,
>> diff --git a/lib/utils.c b/lib/utils.c
>> index 9aa3219..42c3bf5 100644
>> --- a/lib/utils.c
>> +++ b/lib/utils.c
>> @@ -898,8 +898,8 @@ static const char *resolve_address(const void *addr,
>> int len, int af)
>>  }
>>  #endif
>>
>> -const char *format_host_r(int af, int len, const void *addr,
>> -			char *buf, int buflen)
>> +const char *format_host_rb(int af, int len, const void *addr,
>> +			char *buf, int buflen, bool *resolved)
>>  {
>>  #ifdef RESOLVE_HOSTNAMES
>>  	if (resolve_hosts) {
>> @@ -909,17 +909,20 @@ const char *format_host_r(int af, int len, const
>> void *addr,
>>
>>  		if (len > 0 &&
>>  		    (n = resolve_address(addr, len, af)) != NULL)
>> +		{
>> +			*resolved = true;
>>  			return n;
>> +		}
>>  	}
>>  #endif
>>  	return rt_addr_n2a_r(af, len, addr, buf, buflen);
>>  }
> 
> Did you test that? I guess calling format_host() will lead to
> dereference of a NULL pointer.

Yes, I did. And it just worked.
David Laight suggested to use strchr(). Instead of changing stuff in
lib/* I will try this.
