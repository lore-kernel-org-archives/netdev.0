From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Sat, 28 Mar 2009 10:29:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
 <20090328045056.GA2394@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1020361286-1238228998=:6696"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47850 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbZC1IaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 04:30:04 -0400
In-Reply-To: <20090328045056.GA2394@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1020361286-1238228998=:6696
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:

> On Sat, Mar 28, 2009 at 01:05:09AM +0200, Ilpo Järvinen wrote:
> > On Fri, 27 Mar 2009, Markus Trippelsdorf wrote:
> > 
> > > I'm running the latest git kernel (2.6.29-03321-gbe0ea69) and I've got
> > > this warning twice in the last few hours.:
> > 
> > What did you run previously?
> 
> 2.6.29

Ok, just wanted to confirm it wasn't some from 2.6.veryold transition, 
where veryold didn't even have tracking for that invariant.

> > > Mar 27 21:37:00 [kernel] ------------[ cut here ]------------
> > > Mar 27 21:37:00 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
> > 
> > This one may or may not be a new one... Starting from the point when the 
> > warning was added it has been seen and some of those miscounts got tracked 
> > down but there is still something remaining (and that has been the state 
> > for couple of version already). It seems to require some particularly hard 
> > to reproduce network behavior people usually hit once in a lifetime. 
> > However, those miscount alone should not cause crashes, stalled TCP at 
> > worst but even that is quite unlikely to happen if fackets_out was not 
> > counted right.
> 
> The only unusual thing in my setup is that I use two Internet providers
> at the same time:
> 
> # ip route show
> 192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.2
> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.2
> 127.0.0.0/8 via 127.0.0.1 dev lo
> default equalize
>         nexthop via 192.168.1.1  dev eth1 weight 10
>         nexthop via 192.168.0.1  dev eth0 weight 1

Right. But I meant even larger picture, ie., the whole path(s) with the 
remote hosts you're communicating with.

> > > The machine hangs afterwards.
> > 
> > Is it really related to the warning for sure? I find it hard to 
> > believe...
> 
> The machine is normally running stable for days. Switching back to 2.6.29
> solves the problem...

Sure, but does is hang right after printing that warning or much later on,
e.g., one minute is already a very long time for the crash to be related 
to that warning... Even 5 seconds is a long time but I'd immediately say 
it's not related then :-).

So you never saw this warning before within 2.6.29 or 2.6.28-26 timeframe?
Anyway, if it turns out that the warning is unrelated to the crash and at 
the same time seems that you can so easily reproduce the warning it is 
worth of tracking its cause down as well but lets track the crash down 
first and see what to do once it is solved.

> > We even fixed that miscount for you when the warning was printed out (and 
> > the miscount alone wouldn't be able to cause crash anyway). Obviously 
> > there could something that got broken but reading through all post 2.6.29 
> > tcp material doesn't reveal anything particularly suspicious or even 
> > tricky... Only one thing that is remotely related to the warning that gets 
> > printed out is d3d2ae454501a4dec360995649e1b002a2ad90c5 but even that has 
> > very strong foundation as it does not have any potential to introduce 
> > stale references, rest of the effects would be just stalled tcp connection 
> > at worst.
> > 
> > Please add some debugging things, at least lockdep (CONFIG_PROVE_LOCKING) 
> > and soft lockup detector (CONFIG_DETECT_SOFTLOCKUP) to find out if we can 
> > get some info about the actual place of hang, some other debug things 
> > might also end up being useful.
> 
> Ok, will try this later today and report back. (It takes ~1 hour to
> reproduce the problem with a big torrent download).

Thanks, there are plenty of other changes in the range in question 
already:

ijjarvin@pointhope:~/linux/mainline$ git-diff --stat v2.6.29..be0ea69 | 
tail -n 1
 2871 files changed, 216209 insertions(+), 131463 deletions(-)
ijjarvin@pointhope:~/linux/mainline$ 

...So the crash could well be because of something else. It's probably 
worth of tracking bug fixes by keeping up with mainline and if crashes 
vanish we know that somebody solved the (same) problem.

-- 
 i.
---696208474-1020361286-1238228998=:6696--
