From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Sun, 26 Jul 2009 23:47:29 +0200
Message-ID: <4A6CCEF1.3030503@gmail.com>
References: <4A6B61FB.4050304@gmail.com> <4A6CB9A6.4070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:49529 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbZGZVri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 17:47:38 -0400
Received: by bwz28 with SMTP id 28so2280502bwz.37
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2009 14:47:37 -0700 (PDT)
In-Reply-To: <4A6CB9A6.4070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 07/26/2009 10:16 PM:

> Roel Kluin wrote, On 07/25/2009 09:50 PM:
> 
>> start_code is 69 words, but the code always writes a multiple of 16 words,
>> so the last 11 words written are outside the array.
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> This was observed using Parfait http://research.sun.com/projects/parfait/
>>
>> diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
>> index 1686dca..e304abb 100644
>> --- a/drivers/net/eexpress.c
>> +++ b/drivers/net/eexpress.c
>> @@ -1474,15 +1474,14 @@ static void eexp_hw_init586(struct net_device *dev)
>>  	outw(0x0000, ioaddr + 0x800c);
>>  	outw(0x0000, ioaddr + 0x800e);
>>  
>> -	for (i = 0; i < (sizeof(start_code)); i+=32) {
>> -		int j;
>> -		outw(i, ioaddr + SM_PTR);
>> -		for (j = 0; j < 16; j+=2)
>> -			outw(start_code[(i+j)/2],
>> -			     ioaddr+0x4000+j);
>> -		for (j = 0; j < 16; j+=2)
>> -			outw(start_code[(i+j+16)/2],
>> -			     ioaddr+0x8000+j);
> 
> 
> (max) i = 64, (max) j = 14, (64+14+16)/2 = 47 < 69, so it seems to copy
> less than its size?


OOPS: (max) i = 128, (max) j = 14, (128+14+16)/2 = 79, so you are right!

Sorry,
Jarek P.

> 
>> +	for (i = 0; i < ARRAY_SIZE(start_code); i += 16) {
>> +		int j, jmax;
>> +		outw(i * 2, ioaddr + SM_PTR);
>> +
>> +		jmax = min_t(int, 16, ARRAY_SIZE(start_code) - i);
>> +		for (j = 0; j < jmax; j++)
>> +			outw(start_code[i + j],
>> +			     ioaddr + j * 2 + (j < 8 ? 0x4000 : 0x8000 - 16));
>>  	}
>>  
>>  	/* Do we want promiscuous mode or multicast? */
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


