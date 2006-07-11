From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 11 Jul 2006 11:11:27 +0200
Message-ID: <200607111111.28040.mb@bu3sch.de>
References: <200607110054.36520.mb@bu3sch.de> <20060710212536.5a223977.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jbenc@suse.cz, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40143
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750810AbWGKJJn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 05:09:43 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060710212536.5a223977.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 11 July 2006 06:25, you wrote:
> On Tue, 11 Jul 2006 00:54:33 +0200
> Michael Buesch <mb@bu3sch.de> wrote:
> 
> > Please apply this to wireless-dev.
> > Note that this is the second try to submit this patch.
> > The first try contained a little bug. I'm sorry for that.
> > If you already applied the first one, I can provide an incremental patch.
> > 
> > Note2 that this patch depends on the
> > [PATCH] cancel_rearming_delayed_work infinite loop fix
> > I just sent out to the lists and akpm.
> 
> Am still scratching my head over that.  I wouldn't really call it a "fix". 
> More an enhcancement to cover unanticipated (and arguably strange) usage.
> 
> It's odd to call cancel_rearming_delayed_work() against a rearming
> workqueue which isn't actually running.  It tends to indicate that the
> caller has lost track of what it's up to.

No, I don't think so.
Let's say we have the following scenario:
A wq reschedules itself x times after it was scheduled once from outside.
After these x times, it does not reschedule anymore. That's what happens
in d80211. And I don't see a solution to sync this, other than modifying
the function, because we may call it after the x reschedule times.
Or do you think we should really do a statemachine to workaround it?

I am not the first one to hit this (I call it) bug.
It is _very_ confusing to see this sync function blocking forever.
I saw several people complaining about it. Also on #kernelnewbies.

> But as a convenience thing I guess it's an OK thing to do.  I need to stare
> at the implementation for a bit longer - that stuff's tricky.

Actually, I think there's still a little race.
I will send a more complex fix for this, if you agree to change the function.
If you say "no, we don't fix this. Insert a statemachine or something in your
code instead", I can use the time for better things. :)

But I think the following is also broken in the old code:
A wq is not pending anymore, but just executing (before it reschedules itself).
I think that would also loop forever. I don't think that's what we want.
Because we can't really keep track of _this_.

-- 
Greetings Michael.
