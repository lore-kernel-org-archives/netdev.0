From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
Date: Fri, 27 Feb 2009 10:25:19 +0100
Message-ID: <49A7B17F.2020408@krogh.cc>
References: <491FEAD5.4090205@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: aowi@novozymes.com
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:59668 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756624AbZB0JZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 04:25:34 -0500
In-Reply-To: <491FEAD5.4090205@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, update, Rome wasn't build in one day.

A collegue of mine (on CC) found time to do a bisect of this on.

The offending commit seems to be:

bonding: refactor mii monitor

Refactor mii monitor.  As with the previous ARP monitor refactor,
the motivation for this is to handle locking rationally (in this case,
removing conditional locking) and generally clean up the code.

This patch breaks up the monolithic mii monitor into two phases:
an inspection phase, followed by an optional commit phase.  The commit phase
is the only portion that requires RTNL or makes changes to state, and is
only called when inspection finds something to change.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


A test with a fresh 2.6.29-rc6 revealed that the problem has been fixed 
subsequently.. but still exists in 2.6.27-newest.  (havent tested 
2.6.28-newest yet).

Any ideas of what the "fixing" commit is .. or should that also be 
bisected?

Dmesg of 2-6-29-rc6 working system here:
http://krogh.cc/~jesper/dmesg-2.6.29-rc6.txt .. shows that when bonding 
is initialized it doesnt have link up on any of the interfaces.


git bisect log

# bad: [adee14b2e1557d0a8559f29681732d05a89dfc35] Linux 2.6.27-rc6
# good: [63e0e67b17dc233f93f709610971bbfadc97f75e] Linux 2.6.26.8
git-bisect start 'v2.6.27-rc6' 'v2.6.26.8'
# good: [d536b1f86591fb081c7a56eab04e711eb4dab951] x86: fix crash due to 
missing debugctlmsr on AMD K6-3
git-bisect good d536b1f86591fb081c7a56eab04e711eb4dab951
# good: [d536b1f86591fb081c7a56eab04e711eb4dab951] x86: fix crash due to 
missing debugctlmsr on AMD K6-3
git-bisect good d536b1f86591fb081c7a56eab04e711eb4dab951
# good: [8d0b1c51eb8375f88c0886d2e9f71881e19d42a7] gbefb: cmap FIFO timeout
git-bisect good 8d0b1c51eb8375f88c0886d2e9f71881e19d42a7
# bad: [ab1666c1364a209e6141d7c14e47a42b5f00eca2] USB: quirk PLL power 
down mode
git-bisect bad ab1666c1364a209e6141d7c14e47a42b5f00eca2
# good: [37193fb4639fa94f91cbbab1e8aca596300e1d94] docbook: fix s390 
fatal error after header files moved
git-bisect good 37193fb4639fa94f91cbbab1e8aca596300e1d94
# bad: [f2d7499be1b1fe1cd8a5e6a01c1f44173894a241] Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
git-bisect bad f2d7499be1b1fe1cd8a5e6a01c1f44173894a241
# good: [b588e2bbd7b872c9cdf635fe0f04840534e72443] Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-watchdog
git-bisect good b588e2bbd7b872c9cdf635fe0f04840534e72443
# bad: [86b89eed9aca2a4a335b9c1bf7380f9183db431f] ath9k: Revamp wireless 
mode usage
git-bisect bad 86b89eed9aca2a4a335b9c1bf7380f9183db431f
# good: [9a5d3414202a21ed4b053657345ea0fd492d513a] 3c59x: use 
netdev_alloc_skb
git-bisect good 9a5d3414202a21ed4b053657345ea0fd492d513a
# bad: [3859069bc3358772b08bd91efe9edec39a746ea8] Merge branch 
'for-jeff' of 
git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6 into tmp
git-bisect bad 3859069bc3358772b08bd91efe9edec39a746ea8
# good: [52e8a6a2d8dc19002d1757870d16051157ce999c] WAN: Convert 
Zilog-based drivers to generic HDLC
git-bisect good 52e8a6a2d8dc19002d1757870d16051157ce999c
# bad: [0d7a3681232f545c6a59f77e60f7667673ef0e93] net/core: Allow 
certain receives on inactive slave.
git-bisect bad 0d7a3681232f545c6a59f77e60f7667673ef0e93
# bad: [f0c76d61779b153dbfb955db3f144c62d02173c2] bonding: refactor mii 
monitor
git-bisect bad f0c76d61779b153dbfb955db3f144c62d02173c2
# good: [c16d118537cadb21d186e35aebad90a13cd78846] [netdrvr] Drivers 
should not set IFF_* flag themselves
git-bisect good c16d118537cadb21d186e35aebad90a13cd78846

