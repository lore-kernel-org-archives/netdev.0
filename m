From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [Regression in 2.6.29] forcedeth doesn't work after resume from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Fri, 27 Mar 2009 21:09:20 +0100
Message-ID: <200903272109.21259.rjw@sisk.pl>
References: <200903261920.32173.tvrtko@ursulin.net> <200903270801.46712.tvrtko@ursulin.net> <200903271255.36429.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, linux-pm@lists.linux-foundation.org,
	kernel list <linux-kernel@vger.kernel.org>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org,
	Ed Swierk <eswierk@arastra.com>,
	Arthur Jones <ajones@riverbed.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:57644 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761804AbZC0UJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 16:09:27 -0400
In-Reply-To: <200903271255.36429.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 March 2009, Rafael J. Wysocki wrote:
> On Friday 27 March 2009, Tvrtko A. Ursulin wrote:
> > On Thursday 26 March 2009 23:08:59 Rafael J. Wysocki wrote:
> > > On Friday 27 March 2009, Tvrtko A. Ursulin wrote:
> > > > On Thursday 26 March 2009 22:38:55 Pavel Machek wrote:
> > > > > On Thu 2009-03-26 22:01:03, Tvrtko A. Ursulin wrote:
> > > > > > On Thursday 26 March 2009 21:35:29 Rafael J. Wysocki wrote:
> > > > > > > On Thursday 26 March 2009, Pavel Machek wrote:
> > > > > > > > On Thu 2009-03-26 20:55:23, Tvrtko A. Ursulin wrote:
> > > > > > > > > On Thursday 26 March 2009 20:18:40 Pavel Machek wrote:
> > > > > > > > > > On Thu 2009-03-26 19:20:32, Tvrtko A. Ursulin wrote:
> > > > > > > > > > > Hi guys,
> > > > > > > > > > > I have been running custom compiled 2.6.28.7 in OpenSUSE
> > > > > > > > > > > 11.1 and using hiberation/resume daily as configured by the
> > > > > > > > > > > distro. Yesterday I upgraded to 2.6.29 (make oldconfig from
> > > > > > > > > > > 2.6.28.7, attached) and after resume networking (at least)
> > > > > > > > > > > does not work. Reboot at this point takes very long because
> > > > > > > > > > > of timeouts on CIFS and whatelse.
> > > > > > > > > > >
> > > > > > > > > > > Below is how /var/log/messagess looks for one cycle
> > > > > > > > > > > (hibernate-resume-reboot) and I am also attaching kernel
> > > > > > > > > > > config and /var/log/pm-suspend.log.
> > > > > > > > > > >
> > > > > > > > > > > You will probably notice evil nvidia.ko in there but don't
> > > > > > > > > > > panic, it all happens without it as well. Tested from
> > > > > > > > > > > runlevel 3 and by running pm-hibernate. After resume from
> > > > > > > > > > > that NIC LEDs were off. I tried /etc/init.d/network restart
> > > > > > > > > > > but that hung so I ^C and tried rmmod forcedeth && modprobe
> > > > > > > > > > > forcedeth && ifup eth0 and after some time network went
> > > > > > > > > > > live again. Haven't had time to test further though, so
> > > > > > > > > > > this is all pretty rough.
> > > > > > > > > >
> > > > > > > > > > Ok, can you try to rmmod forcedeth before hibernation, then
> > > > > > > > > > insmod it after resume?
> > > > > > > > >
> > > > > > > > > Sure, after insmod and /etc/init.d/network start following
> > > > > > > > > resume network was fine. Guess I could kludge that sequence
> > > > > > > > > into pm scripts somehow but would rather avoid that since it
> > > > > > > > > slows down the cycle and would make scripts non-stock.
> > > > > > > >
> > > > > > > > Ok, I guess you need to talk to forcedeth maintainers then...
> > > > > > > > sounds like a forcedeth problem to me.
> > > > > > >
> > > > > > > I have a box with forcedeth somewhere here, I should be able to
> > > > > > > check that in the next few days.
> > > > > >
> > > > > > Not a lot activity in forcedeth.c from 2.6.28 to 2.6.29 so I will CC
> > > > > > two guys who commited changes in that period. Ayaz, Tobias, forcedeth
> > > > > > does not seem to come up after hibernation well for me. Actual
> > > > > > hardware is:
> > > > > >
> > > > > > 00:0f.0 Ethernet controller: nVidia Corporation MCP73 Ethernet (rev
> > > > > > a2)
> > > > > >
> > > > > > Anything more I can do just shout!
> > > > >
> > > > > Actually yes. Testing forcedeth from 2.6.28 in 2.6.29 would be nice
> > > > > way to prove problem is indeed in that module.
> > > >
> > > > Good idea, I had to massage it a bit due to some API changes, but the end
> > > > result is a correct resume which proves that the problem really is in
> > > > forcedeth.
> > >
> > > Well, since you can easily check what commits changed forcedeth between
> > > 2.6.28 and 2.6.29, you can find the one that introduced the problem for
> > > you.

I was able to reproduce the problem and identify the commit that broke the
resume of forcedeth, which turned out to be:

commit cb52deba12f27af90a46d2f8667a64888118a888
Author: Ed Swierk <eswierk@arastra.com>
Date:   Mon Dec 1 12:24:43 2008 +0000

    forcedeth: power down phy when interface is down

    Signed-off-by: Ed Swierk <eswierk@arastra.com>
    Tested-by: Arthur Jones <ajones@riverbed.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Since I have no slightest idea of what this commit is supposed to achieve,
I can only ask for reverting it.  It reverts cleanly, BTW.

Thanks,
Rafael
