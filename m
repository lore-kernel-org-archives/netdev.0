From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with optional structs in data area
Date: Tue, 27 Jan 2009 16:23:57 +0100
Message-ID: <1233069837.24438.54.camel@pohly-MOBL>
References: <1232532457.7829.19.camel@ecld0pohly>
	 <20090125.210442.129666692.davem@davemloft.net>
	 <1233002392.23161.6.camel@pohly-MOBL>
	 <20090126.172202.261408793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56152 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbZA0PYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 10:24:04 -0500
In-Reply-To: <20090126.172202.261408793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-27 at 03:22 +0200, David Miller wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Mon, 26 Jan 2009 21:39:52 +0100
> 
> > On Mon, 2009-01-26 at 07:04 +0200, David Miller wrote:
> > > Just consolidate the array into a direct conversion table.  You only
> > > have 2 bits defined so you only need an array of 4 entries.  Pass the
> > > optional flag bits directly in as the index of that table.
> > 
> > How can I get some code executed during the initialization of the IP
> > stack which initializes the table, before any sk_buff gets allocated?
> > 
> > The content is constant, but writing it down as static initializers
> > using just preprocessor macros would be difficult and/or ugly - that's
> > why I haven't done it already.
> 
> It's 4 entries... really.

True - at this time. But what if this extension mechanism turns out to
be useful and we end up with more optional structures? I was hoping that
this might be the case and thus tried to make it easy to add more
structures.

> You can initialize them simply, perhaps
> with some fancy macro used by the initializers.

Unfortunately recursion in macros is not possible. One needs duplicated
macro definitions, one for each additional structure. But perhaps my
preprocessor code fu is lacking today and there is a simpler
solution :-/

Anyway, below is example code with three structures which initializes a
size array indexed by a bit mask. I find it truly ugly and hard to
understand - and I wrote it. gcc -S shows that the size arrays contain
the expected values.

Please let me know what approach is preferred and I'll revise the patch
accordingly:
     1. array with four hard-coded values
     2. init code (where?)
     3. macro initialization of array
     4. simpler initialization solution

---------------------------------------------------------------
struct A {
    int a;
};

struct B {
    char b;
};

struct C {
    long long c;
};

enum {
    BIT_A,
    BIT_B,
    BIT_C
};

#define MIN(_a, _b) ((_a) < (_b) ? (_a) : (_b))

/* round up _previous number of bytes so that a struct of_structsize
   bytes is properly aligned at an 8 byte boundary or the structure size,
   whatever is smaller */
#define ALIGN(_previous, _structsize) \
    (((_previous) + MIN(_structsize, 8) - 1) & ~(MIN(_structsize, 8) - 1))

/* number of bytes for struct X alone
 * @_flags: bit mask of BIT_ values
 * @_bitname: name of bit enum for X
 * @_structname: structure name of X, without struct
 */
#define SIZE_X(_flags, _bitname, _structname) \
    (((_flags) & (1<<_bitname)) ? sizeof(struct _structname) : 0)

/* number of bytes needed for B (if present) with or without A in
 * front of it
 * @_flags: bit mask of BIT_A and BIT_B
 */
#define SIZE_B(_flags) \
    (((_flags) & (1<<BIT_B)) ? \
     (ALIGN(SIZE_X(_flags, BIT_A, A), SIZE_X(_flags, BIT_B, B)) + sizeof(struct B)) : \
     SIZE_X(_flags, BIT_A, A))

/* number of bytes needed for C (if present) with combinations of
 * struct A, B in front
 * @_flags: bit mask of BIT_A, BIT_B, BIT_C
 */
#define SIZE_C(_flags) \
    (((_flags) & (1<<BIT_C)) ? \
     (ALIGN(SIZE_B(_flags), SIZE_X(_flags, BIT_C, C)) + sizeof(struct C)) : \
     SIZE_B(_flags))

/* number of bytes needed to store combinations of A, B, C, in this
   order */
int size[] = { 0,

               SIZE_X((1<<BIT_A), BIT_A, A),

               SIZE_B((1<<BIT_B)),
               SIZE_B((1<<BIT_B)|(1<<BIT_A)),

               SIZE_C((1<<BIT_C)),
               SIZE_C((1<<BIT_C)|(1<<BIT_A)),
               SIZE_C((1<<BIT_C)|(1<<BIT_B)),
               SIZE_C((1<<BIT_C)|(1<<BIT_B)|(1<<BIT_A)) };

#define LIST_A(_flags) SIZE_C(_flags), SIZE_C((_flags)|(1<<BIT_A))
#define LIST_B(_flags) LIST_A(_flags), LIST_A((_flags)|(1<<BIT_B))
#define LIST_C(_flags) LIST_B(_flags), LIST_B((_flags)|(1<<BIT_C))

/* same as size */
int size2[] = { LIST_C(0) };
---------------------------------------------------------------

Bye, Patrick

