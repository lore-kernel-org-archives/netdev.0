From: David Miller <davem@davemloft.net>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 13 Apr 2007 22:29:41 -0700 (PDT)
Message-ID: <20070413.222941.123978678.davem@davemloft.net>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
	<Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bunk@stusta.de, greg@kroah.com,
	davej@redhat.com, akpm@linux-foundation.org, jgarzik@pobox.com,
	mingo@elte.hu
To: torvalds@linux-foundation.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 13 Apr 2007 18:34:23 -0700 (PDT)

Let's see how related these two might actually be.

> On Sat, 14 Apr 2007, Adrian Bunk wrote:
> > 
> > Subject    : laptops with e1000: lockups
> > References : https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603
> > Submitter  : Dave Jones <davej@redhat.com>
> > Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Status     : problem is being debugged

In this case the entire machine hangs and sometimes spits out an
NMI message.

The user confirms that using another network interface (albeit
wireless) works properly.

The Intel folks can reproduce this one in-house and will look more
deeply into it on Monday.

> > Subject    : forcedeth: interface hangs under load
> > References : http://lkml.org/lkml/2007/4/3/39
> > Submitter  : Ingo Molnar <mingo@elte.hu>
> > Handled-By : Ingo Molnar <mingo@elte.hu>
> >              Ayaz Abdulla <aabdulla@nvidia.com>
> > Status     : problem is being debugged

In Ingo's case here the interface stops working entirely, but his
system is still otherwise operational.

I looked at the interrupt handler for this driver and it is absolutely
awful especially in the NAPI enabled case.

It tries to handle TX done interrupts and other status events in the
HW irq handler, and the RX packet processing via NAPI ->poll().

Time has shown that this is a faulty way to use NAPI and that all
events types should be done in the NAPI ->poll() handler, not just
RX packet processing.

The way the loop is coded now it will keep prodding at the interrupt
status register in the HW irq handler loop even after the RX packet
processing has been deferred to NAPI ->poll().  It seems likely that
since the RX packets aren't being processed there, the RX irq event
status should keep showing as set as new packets arrive.

Really, the interrupt status should be checked exactly once, all the
work deferred to NAPI's ->poll() and then the HW interrupt handler
should return immediately.  This is what e1000 and tg3 do, and it is
therefore the most well tested manner in which to use NAPI in a
network driver.

Anything else is racey and error prone.

This would also eliminate the max_interrupt_work hack, it's a side
effect of the way the interrupt handler is implemented in this
driver.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
