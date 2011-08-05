From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Fri, 5 Aug 2011 16:08:15 +0200
Message-ID: <20110805140047.GA19758@colin.search.kasperd.net>
References: <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com> <20110728114305.GA24549@colin.search.kasperd.net> <20110728115936.GC24549@colin.search.kasperd.net> <20110728122328.GA11424@electric-eye.fr.zoreil.com> <20110728124548.GA24762@colin.search.kasperd.net> <20110728125437.GA24876@colin.search.kasperd.net> <20110728144719.GA11465@electric-eye.fr.zoreil.com> <20110728210112.GA25953@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:29426 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752917Ab1HEOIV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 10:08:21 -0400
Content-Disposition: inline
In-Reply-To: <20110728210112.GA25953@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did a bit more of experiments. I took the unmodified
2.6.32.43 kernel and added printk statements to see when
it entered the interrupt handler and when it left it.

That way I was able to confirm that the system locked
up inside the interrupt handler.

Next I added printk statements to see how many times the
loop in the interrupt handler was run. It seemed that
when it locked up inside the handler it would run the
loop just two times and then lock up before leaving the
handler.

I added more printk statements to see which branches were
taken inside the loop. Unfortunately those printk
statements changed the timing enough that the crashes
were no longer as reproducable.

I saw a pattern repeating. It would do the stop queue
thing, then leave the handler and while not inside this
interrupt handler there would be a message about the
interface coming up again. Seems like it was doing stop
queue calls much more frequently than it should be.

After a few attempts I managed to get it to lock up again
with all the printk statements in place. What I found was
that in the beginning of the loop status was 0x85. It
would then call the napi event code. At the end of the
first itteration of the loop status was 0.

At that point it did not itterate through the loop again
and it did not leave the interrupt handler either. I'll
power cycle the machine and take a closer look on the
source to see what could possible be happening at that
point.

I also did a bit of testing with the patches that causes
it to drop the network instead of crashing. On those I
am able to bring up the second interface and get data off
the machine for debugging, so if there is any debug info
you think would be useful in those cases, let me know.

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
