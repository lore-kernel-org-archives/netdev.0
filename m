From: Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH 2/2] tcp: md5: add fields to the tcp_md5sig struct to set
 a key address prefix
Date: Wed, 7 Jun 2017 08:13:20 +0200
Message-ID: <20170607061320.GB11691@ycc.fr>
References: <20170607005414.25361-1-colona@arista.com>
 <20170607005414.25361-2-colona@arista.com>
 <1496808502.736.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38284 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdFGGNX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 02:13:23 -0400
Received: by mail-wm0-f41.google.com with SMTP id n195so3672386wmg.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 23:13:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496808502.736.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 09:08:22PM -0700, Eric Dumazet wrote:
> On Tue, 2017-06-06 at 17:54 -0700, Ivan Delalande wrote:
>> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
>> index 38a2b07afdff..52ac30aa0652 100644
>> --- a/include/uapi/linux/tcp.h
>> +++ b/include/uapi/linux/tcp.h
>> @@ -234,9 +234,13 @@ enum {
>>  /* for TCP_MD5SIG socket option */
>>  #define TCP_MD5SIG_MAXKEYLEN	80
>>  
>> +/* tcp_md5sig flags */
>> +#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
>> +
>>  struct tcp_md5sig {
>>  	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
>> -	__u16	__tcpm_pad1;				/* zero */
>> +	__u8	tcpm_flags;				/* flags */
>> +	__u8	tcpm_prefixlen;				/* address prefix */
>>  	__u16	tcpm_keylen;				/* key length */
>>  	__u32	__tcpm_pad2;				/* zero */
>>  	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
> 
> This will break some applications that maybe did not clear the
> __tcpm_pad1 field ?
> 
> 
> You need to find another way to maintain compatibility with old
> applications.

All right, I thought this was acceptable after seeing a few examples of
this in commits extending other structures in uapi, but the context and
use were probably different for those.

We had another version of this patch which steals a bit from tcpm_keylen
to use as a flag for this feature specifically and with the prefixlen at
the same place as this patch. So when the flag is set we know we can
safely interpret this part of the padding field as a prefix as all valid
calls from older user programs should not have a key length greater than
80 bytes.

Would this be better? Programs compiled with the new headers could break
on older kernels if they don't check the version, I don't know if that's
a concern.

Or should we just add these two new fields at the end of tcp_md5sig and
use them only if the value of optlen in the parse function called from
setsockopt is large enough?


Thank you,
-- 
Ivan Delalande
Arista Networks
