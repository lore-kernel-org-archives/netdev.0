From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] vsprintf.c: Reduce sizeof struct printf_spec from 24 to
 8 bytes
Date: Sat, 6 Mar 2010 18:03:33 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>  <1267911399.849.39.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
  <1267914654.849.81.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>  <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>  <1267918554.849.89.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
  <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>  <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain> <1267924214.1937.12.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53189 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638Ab0CGCDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 21:03:47 -0500
In-Reply-To: <1267924214.1937.12.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 6 Mar 2010, Joe Perches wrote:
> 
> Reducing the size of struct printf_spec is a good thing
> because multiple instances are commonly passed on stack.

Sadly, this is not enough.

the 'pointer()' function has a 200+ byte stack footprint on x86-64. And 
vsnprintf itself is about 100+ bytes. So that stack depth is way bigger 
than I would have expected.

I'm not sure _why_ that stack footprint for 'pointer()' is so big, but I 
bet it's due to some simple inlining, and gcc (once more) sucking at it 
and not being able to combine stack frames. It's a damn shame.

I suspect it's mac_address_string() having 20-odd bytes of temporary data, 
ip6_compressed_string() having some more, ip6_addr_string() having 50 
bytes, uuid_string() adding thirty-odd bytes etc. Inline them all, suck up 
merging stack slots, and 200 bytes is easy.

So no, I don't think we can do the recursion as things stand. I've applied 
your cleanup patch, along with the two from Bjorn Helgaas (which he did 
for his pnp set), but they don't help this fundamental problem.

A few noinlines might be appropriate. As would a good gcc cluestick about 
inlining and stack usage. The latter is unlikely to materialize, I guess.

		Linus
