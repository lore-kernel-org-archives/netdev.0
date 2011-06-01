From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: Section conflict compile failures in net
Date: Wed, 01 Jun 2011 10:42:50 +0900
Message-ID: <1306892570.11897.35.camel@mulgrave.site>
References: <1306445993.4048.58.camel@mulgrave.site>
	 <20110531.154531.493226762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:49949 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933048Ab1FABpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 21:45:16 -0400
In-Reply-To: <20110531.154531.493226762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-31 at 15:45 -0700, David Miller wrote:
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
> Date: Thu, 26 May 2011 16:39:53 -0500
> 
> BTW, linux-netdev doesn't exist, it's just plain netdev.

Um, yes ... I thought it was netdev, then I checked MARC and it had
linux-netdev.  I'll remember for next time (well, at least for the next
six months).

> > Simply reverting 
> > 
> > commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4
> > Author: Micha<C5><82> Miros<C5><82>aw <mirq-linux@rere.qmqm.pl>
> > Date:   Mon Apr 18 13:31:20 2011 +0000
> > 
> >     net: fix section mismatches
> >     
> > Fixes the problem.
> > 
> > If I look at the first problem in hp100.c, the addition of
> > __devinitconst to the device tables is fine, but there's no
> > corresponding sectional tag on their use, so when compiled as a module,
> > things like hp100_eisa_driver is now in the main data section but refers
> > to something in the init data section ... I assume all the others are
> > the same type of problem.
> 
> Yeah I think the device ID table __devinitconst bits have to be
> reverted.
> 
> I'll apply something like the following:
> 
> net: Revert adding __devinitconst to driver ID tables.
> 
> If the table is hooked up to foo_driver->id_table we can't
> mark it __devinitconst otherwise we end up with section
> mismatches.
> 
> Reported-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

That fixes some but not all; the pci tables still cause a section
conflict:

drivers/net/hp100.c:211: error: hp100_pci_tbl causes a section type conflict
make[2]: *** [drivers/net/hp100.o] Error 1


It's really, as has been said, a compiler problem: the compiler is
confused about the read only sections.  However, 4.2 is a pretty common
compiler (especially for non-x86), so if the compiler can't do the read
only section tracking, just not using the __devinitconst designation
globally seems to be the best thing, just change it to __devinitdata
instead.

James


