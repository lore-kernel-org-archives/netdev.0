From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Fri, 22 Dec 2006 11:53:48 +1100
Message-ID: <E1GxYfU-0003EG-00@gondolin.me.apana.org.au>
References: <20061220.103112.85414445.davem@davemloft.net>
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4805 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1423170AbWLVAyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 19:54:23 -0500
To: davem@davemloft.net (David Miller)
In-Reply-To: <20061220.103112.85414445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Thu, 14 Dec 2006 15:07:06 +0000
> 
>> While looking at DCCP sequence numbers, I stumbled over a problem with
>> the following definition of before in tcp.h:
>> 
>> static inline int before(__u32 seq1, __u32 seq2)
>> {
>>         return (__s32)(seq1-seq2) < 0;
>> }
>> 
>> Problem: This definition suffers from an an ambiguity, i.e. always
>>                    
>>            before(a, (a + 2^31) % 2^32)) = 1
>>            before((a + 2^31) % 2^32), a) = 1
>>  
>>          In text: when the difference between a and b amounts to 2^31,
>>          a is always considered `before' b, the function can not decide. 
>>          The reason is that implicitly 0 is `before' 1 ... 2^31-1 ... 2^31
>>       
>> Solution: There is a simple fix, by defining before in such a way that 
>>           0 is no longer `before' 2^31, i.e. 0 `before' 1 ... 2^31-1
>>           By not using the middle between 0 and 2^32, before can be made 
>>           unambiguous. 
>>           This is achieved by testing whether seq2-seq1 > 0 (using signed
>>           32-bit arithmetic).
>> 
>> I attach a patch to codify this. Also the `after' relation is basically 
>> a redefinition of `before', it is now defined as a macro after before.
>> 
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> Applied, thanks Gerrit.
> 
> I went over this patch and analysis a dozen times, because I
> couldn't believe something like this has been broken for
> so long :-)

Sorry, I still don't get the point of this change.

Prior to the patch, we have values x and y such that both
before(x, y) and before(y, x) are true.  Now for those same
values both before(x, y) and before(y, x) are false.

It's still as ambiguous as ever.  Surely to resolve the
ambiguity we want to make before(x, y) = !before(y, x), no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
