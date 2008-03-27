From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 11:56:19 +0100
Message-ID: <1206615379.8514.502.camel@twins>
References: <bug-10326-10286@http.bugzilla.kernel.org/>
	 <20080325134320.21525479.akpm@linux-foundation.org>
	 <47EAD8A5.3070806@gmail.com>
	 <20080326171403.ad186037.akpm@linux-foundation.org>
	 <20080327085542.GA2778@ami.dom.local>
	 <20080327021812.601776b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:64011 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754633AbYC0K4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 06:56:31 -0400
In-Reply-To: <20080327021812.601776b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-27 at 02:18 -0700, Andrew Morton wrote:
> On Thu, 27 Mar 2008 09:55:42 +0100 Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > On Wed, Mar 26, 2008 at 05:14:03PM -0700, Andrew Morton wrote:
> > ...
> > > > >> http://bugzilla.kernel.org/show_bug.cgi?id=10326
> > ...
> > > No, it's not an irq_disable() thing, directly.
> > > 
> > > What lockdep is saying is that sky2_poll() is taking napi->poll_lock for
> > > writing with softirqs enabled, but net_rx_action() takes the same lock from
> > > within softirq context.
> > > 
> > > If sky2_poll() always takes napi->poll_lock under local_irq_disable() then
> > > that would be a lockdep bug.
> > 
> > sky2_poll() doesn't take napi->poll_lock; this lock is taken by
> > netpoll_poll() before calling sky2_poll(). And before this hardirqs
> > are disabled in write_msg(). So, theoretically lockdep could be right
> > if sky2_poll() would enable irqs after this. (If it were done in
> > netpoll - lockdep should warn before or after sky2_poll() call.)
> > But I really can't see any such possibility in sky2_poll().
> 
> I can't spot it from a five-minute read either.  gcc's autoinlining really
> makes this sort of thing much harder than it used to be :(
> 
> Anyway, the accusation is that lockdep is busted, in that it doesn't realise that
> local_irq_disable() blocks softirqs.
> 
> I bet the net code is wrong and we missed it ;)

How about this:

<irqs disabled>

  netpoll_poll()
    poll_napi()
      spin_trylock(&napi->poll_lock)
      poll_one_napi()
        napi->poll() := sky2_poll()
          napi_complete()
            local_irq_disable()
            local_irq_enable() <--- *BUG*

  <irq>
    irq_exit()
      do_softirq()
        net_rx_action()
          spin_lock(&napi->poll_lock) <--- Deadlock!

Because we still hold the lock....

