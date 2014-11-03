From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH -next v3 1/3] syncookies: avoid magic values and document
 which-bit-is-what-option
Date: Mon, 03 Nov 2014 15:33:36 +0100
Message-ID: <54579240.8060309@redhat.com>
References: <1415019720-17106-1-git-send-email-fw@strlen.de> <1415019720-17106-2-git-send-email-fw@strlen.de> <063D6719AE5E284EB5DD2968C1650D6D1C9E44B1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Florian Westphal'" <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbaKCOdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:33:46 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E44B1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2014 03:24 PM, David Laight wrote:
> From: Florian Westphal
>> Was a bit more difficult to read than needed due to magic shifts;
>> add defines and document the used encoding scheme.
>>
>> Joint work with Daniel Borkmann.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> ---
>>   This patch was not part of earlier versions of the set.
>>
>>   net/ipv4/syncookies.c | 50 +++++++++++++++++++++++++++++++++++---------------
>>   1 file changed, 35 insertions(+), 15 deletions(-)
>>
>> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
>> index 4ac7bca..c3792c0 100644
>> --- a/net/ipv4/syncookies.c
>> +++ b/net/ipv4/syncookies.c
>> @@ -19,10 +19,6 @@
>>   #include <net/tcp.h>
>>   #include <net/route.h>
>>
>> -/* Timestamps: lowest bits store TCP options */
>> -#define TSBITS 6
>> -#define TSMASK (((__u32)1 << TSBITS) - 1)
>> -
>>   extern int sysctl_tcp_syncookies;
>>
>>   static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
>> @@ -30,6 +26,30 @@ static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
>>   #define COOKIEBITS 24	/* Upper bits store count */
>>   #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
>>
>> +/* TCP Timestamp: 6 lowest bits of timestamp sent in the cookie SYN-ACK
>> + * stores TCP options:
>> + *
>> + * MSB                               LSB
>> + * | 31 ...   6 |  5  |  4   | 3 2 1 0 |
>> + * |  Timestamp | ECN | SACK | WScale  |
>> + *
>> + * When we receive a valid cookie-ACK, we look at the echoed tsval (if
>> + * any) to figure out which TCP options we should use for the rebuilt
>> + * connection.
>> + *
>> + * A WScale setting of '0xf' (which is an invalid scaling value)
>> + * means that original syn did not include the TCP window scaling option.
>> + */
>> +#define TS_OPT_WSCALE_MASK	0xf
>> +#define TS_OPT_SACK		BIT(4)
>> +#define TS_OPT_ECN		BIT(5)
>> +/* There is no TS_OPT_TIMESTAMP:
>> + * if ACK contains timestamp option, we already know it was
>> + * requested/supported by the syn/synack exchange.
>> + */
>> +#define TSBITS	6
>> +#define TSMASK	(((__u32)1 << TSBITS) - 1)
>
> Personally I'd define all the values as hex constants instead of mixing
> and matching the defines.
>
> So probably just:
> #define TS_OPT_WSCALE_MASK	0x0f
> #define TS_OPT_SACK		0x10
> #define TS_OPT_ECN		0x20
> #define TSMASK                0x3f

If you look at the above comment and then take a peek at the actual TS_OPT_*,
it is much easier to follow. Moreover, how is having TSMASK as 0x3f better?!
Currently, it is a constant calculated based upon TSBITS.
