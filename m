From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH v2] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 16:14:36 +0300
Message-ID: <573C6ABC.3090008@virtuozzo.com>
References: <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
 <1463572995-17432-1-git-send-email-aryabinin@virtuozzo.com>
 <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0122.outbound.protection.outlook.com ([157.55.234.122]:26349
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751120AbcERN3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 09:29:39 -0400
In-Reply-To: <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/18/2016 04:03 PM, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 15:03 +0300, Andrey Ryabinin wrote:
>> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
>> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
>> sock_setsockopt() may write to these bits, while holding the socket lock.
>>
>> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
>> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
>> to corrupting these bits.
>>
>> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
>> This will not change the 'struct sock' size since ->sk_shutdown moved into
>> previously unused 16-bit hole.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>  include/net/sock.h | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index c9c8b19..04dc131 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -383,8 +383,7 @@ struct sock {
>>  	int			sk_sndbuf;
>>  	struct sk_buff_head	sk_write_queue;
>>  	kmemcheck_bitfield_begin(flags);
>> -	unsigned int		sk_shutdown  : 2,
> 
> 
> Please replace by a padding, so that sk_protocol is sill a byte,
> not 8 bits spaning 2 bytes in memory.

I think, it would be better to have something like this:

	u16 sk_type;
	u8 sk_protocol;
	kmemcheck_bitfield_begin(flags);
	u8			sk_no_check_tx : 1,
				sk_no_check_rx : 1,
				sk_userlocks : 4,
	kmemcheck_bitfield_end(flags);
