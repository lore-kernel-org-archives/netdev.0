From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 18:00:25 +0100
Message-ID: <20070320170025.GA14329@elte.hu>
References: <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60395 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965346AbXCTRBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 13:01:45 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> I have this dim memory that ARM has done it that way for a long time 
> because it's so expensive to do a "real" cli/sti.
> 
> And I think -rt does it for other reasons. It's just more flexible.

-rt doesnt wrap cli/sti anymore: spin_lock_irq*() doesnt disable irq 
flags on -rt, thus the amount of real irqs-off sections is very small 
and reviewable.

But nevertheless an incarnation of the code survived and is upstream 
already, in the form of TRACE_IRQFLAGS lockdep code ;) This implements a 
soft hardirq flag _today_: all that would be needed is for Xen to define 
raw_local_irq_disable() as a NOP, and to use the 
current->hardirqs_enabled as 'soft IRQ-off flag'.

Note that ->hardirqs_enabled is self-maintained, i.e. it's not just a 
stupid shadow of the hardirq flag, it's an independently maintained flag 
that does not rely on the existence of the hard flag.

[ this code even has its own debugging code, so out-of-sync-flags,
  double-off and double-on is detected and complained about. So all the 
  hard stuff has already been done as part of lockdep, and it's even 
  long-term maintainable because under a native lockdep kernel we check 
  the soft flag against the hard flag. ]

so i think a soft cli/sti flag support should be merged/unified with the 
trace_hardirqs_on()/trace_hardirqs_off() code.

	Ingo
