From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Fri, 5 Jan 2007 12:49:13 +0000
Message-ID: <200701051249.13325@strip-the-willow>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701051151.16377@strip-the-willow> <20070105120157.GA21872@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:48867 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161091AbXAEMss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 07:48:48 -0500
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20070105120157.GA21872@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Herbert Xu:
|  On Fri, Jan 05, 2007 at 11:51:16AM +0000, Gerrit Renker wrote:
|  >      
|  > |  2) Change before/after such that before(x, x+2^31) == !before(x+2^31, x).
|  > This is what the new definition does: in the old definition we always have that
|  > before(x, x+2^31) == before(x+2^31, x).
|  
|  Sorry but the new definition has exactly the same problem since
|  
|  	before(x, x+2^31) == before(x+2^31, x) == 0

You are right. Sorry, I misread the text. Please see below.


|  While the old definition had
|  
|  	before(x, x+2^31) == before(x+2^31, x) == 1
|  
|  Both are equally bad.  It's only unambiguous if
|  
|  	before(x, x+2^31) == !before(x+2^31, x) == 0
|  
|  or
|  
|  	before(x, x+2^31) == !before(x+2^31, x) == 1
Implementing such a solution is a challenge - RFC 1982 suggests here (sec. 3.2):
 "Thus the problem case is left undefined, implementations are free to
  return either result, or to flag an error, and users must take care
  not to depend on any particular outcome."

I think that a definition which satisfies before(x, x+2^31) != !before(x+2^31, x)
will be more complex to implement and will need more instructions.

To illustrate with an example, if we assume that `before' operates on minutes and uses
modulo-60 arithmetic, the above requirement becomes

	before60(x, x+30)   !=   before(x+30, x)

On a clock, one cannot tell this when we merely look at the minute hands: "half before xx o'clock" 
is the same as "xx o'clock before half". Only if we also take the hour hand into consideration, the
statement "half before 2:00 o'clock" becomes unambiguous (although one would rather say "half past 
1:00 o'clock" :-). 

With regard to 31-bit sequence numbers, this would mean that we need additional information to enforce

	before(x, x+2^31) != before(x+2^31, x)

Taking the clock example further, it could be disambiguated by using 33 bits, but then the same problem
crops up with regard to modulo-2^33 arithmetic: how to disambiguate the case for x and x+2^32.

Please let me restate the differences between the old and new definition:

1) Old definition has the following list of exclusive-or cases
	* x == y				- identity
	* before(x, y) && !before(y, x)		- x `before' y and y != (x + 2^31) % 2^32
	* before(y, x) && !before(x, y)		- y `before' x and y != (x + 2^31) % 2^32
	* before(x, y) && before(y, x)		- y == (x + 2^31) % 2^32

2) New definition has the following list of exclusive-or cases
	* x == y				- identity
	* before(x, y)				- x `before' y and y != (x + 2^31) % 2^32
	* before(y, x) 				- y `before' x and y != (x + 2^31) % 2^32
	* !before(x, y) && !before(y, x)	- y == (x + 2^31) % 2^32

Since the old definition is not used in the way "before(x, y) && !before(y, x)", but rather in the
fashion "before(x, y)" or "after(y, x)", the main advantage of the new definition is that it makes
this type of use a safe case. 

My view is that this is as good as one can get; if you have a suggestion of how one could also
disambiguate before(x, x+2^31) != before(x+2^31, x), can you please let me know.


Gerrit
