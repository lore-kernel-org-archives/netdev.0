From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] vsprintf.c: Use noinline_for_stack
Date: Sat, 13 Mar 2010 07:35:41 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003130734420.3719@i5.linux-foundation.org>
References: <cover.1267682641.git.joe@perches.com> <20100304143837.af39845d.akpm@linux-foundation.org> <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain> <1267911399.849.39.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
 <1267914654.849.81.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain> <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain> <1267918554.849.89.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
 <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain> <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain> <1267924214.1937.12.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain> <1267929215.1937.18.camel@Joe-Laptop.home>
 <20100312162559.a8e51777.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100312162559.a8e51777.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 12 Mar 2010, Andrew Morton wrote:
> 
> -ENOTESTINGRESULTS.
> 
> Before:
> 
> akpm:/usr/src/25> objdump -d lib/vsprintf.o | perl scripts/checkstack.pl
> 0x00000e82 pointer [vsprintf.o]:                        344
> 0x0000198c pointer [vsprintf.o]:                        344
> 0x000025d6 scnprintf [vsprintf.o]:                      216
> 0x00002648 scnprintf [vsprintf.o]:                      216
> 0x00002565 snprintf [vsprintf.o]:                       208
> 0x0000267c sprintf [vsprintf.o]:                        208
> 0x000030a3 bprintf [vsprintf.o]:                        208
> 0x00003b1e sscanf [vsprintf.o]:                         208
> 0x00000608 number [vsprintf.o]:                         136
> 0x00000937 number [vsprintf.o]:                         136
> 
> After:
> 
> akpm:/usr/src/25> objdump -d lib/vsprintf.o | perl scripts/checkstack.pl  
> 0x00000a7c symbol_string [vsprintf.o]:                  248
> 0x00000ae8 symbol_string [vsprintf.o]:                  248
> 0x00002310 scnprintf [vsprintf.o]:                      216
> 0x00002382 scnprintf [vsprintf.o]:                      216
> 0x0000229f snprintf [vsprintf.o]:                       208
> 0x000023b6 sprintf [vsprintf.o]:                        208
> 0x00002ddd bprintf [vsprintf.o]:                        208
> 0x00003858 sscanf [vsprintf.o]:                         208
> 0x00000625 number [vsprintf.o]:                         136
> 0x00000954 number [vsprintf.o]:                         136
> 
> nice.

Note that the fact that the numbers are smaller is to some degree less 
important than _where_ the numbers are.

In the "before" side, it's the "pointer()" function that has a big stack 
depth. And the recursion that is going to happen is very much about 
vsnprintf -> pointer -> vsnprintf, so that is bad.

Now it's the new non-inlined leaf functions that still have a big stack 
footprint, and that's much better, because they wouldn't be part of any 
recursive behavior.

Not that I think it's wonderful even now. Especially that whole 
'symbol_string()' thing is not only a big stack user, it ends up calling 
down a fair number of other functions. Non-recursively, but still.

That, in turn, is due to this:

 - include/linux/kallsyms.h:
	#define KSYM_NAME_LEN 128
	#define KSYM_SYMBOL_LEN (sizeof("%s+%#lx/%#lx [%s]") + (KSYM_NAME_LEN - 1) + \

 - symbol_string():
	char sym[KSYM_SYMBOL_LEN];

ie we "need" about 150 bytes for just that silly symbol expansion (rounded 
up etc). Which is ridiculous, since we could/should limit it to something 
sane. But the kallsyms_lookup()/sprint_symbol() functions don't take a 
length parameter, so we have to do the worst-case thing (which itself has 
tons of unnecessary padding).

Gaah. We do _not_ want a kmalloc() or something like that in this path, 
since its' very much used for oopses (which in turn may be due to various 
slab bugs etc).

		Linus
