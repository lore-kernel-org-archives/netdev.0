From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 19:56:52 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031215652.GR3705@conectiva.com.br>
References: <200310312006.h9VK62Hh005910@hera.kernel.org> <1067635446.11564.92.camel@localhost.localdomain> <20031031132331.35a9aaca.davem@redhat.com> <1067637004.11564.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David S Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
Content-Disposition: inline
In-Reply-To: <1067637004.11564.98.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Oct 31, 2003 at 01:50:04PM -0800, Joe Perches escreveu:
> On Fri, 2003-10-31 at 13:23, David S. Miller wrote:
> > we're as mystified as you are as to why it is that:
> > 	if (sum & 0x10000) {
> > 		sum++;
> > 		sum &= 0xffff;
> > 	}
> > works while:
> > 	sum = ((sym >> 16) + sum) & 0xffff;
> > does not.  The theory was that it might be some x86 gcc bug,
> > but looking at the assembler diff Arnaldo Carvalho de Melo
> > (the appletalk maintainer) showed me between the before and
> > after:
> >  	xorl	%eax, %eax
> > -	decl	%ecx
> >  	movb	(%ebx), %al
> > -	incl	%ebx
> >  	addl	%eax, %edx
> >  	addl	%edx, %edx
> > -	movl	%edx, %eax
> > -	shrl	$16, %eax
> > -	addl	%edx, %eax
> > -	movzwl	%ax,%edx
> > +	testl	$65536, %edx
> > +	je	.L982
> > +	incl	%edx
> > +	andl	$65535, %edx
> > +.L982:
> > +	decl	%ecx
> > +	incl	%ebx
> >  	cmpl	$-1, %ecx
> > 
> > we still can't see what's wrong.
> > He did confirm that the change in question makes IPX compute checksums
> > correctly.
> 
> If so, something major is WRONG.

I guess so. If people with an Appletalk testbed could try with and without
the patch, that would be great.

> Code all over the place would need this "fix".

Haven't noticed any other place with this problem, but yes, this is something
that may well happen in other code.

> Was an old NG Sniffer being used to verify this?

Nope, MacOS 7.5.5 and 9 just hang when communicating with the machine without
this patch, gcc 3.3.1/2 was used.

> Sniffer had a long term problem with IPX checksums.

I added back the old atalk_checksum from 2.4 and compared the results, not
all were wrong, but some were.
 
> Has the gcc team been contacted?

Nope, feel free to forward this message.

- Arnaldo
