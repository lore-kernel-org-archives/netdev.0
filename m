From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Wed, 1 Oct 2008 22:05:09 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi> <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1354937636-1222891510=:5549"
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:45838 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbYJAUFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 16:05:35 -0400
In-Reply-To: <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1354937636-1222891510=:5549
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 1 Oct 2008, Dâniel Fraga wrote:
> On Wed, 1 Oct 2008 15:52:19 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Hi Daniel,
> > 
> > I forward part of the details to public knowledge (and for Thomas mainly).
> > 
> > I also put the epoll & accept only log available for him at
> > http://www.cs.helsinki.fi/u/ijjarvin/tcp/epoll_accept.txt
> > as it won't contain encryption key, etc. related bits.
> > 
> > Can you Daniel please confirm what exactly was the status about the effect 
> > of disabling ntpd?
> 
> 	Hi Ilpo, ok, thanks. Following suggestion of kernel developers
> from bugzilla, I tested with 2.6.27-rc7 and 2.6.27-rc8. The problem
> happens less frequently, but still happens.
> 
> 	Disabling ntpd helps to not "trigger" the problem often. With
> ntpd enabled the problem happens at least once a day. Without ntpd, it
> doesn't happen anymore or seldom happens. Disabling high resolution
> timers helps too.
> 
> 	I'll follow your previous suggestions, but I didn't have time
> yet. If anyone needs more info, just ask. Thanks.
> 
> 	Ps: just to clarify for Thomas. The problem has started in
> 2.6.25 kernel and remain in 2.6.26 until now (2.6.27-rc8). Something
> (probably related to timers) changed in 2.6.25 which causes this,
> although the effect is seem on network stalling.

Lots of things related to timers changed over the last kernel
versions, but the big changes were 2.6.21 for 32bit and 2.6.24 for
64bit, where the high resolution timer were enabled. Since then we
have only bigfixes and improvements in the timer related code. 2.6.25
has no fundamental changes in the timer code at all.

I think your observation vs. ntpd and hrtimer is just a red
herring. It influences the visibility of the problem by shifting
timings around, but it does not pinpoint them as the root cause.

I might be wrong as usual, but in that case I insist on "in dubio pro
reo". :)

I looked at the strace output and the point where you said it stalled.
We can see the epoll_wait() calls of all worker threads not come back
for 30 seconds. At the point where you said you poked with nmap at the
system they all come back out of the blue with exactly 1 event set each.

I really can not connect the timer system to that behaviour at all,
except there is some timer interaction deep inside of the networking
code causing this, but I have no clue where I should start digging.

One possibility to get deeper insight into this problem is to use the
function tracer and stop it once we notice the wreckage. 
listenoverflow should be a good point to stop it.

Thanks,

	tglx


--8323328-1354937636-1222891510=:5549--
