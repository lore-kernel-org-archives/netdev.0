From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 14:55:23 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708161342290.25951@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <20070815233721.91032366.billfink@mindspring.com>
 <alpine.LFD.0.999.0708161045360.25951@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708161115370.25951@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50653 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbXHPJNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 05:13:01 -0400
In-Reply-To: <alpine.LFD.0.999.0708161115370.25951@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Bill tells me in private communication he gets this already, but I
  think it's more complicated than the shoddy explanation I'd made
  earlier so would wish to make this clearer in detail one last time,
  for the benefit of others listening in or reading the archives. ]


On Thu, 16 Aug 2007, Satyam Sharma wrote:

> On Thu, 16 Aug 2007, Satyam Sharma wrote:
> [...]
> > On Wed, 15 Aug 2007, Bill Fink wrote:
> > > [...]
> > > I'm curious about one minor tangential point.  Why, instead of:
> > > 
> > > 	b = *(volatile int *)&a;
> > > 
> > > why can't this just be expressed as:
> > > 
> > > 	b = (volatile int)a;
> > > 
> > > Isn't it the contents of a that's volatile, i.e. it's value can change
> > > invisibly to the compiler, and that's why you want to force a read from
> > > memory?  Why do you need the "*(volatile int *)&" construct?
> > 
> > "b = (volatile int)a;" doesn't help us because a cast to a qualified type
> > has the same effect as a cast to an unqualified version of that type, as
> > mentioned in 6.5.4:4 (footnote 86) of the standard. Note that "volatile"
> > is a type-qualifier, not a type itself, so a cast of the _object_ itself
> > to a qualified-type i.e. (volatile int) would not make the access itself
> > volatile-qualified.

Casts don't produce lvalues, and the cast ((volatile int)a) does not
produce the object-int-a-qualified-as-"volatile" -- in fact, the
result of the above cast is whatever is the _value_ of "int a", with
the access to that object having _already_ taken place, as per the
actual type-qualification of the object (that was originally declared
as being _non-volatile_, in fact). Hence, defining atomic_read() as:

#define atomic_read(v)          ((volatile int)((v)->counter))

would be buggy and not give "volatility" semantics at all, unless the
"counter" object itself isn't volatile-qualified already (which it
isn't).

The result of the cast itself being the _value_ of the int object, and
not the object itself (i.e., not an lvalue), is thereby independent of
type-qualification in that cast itself (it just wouldn't make any
difference), hence the "cast to a qualified type has the same effect
as a cast to an unqualified version of that type" bit in section 6.5.4:4
of the standard.


> > To serve our purposes, it is necessary for us to take the address of this
> > (non-volatile) object, cast the resulting _pointer_ to the corresponding
> > volatile-qualified pointer-type, and then dereference it. This makes that
> > particular _access_ be volatile-qualified, without the object itself being
> > such. Also note that the (dereferenced) result is also a valid lvalue and
> > hence can be used in "*(volatile int *)&a = b;" kind of construction
> > (which we use for the atomic_set case).

Dereferencing using the *(pointer-type-cast)& construct, OTOH, serves
us well:

#define atomic_read(v)          (*(volatile int *)&(v)->counter)

Firstly, note that the cast here being (volatile int *) and not
(int * volatile) qualifies the type of the _object_ being pointed to
by the pointer in question as being volatile-qualified, and not the
pointer itself (6.2.5:27 of the standard, and 6.3.2.3:2 allows us to
convert from a pointer-to-non-volatile-qualified-int to a pointer-to-
volatile-qualified-int, which suits us just fine) -- but note that
the _access_ to that address itself has not yet occurred.

_After_ specifying the memory address as containing a volatile-qualified-
int-type object, (and GCC co-operates as mentioned below), we proceed to
dereference it, which is when the _actual access_ occurs, therefore with
"volatility" semantics this time.

Interesting.


> Here, I should obviously admit that the semantics of *(volatile int *)&
> aren't any neater or well-defined in the _language standard_ at all. The
> standard does say (verbatim) "precisely what constitutes as access to
> object of volatile-qualified type is implementation-defined", but GCC
> does help us out here by doing the right thing. Accessing the non-volatile
> object there using the volatile-qualified pointer-type cast makes GCC
> treat the object stored at that memory address itself as if it were a 
> volatile object, thus making the access end up having what we're calling
> as "volatility" semantics here.
> 
> Honestly, given such confusion, and the propensity of the "volatile"
> type-qualifier keyword to be ill-defined (or at least poorly understood,
> often inconsistently implemented), I'd (again) express my opinion that it
> would be best to avoid its usage, given other alternatives do exist.


Satyam
