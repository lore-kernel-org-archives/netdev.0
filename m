From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Fri, 7 Aug 2009 13:29:44 +0200
Message-ID: <200908071329.44437.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <20090806210002.75beb7c6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Fischer, Anna" <anna.fischer@hp.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:58125 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbZHGLbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 07:31:31 -0400
In-Reply-To: <20090806210002.75beb7c6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 August 2009, Stephen Hemminger wrote:
> So instead of adding more stuff to existing bridge code, why not
> have a new driver for just VEPA. You could
> do it with a simple version of macvlan type driver.

The current macvlan driver already does the downstream side of
VEPA and only needs a connection to KVM et al, either using
Or's qemu packet socket interface, or using the macvtap driver
I posted.

Now Anna's patch also addresses the upstream side of VEPA, by
making it possible for the bridge code to send frames back
in the bridge code that they were received from, if that port
is marked as a hairpin mode port.

Is your suggestion to do that part also with a macvlan type driver?
I've thought about this before, and I guess that would mean
basically the same as the macvlan driver, except hashing the
source MAC address instead of the destination MAC address for
inbound frames. That way you should be able to do something
like:

            Host A                             Host B

      /- nalvcam0 -\                   /- macvlan0 - 192.168.1.1
br0 -|              |- ethA === ethB -|
      \- nalvcam1 -/                   \- macvlan1 - 192.168.1.2
  
Now assuming that macvlan0 and macvlan1 are in different
network namespaces or belong to different KVM guests, these
guests would be able to communicate with each other through
the bridge on host A, which can set the policy (using ebtables)
for this communication and get interface statistics on its
nalvcam interfaces. Also, instead of having the br0, Host A could
assign an IP addresses to the two nalvcam interfaces that host
B has, and use IP forwarding between the guests of host B.

	Arnd <><
