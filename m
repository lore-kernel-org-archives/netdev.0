From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 02:22:14 +0300
Message-ID: <20060208232214.GC14543@mipter.zuzino.mipt.ru>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au> <OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	James Carlson <carlsonj@workingcode.com>,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2006 at 02:45:08PM -0800, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 02/08/2006 02:19:20 PM:
> 
> > James Carlson <carlsonj@workingcode.com> wrote:
> > > Alexey Dobriyan writes:
> > >> -     if (ap == 0)
> > >> +     if (!ap)
> > >
> > > And the solution is to treat it as a boolean instead?!  I'm not sure
> > > which is more ugly.
> >
> > Treating it as a boolean looks good to me.  It's better than the
> existing
> > code because it shuts sparse up.
>
>         Why would sparse complain about this? 0 is a well-defined
> pointer value (the only value guaranteed to be by the language).
>         From K&R ANSI C edition, section 5.4:
>
>         "Pointers and integers are not interchangeable. Zero is the sole
> exception: the constant zero may be assigned to a pointer, and a pointer
> may be compared with the constant zero."

O is an integer, NULL is a pointer. You compare integers with integers
and pointers with pointers. You don't compare integers with pointers
because they are fundamentally different objects. The former counts
things, the latter points to them.

The fact that they can be represented by the same bit patterns is
irrelevant. The fact that K&R, C89, C99 make

	p = malloc();
	if (p == NULL)

legal C is irrelevant.

Because

	p = malloc();
	if (!p)
		err;

is idiomatic C, I've used this form.

<full-disclosure>
Oh, and for the record: current sparse from Linus doesn't warn about
this. Slightly modified sparse warns. Bugs which were uncovered by
more or less trivial and slightly broken sparse patch [1] are:

	[PATCH] dscc4: fix dscc4_init_dummy_skb check
	[PATCH] opl3sa2: fix adding second dma channel
	[PATCH] gusclassic: fix adding second dma channel
	[PATCH] ipw2200: fix ->eeprom[EEPROM_VERSION] check
	[PATCH] ixj: fix writing silence check

ppp-NULL.patch is the biggest part of
	187 files changed, 494 insertions(+), 499 deletions(-)
so I've flushed it first.

[1]:

--- a/evaluate.c
+++ b/evaluate.c
@@ -934,6 +934,10 @@ static struct symbol *evaluate_compare(s
 	/* Pointer types? */
 	if (is_ptr_type(ltype) || is_ptr_type(rtype)) {
 		// FIXME! Check the types for compatibility
+		if (is_ptr_type(ltype) && !is_ptr_type(rtype))
+			bad_expr_type(expr);
+		if (!is_ptr_type(ltype) && is_ptr_type(rtype))
+			bad_expr_type(expr);
 		expr->op = modify_for_unsigned(expr->op);
 		goto OK;
 	}

</full-disclosure>

