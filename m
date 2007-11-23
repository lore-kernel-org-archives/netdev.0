From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 11:07:56 -0600
Message-ID: <20071123170756.GV19691@waste.org>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:39581 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbXKWRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 12:09:08 -0500
Content-Disposition: inline
In-Reply-To: <20071123105518.GA22062@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 01:55:19PM +0300, Evgeniy Polyakov wrote:
> On Fri, Nov 23, 2007 at 12:21:57AM -0800, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > [2059664.615816] __iptables__: init4 IN=ppp0 OUT=ppp0 WARNING: at kernel/softirq.c:139 local_bh_enable()
> > > [2059664.620535]  [<80120364>] local_bh_enable+0x3c/0x97
> 
> > > [2059664.620657]  [<8011c205>] __call_console_drivers+0x61/0x6d
> > > [2059664.620669]  [<8011c3fc>] release_console_sem+0x164/0x1bf
> > > [2059664.620679]  [<8011c81f>] vprintk+0x27a/0x2ff
>  
> > If that trace is to be beieved we're doing nefilter stuff on packets which
> > were sent across netconsole.
> > 
> > This probably isn't anything the netfilter guys have thought about.  And
> > probably we don't want them to.  Is there some simple way in which we can
> > exempt netconsole from netfilter processing?
> 
> This is not about netfilter, but about freeing skb in interrupt context, 
> which is not allowed, and in interrupt skbs are queued to be freed in softirq,
> but netcnsole wants to flush softirq freeing queue. That is a question: why?

My memory here is hazy, but I think this exists to rescue netconsole
in low-memory situations. This bit originated with Ingo, so maybe he
can recall.

Netpoll can process an arbitrary number of skbs inside a single
interrupt. Think sysrq-t at one packet per line or kgdboe where the
entire trace session can happen inside one very long interrupt.

Perhaps we can refine this to mark netpoll's skbs (perhaps with
->destructor?) and delete only skbs we own. As these are never passed
through any of the other route/xfrm/filter code, they should be safe
to delete even in irq context, yes?

> Removing zap_completion_queue() from find_skb() will fix the warning,
> but I'm not sure this is a correct fix. I've added Matt to the Cc list.

Care to try the sysrq-t or OOM message tests?

-- 
Mathematics is the supreme nostalgia of our time.
