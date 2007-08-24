From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] i386: Fix a couple busy loops in
 mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 10:34:22 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708241025430.25853@woody.linux-foundation.org>
References: <NBBBIGEGHIGMPCNKHCECAEPEELAA.kenn@bluetree.ie>
 <200708241525.51049.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Kenn Humborg <kenn@bluetree.ie>,
	Satyam Sharma <satyam@infradead.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49817 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764176AbXHXRlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 13:41:00 -0400
In-Reply-To: <200708241525.51049.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 24 Aug 2007, Denys Vlasenko wrote:
> 
> So you are ok with compiler propagating n1 to n2 here:
> 
> n1 += atomic_read(x);
> other_variable++;
> n2 += atomic_read(x);
> 
> without accessing x second time. What's the point? Any sane coder
> will say that explicitly anyway:

No.

This is a common mistake, and it's total crap.

Any "sane coder" will often use inline functions, macros, etc helpers to 
do certain abstract things. Those things may contain "atomic_read()" 
calls.

The biggest reason for compilers doing CSE is exactly the fact that many 
opportunities for CSE simple *are*not*visible* on a source code level. 

That is true of things like atomic_read() equally as to things like shared 
offsets inside structure member accesses. No difference what-so-ever.

Yes, we have, traditionally, tried to make it *easy* for the compiler to 
generate good code. So when we can, and when we look at performance for 
some really hot path, we *will* write the source code so that the compiler 
doesn't even have the option to screw it up, and that includes things like 
doing CSE at a source code level so that we don't see the compiler 
re-doing accesses unnecessarily.

And I'm not saying we shouldn't do that. But "performance" is not an 
either-or kind of situation, and we should:

 - spend the time at a source code level: make it reasonably easy for the 
   compiler to generate good code, and use the right algorithms at a 
   higher level (and order structures etc so that they have good cache 
   behaviour).

 - .. *and* expect the compiler to handle the cases we didn't do by hand
   pretty well anyway. In particular, quite often, abstraction levels at a 
   software level means that we give compilers "stupid" code, because some 
   function may have a certain high-level abstraction rule, but then on a 
   particular architecture it's actually a no-op, and the compiler should 
   get to "untangle" our stupid code and generate good end results.

 - .. *and* expect the hardware to be sane and do a good job even when the 
   compiler didn't generate perfect code or there were unlucky cache miss
   patterns etc.

and if we do all of that, we'll get good performance. But you really do 
want all three levels. It's not enough to be good at any one level (or 
even any two).

			Linus
