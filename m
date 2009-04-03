From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [Regression in 2.6.29] forcedeth doesn't work after resume
 from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Fri, 03 Apr 2009 10:41:12 -0700
Message-ID: <1238780473.19305.3.camel@localhost.localdomain>
References: <200903261920.32173.tvrtko@ursulin.net>
	 <200903270801.46712.tvrtko@ursulin.net> <200903271255.36429.rjw@sisk.pl>
	 <200903272109.21259.rjw@sisk.pl>
	 <9ae48b020904030824o1f94831asb60f979b3e489a8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>,
	Pavel Machek <pavel@ucw.cz>,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	netdev <netdev@vger.kernel.org>,
	Arthur Jones <ajones@riverbed.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:28614 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932760AbZDCRlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 13:41:25 -0400
In-Reply-To: <9ae48b020904030824o1f94831asb60f979b3e489a8b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-04-03 at 08:24 -0700, Ed Swierk wrote:
> On Fri, Mar 27, 2009 at 1:09 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > I was able to reproduce the problem and identify the commit that broke the
> > resume of forcedeth, which turned out to be:
> >
> > commit cb52deba12f27af90a46d2f8667a64888118a888
> > Author: Ed Swierk <eswierk@arastra.com>
> > Date:   Mon Dec 1 12:24:43 2008 +0000
> >
> >    forcedeth: power down phy when interface is down
> >
> >    Signed-off-by: Ed Swierk <eswierk@arastra.com>
> >    Tested-by: Arthur Jones <ajones@riverbed.com>
> >    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >    Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > Since I have no slightest idea of what this commit is supposed to achieve,
> > I can only ask for reverting it.  It reverts cleanly, BTW.
> 
> The change causes forcedeth to bring down the physical link when an
> interface goes down; leaving it up causes the switch at the other end
> to think the port is still active, with potentially random speed and
> duplex parameters.
> 
> It's possible that the forcedeth driver needs to reset autonegotiation
> after bringing it up the link again.
> 
> Can you please try this on a 2.6.29 kernel that's exhibiting the
> symptoms you describe, after resuming the machine from hibernation:
> 
>   ethtool -s eth1 autoneg off speed 100 duplex full
>   ethtool -s eth1 autoneg on
> 
> This should reset autonegotiation manually and bring the link. Let me
> know how it goes.

Also please try this patch; it fixes the problem on my test system (a
DFI board with an nVidia MCP55).

Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>
--
--- linux-2.6.29.x86_64/drivers/net/forcedeth.c.orig	2009-03-23 16:12:14.000000000 -0700
+++ linux-2.6.29.x86_64/drivers/net/forcedeth.c	2009-04-03 10:11:26.839614710 -0700
@@ -5995,6 +5995,9 @@
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
+	/* restore phy state, including autoneg */
+	phy_init(dev);
+
 	netif_device_attach(dev);
 	if (netif_running(dev)) {
 		rc = nv_open(dev);


