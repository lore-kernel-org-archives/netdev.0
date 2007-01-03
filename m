From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Wed, 3 Jan 2007 08:56:19 +0000
Message-ID: <200701030856.19416@strip-the-willow>
References: <E1GxYfU-0003EG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46532 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755045AbXACI4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 03:56:51 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GxYfU-0003EG-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,


|  >> While looking at DCCP sequence numbers, I stumbled over a problem with
|  >> the following definition of before in tcp.h:
|  >> 
|  >> static inline int before(__u32 seq1, __u32 seq2)
|  >> {
|  >>         return (__s32)(seq1-seq2) < 0;
|  >> }
|  >> 
|  >> Problem: This definition suffers from an an ambiguity, i.e. always
|  >>                    
|  >>            before(a, (a + 2^31) % 2^32)) = 1
|  >>            before((a + 2^31) % 2^32), a) = 1
|  >>  
|  >>          In text: when the difference between a and b amounts to 2^31,
|  >>          a is always considered `before' b, the function can not decide. 
|  >>          The reason is that implicitly 0 is `before' 1 ... 2^31-1 ... 2^31
|  >>       
|  >> Solution: There is a simple fix, by defining before in such a way that 
|  >>           0 is no longer `before' 2^31, i.e. 0 `before' 1 ... 2^31-1
|  >>           By not using the middle between 0 and 2^32, before can be made 
|  >>           unambiguous. 
|  >>           This is achieved by testing whether seq2-seq1 > 0 (using signed
|  >>           32-bit arithmetic).
| 
|  Sorry, I still don't get the point of this change.
|  
|  Prior to the patch, we have values x and y such that both
|  before(x, y) and before(y, x) are true.  Now for those same
|  values both before(x, y) and before(y, x) are false.
|
|  It's still as ambiguous as ever.  Surely to resolve the
|  ambiguity we want to make before(x, y) = !before(y, x), no?
Please let me restate:
 Ambiguity here means that for those numbers x,y such that  (x + 2^31) % 2^32) = y
 before(x, y) = 1 and before(y, x) = 1. With the previous implementation, one could 
 not tell the difference here: and there are 2^32 such cases where this occurs.

 With the implementation now, the output of before(x,y) is reliable: it returns true
 if (and only if) x is indeed `before' y.

 If before(x,y) is false then there are now two possibilities:
  (a) before(y, x) is true   and y != (x + 2^31) % 2^32
  (b) before(y, x) is false  and y == (x + 2^31) % 2^32
 This means that the cases can be clearly separated out, which was not possible before.

		To summarize the differences:
		-----------------------------

1) Possible cases in the old implementation (exclusive-or list):
    * x == y                            -  identity
    * before(x, y) && !before(y, x)     -  x is `before' y
    * before(y, x) && !before(x, y) 	-  y is `before' x
    * before(x, y) && before(y, x)      -  y == (x + 2^31) % 2^32
    
2) Possible cases in the new implementation (exclusive-or list):
    * x == y 				-  identity
    * before(x, y)			-  x is `before' x
    * before(y, x)			-  y is `before x
    * !before(x, y) && !before(y, x)    -  y == (x + 2^31) % 2^32

As can be seen (2) requires fewer test cases while (1) would need extra checks to disambiguate
before(x, y) from the case "before(x,y) && before(y,x)".

I do believe that this is useful, since now speeds of 10 Gigabits are in use, which means that
sequence numbers wrap around faster; and also with regard to the issue of selecting an initial
sequence number; and protection against sequence number attacks.

A related discussion is in RFC 1982, but with regard to the case y == (x + 2^31) % 2^32 it 
recommends to leave this `undefined' -- the new solution is in agreement with this, and is
even less complicated to implement.

Gerrit
