From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Bugme-new] [Bug 36602] New: Bridge fails to work normally
 without net.ipv4.ip_forward=1
Date: Fri, 03 Jun 2011 23:37:46 +0100
Message-ID: <1307140667.22348.120.camel@localhost>
References: <bug-36602-10286@https.bugzilla.kernel.org/>
	 <20110603123632.139f83ca.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: igor@novg.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30169 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab1FCWhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 18:37:51 -0400
In-Reply-To: <20110603123632.139f83ca.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-03 at 12:36 -0700, Andrew Morton wrote:
[...]
> > At the bridge, on each interface i've created a vlan, and then bridged them:
> > # vconfig add eth0 102
> > # vconfig add eth1 102
> > # brctl addbr br0
> > # brctl addif br0 eth0.102
> > # brctl addif br0 eth1.102
> > # ip link set br0 mtu 9000 up
> > ...etc...
> > 
> > At this point, the bridge seems to be working, i can ping between host1 &
> > host2, even with jumbo frames without fragmentation.
> > 
> > BUT when i am trying to use iperf & friends to measure raw tcp speed between
> > hosts 1/2, i'm getting something weird like 7-10 MEGABITS per second, or even
> > an iperf hang until ctrl+c.

This sounds like a symptom of doing LRO on a bridged device.  Normally
we turn off LRO for bridge members automatically, but we haven't been
doing that when the bridge members are VLAN devices.

> > If i attach an ip address to the bridge, and measure between hosts and the
> > bridge, it works flawlessly, rendering 9.8Gbit/s in both directions.
> > 
> > While trying to find a solution, when i ran out of options, i've set
> > net.ipv4.ip_forward to 1, and, SURPRISE, the bridge started to work like a
> > charm, at almost 10gig speed.
[...]

Right, that should force LRO off for all devices with IPv4 set up.

This should be fixed by:

commit f11970e383acd6f505f492f1bc07fb1a4d884829
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Tue May 24 08:31:09 2011 +0000

    net: make dev_disable_lro use physical device if passed a vlan dev (v2)

which is in 3.0-rc1.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

