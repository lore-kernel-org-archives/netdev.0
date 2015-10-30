From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 30 Oct 2015 22:33:17 +0000
Message-ID: <20151030223317.GK22011@ZenIV.linux.org.uk>
References: <20151028223330.GD22011@ZenIV.linux.org.uk>
 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151029001532.GE22011@ZenIV.linux.org.uk>
 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151029041611.GF22011@ZenIV.linux.org.uk>
 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57591 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbJ3WdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 18:33:21 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 02:50:46PM -0700, Linus Torvalds wrote:

> Anyway. This is a pretty simple patch, and I actually think that we
> could just get rid of the "next_fd" logic entirely with this. That
> would make this *patch* be more complicated, but it would make the
> resulting *code* be simpler.

Dropping next_fd would screw you in case of strictly sequential allocations...

Your point re power-of-two allocations is well-taken, but then I'm not
sure that kzalloc() is good enough here.  Look: you have a bit for every
64 descriptors, i.e. byte per 512.  On 10M case Eric had been talking
about that'll yield 32Kb worth of your secondary bitmap.  It's right on
the edge of the range where vmalloc() becomes attractive; for something
bigger it gets even worse...

Currently we go for vmalloc (on bitmaps) once we are past 128K descriptors
(two bitmaps packed together => 256Kbit = 32Kb).  kmalloc() is very
sensitive to size being a power of two, but IIRC vmalloc() isn't...
