From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 10:51:52 -0700
Message-ID: <1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34318 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbbDNRvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 13:51:54 -0400
Received: by iedfl3 with SMTP id fl3so24108882ied.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 10:51:53 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 16:44 +0000, Yuval Mintz wrote:
> >> Commit 9a2620c877454 ("bnx2x: prevent WARN during driver unload") switched
> >> the napi/busy_lock locking mechanism from spin_lock() into spin_lock_bh(),
> >> breaking inter-operability with netconsole, as netpoll disables interrupts
> >> prior to calling our napi mechanism.
> >>
> >> This switches the driver into using atomic assignments instead of the spinlock
> >> mechanisms previously employed.
> 
> > This fix is prone to starvation of softirq handler.
> > Since you use 2 bits, I believe you could set one bit unconditionally to
> > make sure the bnx2x_low_latency_recv() will yield to softirq handler.
> 
> Care to elaborate a bit? About the possibly starvation?
> 
> > Please CC me and Willem on busypoll stuff, thanks !

I believe the original busypoll yield concern was forgotten or reversed.

If you have many busypoll users, they might get the 'lock', and the poor
cpu that received the hardware interrupt and raised RX softirq for this
RX queue will spin forever [1]

busypoll users should backoff and not attempt to grab a lock (especially
if this lock is not a ticket lock anymore) if the softirq handler is
desperately trying to make progress.

[1]
sofirq handler

   while (1) {
       if (!bnx2x_fp_lock_napi())
		continue;
        }
   }

I can provide an alternative patch if you like.
