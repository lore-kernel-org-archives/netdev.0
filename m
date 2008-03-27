From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 13:30:14 +0100
Message-ID: <1206621014.8514.563.camel@twins>
References: <bug-10326-10286@http.bugzilla.kernel.org/>
	 <20080325134320.21525479.akpm@linux-foundation.org>
	 <47EAD8A5.3070806@gmail.com>
	 <20080326171403.ad186037.akpm@linux-foundation.org>
	 <20080327085542.GA2778@ami.dom.local>
	 <20080327021812.601776b8.akpm@linux-foundation.org>
	 <1206615379.8514.502.camel@twins>  <20080327122255.GC2845@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758505AbYC0Mal@vger.kernel.org>
In-Reply-To: <20080327122255.GC2845@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-03-27 at 13:22 +0100, Jarek Poplawski wrote:
> On Thu, Mar 27, 2008 at 11:56:19AM +0100, Peter Zijlstra wrote:
> > On Thu, 2008-03-27 at 02:18 -0700, Andrew Morton wrote:
> ....
> > > I bet the net code is wrong and we missed it ;)
> 
> It looks like you are natural born winner! Congratulations!
> 
> > How about this:
> > 
> > <irqs disabled>
> > 
> >   netpoll_poll()
> >     poll_napi()
> >       spin_trylock(&napi->poll_lock)
> >       poll_one_napi()
> >         napi->poll() := sky2_poll()
> >           napi_complete()
> >             local_irq_disable()
> >             local_irq_enable() <--- *BUG*
> 
> Yes! I missed it's unconditional here... Great catch!
> 
> On the other hand, still a question why lockdep doesn't see this
> every day?

My guess is that it is a race between polling the device and irq pushing
the packet. That is, normally the IRQ handler wins and netpoll doesn't
have anything to do and it doesn't traverse this code path.

(although I must admit to being a little out of my depth here)
