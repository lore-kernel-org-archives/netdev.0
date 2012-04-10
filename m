From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] pppoatm: Fix excessive queue bloat
Date: Tue, 10 Apr 2012 10:26:12 -0400
Message-ID: <20120410102612.368b1a4f@thirdoffive.cmf.nrl.navy.mil>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	<20120322.230331.1623101647193498167.davem@davemloft.net>
	<1332672230.32446.160.camel@shinybook.infradead.org>
	<20120325.173635.1909319488008466320.davem@davemloft.net>
	<1332875447.2058.48.camel@shinybook.infradead.org>
	<1332878138.3547.41.camel@edumazet-glaptop>
	<1332880522.2058.67.camel@shinybook.infradead.org>
	<1333914837.31812.57.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	paulus@samba.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:35145 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab2DJO2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:28:17 -0400
In-Reply-To: <1333914837.31812.57.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 08 Apr 2012 21:53:57 +0200
David Woodhouse <dwmw2@infradead.org> wrote:

> Seriously, this gets *much* easier if we just ditch the checks against
> sk_sndbuf. We just wake up whenever decrementing ->inflight from zero.
> Can I?

i dont know.  on a 'low' speed connection like queuing 2 packets might
be enough to keep something busy but imagine an interace like oc3 or
oc12.  i dont know anything running pppoatm on such an interface but it
seems like just dropping sk_sndbuf isnt right either.

sk_sndbuf is per vcc and that isnt right either since the transmit
limit is actually the atm device's transmit queue depth.  in your case,
since you are only using a single vcc, this problem does somewhat map
to a sk_sndbuf.  but sk_sndbuf counts bytes and not entries in a queue
which is typically the limit imposed by the hardware.

it makes me wonder if we dont need to add another stub to the atm
driver interface to check if the device can transmit instead of 'can we
queue on the vcc'.  atm_may_send() then would be changed to check to see
if a transmit queue entry is available and there is sk_sndbuf queue
space.  if a driver doesnt have this stub to check for queue space,
atm_may_send() can just assume there is a queue entry and we get the
previous default behavior.  what is the "queue depth" of your atm
device's transmit queue?
 
yes, the vcc->sk_sndbuf should be MAX(vcc->sk_sndbuf, pppoatm->MTU) but
since people dont often change the sk_sndbuf i guess no one has run
into this issue.   pppoatm (et al) should enforce this limit though.
