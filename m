From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 7 Jan 2014 13:09:50 -0800
Message-ID: <CA+mtBx_Zctape7mAA=d-bvrFJbzn8f6tW5jBnPUcL5Cfhfai-g@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-fUe_VbUUnjEVXeJO=87yypoDuMfoctO0Q3nMx+6UZFA@mail.gmail.com>
	<CAJZOPZKHC1t6tGjZ9ZyTD912-5Bw_Vtin8N2MnqkOi4W2wPrzA@mail.gmail.com>
	<1389124947.26646.54.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+_1z+Qq0U0XnEAMygXMXTivN7giZ5P-QH-L_dkz2_hFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:49433 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaAGVJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:09:51 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so11289821igc.3
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 13:09:50 -0800 (PST)
In-Reply-To: <CAJZOPZ+_1z+Qq0U0XnEAMygXMXTivN7giZ5P-QH-L_dkz2_hFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 12:12 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jan 7, 2014 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2014-01-07 at 21:43 +0200, Or Gerlitz wrote:
>>> On Tue, Jan 7, 2014 at 8:08 PM, Tom Herbert <therbert@google.com> wrote:
>>
>>> > Why ^ instead of != ?
>>>
>>> The XOR approach is very popular in the GRO stack, e.g see the IPv4 chain
>>> of inet_gro_receive() && tcp_gro_receive(), I guess this might relates
>>> to more efficient assembly code for ^ vs. != and/or the fast/elegant
>>> transitive nature of that operator
>>
>> This trick is only needed/used when many compares are folded into a
>> single conditional :
>>
>> if (a->f1 != b->f1 || a->f2 != b->f2)
>>
>> ->
>>
>> if (((a->f1 ^ b->f1) | (a->f2 ^ b->f2)) != 0)
>>
>> Please do not use XOR for a single compare.
>
> OK, but just out of curiosity -- what's the reasoning? clarity or
> efficiency or both?

Both. Compiling a simple program and comparing alternatives: gcc
produced the identical code for the single conditional (^ vs !=)
using the cmp instruction. Testing the two conditional case like Eric
provided; the second method (using ^) resulted in 4 more instructions,
but only one branch as opposed to two in the first method (!=). Method
#1 has the advantage of short circuiting when the first condition is
true, so organizing the conditionals to maximize the probability of
short circuit could be beneficial.


>>
>>
>>
