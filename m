From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] softirq: Use local_irq_save() in local_bh_enable()
Date: Tue, 18 Nov 2008 07:38:19 +0000
Message-ID: <20081118073819.GA4440@ff.dom.local>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu> <20081117133548.GC6345@ff.dom.local> <20081117161617.GF12081@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:30742 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbYKRHiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 02:38:25 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2376025fgg.17
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 23:38:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081117161617.GF12081@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2008 at 05:16:17PM +0100, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > This report: http://marc.info/?l=linux-netdev&m=122599341430090&w=2 
> > shows local_bh_enable() is used in the wrong context (irqs 
> > disabled). It happens when a usual network receive path is called by 
> > netconsole, which simply turns off irqs around this all. Probably 
> > this is wrong, but it worked like this long time, and it's not 
> > trivial to fix this.
> > 
> > Anyway, a commit 0f476b6d91a1395bda6464e653ce66ea9bea7167 "softirq: 
> > remove irqs_disabled warning from local_bh_enable" can break things 
> > after changing from local_irq_save() to local_irq_disable(). Before 
> > this commit there was only a warning, now a lockup is possible, so 
> > it could be treated as a regression. This patch reverts the change 
> > in irqs.
> 
> hm, but calling local_bh_enable() with hardirqs off is a bug. It might 
> be a long-standing bug, but it can cause lockups even with that change 
> reverted: when we process softirqs in local_bh_enable().

I think it's what they call a regression: this is a long-standing bug,
and this commit doesn't fix this, but can cause additional lockups.

> So why not 
> fix the bug instead?

It's not about instead: this bug could be fixed as well (if somebody
knows how to do it "properly" without hacks like:
	if (!in_irq())
		local_bh_disable();
etc.; but, I guess, the network code has more such bh disabling).

Jarek P.
