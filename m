From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Sun, 18 Mar 2007 16:46:26 -0700
Message-ID: <45FDCF52.4000805@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de> <45FD619D.6030402@goop.org>
	<20070318170414.GB45869@muc.de> <45FD76E6.4060907@goop.org>
	<20070318193030.GB71548@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zach@vmware.com, xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, anthony@codemonkey.ws,
	mingo@elte.hu, torvalds@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Andi Kleen <ak@muc.de>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070318193030.GB71548@muc.de>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Yes. All inline assembly tells gcc what registers are clobbered
> and it fills in the tables. Hand clobbering in inline assembly cannot
> be expressed with the current toolchain, so we moved all those
> out of line.
>
> But again I'm not sure it will work anyways. For once you would
> need large padding around the calls anyways for inline replacement --
> how would you generate that? I expect you would need to put the calls
> into asm() again and with that a custom annotiation format looks reasonable.

Inlining is most important for very small code: sti, cli, pushf;pop eax,
etc (in many cases, no-ops).  We'd have at least 5 bytes to work in, and
maybe more if there are surrounding push/pops to be consumed.

For example, say we wanted to put a general call for sti into entry.S,
where its expected it won't touch any registers.  In that case, we'd
have a sequence like:

    push %eax
    push %ecx
    push %edx
    call paravirt_cli
    pop %edx
    pop %ecx
    pop %eax
      

If we parse the relocs, then we'd find the reference to paravirt_cli. 
If we look at the byte before and see 0xe8, then we can see if its a
call.  If we then work out in each direction and see matched push/pops,
then we know what registers can be trashed in the call.  This also
allows us to determine the callsite size, and therefore how much space
we need for inlining.

So in this case, we see that there are 5 bytes for the call and a
further 6 bytes of push/pops available for inlining.

Of course this is hand-written code anyway, so there's no particular
burden to having some extra metadata stashed away in another section. 
For compiler-generated code, we know that it's already expecting
standard C ABI calling conventions.  The downside, of course, is that
only the 5 byte call space is available for inline patching.

    J
