From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Suspend/resume - slow resume
Date: Sun, 17 Apr 2011 09:42:57 -0700
Message-ID: <BANLkTi=tPc6NmUuTYqbVZduNRNbE=-c34Q@mail.gmail.com>
References: <Pine.SOC.4.64.1104150931390.1320@er3.rutgers.edu>
 <BANLkTinO+HFq+Mgg1aUz9V==zYs7qSBtDw@mail.gmail.com> <Pine.SOC.4.64.1104151122330.1320@er3.rutgers.edu>
 <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com> <20110417101731.GA17986@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ciprian Docan <docan@eden.rutgers.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael, J. Wysocki" <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55385 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392Ab1DQQnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 12:43:19 -0400
In-Reply-To: <20110417101731.GA17986@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 17, 2011 at 3:17 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>
> One can try the patch below. It is completely untested yet.

Looks _fairly_ sane to me.  The "request firmware in open, release
firmware in close" approach would seem to be a fairly obvious one.

HOWEVER.

I think it's broken in two ways:

 - it causes too much re-loading for no good reason. I'm looking at
rtl8169_reinit_task() in particular, and if I read that correctly,
then if there are any problems, that crazy function will end up
loading and unloading the firmware EVERY FOUR TIMER TICKS!

   That's just totally broken.

   But I'd also worry about some init scripts in particular, maybe
that whole "open to test something, close immediately" is common. I
don't know.

 - it seems to leak the open function fails after requesting the
firmware - nothing will ever close it, and if you unload the module
the firmware will never be released as far as I can tell.

I might be missing some failure path (maybe the network device open
will call close even if the open failed), but it looks real.

So I think your patch _approaches_ being sane, but no, it's not working as-is.

I really think that this kind of "ad-hoc random firmware loading"
stuff should go away. The device layer (or maybe the network layer)
should have some clear and unambiguous rules. Exactly so that drivers
don't make these kinds of mistakes.

My gut feel for what the rules should be is roughly (but please take
this as a starting point for discussion rather than some final thing):

 - try to load the firmware at each time the user tries to activate
the device. IOW, not like this, where the rtl8169_open() function is
called from many different contexts, only one of them being the
"network layer tried to open the device".

   I do think we need to do it potentially multiple times: the main
issue being something like this:

      ifconfig eth0 up
      ** oops, that failed because we didn't have the firmware files
installed **
      ... install firmware files, the 'dmesg' gave good error messages
that the user could use to know what was going on ..
      ifconfig eth0 up
      ** this needs to trigger another firmware load attempt **

   In other words, doing firmware load at module load time - or at
device scan time - is fundamentally broken for a network driver.

 - unload not on close, but on device unregister (iow not when you do
"ifconfig eth0 down", but when the "eth0" device really goes away)

But as mentioned, the above is (a) just my gut feel - please discuss -
and (b) I really think that leaving this to the network driver has
been shown to continually result in the drivers doing the firmware
load/unload in all the wrong places.

So I do wonder whether we could add a "ndo_firmware_load()" and
"ndo_firmware_unload()" callback to the network device operations, and
have the network layer make the above rules. A network driver
obviously _could_ do its firmware load from other places instead, but
such a network driver would basically be "obviously broken".

Comments?

(That said, I think that Francois' patch could be made acceptable
fairly trivially:

 - avoiding the load/unload from rtl8169_reinit_task() and that
horrible "every four timer ticks" issue. That just seems crazy. Maybe
by just having an internal open helper function that does everything
but the firmware load)

 - adding a rtl_release_firmware on open failure so that you don't leak stuff

but I do think that this whole "firmware load in random places" has
been such a common bug that I think we should have some real rules
about it)

Hmm?

                                Linus
